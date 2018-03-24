import { resolve, relative, normalize } from "path";
import { readFileSync } from "fs";
import { execSync, spawn, ChildProcess } from "child_process";
import * as rimraf from "rimraf";
import * as glob from "glob";
import phantom from "phantom";
import { test } from "tape";
import { Fixture, getFixtures } from "./fixtures";
import {
  Result,
  Options,
  ElmIntel,
  QueryResult,
  getGraphqlToElm,
  generateElm,
  writeResult
} from "../src";
import { ElmEncoder, validModuleName } from "../src/elmIntel";
import { writeFile } from "../src/utils";

interface FixtureResult {
  fixture: Fixture;
  result: Result;
}

const basePath = resolve(__dirname, "browserTest");
const generatePath = resolve(basePath, "generated");

test("graphqlToElm browser test", t => {
  generateTestFiles(t);
  makeElm(t);

  const killServer = runServer(t);
  const killBrowser = openTestPage(t);

  test.onFinish(() => {
    killServer();
    killBrowser();
  });
});

const generateTestFiles = t => {
  rimraf.sync(generatePath);
  const fixtures = getFixtures().filter(fixture => !fixture.throws);
  const results: FixtureResult[] = fixtures.map(writeQueries(t));
  writeTests(results);
  writeNamedQueries(results);
  writeSchemas(fixtures);
};

const writeQueries = t => (fixture: Fixture): FixtureResult => {
  const { id, dir, options } = fixture;

  const result: Result = getGraphqlToElm({
    ...options,
    schema: resolve(__dirname, dir, options.schema),
    queries: options.queries.map(query => resolve(__dirname, dir, query)),
    src: resolve(__dirname, dir, options.src || ""),
    log: t.comment
  });

  result.queries = result.queries.map(query => {
    const moduleName = validModuleName(id);
    query.elmIntel.module = `Tests.${moduleName}.${query.elmIntel.module}`;
    query.elmIntel.dest = resolve(
      generatePath,
      `${query.elmIntel.module.replace(/\./g, "/")}.elm`
    );
    query.elm = generateElm(query.elmIntel);
    return query;
  });

  writeResult(result);

  return { fixture, result };
};

interface FixtureElmIntel {
  fixture: Fixture;
  elmIntel: ElmIntel;
}

const writeTests = (results: FixtureResult[]) => {
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

  const tests = elmIntels.reduce(
    (tests, { fixture, elmIntel }) => [
      ...tests,
      ...elmIntel.operations.map(
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

  const content = `module Tests exposing (Test, tests)

import GraphqlToElm.Operation as Operation exposing (Operation)
import GraphqlToElm.Optional as Optional
${imports.join("\n")}


type alias Test =
    { id : String
    , schemaId : String
    , operation : Operation String String
    }


tests : List Test
tests =
    [ ${tests.join("    , ")}    ]  
`;

  const testsPath = resolve(generatePath, "Tests.elm");

  writeFile(testsPath, content);
};

const generateVariables = (encoder: ElmEncoder): string => {
  switch (encoder.kind) {
    case "record-encoder": {
      const fields = encoder.fields.map(
        field =>
          `${field.jsonName} = ${
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

const writeNamedQueries = (results: FixtureResult[]) => {
  const namedQueries = [];

  results.forEach(({ result, fixture }) => {
    result.queries.forEach(query =>
      query.elmIntel.operations.forEach(operation => {
        if (operation.kind === "named") {
          namedQueries.push({
            id: `${fixture.id}/${operation.gqlName}`,
            query: query.queryIntel.query
          });
        }
      })
    );
  });

  const entries = namedQueries.map(
    ({ id, query }) => `  "${id}": \`${query}\``
  );
  const content = `export const namedQueries = {\n${entries.join(",\n")}\n};\n`;

  const path = resolve(generatePath, "namedQueries.ts");

  writeFile(path, content);
};

const writeSchemas = (fixtures: Fixture[]) => {
  const schemas = fixtures.map(({ id, dir, options }) => ({
    id,
    path: normalize(resolve(__dirname, dir, options.schema)).replace(/\\/g, "/")
  }));

  const entries = schemas.map(({ id, path }) => `  "${id}": "${path}"`);
  const content = `export const schemas = {\n${entries.join(",\n")}\n};\n`;

  const path = resolve(generatePath, "schemas.ts");

  writeFile(path, content);
};

export const makeElm = t => {
  t.comment("running elm-make");
  const log = execSync(
    `elm-make src/Main.elm --output generated/index.html --yes`,
    { cwd: basePath }
  );
  t.comment(log.toString());
};

export const runServer = t => {
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

export const openTestPage = t => {
  let browser;
  let killed = false;

  phantom
    .create()
    .then(instance => {
      if (killed) {
        instance.kill();
        return;
      }

      browser = instance;

      browser
        .createPage()
        .then(page => {
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
      browser.kill();
      browser = null;
    }
  };

  return kill;
};
