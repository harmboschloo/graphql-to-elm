import { readFileSync, writeFileSync } from "fs";
import { resolve, relative, dirname, normalize } from "path";
import { spawn, execSync } from "child_process";
import * as assert from "assert";
import * as rimraf from "rimraf";
import * as mkdirp from "mkdirp";
import * as glob from "glob";
import phantom from "phantom";
import {
  Options,
  Result,
  QueryResult,
  ElmIntel,
  graphqlToElm as gqlToElm,
  generateElm
} from "..";
import { firstToUpperCase } from "../src/utils";
import { setTimeout } from "timers";

export const logPassed = (...messages) =>
  console.log("[Test Passed]", ...messages);

interface TestResult {
  id: string;
  cwd: string;
  options: Options;
  result: Result;
}

let graphqlToElmResults: TestResult[] = [];

export const clearGraphqlToElmResults = () => {
  graphqlToElmResults = [];
};

export const getGraphqlToElmResults = () => graphqlToElmResults;

export const addGraphqlToElmResult = (result: TestResult) =>
  graphqlToElmResults.push(result);

export const graphqlToElm = (testName: string, options: Options): Result => {
  const result = gqlToElm(options);

  addGraphqlToElmResult({
    id: `test${getGraphqlToElmResults().length}-${testName}`,
    cwd: process.cwd(),
    options,
    result
  });

  return result;
};

export const runSnapshotTests = () => {
  clearGraphqlToElmResults();

  rimraf.sync(resolve(__dirname, "snapshot/**/generated*"));

  const testFiles = resolve(__dirname, "snapshot/**/test.ts");

  glob.sync(testFiles).map(file => {
    const cwd = process.cwd();

    console.log("[Start Test] ", file);

    process.chdir(dirname(file));
    require(file);

    console.log("[End Test] ", file);

    process.chdir(cwd);
  });
};

export const runSnapshotAndIntegrationTests = () => {
  runSnapshotTests();
  const graphqlToElmResults = getGraphqlToElmResults();

  rimraf.sync(resolve(__dirname, "integration/generated*"));

  console.log("[Start Generating Integration Test]");
  writeIntegrationTests(graphqlToElmResults);
  console.log("[End Generating Integration Test]");

  const path = resolve(__dirname, "integration");

  console.log("[Start Elm Make]");
  makeElm(path, "Main.elm");
  console.log("[End Elm Make]");

  console.log("[Start Integration Test]");
  const server = initServer(path);

  server
    .start()
    .then(() => {
      console.log("[End Integration Test]");
    })
    .catch(error => {
      server.stop();
      throwCatchedError(error);
    });

  testPage()
    .then(() => {
      server.stop();
    })
    .catch(error => {
      server.stop();
      throwCatchedError(error);
    });
};

const throwCatchedError = error =>
  setTimeout(() => {
    throw error;
  }, 0);

export const compareDirs = (actualPath: string, expectedPath: string) => {
  const actualFiles = glob
    .sync(resolve(actualPath, "**/*"))
    .map(path => relative(actualPath, path));

  const expectedFiles = glob
    .sync(resolve(expectedPath, "**/*"))
    .map(path => relative(expectedPath, path));

  assert.deepEqual(actualFiles, expectedFiles);

  logPassed("compareDirs structure");

  actualFiles.forEach(file => {
    const actualContent = readFileSync(resolve(actualPath, file), "utf8");
    const expectedContent = readFileSync(resolve(expectedPath, file), "utf8");
    assert.equal(actualContent, expectedContent);
  });

  logPassed("compareDirs content");
};

export const makeElm = (path, mainFile) => {
  const log1 = execSync(`elm-package install -y`, { cwd: path });
  console.log(log1.toString());

  const log2 = execSync(`elm-make ${mainFile}`, { cwd: path });
  console.log(log2.toString());
};

