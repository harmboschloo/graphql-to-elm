export const firstToUpperCase = (string: string): string =>
  string ? `${string.charAt(0).toUpperCase()}${string.slice(1)}` : string;

export const firstToLowerCase = (string: string): string =>
  string ? `${string.charAt(0).toLowerCase()}${string.slice(1)}` : string;

export const sortString = (a: string, b: string): number =>
  a < b ? -1 : b < a ? 1 : 0;

export const withParentheses = (x: string): string => `(${x})`;
