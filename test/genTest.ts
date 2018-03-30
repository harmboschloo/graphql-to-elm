import { resolve, relative } from "path";
import { readFileSync } from "fs";
import * as rimraf from "rimraf";
import * as glob from "glob";
import * as test from "tape";
import { Fixture, getFixtures } from "./fixtures";
import { graphqlToElm } from "../src";

const fixtureId = "";

test("graphqlToElm generate test", t => {
  rimraf.sync(resolve(__dirname, "fixtures/**/generated*"));

  const cwd = process.cwd();

  getFixtures(fixtureId).forEach(testFixture(t));

  process.chdir(cwd);

  t.end(fixtureId ? "with fixture filter" : undefined);
});

const testFixture = t => ({ id, dir, options, expect, throws }: Fixture) =>
  t.test(`== fixture ${id} ==`, t => {
    process.chdir(resolve(__dirname, dir));

    const throwsTest = throws
      ? (fn, msg) => {
          try {
            fn();
            t.fail(`Expected error message: ${throws}`);
          } catch (error) {
            t.equal(error.message, throws, "Expected error message");
          }
        }
      : t.doesNotThrow;

    if (process.argv.slice(2).includes("--update")) {
      throwsTest(
        () =>
          graphqlToElm({
            ...options,
            dest: expect,
            log: t.comment
          }),
        "graphqlToElm UPDATE"
      );
    }

    throwsTest(
      () =>
        graphqlToElm({
          ...options,
          log: t.comment
        }),
      "graphqlToElm"
    );

    t.doesNotThrow(
      () => compareDirs(t, { actual: options.dest, expect }),
      "compare generated and expected should not throw"
    );

    t.end();
  });

const compareDirs = (t, { actual, expect }) => {
  const actualFiles = glob
    .sync(resolve(actual, "**/*"))
    .map(path => relative(actual, path));

  const expectedFiles = glob
    .sync(resolve(expect, "**/*"))
    .map(path => relative(expect, path));

  t.deepEqual(actualFiles, expectedFiles, `${actual}/**/* === ${expect}/**/*`);

  actualFiles.forEach(file => {
    const actualFile = resolve(actual, file);
    const expectedFile = resolve(expect, file);
    const actualContent = readFileSync(actualFile, "utf8");
    const expectedContent = readFileSync(expectedFile, "utf8");
    t.equal(
      actualContent,
      expectedContent,
      `${relative(process.cwd(), actualFile)} === ${relative(
        process.cwd(),
        expectedFile
      )}`
    );
  });
};
