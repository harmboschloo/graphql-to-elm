import * as p from "path";
import {
  Test,
  test,
  testNoThrow,
  glob,
  readFile,
  Stats,
  lstat
} from "graphql-to-elm-test-utils";
import {
  Fixture,
  getFixtures,
  clean as cleanFixtures
} from "graphql-to-elm-test-fixtures";
import { graphqlToElm } from "graphql-to-elm/src/graphqlToElm";

const fixtureId = "";

export type Config = {
  graphqlVersion: "0.12" | "0.13";
  update?: boolean;
};

export const testGen = (config: Config): void => {
  test("graphqlToElm generate test").then(t =>
    cleanFixtures()
      .then(() => {
        const cwd = process.cwd();

        Promise.all(
          getFixtures({
            graphqlVersion: config.graphqlVersion,
            fixtureId
          }).map(testFixture(t))
        ).then(() => {
          process.chdir(cwd);
        });
      })
      .then(() => t.end(fixtureId ? "with fixture filter" : undefined))
  );

  const testFixture = (t: Test) => ({
    id,
    dir,
    options,
    actual,
    expect,
    throws
  }: Fixture): Promise<void> =>
    test(`== fixture ${id} ==`, t).then(
      (t: Test): Promise<void> => {
        process.chdir(p.resolve(__dirname, dir));

        const runTest = (
          fn: () => Promise<void>,
          msg: string
        ): Promise<void> => {
          if (throws) {
            return fn()
              .then(() => t.fail(`Expected error message: ${throws}`))
              .catch(error =>
                t.equal(error.message, throws, "Expected error message")
              );
          } else {
            return fn()
              .then(() => t.pass(msg))
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
          )
            .then(() =>
              testNoThrow(t, "compare generated and expected should not throw")
            )
            .then((t: Test) => compareDirs(t, { actual, expect }))
            .then((t: Test) => t.end());

        if (config.update) {
          return runTest(
            () =>
              graphqlToElm({
                ...options,
                dest: expect,
                log: t.comment
              }),
            "graphqlToElm UPDATE"
          ).then(runFixtureTest);
        } else {
          return runFixtureTest();
        }
      }
    );

  const compareDirs = (
    t: Test,
    { actual, expect }: { actual: string; expect: string }
  ): Promise<Test> =>
    Promise.all([
      glob(p.resolve(actual, "**/*")).then(matches =>
        matches.map(path => p.relative(actual, path))
      ),
      glob(p.resolve(expect, "**/*")).then(matches =>
        matches.map(path => p.relative(expect, path))
      )
    ])
      .then(
        ([actualFiles, expectedFiles]): Promise<any> => {
          t.deepEqual(
            actualFiles,
            expectedFiles,
            `${actual}/**/* === ${expect}/**/*`
          );

          return Promise.all(
            actualFiles.map(
              (file: string): Promise<any> => {
                const actualFile: string = p.resolve(actual, file);
                const expectedFile: string = p.resolve(expect, file);
                const message: string = `${p.relative(
                  process.cwd(),
                  actualFile
                )} === ${p.relative(process.cwd(), expectedFile)}`;

                return Promise.all([
                  lstat(actualFile),
                  lstat(expectedFile)
                ]).then(
                  ([actualStats, expectedStats]: Stats[]): Promise<void> => {
                    if (actualStats.isDirectory()) {
                      t.equal(true, expectedStats.isDirectory(), message);
                      return Promise.resolve();
                    } else {
                      return Promise.all([
                        readFile(actualFile),
                        readFile(expectedFile)
                      ]).then(([actualContent, expectedContent]: string[]) => {
                        t.equal(actualContent, expectedContent, message);
                        return Promise.resolve();
                      });
                    }
                  }
                );
              }
            )
          );
        }
      )
      .then(() => t);
};
