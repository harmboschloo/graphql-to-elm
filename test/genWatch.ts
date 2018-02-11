import { spawnSync } from "child_process";
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

const run = () => {
  spawnSync("npm", ["run", "test:gen"], {
    stdio: "inherit",
    shell: true
  });
};
