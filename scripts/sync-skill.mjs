#!/usr/bin/env node
// Copies the canonical SKILL.md and references/ (repository root) into every
// mirrored skill directory. Run after editing any of them: `npm run sync`.
// `npm run sync -- --check` exits non-zero if a mirror is out of date.
import fs from 'node:fs';
import path from 'node:path';

const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const MIRRORS = ['skills/claude-mimic', '.cursor/skills/claude-mimic'];
const FILES = ['SKILL.md', 'references/model-matrix.md', 'references/pr-signatures.md', 'references/templates.md'];
const check = process.argv.includes('--check');

let stale = 0;
for (const mirror of MIRRORS) {
  for (const file of FILES) {
    const src = fs.readFileSync(path.join(ROOT, file), 'utf-8');
    const dest = path.join(ROOT, mirror, file);
    const current = fs.existsSync(dest) ? fs.readFileSync(dest, 'utf-8') : null;
    if (current === src) continue;
    stale++;
    if (check) {
      console.error(`out of date: ${mirror}/${file}`);
    } else {
      fs.mkdirSync(path.dirname(dest), { recursive: true });
      fs.writeFileSync(dest, src);
      console.log(`synced: ${mirror}/${file}`);
    }
  }
}
if (check && stale > 0) {
  console.error(`${stale} mirrored file(s) out of date. Run: npm run sync`);
  process.exit(1);
}
