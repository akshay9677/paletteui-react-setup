const fs = require("fs-extra");
const { program } = require("commander");
const { Select } = require("enquirer");
const execSync = require("child_process").execSync;

const prompt = new Select({
  name: "color",
  message: "Do u need socket boilerplates ?",
  choices: ["Yes", "No"],
});

const loginPrompt = new Select({
  name: "color1",
  message: "Do u need login templates?",
  choices: ["Yes", "No"],
});

async function initializeProjectSetup(appName) {
  let isSocketNeeded = false,
    isLoginNeeded = false;
  try {
    let response = await prompt.run();
    isSocketNeeded = response === "Yes";
    let loginRes = await loginPrompt.run();
    isLoginNeeded = loginRes === "Yes";

    console.log(isLoginNeeded, isSocketNeeded);

    await fs.copy(`${__dirname}/template/basic`, `./${appName}`, (err) => {
      if (err) {
        console.log(err);
        process.exit(1);
      } else {
        if (isLoginNeeded) {
          fs.unlinkSync(`${__dirname}/${appName}/src/app/page.tsx`);
          execSync(`npx hygen cli login --component=${appName}`, (e) => {
            console.log(e);
            process.exit(1);
          });
        }
      }
    });
  } catch (e) {
    console.log(e);
  }
}

function start() {
  program
    .version("0.0.1")
    .command("create <appName>")
    .action((appName) => {
      if (appName.toLowerCase() == appName && appName.toUpperCase() != appName)
        initializeProjectSetup(appName);
      else console.log("Enter a valid project name");
    });

  program.parse(process.argv);
}

module.exports = { start };
