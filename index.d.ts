export as namespace graphqlToElm;
import { Options } from "./src/options";
export {
  Options,
  EnumOptions,
  TypeEncoders,
  TypeEncoder,
  TypeDecoders,
  TypeDecoder
} from "./src/options";
export declare const graphqlToElm: (options: Options) => void;
export default graphqlToElm;
