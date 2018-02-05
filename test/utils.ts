import { readFileSync } from "fs";
import { resolve, relative, dirname } from "path";
import { execSync } from "child_process";
import * as assert from "assert";
import * as glob from "glob";
import phantom from "phantom";
import * as lib from "..";

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
  testPage(path, "index.html", () => {
    console.log("[End Integration Test]");
  });
};

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

export const testPage = (path, htmlFile, callback) => {
  phantom
    .create()
    .then(instance => {
      instance
        .createPage()
        .then(page => {
          page.on("onConsoleMessage", message => {
            console.log(message);

            if (message.startsWith("[Test Failed]")) {
              throw new Error(message);
            }

            if (message.startsWith("[End Test]")) {
              logPassed("page test");
              instance.exit();
              callback();
            }
          });
          page.on("onError", (...messages) => {
            throw new Error(messages[0]);
          });
          page.open("file:///" + resolve(path, htmlFile));
        })
        .catch(error => {
          instance.exit();
          throw error;
        });
    })
    .catch(error => {
      throw error;
    });
};
