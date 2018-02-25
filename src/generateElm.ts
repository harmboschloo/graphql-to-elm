import {
  ElmIntel,
  ElmIntelItem,
  ElmIntelEncodeItem,
  ElmIntelDecodeItem
} from "./elmIntelTypes";
import {
  sortString,
  withParentheses,
  extractModule,
  findByIdIn
} from "./utils";

export const generateElm = (intel: ElmIntel): string =>
  `module ${intel.module}
    exposing
        ( ${generateExports(intel)}
        )

${generateImports(intel)}


${generatePost(intel)}


query : String
query =
    """${intel.query}"""
${generateTypesAndEncoders(intel)}${generateTypesAndDecoders(intel)}
`;

const generateExports = (intel: ElmIntel): string => {
  const types: string[] = [];

  const addType = (value: string) => {
    if (!types.includes(value)) {
      types.push(value);
    }
  };

  const addTypes = (items: ElmIntelItem[]) =>
    items
      .slice()
      .reverse()
      .forEach(item => {
        if (item.kind === "record") {
          addType(item.type);
        } else if (item.kind === "union") {
          addType(`${item.type}(..)`);
        }
      });

  addTypes(intel.encode.items);
  addTypes(intel.decode.items);

  const variables = ["query"];

  if (intel.encode.items.length) {
    variables.push("encodeVariables");
  }

  if (intel.decode.items.length) {
    variables.unshift("post");
    variables.push("decoder");
  }

  return [...types, ...variables].join("\n        , ");
};

const generateImports = (intel: ElmIntel): string => {
  const imports = { "Json.Encode": true };

  const addImportOf = x => {
    const module = x && extractModule(x);
    if (module) {
      imports[module] = true;
    }
  };

  intel.encode.items.forEach(item => {
    addImportOf(item.type);
    addImportOf(item.encoder);
    if (item.isNullable || item.isListOfNullables) {
      imports["GraphqlToElm.Optional"] = true;
    }
  });

  intel.decode.items.forEach(item => {
    imports["Json.Decode"] = true;
    imports["GraphqlToElm.Http"] = true;
    addImportOf(item.type);
    addImportOf(item.decoder);
    if (item.isOptional) {
      imports["GraphqlToElm.Optional"] = true;
    }
  });

  return Object.keys(imports)
    .sort()
    .map(name => `import ${name}`)
    .join("\n");
};

const generatePost = (intel: ElmIntel): string => {
  const dataItem = intel.decode.items.find(item => item.id === 0);
  if (!dataItem) {
    return "";
  }

  const variablesItem = intel.encode.items.find(item => item.id === 0);

  if (variablesItem) {
    return `post : String -> ${
      variablesItem.type
    } -> GraphqlToElm.Http.Request ${dataItem.type}
post url variables =
    GraphqlToElm.Http.post
        url
        { query = query
        , variables = ${variablesItem.encoder} variables
        }
        ${dataItem.decoder}`;
  } else {
    return `post : String -> GraphqlToElm.Http.Request ${dataItem.type}
post url =
    GraphqlToElm.Http.post
        url
        { query = query
        , variables = Json.Encode.null
        }
        ${dataItem.decoder}`;
  }
};

const generateTypesAndEncoders = (intel: ElmIntel): string => {
  const typesAndEncoders = intel.encode.items
    .sort((a, b) => a.id - b.id)
    .map(generateTypeAndEncoder(intel))
    .filter(x => !!x)
    .join("\n\n\n");

  return typesAndEncoders ? `\n\n${typesAndEncoders}\n` : "";
};

const generateTypeAndEncoder = (intel: ElmIntel) => {
  const generatedTypes = {};

  return (item: ElmIntelEncodeItem): string => {
    if (generatedTypes[item.type]) {
      return "";
    }
    generatedTypes[item.type] = true;

    if (item.kind === "record") {
      const children = item.children.map(findByIdIn(intel.encode.items));

      return `${generateRecordTypeDeclaration(
        item,
        children
      )}\n\n\n${generateRecordEncoder(item, children)}`;
    }

    return "";
  };
};

const generateRecordEncoder = (
  item: ElmIntelEncodeItem,
  children: ElmIntelEncodeItem[]
): string => {
  const hasNullables = children.some(child => child.isNullable);

  const objectEncoder = hasNullables
    ? "GraphqlToElm.Optional.encodeObject"
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
    encoder = `(GraphqlToElm.Optional.encodeList ${encoder})`;
  } else if (item.isList) {
    encoder = `(List.map ${encoder} >> Json.Encode.list)`;
  }

  if (parentHasNullables) {
    if (item.isNullable) {
      encoder = `(GraphqlToElm.Optional.map ${encoder})`;
    } else {
      encoder = `(${encoder} >> GraphqlToElm.Optional.Present)`;
    }
  }

  return encoder;
};

