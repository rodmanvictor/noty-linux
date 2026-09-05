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

assert.match(page, /<title>Noty for Plasma<\/title>/, "page title must identify the independent KDE project");
assert.match(page, /Independent KDE Plasma implementation inspired by/i, "page must credit the design source honestly");
assert.match(page, /github\.com\/aimen08\/noty/, "page must link to the original Noty project");
assert.match(page, /github\.com\/rodmanvictor\/noty-plasma/, "page must expose the independent source repository");
assert.match(page, /Phosphor Icons/i, "page must identify its bundled icon source");
assert.match(page, /kpackagetool6/, "page must show the Plasma installation command");
assert.doesNotMatch(page, /noty-sepia\.vercel\.app|Download for macOS|SwiftUI and AppKit/, "macOS site copy must not leak into the KDE landing page");

for (const asset of [
    "assets/noty-plasma.svg",
    "assets/screenshots/pastel-card-contrast.png",
    "assets/screenshots/archive-confirmation.png",
    "assets/screenshots/appearance-settings.png",
    "assets/screenshots/icon-system.png",
    "robots.txt",
    "sitemap.xml"
]) {
    requireAsset(asset);
}

console.log("Static landing page contracts are intact.");
