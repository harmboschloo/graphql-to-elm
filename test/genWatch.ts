import { spawn } from "child_process";
import { watch } from "chokidar";

const watcher = watch(
  [__dirname, `${__dirname}/../src`, `${__dirname}/../index.ts`],
  { ignored: ["**/generated*", "**/browserTest*"] }
);

watcher.on("ready", () => {
  // console.log("watched files", watcher.getWatched());
  watcher.on("all", run);
  run();
});

let running = false;
let rerun = false;

const run = () => {
  if (running) {
    rerun = true;
    return;
  }

  running = true;
  rerun = false;

  const test = spawn("npm", ["run", "test:gen"], {
    stdio: "inherit",
    shell: true
  });

  test.on("close", () => {
    running = false;
    if (rerun) {
      run();
    }
  });
};
