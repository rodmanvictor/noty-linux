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
assert.match(page, /github\.com\/rodmanvictor\/noty-linux/, "page must expose the independent source repository");
assert.match(page, /Phosphor Regular/i, "page must identify its bundled icon source");
assert.match(page, /kpackagetool6/, "page must show the Plasma installation command");
assert.match(page, /Real KDE Plasma desktop capture/, "page must label the real product capture");
assert.match(page, /Read the guide in your language\./, "page must expose the multilingual public documentation");
assert.match(page, /guide\.(en|ru|es|de|fr)\.md/, "page must link to every public guide language");
assert.match(page, /edge-tabs-full\.png/, "page must use the full-frame resting deck capture");
assert.match(page, /open-note-full\.png/, "page must use the full-frame open note capture");
assert.match(page, /noty-workflow-full\.(gif|mp4)/, "page must publish the uncropped workflow media");
assert.doesNotMatch(page, /object-fit/, "the product captures must not be cropped by CSS");

for (const asset of [
    "assets/noty-linux.svg",
    "assets/screenshots/edge-tabs-full.png",
    "assets/screenshots/open-note-full.png",
    "assets/screenshots/colour-change-full.png",
    "assets/demo/noty-workflow-full.mp4",
    "assets/demo/noty-workflow-full.gif",
    "assets/fonts/NotoSerif-Regular.ttf",
    "assets/fonts/NotoSerif-Bold.ttf",
    "robots.txt",
    "sitemap.xml"
]) {
    requireAsset(asset);
}

console.log("Static landing page contracts are intact.");
