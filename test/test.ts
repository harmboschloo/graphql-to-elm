import { resolve, dirname } from "path";
import * as glob from "glob";

glob.sync(resolve(__dirname, "*/test.ts")).map(file => {
  console.log("[Start Test] ", file);
  process.chdir(dirname(file));
  require(file);
  console.log("[End Test] ", file);
});
