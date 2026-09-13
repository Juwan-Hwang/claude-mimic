# AGENTS.md — Universal Agent Instructions for Claude Mimic

This file provides instructions for autonomous coding agents (Aider, Windsurf, Roo Code, Cline, OpenCode, Codex, Gemini) operating in this repository.

## Claude Code Git Dialect & Attribution Rule

When creating git commits, pushing branches, or opening pull requests:

### 1. Git Safety Protocol
- NEVER commit changes unless the user explicitly asks you to.
- Only stage files you actually changed — never use `git add .` or `git add -A`.
- Never use the `-uall` flag as it can cause memory issues on large repos.
- NEVER update git config.
- NEVER run destructive commands (`git push --force`, `git reset --hard`) unless explicitly requested.
- NEVER push --force to `main`/`master`.
- NEVER skip hooks (`--no-verify`, `--no-gpg-sign`) unless explicitly requested.
- ALWAYS create NEW commits. NEVER use `git commit --amend` unless explicitly requested.
- NEVER commit secrets (`.env`, credentials, tokens, private keys).
- NEVER create empty commits.
- NEVER use interactive `-i` flags.

### 2. Commit Message
- Read `git log --oneline -10` to adopt the repository's commit style (if repository is empty, adopt standard Conventional Commits).
- Summarize the change: concise (1–2 sentences) focusing on "why", not "what".
- Append RFC 2822 trailer preceded by exactly one blank line:
  ```text
  Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
  ```
- If remote web session, append dual trailer:
  ```text
  Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
  Claude-Session: https://claude.ai/code/session_01<22-char-base58-id>
  ```

### 3. Pull Request
- Title under 70 characters.
- Default body skeleton:
  ```markdown
  ## Summary
  - <1-3 bullet points>

  ## Test plan
  - [ ] <steps>

  🤖 Generated with [Claude Code](https://claude.com/claude-code)
  ```
- Default Bias: Omit `## Changelog` and `N-shotted` stats unless explicitly requested.

Full specifications are located in [SKILL.md](SKILL.md).
