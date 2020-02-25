export as namespace graphqlToElm;
import { Options } from "./src/gen/options";
export {
  Options,
  SchemaString,
  EnumOptions,
  TypeEncoders,
  TypeEncoder,
  TypeDecoders,
  TypeDecoder
} from "./src/gen/options";
export declare const graphqlToElm: (options: Options) => Promise<void>;
export default graphqlToElm;
