import { readFileSync } from "fs";
import { resolve, relative } from "path";
import { execSync } from "child_process";
import * as assert from "assert";
import * as glob from "glob";
import phantom from "phantom";

export const log = (...messages) => console.log("[Test]", ...messages);

export const logPassed = (...messages) =>
  console.log("[Test Passed]", ...messages);

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

export const testPage = (path, htmlFile) => {
  phantom
    .create()
    .then(instance => {
      instance
        .createPage()
        .then(page => {
          page.on("onConsoleMessage", (...messages) => {
            console.log("CONSOLE", ...messages);
            // instance.exit();
          });
          page.on("onError", (...messages) => {
            console.log("CONSOLE ERROR", ...messages);
            instance.exit();
          });
          page.open("file:///" + resolve(path, htmlFile));
        })
        .catch(error => {
          console.error(error);
          instance.exit();
        });
    })
    .catch(error => console.error(error));
};
