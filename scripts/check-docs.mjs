#!/usr/bin/env node
/**
 * Validate the project's two-level documentation index contract.
 *
 * Every directory below docs must have an index.md. The root index may only
 * point at folder indexes, and each folder index must describe every Markdown
 * document in the same folder using the required link-plus-description form.
 */
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { join, relative } from "node:path";

const root = join(process.cwd(), "docs");
const failures = [];
const linkPattern = /^- \[[^\]]+\]\(([^)]+)\):\s+.+$/gm;

/** Return direct subdirectories, excluding dot-directories. */
function directories(path) {
  return readdirSync(path, { withFileTypes: true }).filter(entry => entry.isDirectory() && !entry.name.startsWith(".")).map(entry => entry.name);
}

/** Parse only compliant Markdown index links. */
function indexedLinks(indexPath) {
  const contents = readFileSync(indexPath, "utf8");
  return [...contents.matchAll(linkPattern)].map(match => match[1]);
}

if (!existsSync(root)) {
  failures.push("docs/ is missing");
} else if (!existsSync(join(root, "index.md"))) {
  failures.push("docs/index.md is missing");
} else {
  const rootLinks = indexedLinks(join(root, "index.md"));
  for (const directory of directories(root)) {
    const index = join(root, directory, "index.md");
    if (!existsSync(index)) failures.push(`docs/${directory}/index.md is missing`);
    if (!rootLinks.includes(`${directory}/index.md`)) failures.push(`docs/index.md does not describe ${directory}/index.md`);
  }
  for (const directory of directories(root)) {
    const dir = join(root, directory);
    const index = join(dir, "index.md");
    if (!existsSync(index)) continue;
    const links = indexedLinks(index);
    for (const file of readdirSync(dir, { withFileTypes: true }).filter(entry => entry.isFile() && entry.name.endsWith(".md") && entry.name !== "index.md")) {
      if (!links.includes(file.name)) failures.push(`${relative(process.cwd(), index)} does not describe ${file.name}`);
    }
  }
}
if (failures.length) {
  console.error(failures.join("\n"));
  process.exit(1);
}
console.log("Documentation indexes are valid.");
