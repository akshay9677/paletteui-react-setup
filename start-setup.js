const fs = require("fs-extra");
const { program } = require("commander");
const { Select } = require("enquirer");
const execSync = require("child_process").execSync;
const chalk = require("chalk");
const ora = require("ora");

const prompt = new Select({
  name: "color",
  message: "Would you like to add templates for socket connections?",
  choices: ["Yes", "No"],
});

const loginPrompt = new Select({
  name: "color1",
  message: "Would you like to add templates for login?",
  choices: ["Yes", "No"],
});

function createBasicTemplate(appName) {
  return new Promise((resolve, reject) => {
    fs.copy(`${__dirname}/template/basic`, `./${appName}`, async (err) => {
      if (err) {
        reject(err);
      }
      resolve();
    });
  });
}

async function addLoginTemplate(appName) {
  try {
    execSync(`cd ${appName} && npx hygen cli login`, { stdio: "ignore" });
  } catch (err) {
    console.log(err);
  }
}

async function addSocketTemplate(appName) {
  try {
    execSync(`cd ${appName} && npx hygen cli socket`, { stdio: "ignore" });
  } catch (err) {
    console.log(err);
  }
}

async function initializeProjectSetup(appName) {
  let isSocketNeeded = false,
    isLoginNeeded = false;

  try {
    let loginRes = await loginPrompt.run();
    isLoginNeeded = loginRes === "Yes";
    let response = await prompt.run();
    isSocketNeeded = response === "Yes";

    const spinner = ora("Setting up project...").start();

    await createBasicTemplate(appName);

    if (isLoginNeeded) await addLoginTemplate(appName);

    if (isSocketNeeded) await addSocketTemplate(appName);

    await new Promise((resolve, reject) => {
      fs.rm(
        `${__dirname}/${appName}/_templates`,
        {
          recursive: true,
          force: true,
        },
        (err) => {
          if (err) {
            reject(err);
          }
          resolve();
        }
      );
    });

    spinner.succeed(
      "Project setup completed! Run the following commands to start your app"
    );

    console.log("");
    console.log(chalk.blue(`$ cd ${appName}`));
    console.log("");
    console.log(chalk.blue(`$ npm i`));
    console.log("");
    console.log(chalk.blue(`$ npm run dev`));
    console.log("");
  } catch (e) {
    console.log(e);
  }
}

function start() {
  program
    .version("0.0.1")
    .argument("<appName>")
    .action((appName) => {
      if (
        appName.toLowerCase() === appName &&
        appName.toUpperCase() !== appName
      ) {
        initializeProjectSetup(appName);
      } else {
        console.log("Enter a valid project name");
      }
    });

  program.parse(process.argv);
}

module.exports = { start };
