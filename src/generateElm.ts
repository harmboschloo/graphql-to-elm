import {
  ElmIntel,
  ElmIntelItem,
  ElmIntelEncodeItem,
  ElmIntelDecodeItem,
  getEncodeItemChild,
  getDecodeItemChild
} from "./elmIntel";
import { sortString, withParentheses, extractModule } from "./utils";

export const generateElm = (intel: ElmIntel): string =>
  `module ${intel.module}
    exposing
        ( ${generateExports(intel)}
        )

${generateImports(intel)}


query : String
query =
    """${intel.query}"""
${generateRecordTypesAndEncoders(intel)}${generateRecordTypesAndDecoders(intel)}
`;

const generateExports = (intel: ElmIntel): string => {
  const types: string[] = [];

  const addType = ({ type }) => {
    if (!types.includes(type)) {
      types.push(type);
    }
  };

  const addTypes = items =>
    items
      .filter(item => item.isRecordType)
      .reverse()
      .forEach(addType);

  addTypes(intel.encode.items);
  addTypes(intel.decode.items);

  const variables = ["query"];

  if (intel.encode.items.length) {
    variables.push("encodeVariables");
  }

  if (intel.decode.items.length) {
    variables.push("decoder");
  }

  return [...types, ...variables].join("\n        , ");
};

const generateImports = (intel: ElmIntel): string => {
  const imports = {};

  const addImportOf = x => {
    const module = x && extractModule(x);
    if (module) {
      imports[module] = true;
    }
  };

  intel.encode.items.forEach(item => {
    imports["Json.Encode"] = true;
    addImportOf(item.type);
    addImportOf(item.encoder);
    if (item.isNullable || item.isListOfNullables) {
      imports["GraphqlToElm.OptionalInput"] = true;
    }
  });

  intel.decode.items.forEach(item => {
    imports["Json.Decode"] = true;
    addImportOf(item.type);
    addImportOf(item.decoder);
  });

  return Object.keys(imports)
    .sort()
    .map(name => `import ${name}`)
    .join("\n");
};

const generateRecordTypesAndEncoders = (intel: ElmIntel): string => {
  const typesAndEncoders = intel.encode.items
    .sort((a, b) => a.id - b.id)
    .map(generateRecordTypeAndEncoder(intel))
    .filter(x => !!x)
    .join("\n\n\n");

  return typesAndEncoders ? `\n\n${typesAndEncoders}\n` : "";
};

const generateRecordTypeAndEncoder = (intel: ElmIntel) => (
  item: ElmIntelEncodeItem
): string => {
  if (!item.isRecordType) {
    return "";
  }

  const nullableType = "GraphqlToElm.OptionalInput.OptionalInput";
  const children = item.children.map(id => getEncodeItemChild(id, intel));

  return `${generateRecordTypeDeclaration(
    item,
    children,
    nullableType
  )}\n\n${generateRecordEncoder(item, children)}`;
};

const generateRecordEncoder = (
  item: ElmIntelEncodeItem,
  children: ElmIntelEncodeItem[]
): string => {
  const hasNullables = children.some(child => child.isNullable);

  const objectEncoder = hasNullables
    ? "GraphqlToElm.OptionalInput.encodeObject"
    : "Json.Encode.object";

  const fieldEncoders = children
    .map(
      child =>
        `( "${child.name}", ${wrapEncoder(child, hasNullables)} inputs.${
          child.fieldName
        } )`
    )
    .join("\n        , ");

  return `${item.encoder} : ${item.type} -> Json.Encode.Value
${item.encoder} inputs =
    ${objectEncoder}
        [ ${fieldEncoders}
        ]`;
};

const wrapEncoder = (
  item: ElmIntelEncodeItem,
  parentHasNullables: boolean
): string => {
  let encoder = item.encoder;

  if (item.isListOfNullables) {
    encoder = `(GraphqlToElm.OptionalInput.encodeList ${encoder})`;
  } else if (item.isList) {
    encoder = `(List.map ${encoder} >> Json.Encode.list)`;
  }

  if (parentHasNullables) {
    if (item.isNullable) {
      encoder = `(GraphqlToElm.OptionalInput.map ${encoder})`;
    } else {
      encoder = `(${encoder} >> GraphqlToElm.OptionalInput.Present)`;
    }
  }

  return encoder;
};

const generateRecordTypesAndDecoders = (intel: ElmIntel): string => {
  const typesAndDecoders = intel.decode.items
    .sort((a, b) => a.id - b.id)
    .map(generateRecordTypeAndDecoder(intel))
    .filter(x => !!x)
    .join("\n\n\n");

  return typesAndDecoders ? `\n\n${typesAndDecoders}` : "";
};

const generateRecordTypeAndDecoder = (intel: ElmIntel) => {
  const generatedTypes = {};

  return (item: ElmIntelDecodeItem): string => {
    if (!item.isRecordType || generatedTypes[item.type]) {
      return "";
    }

    generatedTypes[item.type] = true;

    const nullableType = "Maybe.Maybe";
    const children = item.children.map(id => getDecodeItemChild(id, intel));

    return `${generateRecordTypeDeclaration(
      item,
      children,
      nullableType
    )}\n\n${generateRecordDecoder(item, children)}`;
  };
};

const generateRecordDecoder = (
  item: ElmIntelDecodeItem,
  children: ElmIntelDecodeItem[]
): string => {
  const map = children.length > 1 ? children.length : "";

  const fieldDecoders = children
    .map(
      child =>
        `        (Json.Decode.field "${child.name}" ${wrapDecoder(child)})`
    )
    .join("\n");

  return `${item.decoder} : Json.Decode.Decoder ${item.type}
${item.decoder} =
    Json.Decode.map${map} ${item.type}
${fieldDecoders}`;
};

const wrapDecoder = (item: ElmIntelDecodeItem): string => {
  let decoder = item.decoder;

  if (item.isListOfNullables) {
    decoder = `(Json.Decode.nullable ${decoder})`;
  }

  if (item.isList) {
    decoder = `(Json.Decode.list ${decoder})`;
  }

  if (item.isNullable) {
    decoder = `(Json.Decode.nullable ${decoder})`;
  }

  return decoder;
};

const generateRecordTypeDeclaration = (
  item: ElmIntelItem,
  children: ElmIntelItem[],
  nullableType: string
): string => {
  const fieldTypes = children
    .map(child => `${child.fieldName} : ${wrapType(child, nullableType)}`)
    .join("\n    , ");

  return `type alias ${item.type} =
    { ${fieldTypes}
    }
`;
};

const wrapType = (item: ElmIntelItem, nullableType: string): string => {
  let signature = item.type;
  let wrap = x => x;

  if (item.isListOfNullables) {
    signature = `${nullableType} ${signature}`;
    wrap = withParentheses;
  }

  if (item.isList) {
    signature = `List ${wrap(signature)}`;
    wrap = withParentheses;
  }

  if (item.isNullable) {
    signature = `${nullableType} ${wrap(signature)}`;
  }

  return signature;
};
