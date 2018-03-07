import { EOL } from "os";
import { readFileSync, writeFileSync } from "fs";
import { dirname } from "path";
import * as mkdirp from "mkdirp";

export const readFile = (path: string): string => readFileSync(path, "utf8");

export const writeFile = (dest: string, content: string): void => {
  mkdirp.sync(dirname(dest));
  content = content.replace(/\r?\n|\r/g, EOL);
  writeFileSync(dest, content, "utf8");
};

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
