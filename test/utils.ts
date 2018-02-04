import { resolve, relative } from "path";
import * as assert from "assert";
import * as glob from "glob";

export const compareDirs = (actualPath: string, expectedPath: string) => {
  const actualFiles = glob
    .sync(resolve(actualPath, "**/*"))
    .map(path => relative(actualPath, path));

  const expectedFiles = glob
    .sync(resolve(expectedPath, "**/*"))
    .map(path => relative(expectedPath, path));

  assert.deepEqual(actualFiles, expectedFiles);

  console.log("[TEST] compareDirs: structure passed");

  assert.ok(false, "TODO: dir file content");
};
