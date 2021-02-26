import * as fs from "fs";
import * as childProcess from "child_process";
import * as tape from "tape";
import * as rimrafAsync from "rimraf";
import * as globAsync from "glob";
export { Stats } from "fs";
export { Test } from "tape";
export { readFile, writeFile, fixLineEndings } from "../../../src/gen/utils";

export const test = (name: string, test?: tape.Test): Promise<tape.Test> =>
  new Promise((resolve) =>
    test ? test.test(name, resolve) : tape(name, resolve)
  );

export const testNoThrow = (
  test: tape.Test,
  message: string
): Promise<tape.Test> =>
  new Promise((resolve) => test.doesNotThrow(() => resolve(test), message));

export const rimraf = (pattern: string): Promise<void> =>
  new Promise((resolve, reject) =>
    rimrafAsync(pattern, (error) => (error ? reject(error) : resolve()))
  );

export const glob = (pattern: string): Promise<string[]> =>
  new Promise((resolve, reject) =>
    globAsync(pattern, (error, matches) =>
      error ? reject(error) : resolve(matches)
    )
  );

export const lstat = (path: string): Promise<fs.Stats> =>
  new Promise((resolve, reject) =>
    fs.lstat(path, (error, stats) => (error ? reject(error) : resolve(stats)))
  );

export const exec = (
  command: string,
  options?: childProcess.ExecOptions
): Promise<String> =>
  new Promise((resolve, reject) =>
    childProcess.exec(command, options || {}, (error, stdout) =>
      error ? reject(error) : resolve(stdout.toString())
    )
  );
