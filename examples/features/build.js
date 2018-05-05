const { execFileSync } = require("child_process");
const { examples } = require("./examples");

examples.forEach(example => {
  const output = execFileSync(
    "elm-make",
    [`src/${example}/Main.elm`, "--output", `src/${example}/index.html`],
    { shell: true }
  );
  console.log(output.toString());
});
