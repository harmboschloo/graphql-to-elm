import { resolve } from "path";
import { execSync, spawn, ChildProcess } from "child_process";
import * as rimraf from "rimraf";
import { PhantomJS, WebPage } from "phantom";
import * as phantom from "phantom";
import { Test } from "tape";
import * as test from "tape";
import { Fixture, getFixtures } from "./fixtures";
import {
  Result,
  QueryResult,
  getGraphqlToElm,
  writeResult
} from "../src/graphqlToElm";
import { Options } from "../src/options";
import { getSchemaString } from "../src/schema";
import { ElmIntel } from "../src/queries/elmIntel";
import { ElmEncoder, ElmOperationType } from "../src/queries/elmIntel";
import { validModuleName } from "../src/elmUtils";
import { writeFile } from "../src/utils";

interface FixtureResult {
  fixture: Fixture;
  result: Result;
}

const basePath = resolve(__dirname, "browserTest");
const generatePath = resolve(basePath, "generated");

test("graphqlToElm browser test", t => {
  generateTestFiles(t).then(() => {
    makeElm(t);

    const killServer = runServer(t);
    const killBrowser = openTestPage(t);

    test.onFinish(() => {
      killServer();
      killBrowser();
    });
  });
});

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

  return Promise.all(fixtures.map(writeQueries(t))).then(
    (results: FixtureResult[]) =>
      Promise.all([
        writeTests(results),
        writeNamedQueries(results),
        writeSchemas(fixtures)
      ])
  );
};

const writeQueries = (t: Test) => (
  fixture: Fixture
): Promise<FixtureResult> => {
  const { id, dir, options } = fixture;

  const baseModule = `Tests.${validModuleName(id)}`;

  const enumOptions = {
    baseModule: "GraphQL.Enum",
    ...(options.enums || {})
  };

  return getSchemaString(options)
    .then(
      (schemaString: string): Options => ({
        ...options,
        schema: { string: schemaString },
        enums: {
          ...enumOptions,
          baseModule: `${baseModule}.${enumOptions.baseModule}`
        },
        queries: options.queries.map(query => resolve(__dirname, dir, query)),
        src: resolve(__dirname, dir, options.src || ""),
        log: t.comment
      })
    )
    .then(getGraphqlToElm)
    .then((result: Result) => {
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
      return result;
    })
    .then(writeResult)
    .then(result => ({ fixture, result }));
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

  const getTests = (operationType: ElmOperationType) =>
    elmIntels.reduce(
      (tests, { fixture, elmIntel }) => [
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
              } |> Operation.mapData toString |> Operation.mapErrors toString
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
  t.comment("running elm-make");
  const log = execSync(
    `elm-make src/Main.elm --output generated/index.html --yes`,
    { cwd: basePath }
  );
  t.comment(log.toString());
};

export const runServer = (t: Test) => {
  let server: ChildProcess | null = spawn("ts-node", ["server.ts"], {
    cwd: basePath,
    shell: true
  });

  server.stdout.on("data", data => {
    t.comment(`[SERVER] ${data.toString()}`);
  });

  server.stderr.on("data", data => {
    t.end(`[SERVER] ${data.toString()}`);
  });

  const kill = () => {
    t.comment(`kill server ${server && server.pid}`);
    if (server && server.pid) {
      const pid = server.pid;
      server = null;

      if (process.platform === "win32") {
        execSync(`taskkill /pid ${pid} /f /t`);
      } else {
        process.kill(pid);
      }
    }
  };

  return kill;
};

export const openTestPage = (t: Test) => {
  let browser: PhantomJS | null = null;
  let killed = false;

  phantom
    .create()
    .then((instance: PhantomJS) => {
      if (killed) {
        // @ts-ignore
        instance.kill();
        return;
      }

      browser = instance;

      browser
        .createPage()
        .then((page: WebPage) => {
          page.on("onConsoleMessage", (message: string) => {
            if (message.startsWith("[Test Failed]")) {
              t.fail(message);
            } else if (message.startsWith("[Test Passed]")) {
              t.pass(message);
            } else {
              t.comment(message);
              if (message.startsWith("[End Test]")) {
                t.end();
              }
            }
          });

          page.on("onError", t.end);

          page.open("http://localhost:3000");
        })
        .catch(t.end);
    })
    .catch(t.end);

  const kill = () => {
    t.comment(`kill browser ${!!browser}`);
    killed = true;
    if (browser) {
      // @ts-ignore
      browser.kill();
      browser = null;
    }
  };

  return kill;
};
