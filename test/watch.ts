import * as path from "path";
import { watch } from "chokidar";

const watcher = watch(
  [__dirname, `${__dirname}/../src`, `${__dirname}/../index.ts`],
  { ignored: ["**/generated*", "**/integration"] }
);

watcher.on("ready", () => {
  console.log("watched files", watcher.getWatched());
  watcher.on("all", run);
  run();
});

const run = () => {
  clearCacheForWatchedFiles();
  try {
    require("./utils").runSnapshotTests();
  } catch (e) {
    console.error(e);
  }
};

const clearCacheForWatchedFiles = () => {
  const watched = watcher.getWatched();
  Object.keys(watched).forEach(dir =>
    watched[dir].forEach(file => {
      if (path.extname(file)) {
        const relativePath = path.relative(__dirname, path.resolve(dir, file));
        delete require.cache[require.resolve(`./${relativePath}`)];
      }
    })
  );
};
