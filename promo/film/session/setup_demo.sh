#!/usr/bin/env bash
# Build the demo repository the film's terminal works in: a tiny auth helper with a real token-expiry bug,
# three ordinary human commits, and the same fix committed two ways (branch `plain`: the generic-agent commit from
# the claude-mimic README's "Before" column; `main`: committed by an agent following claude-mimic's SKILL.md).
set -euo pipefail
cd "$(dirname "$0")"
export HOME="$PWD/home"; rm -rf "$HOME" demo; mkdir -p "$HOME/bin"
export GIT_CONFIG_GLOBAL="$HOME/.gitconfig"
git config --global init.defaultBranch main
mkdir demo && cd demo && git init -q
git config user.name "Developer"; git config user.email "dev@example.com"
mkdir -p src test
cat > src/token.js <<'J'
// Session token helpers.
export function isExpired(token, now = Date.now()) {
  return token.exp * 1000 < now;
}

export function requireSession(token) {
  if (isExpired(token)) throw new Error('session expired');
  return token.sub;
}
J
git add src/token.js; GIT_AUTHOR_DATE="2026-10-26T10:12:00+0800" GIT_COMMITTER_DATE="2026-10-26T10:12:00+0800" git commit -q -m "feat(auth): add session token helpers"
cat > test/token.test.js <<'J'
import { test } from 'node:test';
import assert from 'node:assert';
import { isExpired } from '../src/token.js';

test('fresh token is valid', () => {
  assert.equal(isExpired({ exp: Date.now() / 1000 + 60 }), false);
});
J
git add test/token.test.js; GIT_AUTHOR_DATE="2026-10-26T11:40:00+0800" GIT_COMMITTER_DATE="2026-10-26T11:40:00+0800" git commit -q -m "test(auth): cover fresh tokens"
printf '# acme-auth\n\nSession helpers for the acme dashboard.\n' > README.md
git add README.md; GIT_AUTHOR_DATE="2026-10-26T14:05:00+0800" GIT_COMMITTER_DATE="2026-10-26T14:05:00+0800" git commit -q -m "docs: add readme"
cat > package.json <<'J'
{ "name": "acme-auth", "type": "module", "scripts": { "test": "node --test" } }
J
git add package.json; GIT_AUTHOR_DATE="2026-10-26T14:20:00+0800" GIT_COMMITTER_DATE="2026-10-26T14:20:00+0800" git commit -q -m "chore: add package.json"
# the fix (working tree, uncommitted): expired tokens now return null so the caller can refresh
cat > src/token.js <<'J'
// Session token helpers.
export function isExpired(token, now = Date.now()) {
  return !token?.exp || token.exp * 1000 <= now;
}

export function requireSession(token) {
  if (isExpired(token)) return null; // caller refreshes
  return token.sub;
}
J
# branch `plain`: the README's "Before" commit, verbatim
git switch -q -c plain
git add src/token.js
GIT_AUTHOR_DATE="2026-10-27T03:02:00+0800" GIT_COMMITTER_DATE="2026-10-27T03:02:00+0800" git commit -q -F - <<'M'
fix bug in login

Fixed the token expiry check.
Co-authored-by: DeepSeek-V3
M
git switch -q main
git checkout -q plain -- src/token.js && git reset -q   # same change, back in the working tree, unstaged
# the installed skill's helpers (npx skills add puts them in ~/.agents/skills/claude-mimic) on PATH under their package.json "bin" names
ln -sf "$HOME/.agents/skills/claude-mimic/scripts/git-claude-commit.sh" "$HOME/bin/git-claude-commit"
ln -sf "$HOME/.agents/skills/claude-mimic/scripts/gh-claude-pr.sh" "$HOME/bin/gh-claude-pr"
git status --short; git log --oneline --all
