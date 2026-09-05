/**
 * @fileoverview Validates the static landing page before GitHub Pages publishes it.
 *
 * The checks deliberately stay dependency-free so a contributor can run them on
 * any Node.js installation. They prove that the attribution, local assets and
 * public install path do not silently regress while the visual page is edited.
 */

import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

const websiteRoot = join(process.cwd(), "website");
const pagePath = join(websiteRoot, "index.html");
const page = readFileSync(pagePath, "utf8");

/**
 * Ensures a website asset used by the landing page is committed beside it.
 * @param {string} relativePath Asset path relative to `website/`.
 * @returns {void}
 * @throws {AssertionError} When a public page references a missing local asset.
 */
function requireAsset(relativePath) {
    assert.ok(existsSync(join(websiteRoot, relativePath)), `missing website asset: ${relativePath}`);
}

assert.match(page, /<title>Noty Linux — local notes at the edge of work<\/title>/, "page title must identify the independent Linux project");
assert.match(page, /Independent by design\./, "page must credit the design source honestly");
assert.match(page, /github\.com\/aimen08\/noty/, "page must link to the original Noty project");
assert.match(page, /github\.com\/rodmanvictor\/noty-linux/, "page must expose the independent source repository");
assert.match(page, /Phosphor Icons/i, "page must identify its bundled icon source");
assert.match(page, /kpackagetool6/, "page must show the Plasma installation command");
assert.match(page, /Real KDE Plasma desktop capture/, "page must label the real product capture");
assert.doesNotMatch(page, /noty-sepia\.vercel\.app|Download for macOS|SwiftUI and AppKit/, "macOS site copy must not leak into the KDE landing page");

for (const asset of [
    "assets/noty-linux.svg",
    "assets/screenshots/live-note-editor.png",
    "assets/screenshots/live-note-colour.png",
    "assets/demo/noty-workflow.mp4",
    "assets/demo/noty-workflow.gif",
    "assets/fonts/NotoSerif-Regular.ttf",
    "assets/fonts/NotoSerif-Bold.ttf",
    "robots.txt",
    "sitemap.xml"
]) {
    requireAsset(asset);
}

console.log("Static landing page contracts are intact.");
