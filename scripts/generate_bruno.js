#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const localRoot = path.join(root, ".local");
const cliModules = path.join(localRoot, "tools", "bruno-cli", "node_modules");
const outputRoot = path.join(localRoot, "bruno");
const output = path.join(outputRoot, "erp-supplier-onboarding");
const staging = path.join(outputRoot, `.erp-supplier-onboarding-${process.pid}`);

function requireLocal(packageName) {
  try {
    return require(path.join(cliModules, packageName));
  } catch (error) {
    throw new Error(
      `Bruno CLI dependencies are missing. Run ./scripts/bruno.sh generate. (${error.message})`,
    );
  }
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function walk(items) {
  return items.flatMap((item) => [item, ...(item.items ? walk(item.items) : [])]);
}

function chmodTree(target) {
  for (const entry of fs.readdirSync(target, { withFileTypes: true })) {
    const child = path.join(target, entry.name);
    if (entry.isDirectory()) {
      fs.chmodSync(child, 0o700);
      chmodTree(child);
    } else {
      fs.chmodSync(child, 0o600);
    }
  }
}

async function main() {
  const collectionSource = path.join(
    root,
    "postman",
    "erp-supplier-onboarding.postman_collection.json",
  );
  const environmentSource = path.join(
    localRoot,
    "postman",
    "erp-local.postman_environment.json",
  );
  if (!fs.existsSync(environmentSource)) {
    throw new Error("Generate the local Postman environment before Bruno conversion");
  }

  const { postmanToBruno, postmanToBrunoEnvironment } = requireLocal(
    "@usebruno/converters",
  );
  const { createCollectionFromBrunoObject } = requireLocal(
    "@usebruno/cli/src/utils/collection.js",
  );
  const converted = await postmanToBruno(readJson(collectionSource));
  if (converted.issues.length !== 0) {
    throw new Error(`Bruno conversion reported ${converted.issues.length} issue(s)`);
  }

  const canonicalOperations = walk(converted.collection.items).filter((item) =>
    item.request?.docs?.includes("Canonical operationId:"),
  );
  if (canonicalOperations.length !== 42) {
    throw new Error(`Expected 42 canonical operations, found ${canonicalOperations.length}`);
  }

  const localEnvironment = postmanToBrunoEnvironment(readJson(environmentSource));
  // The generated collection is ignored and owner-only. Persist local demo values
  // here so Bruno needs no account, secure-store setup, or manual credential entry.
  converted.collection.root.request.vars.req = localEnvironment.variables.map(
    (variable) => ({
      name: variable.name,
      value: variable.value,
      enabled: variable.enabled,
      local: false,
    }),
  );
  for (const item of walk(converted.collection.items)) {
    if (item.request?.script?.res) {
      item.request.script.res = item.request.script.res.replaceAll(
        "bru.setEnvVar(",
        "bru.setVar(",
      );
    }
  }
  converted.collection.environments = [];
  fs.mkdirSync(outputRoot, { recursive: true, mode: 0o700 });
  fs.rmSync(staging, { recursive: true, force: true });
  fs.mkdirSync(staging, { recursive: true, mode: 0o700 });
  await createCollectionFromBrunoObject(converted.collection, staging, { format: "bru" });
  chmodTree(staging);

  if (!output.startsWith(`${outputRoot}${path.sep}`)) {
    throw new Error("Refusing to replace a Bruno collection outside .local/bruno");
  }
  fs.rmSync(output, { recursive: true, force: true });
  fs.renameSync(staging, output);
  fs.chmodSync(output, 0o700);

  const requests = walk(converted.collection.items).filter(
    (item) => item.type === "http-request",
  );
  console.log(
    `Generated account-free Bruno collection with ${requests.length} requests and 42 canonical operations at ${path.relative(root, output)}`,
  );
}

main().catch((error) => {
  console.error(`Bruno generation failed: ${error.message}`);
  process.exitCode = 1;
});
