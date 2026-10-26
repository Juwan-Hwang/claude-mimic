# Contributing to Claude Mimic

Thank you for your interest in contributing to Claude Mimic.

Claude Mimic is an open-source compatibility layer that enables any AI coding agent to speak Claude Code's exact Git dialect and attribution standards.

---

## Engineering Philosophy: 1:1 Ground Truth

Every rule in this repository is verified against executable primary sources:
1. **Claude Code production releases** (e.g. the model catalog shipped in `@anthropic-ai/claude-code@2.1.310`).
2. **Official system prompt instructions** (`/commit` and `/commit-push-pr`).
3. **Empirical sampling** across live GitHub commits and pull request bodies.

We do **NOT** accept speculative or unverified additions. Specifically:
- **Do not invent model names**: New models must be confirmed in production binaries or verified live repository commits (e.g. `Claude Haiku 5` does not exist; `Claude Mythos 5.1` is confirmed as a restricted tier; `Claude Haiku 5.5` was added in v2.1.293).
- **Preserve default bias**: Claude Code's wild output is plain and minimal. Do not force exotic features into default paths.

---

## Local Development & Testing

Run the automated assertion suite:

```bash
npm test
```

This executes `tests/validate.test.js` using Node's native test runner (`node --test`), verifying:
- Core [`SKILL.md`](SKILL.md) and Git Safety Protocol adherence.
- Trailer RFC 2822 formatting (preceding blank line, exact spacing).
- Multi-agent manifest integrity across Cursor, Codex, OpenCode, Gemini, Kimi, and Qwen.
- Model whitelist validity across all 19 official catalog models.
- Default emission invariants (plain signature, omission of unneeded changelogs).
- Session ID Bitcoin Base58 pattern compliance (length 32, excluding 0, O, I, l).

---

## Adding Models or Updating Lineups

When a new Anthropic model is launched:
1. Confirm its public display name and canonical identifier in a production binary or authenticated commit.
2. Update [`references/model-matrix.md`](references/model-matrix.md).
3. Update whitelist in [`references/pr-signatures.md`](references/pr-signatures.md).
4. Update model selectors in `scripts/gh-claude-pr.sh`, `scripts/gh-claude-pr.ps1`, `scripts/git-claude-commit.sh`, and `scripts/git-claude-commit.ps1`.
5. Add test coverage in `tests/validate.test.js` and verify with `npm test`.

---

## Pull Request Guidelines

- Follow Claude Code's commit convention: concise 1–2 sentences focusing on "why", not "what".
- Keep PR titles under 70 characters.
- PR descriptions should follow the standard skeleton: `## Summary` + `## Test plan`.
- Ensure all tests pass before opening a pull request.

## Keeping mirrors in sync

`SKILL.md` and `references/` live at the repository root. After editing them, run `npm run sync` so `skills/claude-mimic/` and `.cursor/skills/claude-mimic/` match; CI fails if they drift (`npm run sync:check`).
