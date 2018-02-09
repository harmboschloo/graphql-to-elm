export const firstToUpperCase = (string: string): string =>
  string ? `${string.charAt(0).toUpperCase()}${string.slice(1)}` : string;

export const firstToLowerCase = (string: string): string =>
  string ? `${string.charAt(0).toLowerCase()}${string.slice(1)}` : string;

export const sortString = (a: string, b: string): number =>
  a < b ? -1 : b < a ? 1 : 0;

export const withParentheses = (x: string): string => `(${x})`;

export const validModuleName = name =>
  name
    .split(/[^A-Za-z0-9_]/g)
    .filter(x => !!x)
    .map(firstToUpperCase)
    .join("")
    .replace(/^_+/, "");

export const validTypeName = name =>
  name
    .split(/[^A-Za-z0-9_]/g)
    .filter(x => !!x)
    .map(firstToUpperCase)
    .join("")
    .replace(/^_+/, "");

export const validVariableName = name =>
  name
    .split(/[^A-Za-z0-9_]/g)
    .filter(x => !!x)
    .map(firstToLowerCase)
    .join("")
    .replace(/^_+/, "");
