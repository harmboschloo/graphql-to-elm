export const log = (message: string): void => {
  // console.log("[Debug]", debugPadding(), message);
};

let debugIndent = 0;

export const addLogIndent = (indent: number) => (debugIndent += indent);

const debugPadding = () => "   ".repeat(debugIndent);
