import { resolve, relative, normalize } from "path";
import { readFileSync } from "fs";
import { execSync, spawn } from "child_process";
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
} from "..";
import { validModuleName, writeFile } from "../src/utils";

interface FixtureResult {
  fixture: Fixture;
  result: Result;
}

const basePath = resolve(__dirname, "browserTest");
const generatePath = resolve(basePath, "generated");

test("graphqlToElm browser test", t => {
  generateTestFiles(t);
  makeElm(t);

  const server = initServer(t);
  server.run();
  openTestPage(t, server.close);
});

const generateTestFiles = t => () => {
  rimraf.sync(generatePath);
  const fixtures = getFixtures();
  const results: FixtureResult[] = fixtures.map(writeQueries(t));
  writeTests(results);
  writeSchemas(fixtures);
};

const writeQueries = t => (fixture: Fixture): FixtureResult => {
  const { id, dir, schema, queries, src } = fixture;

  const result: Result = getGraphqlToElm({
    schema: resolve(__dirname, dir, schema),
    queries: queries.map(query => resolve(__dirname, dir, query)),
    src: resolve(__dirname, dir, src),
    log: t.comment
  });

  result.queries = result.queries.map(query => {
    const moduleName = validModuleName(id);
    query.elmIntel.module = `GraphQL.${moduleName}.${query.elmIntel.module}`;
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

  const tests = elmIntels.map(
    ({ fixture, elmIntel }) =>
      `{ id = "${fixture.id}-${elmIntel.module}"
      , schemaId = "${fixture.id}"
      , query = ${elmIntel.module}.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString ${elmIntel.module}.decoder
      }
`
  );

  const content = `module Tests exposing (Test, tests)

import Json.Decode exposing (Decoder)
import Json.Encode
${imports.join("\n")}


type alias Test =
    { id : String
    , schemaId : String
    , query : String
    , variables : Json.Encode.Value
    , decoder : Decoder String
    }


tests : List Test
tests =
    [ ${tests.join("    , ")}    ]  
`;

  const testsPath = resolve(generatePath, "Tests.elm");

  writeFile(testsPath, content);
};

const writeSchemas = (fixtures: Fixture[]) => {
  const schemas = fixtures.map(({ id, dir, schema }) => ({
    id,
    path: normalize(resolve(__dirname, dir, schema)).replace(/\\/g, "/")
  }));

  const entries = schemas.map(({ id, path }) => `  "${id}": "${path}"`);
  const content = `export const schemas = {\n${entries.join(",\n")}\n};\n`;

  const schemasPath = resolve(generatePath, "schemas.ts");

  writeFile(schemasPath, content);
};

export const makeElm = t => () => {
  t.comment("running elm-make");
  const log = execSync(
    `elm-make src/Main.elm --output generated/index.html --yes`,
    { cwd: basePath }
  );
  t.comment(log.toString());
};

export const initServer = t => {
  let server;

  const run = () => {
    if (server) {
      t.fail("server already started");
    }

    server = spawn("ts-node", ["server.ts"], {
      cwd: basePath,
      shell: true
    });

    server.stdout.on("data", data => {
      t.comment("[SERVER]", data.toString());
    });

    server.stderr.on("data", data => {
      t.fail(data.toString());
      close();
    });

    server.on("close", code => {
      if (server) {
        server = null;
        t.end(`[SERVER] exited with code ${code}`);
      } else {
        t.comment("[SERVER] closed");
        t.end();
      }
    });
  };

  const close = () => {
    if (!server) {
      return;
    }

    const pid = server.pid;
    server = null;

    if (process.platform === "win32") {
      execSync(`taskkill /pid ${pid} /f /t`);
    } else {
      process.kill(pid);
    }
  };

  return { run, close };
};

export const openTestPage = (t, done) => {
  phantom
    .create()
    .then(instance => {
      instance
        .createPage()
        .then(page => {
          page.on("onConsoleMessage", message => {
            if (message.startsWith("[Test Failed]")) {
              instance.kill();
              t.fail(message);
              done();
            } else if (message.startsWith("[Test Passed]")) {
              t.pass(message);
            } else if (message.startsWith("[End Test]")) {
              instance.kill();
              t.comment(message);

              if (message.includes("failed: 0")) {
                done();
              } else {
                t.fail(message);
                done();
              }
            } else {
              t.comment(message);
            }
          });

          page.on("onError", message => {
            instance.kill();
            t.fail(message);
            done();
          });

          page.open("http://localhost:3000");
        })
        .catch(error => {
          instance.kill();
          t.fail(error);
          done();
        });
    })
    .catch(error => {
      t.fail(error);
      done();
    });
};
