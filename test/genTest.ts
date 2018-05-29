import { resolve, relative } from "path";
import { readFileSync, lstatSync } from "fs";
import * as rimraf from "rimraf";
import * as glob from "glob";
import * as test from "tape";
import { Fixture, getFixtures } from "./fixtures";
import { graphqlToElm } from "../src/graphqlToElm";

const fixtureId = "";

test("graphqlToElm generate test", t => {
  rimraf.sync(resolve(__dirname, "fixtures/**/generated*"));

  const cwd = process.cwd();

  getFixtures(fixtureId).forEach(testFixture(t));

  process.chdir(cwd);

  t.end(fixtureId ? "with fixture filter" : undefined);
});

const testFixture = (t: test.Test) => ({
  id,
  dir,
  options,
  expect,
  throws
}: Fixture) =>
  t.test(`== fixture ${id} ==`, t => {
    process.chdir(resolve(__dirname, dir));

    const runTest = (fn: () => Promise<void>, msg): Promise<void> => {
      if (throws) {
        return fn()
          .then(() => t.fail(`Expected error message: ${throws}`))
          .catch(error =>
            t.equal(error.message, throws, "Expected error message")
          );
      } else {
        return fn()
          .then(() => t.pass())
          .catch(t.fail);
      }
    };

    const runFixtureTest = (): Promise<void> =>
      runTest(
        () =>
          graphqlToElm({
            ...options,
            log: t.comment
          }),
        "graphqlToElm"
      ).then(() => {
        t.doesNotThrow(
          () => compareDirs(t, { actual: options.dest, expect }),
          "compare generated and expected should not throw"
        );
        t.end();
      });

    if (process.argv.slice(2).includes("--update")) {
      runTest(
        () =>
          graphqlToElm({
            ...options,
            dest: expect,
            log: t.comment
          }),
        "graphqlToElm UPDATE"
      ).then(runFixtureTest);
    } else {
      runFixtureTest();
    }
  });

const compareDirs = (
  t: test.Test,
  { actual, expect }: { actual: string; expect: string }
) => {
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

    if (lstatSync(actualFile).isDirectory()) {
      t.equal(
        true,
        lstatSync(expectedFile).isDirectory(),
        `${relative(process.cwd(), actualFile)} === ${relative(
          process.cwd(),
          expectedFile
        )}`
      );
    } else {
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
    }
  });
};