export const initServer = path => {
  let server;

  const start = () =>
    new Promise((resolve, reject) => {
      if (server) {
        reject("server already started");
      }

      server = spawn("ts-node", ["server.ts"], {
        cwd: path,
        shell: true
      });

      server.stdout.on("data", data => {
        console.log("[SERVER]", data.toString());
      });

      server.stderr.on("data", data => {
        reject(data.toString());
      });

      server.on("close", code => {
        if (server) {
          server = null;
          reject(`[SERVER] exited with code ${code}`);
        } else {
          console.log("[SERVER] closed");
          resolve();
        }
      });
    });

  const stop = () => {
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

  return { start, stop };
};

export const testPage = () =>
  new Promise((resolve, reject) => {
    phantom.create().then(instance => {
      instance
        .createPage()
        .then(page => {
          page.on("onConsoleMessage", message => {
            if (message.startsWith("[Test Failed]")) {
              instance.kill();
              reject(message);
            } else if (message.startsWith("[End Test]")) {
              instance.kill();
              console.log(message);

              if (message.includes("failed: 0")) {
                logPassed("page test");
                resolve();
              } else {
                reject(message);
              }
            } else {
              console.log(message);
            }
          });

          page.on("onError", message => {
            instance.kill();
            reject(message);
          });

          page.open("http://localhost:3000");
        })
        .catch(error => {
          instance.kill();
          reject(error);
        });
    });
  });

const writeIntegrationTests = (results: TestResult[]) => {
  writeSchemas(results);
  writeTests(results);
};

const writeSchemas = (results: TestResult[]) => {
  const schemas = results.map(({ id, cwd, options }) => ({
    id,
    path: normalizePath(resolve(cwd, options.schema))
  }));

  const entries = schemas.map(({ id, path }) => `  "${id}": "${path}"`);
  const content = `export const schemas = {\n${entries.join(",\n")}\n};\n`;

  const schemasPath = resolve(__dirname, "integration/generated/schemas.ts");

  writeFile(schemasPath, content);
};

interface TestElmIntel {
  test: TestResult;
  elmIntel: ElmIntel;
}

const writeTests = (results: TestResult[]) => {
  const testIntels: TestElmIntel[] = results
    .reduce(
      (testIntels: TestElmIntel[], test: TestResult) =>
        test.result.queries.reduce(
          (testIntels: TestElmIntel[], query: QueryResult) =>
            testIntels.concat({ elmIntel: query.elmIntel, test }),
          testIntels
        ),
      []
    )
    .map(({ test, elmIntel }) => {
      const testDir = firstToUpperCase(test.id.replace(/[^A-Za-z0-9]/g, ""));
      const module = `Generated.${testDir}.${elmIntel.module}`;

      const modulePath = elmIntel.module.replace(/\./g, "/") + ".elm";
      const dest = resolve(
        __dirname,
        "integration/generated",
        testDir,
        modulePath
      );

      return { test, elmIntel: { ...elmIntel, module, dest } };
    });

  testIntels.forEach(({ elmIntel }) => {
    const content = generateElm(elmIntel);
    writeFile(elmIntel.dest, content);
  });

  const testImports = testIntels.map(
    ({ elmIntel }) => `import ${elmIntel.module}`
  );

  const tests = testIntels.map(
    ({ test, elmIntel }) =>
      `{ id = "${test.id}"
      , query = ${elmIntel.module}.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString ${elmIntel.module}.decoder
      }
`
  );

  const content = `module Generated.Tests exposing (Test, tests)

import Json.Decode exposing (Decoder)
import Json.Encode
${testImports.join("\n")}


type alias Test =
    { id : String
    , query : String
    , variables : Json.Encode.Value
    , decoder : Decoder String
    }


tests : List Test
tests =
    [ ${tests.join("    , ")}    ]  
`;

  const testsPath = resolve(__dirname, "integration/generated/Tests.elm");

  writeFile(testsPath, content);
};

const normalizePath = (path: string): string =>
  normalize(path).replace(/\\/g, "/");

const writeFile = (path: string, content: string) => {
  console.log(`writing file ${path}`);
  mkdirp.sync(dirname(path));
  writeFileSync(path, content, "utf8");
};
