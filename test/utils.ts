import { readFileSync } from "fs";
import { resolve, relative } from "path";
import * as assert from "assert";
import * as glob from "glob";

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
    const actualContent = readFileSync(resolve(actualPath, file), "utf-8");
    const expectedContent = readFileSync(resolve(expectedPath, file), "utf-8");
    assert.equal(actualContent, expectedContent);
  });

  logPassed("compareDirs content");
};
