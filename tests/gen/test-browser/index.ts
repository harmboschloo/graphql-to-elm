import { resolve } from "path";
import { execSync, spawn, ChildProcess } from "child_process";
import * as kill from "tree-kill";
import * as rimraf from "rimraf";
import { PhantomJS, WebPage } from "phantom";
import * as phantom from "phantom";
import { Test } from "tape";
import * as test from "tape";
import { Fixture, getFixtures } from "../fixtures";
import {
  Result,
  QueryResult,
  getGraphqlToElm,
  writeResult
} from "../../../src/gen/graphqlToElm";
import { Options } from "../../../src/gen/options";
import { getSchemaString } from "../../../src/gen/schema";
import { ElmIntel } from "../../../src/gen/queries/elmIntel";
import { ElmEncoder, ElmOperationType } from "../../../src/gen/queries/elmIntel";
import { validModuleName } from "../../../src/gen/elmUtils";
import { writeFile } from "../../../src/gen/utils";

interface FixtureResult {
  fixture: Fixture;
  result: Result;
}

const basePath = __dirname;
const generatePath = resolve(basePath, "generated");

export const testBrowser = () => {
  test("graphqlToElm browser test", async t => {
    try {
      await generateTestFiles(t);
      await makeElm(t);
      const server: ChildProcess = await runServer(t);
      await openTestPage(t);
      kill(server.pid);
      t.end();
    } catch (error) {
      t.end(error.toString());
    }
  });
};

const generateTestFiles = (t: Test): Promise<any> => {
  rimraf.sync(generatePath);

  const fixtures: Fixture[] = getFixtures()
    .filter(fixture => !fixture.throws)
    .map(fixture => {
      fixture.options.schema =
        typeof fixture.options.schema === "string"
          ? resolve(__dirname, fixture.dir, fixture.options.schema)
          : fixture.options.schema;
      return fixture;
    });

  return Promise.all(
    fixtures.map(writeQueries(t))
  ).then((results: FixtureResult[]) =>
    Promise.all([
      writeTests(results),
      writeNamedQueries(results),
      writeSchemas(fixtures)
    ])
  );
};

const writeQueries = (t: Test) => async (
  fixture: Fixture
): Promise<FixtureResult> => {
  const baseModule = `Tests.${validModuleName(fixture.id)}`;

  const enumOptions = {
    baseModule: "GraphQL.Enum",
    ...(fixture.options.enums || {})
  };

  const schemaString = await getSchemaString(fixture.options);

  const options: Options = {
    ...fixture.options,
    schema: { string: schemaString },
    enums: {
      ...enumOptions,
      baseModule: `${baseModule}.${enumOptions.baseModule}`
    },
    queries: fixture.options.queries.map(query =>
      resolve(__dirname, fixture.dir, query)
    ),
    src: resolve(__dirname, fixture.dir, fixture.options.src || ""),
    log: t.comment
  };

  const result: Result = await getGraphqlToElm(options);

  result.enums = result.enums.map(enumIntel => {
    enumIntel.dest = resolve(
      generatePath,
      `${enumIntel.module.replace(/\./g, "/")}.elm`
    );
    return enumIntel;
  });

  result.queries = result.queries.map(query => {
    query.elmIntel.module = `${baseModule}.${query.elmIntel.module}`;
    query.elmIntel.dest = resolve(
      generatePath,
      `${query.elmIntel.module.replace(/\./g, "/")}.elm`
    );
    return query;
  });

  result.options.dest = generatePath;

  await writeResult(result);

  return { fixture, result };
};

interface FixtureElmIntel {
  fixture: Fixture;
  elmIntel: ElmIntel;
}

const writeTests = (results: FixtureResult[]): Promise<void> => {
  const elmIntels: FixtureElmIntel[] = results.reduce(
    (elmIntels: FixtureElmIntel[], { fixture, result }: FixtureResult) =>
      result.queries.reduce(
        (elmIntels: FixtureElmIntel[], { elmIntel }: QueryResult) =>
          elmIntels.concat({ fixture, elmIntel }),
        elmIntels
      ),
    []
  );

  const imports = elmIntels.map(({ elmIntel }) => `import ${elmIntel.module}`);

  const getTests = (operationType: ElmOperationType): string[] =>
    elmIntels.reduce(
      (tests: string[], { fixture, elmIntel }) => [
        ...tests,
        ...elmIntel.operations
          .filter(operation => operation.type === operationType)
          .map(
            operation =>
              `{ id = "${fixture.id}-${elmIntel.module}-${operation.name}"
      , schemaId = "${fixture.id}"
      , operation = ${elmIntel.module}.${operation.name}${
                operation.variables
                  ? ` ${generateVariables(operation.variables)}`
                  : ""
              } |> Operation.mapData Debug.toString |> Operation.mapErrors Debug.toString
      }
`
          )
      ],
      []
    );

  const content = `module Tests exposing (Test, queryTests, mutationTests)

import GraphQL.Operation as Operation exposing (Operation, Query, Mutation)
import GraphQL.Optional as Optional
${imports.join("\n")}


type alias Test t =
    { id : String
    , schemaId : String
    , operation : Operation t String String
    }


queryTests : List (Test Query)
queryTests =
    [ ${getTests("Query").join("    , ")}    ]  


mutationTests : List (Test Mutation)
mutationTests =
    [ ${getTests("Mutation").join("    , ")}    ]  
`;

  const testsPath = resolve(generatePath, "Tests.elm");

  return writeFile(testsPath, content);
};

