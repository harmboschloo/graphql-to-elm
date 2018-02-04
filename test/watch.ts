import * as path from "path";
import { watch } from "chokidar";

const watcher = watch(
  [__dirname, `${__dirname}/../src`, `${__dirname}/../index.ts`],
  { ignored: "**/generated-*" }
);

watcher.on("ready", () => {
  watcher.on("all", run);
  run();
});

const run = () => {
  const watched = watcher.getWatched();
  Object.keys(watched).forEach(dir =>
    watched[dir].forEach(file => {
      if (path.extname(file)) {
        const relativePath = path.relative(__dirname, path.resolve(dir, file));
        delete require.cache[require.resolve(`./${relativePath}`)];
      }
    })
  );

  try {
    require("./test");
  } catch (e) {
    console.error(e);
  }
};
