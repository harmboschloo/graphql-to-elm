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

export const cachedValue = (
  key: string,
  cache: { [key: string]: string },
  newValue: () => string
): string => {
  if (cache[key]) {
    return cache[key];
  } else {
    const value = newValue();
    cache[key] = value;
    return value;
  }
};

export const findByIdIn = <T extends { id: number }>(items: T[]) => (
  id: number
): T => {
  const item = items.find(item => item.id === id);
  if (!item) {
    throw new Error(`Could not find item with id: ${id}`);
  }
  return item;
};

export const getId = <T extends { id: number }>(item: T) => item.id;

export const firstToUpperCase = (string: string): string =>
  string ? `${string.charAt(0).toUpperCase()}${string.slice(1)}` : string;

export const firstToLowerCase = (string: string): string =>
  string ? `${string.charAt(0).toLowerCase()}${string.slice(1)}` : string;

export const sortString = (a: string, b: string): number =>
  a < b ? -1 : b < a ? 1 : 0;

export const extractModule = (expression: string): string =>
  expression.substr(0, expression.lastIndexOf("."));

export const withParentheses = (x: string): string => `(${x})`;

export const validModuleName = (name: string): string => validNameUpper(name);

export const validTypeName = (name: string): string => validNameUpper(name);

export const validVariableName = (name: string): string => validNameLower(name);

export const validFieldName = (name: string): string => validNameLower(name);

export const validNameLower = (name: string): string =>
  validWord(firstToLowerCase(validNameUpper(name)));

export const validNameUpper = (name: string): string =>
  name
    .split(/[^A-Za-z0-9_]/g)
    .filter(x => !!x)
    .map(firstToUpperCase)
    .join("")
    .replace(/^_+/, "");

export const validWord = keyword =>
  elmKeywords.includes(keyword) ? `${keyword}_` : keyword;

export const nextValidName = (name: string, usedNames: string[]): string => {
  name = validWord(name);

  if (!usedNames.includes(name)) {
    usedNames.push(name);
    return name;
  } else {
    let count = 2;
    while (usedNames.includes(name + count)) {
      count++;
    }
    const name2 = name + count;
    usedNames.push(name2);
    return name2;
  }
};

const elmKeywords = [
  "as",
  "case",
  "else",
  "exposing",
  "if",
  "import",
  "in",
  "let",
  "module",
  "of",
  "port",
  "then",
  "type",
  "where"
  // "alias",
  // "command",
  // "effect",
  // "false",
  // "infix",
  // "left",
  // "non",
  // "null",
  // "right",
  // "subscription",
  // "true",
];
