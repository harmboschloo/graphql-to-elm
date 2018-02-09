import { ElmIntel, ElmIntelItem, getChild } from "./elmIntel";
import { sortString, withParentheses } from "./utils";

export const generateElm = (intel: ElmIntel): string =>
  `module ${intel.module} exposing (${generateExports(intel)})

${generateImports(intel)}


query : String
query =
    """${intel.query}"""


${generateRecordDecoders(intel)}
`;

const generateExports = (intel: ElmIntel): string =>
  Object.values(intel.recordNames)
    .sort()
    .concat(["decoder", "query"])
    .join(", ");

const generateImports = (intel: ElmIntel): string =>
  Object.keys(intel.imports)
    .sort()
    .map(name => `import ${name}`)
    .join("\n");

const generateRecordDecoders = (intel: ElmIntel): string =>
  intel.items
    .sort((a, b) => sortString(a.type, a.type))
    .map(generateRecordDecoder(intel))
    .filter(x => !!x)
    .join("\n\n\n");

const generateRecordDecoder = (intel: ElmIntel) => {
  const generatedTypes = {};

  return (item: ElmIntelItem): string => {
    if (!item.isRecordType || generatedTypes[item.type]) {
      return "";
    }

    generatedTypes[item.type] = true;

    const children = item.children
      .map(id => getChild(id, intel))
      .sort((a, b) => sortString(a.name, b.name));

    const fieldTypes = children
      .map(child => `${child.name} : ${getTypeSignature(child)}`)
      .join("\n    , ");

    const map = children.length > 1 ? children.length : "";

    const fieldDecoders = children
      .map(
        child =>
          `        (Json.Decode.field "${child.name}" ${getDecoder(child)})`
      )
      .join("\n");

    return `type alias ${item.type} =
    { ${fieldTypes}
    }


${item.decoder} : Json.Decode.Decoder ${item.type}
${item.decoder} =
    Json.Decode.map${map} ${item.type}
${fieldDecoders}`;
  };
};

const getTypeSignature = (item: ElmIntelItem): string => {
  let signature = item.type;
  let wrap = x => x;

  if (item.isListMaybe) {
    signature = `Maybe ${signature}`;
    wrap = withParentheses;
  }

  if (item.isList) {
    signature = `List ${wrap(signature)}`;
    wrap = withParentheses;
  }

  if (item.isMaybe) {
    signature = `Maybe ${wrap(signature)}`;
  }

  return signature;
};

const getDecoder = (item: ElmIntelItem): string => {
  let decoder = item.decoder;

  if (item.isListMaybe) {
    decoder = `(Json.Decode.nullable ${decoder})`;
  }

  if (item.isList) {
    decoder = `(Json.Decode.list ${decoder})`;
  }

  if (item.isMaybe) {
    decoder = `(Json.Decode.nullable ${decoder})`;
  }

  return decoder;
};