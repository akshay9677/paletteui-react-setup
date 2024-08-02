#!/usr/bin/env node
var currentNodeVersion = process.versions.node.split(".");
var major = currentNodeVersion[0];

if (major < 10) {
  console.error(
    "You are running Node " +
      currentNodeVersion.join(".") +
      ".\n" +
      "Node version higher than 10 is required for Reactify CLI"
  );
  process.exit(1);
}

const { start } = require("./start-setup.js");

start();
