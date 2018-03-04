export interface ElmIntel {
  dest: string;
  module: string;
  query: string;
  usedNames: string[];
  typesBySignature: { [signature: string]: string };
  encode: {
    items: ElmEncodeItem[];
    encodersByType: { [type: string]: string };
  };
  decode: {
    items: ElmDecodeItem[];
    decodersByType: { [type: string]: string };
  };
}

export interface ElmItem {
  id: number;
  name: string;
  queryTypename: string;
  fieldName: string;
  order: number;
  children: number[];
  isOptional: boolean;
  isListOfOptionals: boolean;
  isNullable: boolean;
  isList: boolean;
  isListOfNullables: boolean;
  type: string;
  kind: ElmIntelItemKind;
}

export type ElmIntelItemKind =
  | "record"
  | "union"
  | "union-on"
  | "enum"
  | "scalar"
  | "empty";

export interface ElmEncodeItem extends ElmItem {
  encoder: string;
}

export interface ElmDecodeItem extends ElmItem {
  decoder: string;
  unionConstructor: string;
}
