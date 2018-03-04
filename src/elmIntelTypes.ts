export interface ElmIntel {
  dest: string;
  module: string;
  query: string;
  usedNames: string[];
  typesBySignature: { [signature: string]: string };
  encode: {
    items: ElmIntelEncodeItem[];
    encodersByType: { [type: string]: string };
  };
  decode: {
    items: ElmIntelDecodeItem[];
    decodersByType: { [type: string]: string };
  };
}

export interface ElmIntelItem {
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

export interface ElmIntelEncodeItem extends ElmIntelItem {
  encoder: string;
}

export interface ElmIntelDecodeItem extends ElmIntelItem {
  decoder: string;
  unionConstructor: string;
}
