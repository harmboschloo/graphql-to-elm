import * as path from "path";
import { GraphQLSchema, GraphQLNamedType, GraphQLEnumType } from "graphql";
import {
  FinalOptions,
  TypeDecoders,
  TypeDecoder,
  TypeEncoders,
  TypeEncoder
} from "./options";
import { validTypeName, validTypeConstructorName } from "./elmUtils";

export interface EnumIntel {
  gqlType: GraphQLEnumType;
  module: string;
  typeName: string;
  values: EnumValue[];
  encoder: TypeEncoder;
  decoder: TypeDecoder;
  dest: string;
}

interface EnumValue {
  gqlValue: string;
  value: string;
}

export const getIntel = (
  schema: GraphQLSchema,
  options: FinalOptions
): EnumIntel[] => {
  const gqlTypes: {
    [gqlTypeName: string]: GraphQLNamedType;
  } = schema.getTypeMap();

  return Object.keys(gqlTypes).reduce(
    (enums: EnumIntel[], typeName: string) => {
      const gqlType: GraphQLNamedType = gqlTypes[typeName];

      if (gqlType instanceof GraphQLEnumType) {
        const typeName: string = validTypeName(gqlType.name);
        const values: EnumValue[] = gqlType.getValues().map(value => ({
          gqlValue: value.name,
          value: validTypeConstructorName(value.name)
        }));

        const module: string = `${options.enums.baseModule}.${typeName}`;
        const moduleParts: string[] = module.split(".");
        const dest: string =
          path.resolve(options.dest, ...moduleParts) + ".elm";
        const encoder: TypeEncoder = {
          type: `${module}.${typeName}`,
          encoder: `${module}.encode`
        };
        const decoder: TypeDecoder = {
          type: `${module}.${typeName}`,
          decoder: `${module}.decoder`
        };

        const intel: EnumIntel = {
          gqlType,
          module,
          typeName,
          values,
          encoder,
          decoder,
          dest
        };

        return [...enums, intel];
      }

      return enums;
    },
    []
  );
};

export const getEncoders = (enums: EnumIntel[]): TypeEncoders =>
  enums.reduce(
    (encoders, intel) => ({ ...encoders, [intel.gqlType.name]: intel.encoder }),
    {}
  );

export const getDecoders = (enums: EnumIntel[]): TypeDecoders =>
  enums.reduce(
    (decoders, intel) => ({ ...decoders, [intel.gqlType.name]: intel.decoder }),
    {}
  );

export const generateElm = ({ module, typeName, values }: EnumIntel): string =>
  `module ${module} exposing
    ( ${typeName}(..)
    , decoder
    , encode
    , fromString
    , toString
    )

import Json.Decode
import Json.Encode


type ${typeName}
    = ${values.map(x => x.value).join("\n    | ")}


encode : ${typeName} -> Json.Encode.Value
encode value =
    Json.Encode.string (toString value)


decoder : Json.Decode.Decoder ${typeName}
decoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\\value ->
                value
                    |> fromString
                    |> Maybe.map Json.Decode.succeed
                    |> Maybe.withDefault
                        (Json.Decode.fail <| "unknown ${typeName} " ++ value)
            )


toString : ${typeName} -> String
toString value =
    case value of
        ${values
          .map(x => `${x.value} ->\n            "${x.gqlValue}"`)
          .join("\n\n        ")}


fromString : String -> Maybe ${typeName}
fromString value =
    case value of
        ${values
          .map(x => `"${x.gqlValue}" ->\n            Just ${x.value}`)
          .join("\n\n        ")}

        _ ->
            Nothing
`;
