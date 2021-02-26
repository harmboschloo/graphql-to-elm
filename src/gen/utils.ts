import { EOL } from "os";
import * as fs from "fs";
import { dirname } from "path";
import * as mkdirp from "mkdirp";

export const readFile = (path: string): Promise<string> =>
  fs.promises.readFile(path, "utf8").then((data) => data.toString());

export const writeFile = (dest: string, data: string): Promise<void> =>
  writeFileWithDir(dest, fixLineEndings(data));

const writeFileWithDir = (dest: string, data: string): Promise<void> =>
  mkdirp(dirname(dest)).then(() => fs.promises.writeFile(dest, data, "utf8"));

export const fixLineEndings = (data: string): string =>
  data.replace(/\r?\n|\r/g, EOL);

export const writeFileIfChanged = (
  dest: string,
  data: string
): Promise<boolean> =>
  new Promise((resolve, reject) => {
    const fileData = fixLineEndings(data);

    isFileChanged(dest, fileData)
      .then((changed) =>
        changed
          ? writeFileWithDir(dest, fileData).then(() => resolve(true))
          : resolve(false)
      )
      .catch(reject);
  });

const isFileChanged = (dest: string, newData: string): Promise<boolean> =>
  new Promise((resolve) =>
    readFile(dest)
      .then((currentData) => resolve(currentData !== newData))
      .catch(() => resolve(true))
  );

export const firstToUpperCase = (string: string): string =>
  string ? `${string.charAt(0).toUpperCase()}${string.slice(1)}` : string;

export const firstToLowerCase = (string: string): string =>
  string ? `${string.charAt(0).toLowerCase()}${string.slice(1)}` : string;

export const sortString = (a: string, b: string): number =>
  a < b ? -1 : b < a ? 1 : 0;

export const withParentheses = (x: string): string => `(${x})`;

export const removeIndents = (string: string): string =>
  string.replace(/^[\s]+/gm, "");

export const assertOk = <T>(
  a: T | undefined,
  errorMessage: string = "not ok"
): T => {
  if (typeof a === "undefined") {
    throw Error(errorMessage);
  }
  return a;
};

export const withDefault = <T>(defaultValue: T, value: T | undefined): T =>
  typeof value !== "undefined" ? value : defaultValue;

export const addOnce = <T>(value: T, values: T[]) => {
  if (!values.includes(value)) {
    values.push(value);
  }
};

export const cachedValue = <T>(
  key: string,
  cache: { [key: string]: T },
  create: () => T
): T => {
  if (cache[key]) {
    return cache[key];
  } else {
    const value = create();
    cache[key] = value;
    return value;
  }
};
