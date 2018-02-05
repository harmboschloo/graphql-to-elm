import { readFileSync } from "fs";
import { resolve, relative, dirname } from "path";
import { spawn, execSync } from "child_process";
import * as assert from "assert";
import * as glob from "glob";
import phantom from "phantom";
import * as lib from "..";
import { setTimeout } from "timers";

export const logPassed = (...messages) =>
  console.log("[Test Passed]", ...messages);

export const graphqlToElm = (options: lib.Options): lib.Result => {
  const result = lib.graphqlToElm(options);
  // TODO generate integration test files
  return result;
};

export const runSnapshotTests = () => {
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
