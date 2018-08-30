import { spawn } from "child_process";
import * as test from "tape";

export const testElm = () => {
  test("# elm test #", t => {
    const elmTest = spawn("elm-test", [], {
      cwd: __dirname,
      shell: true
    });

    elmTest.stdout.on("data", data => {
      t.comment(data);
    });

    elmTest.stderr.on("data", data => {
      t.fail(data);
    });

    elmTest.on("close", code => {
      t.equals(code, 0, "elm-test exit code should be 0");
      t.end();
    });
  });
};
