import * as test from "tape";
import * as options from "../../../src/gen/options";

const finalizeOptions = (opts?: any): any => options.finalizeOptions(opts);

export const testOptions = () => {
  test("# options test #", (t) => {
    t.test("options", (t) => {
      t.throws(() => finalizeOptions(), /options.*object/, "not undefined");
      t.end();
    });

    t.test("schema", (t) => {
      t.throws(() => finalizeOptions({}), /schema.*string/, "not undefined");

      t.throws(
        () => finalizeOptions({ schema: { string: 123 } }),
        /schema.*SchemaString/,
        "invalid schema string"
      );

      t.end();
    });

    t.test("enums", (t) => {
      t.throws(
        () => finalizeOptions({ schema: "", queries: [], enums: null }),
        /enums.*object/,
        "invalid enums"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            enums: { baseModule: 1 },
          }),
        /enums.baseModule.*string/,
        "invalid enums.baseModule"
      );

      t.end();
    });

    t.test("queries", (t) => {
      t.throws(
        () => finalizeOptions({ schema: "" }),
        /queries.*array/,
        "not undefined"
      );

      t.throws(
        () => finalizeOptions({ schema: "", queries: [1] }),
        /queries.*strings/,
        "invalid query"
      );

      t.end();
    });

    t.test("scalarEncoders", (t) => {
      t.throws(
        () =>
          finalizeOptions({ schema: "", queries: [], scalarEncoders: null }),
        /scalarEncoders.*object/,
        "not object"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            scalarEncoders: { Type: { type: "", decoder: "" } },
          }),
        /scalarEncoders.*TypeEncoder/,
        "invalid field"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            scalarEncoders: { Type: { type: 1, encoder: "" } },
          }),
        /scalarEncoders.*TypeEncoder/,
        "invalid type"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            scalarEncoders: { Type: { type: "", encoder: 1 } },
          }),
        /scalarEncoders.*TypeEncoder/,
        "invalid encoder"
      );

      t.end();
    });

    t.test("enumEncoders", (t) => {
      t.throws(
        () => finalizeOptions({ schema: "", queries: [], enumEncoders: null }),
        /enumEncoders.*object/,
        "not object"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            enumEncoders: { Type: { type: "", decoder: "" } },
          }),
        /enumEncoders.*TypeEncoder/,
        "invalid field"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            enumEncoders: { Type: { type: 1, encoder: "" } },
          }),
        /enumEncoders.*TypeEncoder/,
        "invalid type"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            enumEncoders: { Type: { type: "", encoder: 1 } },
          }),
        /enumEncoders.*TypeEncoder/,
        "invalid encoder"
      );

      t.end();
    });

    t.test("scalarDecoders", (t) => {
      t.throws(
        () =>
          finalizeOptions({ schema: "", queries: [], scalarDecoders: null }),
        /scalarDecoders.*object/,
        "not object"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            scalarDecoders: { Type: { type: "", encoder: "" } },
          }),
        /scalarDecoders.*TypeDecoder/,
        "invalid field"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            scalarDecoders: { Type: { type: 1, decoder: "" } },
          }),
        /scalarDecoders.*TypeDecoder/,
        "invalid type"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            scalarDecoders: { Type: { type: "", decoder: 1 } },
          }),
        /scalarDecoders.*TypeDecoder/,
        "invalid decoder"
      );

      t.end();
    });

    t.test("enumDecoders", (t) => {
      t.throws(
        () => finalizeOptions({ schema: "", queries: [], enumDecoders: null }),
        /enumDecoders.*object/,
        "not object"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            enumDecoders: { Type: { type: "", encoder: "" } },
          }),
        /enumDecoders.*TypeDecoder/,
        "invalid field"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            enumDecoders: { Type: { type: 1, decoder: "" } },
          }),
        /enumDecoders.*TypeDecoder/,
        "invalid type"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            enumDecoders: { Type: { type: "", decoder: 1 } },
          }),
        /enumDecoders.*TypeDecoder/,
        "invalid decoder"
      );

      t.end();
    });

    t.test("errorsDecoder", (t) => {
      t.throws(
        () => finalizeOptions({ schema: "", queries: [], errorsDecoder: null }),
        /errorsDecoder.*TypeDecoder/,
        "not object"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            errorsDecoder: { type: "", encoder: "" },
          }),
        /errorsDecoder.*TypeDecoder/,
        "invalid field"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            errorsDecoder: { type: 1, decoder: "" },
          }),
        /errorsDecoder.*TypeDecoder/,
        "invalid type"
      );

      t.throws(
        () =>
          finalizeOptions({
            schema: "",
            queries: [],
            errorsDecoder: { type: "", decoder: 1 },
          }),
        /errorsDecoder.*TypeDecoder/,
        "invalid decoder"
      );

      t.end();
    });

    t.test("src", (t) => {
      t.throws(
        () => finalizeOptions({ schema: "", queries: [], src: null }),
        /src.*string/,
        "not string"
      );
      t.end();
    });

    t.test("dest", (t) => {
      t.throws(
        () => finalizeOptions({ schema: "", queries: [], dest: null }),
        /dest.*string/,
        "not string"
      );
      t.end();
    });

    t.test("operationKind", (t) => {
      t.throws(
        () =>
          finalizeOptions({ schema: "", queries: [], operationKind: "test" }),
        /operationKind.*query.*named/,
        "not 'query' or 'named'"
      );
      t.end();
    });

    t.test("log", (t) => {
      t.throws(
        () => finalizeOptions({ schema: "", queries: [], log: "" }),
        /log.*null.*function/,
        "not 'null' or function"
      );
      t.end();
    });

    t.end();
  });
};