const generateTypesAndDecoders = (intel: ElmIntel): string => {
  const typesAndDecoders = intel.decode.items
    .sort((a, b) => a.id - b.id)
    .map(generateTypeAndDecoder(intel))
    .filter(x => !!x)
    .join("\n\n\n");

  return typesAndDecoders ? `\n\n${typesAndDecoders}` : "";
};

const generateTypeAndDecoder = (intel: ElmIntel) => {
  const generatedTypes = {};

  return (item: ElmIntelDecodeItem): string => {
    if (generatedTypes[item.type]) {
      return "";
    }
    generatedTypes[item.type] = true;

    if (item.kind === "record") {
      const children = item.children.map(findByIdIn(intel.decode.items));

      return `${generateRecordTypeDeclaration(
        item,
        children
      )}\n\n\n${generateRecordDecoder(item, children)}`;
    } else if (item.kind === "union") {
      const children = item.children
        .map(findByIdIn(intel.decode.items))
        .sort((a, b) => b.children.length - a.children.length);

      const constructors = children.map(
        child => `On${child.type} ${child.type}`
      );
      const typeDeclaration = `type ${item.type}\n    = ${constructors.join(
        "\n    | "
      )}`;

      const decoderDeclaration = `${item.decoder} : Json.Decode.Decoder ${
        item.type
      }`;
      const childDecoders = children.map(
        child => `Json.Decode.map On${child.type} ${child.decoder}`
      );
      const decoder = `${
        item.decoder
      } =\n    Json.Decode.oneOf\n        [ ${childDecoders.join(
        "\n        , "
      )}\n        ]`;

      return `${typeDeclaration}\n\n\n${decoderDeclaration}\n${decoder}`;
    }

    return "";
  };
};

const generateRecordTypeDeclaration = (
  item: ElmIntelItem,
  children: ElmIntelItem[]
): string => {
  if (children.length > 0) {
    const fieldTypes = children.map(
      child => `${child.fieldName} : ${wrappedType(child)}`
    );

    return `type alias ${item.type} =\n    { ${fieldTypes.join(
      "\n    , "
    )}\n    }`;
  } else {
    return `type alias ${item.type} =\n    {}`;
  }
};

export const wrappedType = (item: ElmIntelItem): string => {
  let signature = item.type;
  let wrap = x => x;

  if (item.isListOfNullables && item.isListOfOptionals) {
    signature = `GraphqlToElm.Optional.Optional ${signature}`;
    wrap = withParentheses;
  } else if (item.isListOfNullables || item.isListOfOptionals) {
    signature = `Maybe.Maybe ${signature}`;
    wrap = withParentheses;
  }

  if (item.isList) {
    signature = `List ${wrap(signature)}`;
    wrap = withParentheses;
  }

  if (item.isNullable && item.isOptional) {
    signature = `GraphqlToElm.Optional.Optional ${wrap(signature)}`;
  } else if (item.isNullable || item.isOptional) {
    signature = `Maybe.Maybe ${wrap(signature)}`;
  }

  return signature;
};

const generateRecordDecoder = (
  item: ElmIntelDecodeItem,
  children: ElmIntelDecodeItem[]
): string => {
  const declaration = `${item.decoder} : Json.Decode.Decoder ${item.type}`;

  if (children.length > 0) {
    const map = children.length > 1 ? children.length : "";

    const fieldDecoders = children.map(
      child =>
        `        (${fieldDecoder(child)} "${child.name}" ${wrapDecoder(child)})`
    );

    return `${declaration}\n${item.decoder} =\n    Json.Decode.map${map} ${
      item.type
    }\n${fieldDecoders.join("\n")}`;
  } else {
    return `${declaration}\n${item.decoder} =
    Json.Decode.keyValuePairs Json.Decode.value
        |> Json.Decode.andThen
            (\\pairs ->
                if List.isEmpty pairs then
                    Json.Decode.succeed Flip
                else
                    Json.Decode.fail "expected empty object"
            )`;
  }
};

const fieldDecoder = (item: ElmIntelDecodeItem): string => {
  if (item.isOptional) {
    if (item.isNullable) {
      return "GraphqlToElm.Optional.fieldDecoder";
    } else {
      return "GraphqlToElm.Optional.nonNullfieldDecoder";
    }
  } else {
    return "Json.Decode.field";
  }
};

const wrapDecoder = (item: ElmIntelDecodeItem): string => {
  let decoder = item.decoder;

  if (item.isListOfNullables) {
    decoder = `(Json.Decode.nullable ${decoder})`;
  }

  if (item.isList) {
    decoder = `(Json.Decode.list ${decoder})`;
  }

  if (item.isNullable && !item.isOptional) {
    decoder = `(Json.Decode.nullable ${decoder})`;
  }

  return decoder;
};
