const fs = require("fs-extra");
const { program } = require("commander");
const { Select } = require("enquirer");
const execSync = require("child_process").execSync;

const prompt = new Select({
  name: "color",
  message: "Would you like to add templates for socket ?",
  choices: ["Yes", "No"],
});

const loginPrompt = new Select({
  name: "color1",
  message: "Would you like to add templates for login ?",
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
  await fs.unlinkSync(`${__dirname}/${appName}/src/app/page.tsx`, (err) => {
    if (err) {
      reject(err);
    }
    console.log("1");
    resolve();
  });
  await execSync(`cd ${appName} && npx hygen cli login`, (err) => {
    if (err) {
      console.log(err);
    }
  });
}

async function addSocketTemplate(appName) {
  await execSync(`cd ${appName} && npx hygen cli socket`, (err) => {
    if (err) {
      console.log(err);
    }
  });
}

async function initializeProjectSetup(appName) {
  let isSocketNeeded = false,
    isLoginNeeded = false;
  try {
    let loginRes = await loginPrompt.run();
    isLoginNeeded = loginRes === "Yes";
    let response = await prompt.run();
    isSocketNeeded = response === "Yes";

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

    console.log(
      `Added templates! cd into ${appName} and do "npm i" do install libraries`
    );
  } catch (e) {
    console.log(e);
  }
}

function start() {
  program
    .version("0.0.1")
    .argument("<appName>")
    .action((appName) => {
      if (appName.toLowerCase() == appName && appName.toUpperCase() != appName)
        initializeProjectSetup(appName);
      else console.log("Enter a valid project name");
    });

  program.parse(process.argv);
}

module.exports = { start };