const generateVariables = (encoder: ElmEncoder): string => {
  switch (encoder.kind) {
    case "record-encoder": {
      const fields = encoder.fields.map(
        field =>
          `${field.name} = ${
            field.valueWrapper === "optional"
              ? "Optional.Absent"
              : field.valueListItemWrapper
              ? "[]"
              : generateVariables(field.value)
          }`
      );
      return `{ ${fields.join(", ")} }`;
    }
    case "value-encoder":
      switch (encoder.type) {
        case "Int":
          return "0";
        case "Float":
          return "0.0";
        case "Bool":
          return "False";
        case "String":
          return '""';
        default:
          throw new Error(`unhandled encoder type: ${encoder.type}`);
      }
  }
};

type NamedQuery = {
  id: string;
  query: string;
};

const writeNamedQueries = (results: FixtureResult[]): Promise<void> => {
  const namedQueries: NamedQuery[] = [];

  results.forEach(({ result, fixture }) => {
    result.queries.forEach(query =>
      query.elmIntel.operations.forEach(operation => {
        if (operation.kind === "named") {
          namedQueries.push({
            id: `${fixture.id}/${operation.gqlName}`,
            query: query.queryIntel.query
          });
        } else if (operation.kind === "named_prefixed") {
          namedQueries.push({
            id: `${fixture.id}/${operation.gqlFilename}:${operation.gqlName}`,
            query: query.queryIntel.query
          });
        }
      })
    );
  });

  const entries = namedQueries.map(
    ({ id, query }) => `  "${id}": \`${query}\``
  );
  const content = `export const namedQueries: { [id: string]: string } = {\n${entries.join(
    ",\n"
  )}\n};\n`;

  const path = resolve(generatePath, "namedQueries.ts");

  return writeFile(path, content);
};

const writeSchemas = (fixtures: Fixture[]): Promise<void> =>
  Promise.all(
    fixtures.map(({ id, options }) =>
      getSchemaString(options).then(schema => ({ id, schema }))
    )
  ).then(schemas => {
    const entries = schemas.map(({ id, schema }) => `  "${id}": \`${schema}\``);
    const content = `export const schemas: { [id: string]: string } = {\n${entries.join(
      ",\n"
    )}\n};\n`;

    const path = resolve(generatePath, "schemas.ts");

    return writeFile(path, content);
  });

export const makeElm = (t: Test) => {
  t.comment("running elm make");
  const log = execSync(`elm make src/Main.elm --output=generated/index.html`, {
    cwd: basePath,
    stdio: "ignore" // elm make messes with the console
  });
  t.comment(log ? log.toString() : "no log");
  t.comment("done");
};

export const runServer = (t: Test): Promise<ChildProcess> =>
  new Promise((resolve, reject) => {
    t.comment("starting server");

    const server: ChildProcess = spawn("ts-node", ["server.ts"], {
      cwd: basePath,
      shell: true
    });

    if (server.stdout === null) {
      reject("[SERVER] server.stdout === null");
      return;
    }

    if (server.stderr === null) {
      reject("[SERVER] server.stderr === null");
      return;
    }

    server.stdout.on("data", data => {
      t.comment(`[SERVER] ${data.toString()}`);
      resolve(server);
    });

    server.stderr.on("data", data => {
      reject(`[SERVER] ${data.toString()}`);
    });
  });

export const openTestPage = (t: Test): Promise<void> =>
  new Promise(async (resolve, reject) => {
    t.comment("opening test page");

    const instance: PhantomJS = await phantom.create();
    const page: WebPage = await instance.createPage();

    await page.on("onConsoleMessage", (message: string) => {
      if (message.startsWith("[Test Failed]")) {
        t.fail(`[Browser] ${message}`);
      } else if (message.startsWith("[Test Passed]")) {
        t.pass(`[Browser] ${message}`);
      } else {
        t.comment(`[Browser] ${message}`);
        if (message.startsWith("[End Test]")) {
          instance.exit();
          resolve();
        }
      }
    });

    await page.on("onError", error => {
      t.comment(`[Browser] ${error.toString()}`);
      instance.exit();
      reject(error);
    });

    t.comment("loading page");
    await page.open("http://localhost:3000");
  });
