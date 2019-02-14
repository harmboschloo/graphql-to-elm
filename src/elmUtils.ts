import { firstToUpperCase, firstToLowerCase } from "./utils";

export const validModuleName = (name: string): string => validNameUpper(name);

export const validTypeName = (name: string): string => validNameUpper(name);

export const validTypeConstructorName = (name: string): string =>
  validNameUpper(name);

export const validVariableName = (name: string): string => validNameLower(name);

export const validFieldName = (name: string): string => validNameLower(name);

export const validNameLower = (name: string): string =>
  validWord(firstToLowerCase(validNameUpper(name)));

export const validNameUpper = (name: string): string => {
  const isAllUpperCase = name.match(/[^A-Z0-9_]/) === null;

  const validName = isAllUpperCase
    ? name
        .replace(/_(_*)/g, "-$1-")
        .split(/[^A-Z0-9_]/g)
        .filter(isEmpty)
        .map(x => x.toLowerCase())
        .map(firstToUpperCase)
        .join("")
    : name
        .split(/[^A-Za-z0-9_]/g)
        .filter(isEmpty)
        .map(firstToUpperCase)
        .join("");

  const startUnderscores = (name.match(/^_+/) || [""])[0];

  return validName.replace(/^_+/, "") + startUnderscores;
};

const isEmpty = (string: string): boolean => !!string;

// const appendUnderscores = (name: string, originalName: string) => {
//   const matches = originalName.match(/^_+/g);
//   return matches ? name + matches[0] : name;
// };

export const validWord = (keyword: string) =>
  elmKeywords.includes(keyword) ? `${keyword}_` : keyword;

export const elmKeywords = [
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

export const findUnusedName = (name: string, usedNames: string[]): string => {
  name = validWord(name);

  if (!usedNames.includes(name)) {
    return name;
  } else {
    let count = 2;
    while (usedNames.includes(name + count)) {
      count++;
    }
    const name2 = name + count;
    return name2;
  }
};

export const newUnusedName = (name: string, usedNames: string[]): string => {
  const newName = findUnusedName(name, usedNames);
  usedNames.push(newName);
  return newName;
};
