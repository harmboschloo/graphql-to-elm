export interface Options {
  schema: string;
  queries: string[];
  src?: string;
  dest?: string;
  log?: (message: string) => void;
}

export const log = (message: string, options: Options): void =>
  options.log && options.log(message);

export const logDebug = (message: string, options: Options): void =>
  options.log && options.log(`[DEBUG] ${debugPadding()}${message}`);

let debugIndent = 0;

export const logDebugAddIndent = (indent: number) => (debugIndent += indent);

const debugPadding = () => "   ".repeat(debugIndent);
