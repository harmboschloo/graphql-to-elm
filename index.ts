import { readFileSync, writeFileSync } from "fs";
import * as path from "path";
import {
  GraphQLSchema,
  GraphQLOutputType,
  GraphQLNullableType,
  GraphQLNamedType,
  buildSchema,
  validate,
  parse,
  visit,
  visitWithTypeInfo,
  TypeInfo,
  Kind,
  isCompositeType,
  isListType,
  isScalarType,
  isLeafType,
  isNullableType,
  getNamedType,
  getNullableType
} from "graphql";

export interface Options {
  schema: string;
  queries: string[];
}

export const graphqlToElm = (options: Options): void => {
  console.log("reading", options.schema);
  const schema = buildSchema(readFileSync(options.schema, "utf-8"));
  options.queries.forEach(queryToElm(schema, options));
  console.log("done");
};

const queryToElm = (schema: GraphQLSchema, options: Options) => (
  src: string
): void => {
  console.log("reading", src);
  const query = readFileSync(src, "utf-8").trim();
  const queryDocument = parse(query);

  const errors = validate(schema, queryDocument);
  if (errors.length > 0) {
    throw errors[0];
  }

  const typeInfo = new TypeInfo(schema);
  const visitor = queryVisitor({ src, query, typeInfo });

  visit(queryDocument, visitWithTypeInfo(typeInfo, visitor));

  const queryIntel = visitor.intel();
  const elmIntel = queryToElmIntel(queryIntel);
  const elm = generateElm(elmIntel);

  console.log("writing", elmIntel.dest);
  writeFileSync(elmIntel.dest, elm, "utf-8");

  // writeFileSync(
  //   `${src}.queryIntell.json`,
  //   JSON.stringify(queryIntel, null, "\t"),
  //   "utf-8"
  // );

  // writeFileSync(
  //   `${src}.elmIntell.json`,
  //   JSON.stringify(elmIntel, null, "\t"),
  //   "utf-8"
  // );
};

////////////////////////////////////////////////////////////////////////////////
// Query Intel                                                                //
////////////////////////////////////////////////////////////////////////////////

interface QueryIntel {
  src: string;
  query: string;
  items: QueryIntelItem[];
  parentStack: QueryIntelItem[];
}

interface QueryIntelItem {
  id: number;
  type: GraphQLOutputType;
  name: string;
  depth: number;
  children: number[];
}

const queryVisitor = ({
  src,
  query,
  typeInfo
}: {
  src: string;
  query: string;
  typeInfo: TypeInfo;
}) => {
  const intel: QueryIntel = {
    src,
    query,
    items: [],
    parentStack: []
  };

  const getParentItem = () => {
    if (intel.parentStack.length > 0) {
      return intel.parentStack[intel.parentStack.length - 1];
    }
  };

  const isItemNode = node => {
    const { kind } = node;
    const type = typeInfo.getType();
    const nullableType = getNullableType(type);
    const namedType = getNamedType(type);
    return (
      (kind == Kind.OPERATION_DEFINITION || kind == Kind.FIELD) &&
      (isListType(nullableType) ||
        isCompositeType(namedType) ||
        isLeafType(namedType))
    );
  };

  // let indent = 0;
  // let pad = "";

  return {
    intel() {
      return intel;
    },
    enter(node) {
      // pad += "  ";

      // console.log(pad, "enter", node.kind, node.value);
      // console.log(pad, "type", typeInfo.getType());
      // console.log(pad, "name", node.name);
      // console.log("isNullableType", isNullableType(typeInfo.getType()));
      // console.log("nullableType", getNullableType(typeInfo.getType()));
      // console.log("fieldDef", typeInfo.getFieldDef());
      // console.log("inputType", typeInfo.getInputType());
      // console.log("selections", node.selections && node.selections.length);
      // console.log("node", node);

      if (isItemNode(node)) {
        const item = {
          id: intel.items.length,
          type: typeInfo.getType(),
          name: node.name && node.name.value,
          depth: intel.parentStack.length,
          children: []
        };

        const parent = getParentItem();
        if (parent) {
          parent.children.push(item.id);
        }

        intel.items.push(item);
        intel.parentStack.push(item);
      }
    },
    leave(node) {
      // console.log(pad, "leave", node.kind);

      if (isItemNode(node)) {
        intel.parentStack.pop();
      }

      // pad = pad.slice(0, -2);
    }
  };
};

////////////////////////////////////////////////////////////////////////////////
// Elm Intel                                                                  //
////////////////////////////////////////////////////////////////////////////////

interface ElmIntel {
  dest: string;
  module: string;
  query: string;
  items: ElmIntelItem[];
  names: {};
  recordNames: {};
  recordDecoderNames: {};
  imports: {};
}

interface ElmIntelItem {
  id: number;
  name: string;
  depth: number;
  children: number[];
  isMaybe: boolean;
  isList: boolean;
  isListMaybe: boolean;
  type: string;
  isRecordType: boolean;
  decoder: string;
}

const queryToElmIntel = ({ src, query, items }: QueryIntel): ElmIntel => {
  const srcInfo = path.parse(src);

  const moduleParts = srcInfo.dir
    .split(/[\\/]/)
    .filter(x => !!x)
    .concat(srcInfo.name)
    .map(firstToUpperCase);

  const module = moduleParts.join(".");

  const dest = path.resolve(...moduleParts) + ".elm";

  return items
    .sort((a, b) => b.depth - a.depth || b.id - a.id)
    .reduce(getElmIntel, {
      dest,
      module,
      query,
      items: [],
      names: reservedNames,
      recordNames: {},
      recordDecoderNames: {},
      imports: {}
    });
};

const getElmIntel = (intel: ElmIntel, queryItem: QueryIntelItem): ElmIntel => {
  const nullableType: GraphQLNullableType = getNullableType(queryItem.type);
  const namedType: GraphQLNamedType = getNamedType(queryItem.type);

  const id = queryItem.id;
  const name = queryItem.name;
  const depth = queryItem.depth;
  const children = queryItem.children;
  const isMaybe = isNullableType(queryItem.type);
  const isList = isListType(nullableType);
  const isListMaybe = isList && isNullableType(nullableType.ofType);
  let type;
  let isRecordType;
  let decoder;

  if (isCompositeType(namedType)) {
    isRecordType = true;
    if (id === 0) {
      type = "Data";
      decoder = "decoder";
      intel.recordNames[""] = type;
      intel.recordDecoderNames[type] = decoder;
    } else {
      type = getRecordTypeName(namedType.toString(), children, intel);
      decoder = getRecordDecoderName(type, intel);
    }
  } else if (isScalarType(nullableType)) {
    isRecordType = false;

    switch (nullableType.name) {
      case "Int":
        type = "Int";
        decoder = "Json.Decode.int";
        addImport("Json.Decode", intel);
        break;
      case "Float":
        type = "Float";
        decoder = "Json.Decode.float";
        addImport("Json.Decode", intel);
        break;
      case "Boolean":
        type = "Bool";
        decoder = "Json.Decode.bool";
        addImport("Json.Decode", intel);
        break;
      case "String":
        type = "String";
        decoder = "Json.Decode.string";
        addImport("Json.Decode", intel);
        break;
      case "ID": // FIXME
        type = "String";
        decoder = "Json.Decode.string";
        addImport("Json.Decode", intel);
        break;
      default:
        throw new Error(`Unhandled query scalar type: ${queryItem.type}`);
    }
  } else {
    throw new Error(`Unhandled query type: ${queryItem.type}`);
  }

  return addItem(
    {
      id,
      name,
      depth,
      children,
      isMaybe,
      isList,
      isListMaybe,
      type,
      isRecordType,
      decoder
    },
    intel
  );
};

const reservedWords = [
  "if",
  "then",
  "else",
  "case",
  "of",
  "let",
  "in",
  "type",
  "module",
  "where",
  "import",
  "exposing",
  "as",
  "port"
];

const reservedNames = ["Data", "query", "decoder"]
  .concat(reservedWords)
  .reduce((names, name) => ({ ...names, [name]: true }), {});

const addItem = (item: ElmIntelItem, intel: ElmIntel): ElmIntel => ({
  ...intel,
  items: intel.items.concat(item)
});

const getChild = (id: number, intel: ElmIntel): ElmIntelItem => {
  const child = intel.items.find(item => item.id === id);
  if (!child) {
    throw new Error(`Could not find child item with id: ${id}`);
  }
  return child;
};

const getName = (name: string, intel: ElmIntel): string => {
  if (!intel.names[name]) {
    intel.names[name] = true;
    return name;
  } else {
    let count = 2;
    while (intel.names[name + count]) {
      count++;
    }
    const name2 = name + count;
    intel.names[name2] = true;
    return name2;
  }
};

const getRecordTypeName = (
  type: string,
  children: number[],
  intel: ElmIntel
): string => {
  const propertyNames = children
    .map(id => getChild(id, intel).name)
    .sort()
    .join(",");

  const signature = `${type}: ${propertyNames}`;

  if (intel.recordNames[signature]) {
    return intel.recordNames[signature];
  } else {
    const name = getName(firstToUpperCase(type), intel);
    intel.recordNames[signature] = name;
    return name;
  }
};

const getRecordDecoderName = (type: string, intel: ElmIntel) => {
  if (intel.recordDecoderNames[type]) {
    return intel.recordDecoderNames[type];
  } else {
    const name = getName(`${firstToLowerCase(type)}Decoder`, intel);
    intel.recordDecoderNames[type] = name;
    return name;
  }
};

const addImport = (name: string, intel: ElmIntel) => {
  intel.imports[name] = true;
};

////////////////////////////////////////////////////////////////////////////////
// Generate Elm                                                               //
////////////////////////////////////////////////////////////////////////////////

const generateElm = (intel: ElmIntel): string =>
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

////////////////////////////////////////////////////////////////////////////////
// Utils                                                                      //
////////////////////////////////////////////////////////////////////////////////

const firstToUpperCase = (string: string): string =>
  string ? `${string.charAt(0).toUpperCase()}${string.slice(1)}` : string;

const firstToLowerCase = (string: string): string =>
  string ? `${string.charAt(0).toLowerCase()}${string.slice(1)}` : string;

const sortString = (a, b) => (a < b ? -1 : b < a ? 1 : 0);

const withParentheses = x => `(${x})`;
