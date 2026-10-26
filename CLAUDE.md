# CLAUDE.md — Claude Mimic

When asked to commit changes, push code, or open a pull request in this repository, follow the Git Safety Protocol and attribution rules in [SKILL.md](SKILL.md).

Contributor notes:
- Edit `SKILL.md` and `references/` at the repository root only, then run `npm run sync` to update the mirrors in `skills/claude-mimic/` and `.cursor/skills/claude-mimic/`.
- Run `npm test` before committing. PowerShell tests are skipped automatically when `pwsh` is not installed; CI runs them on Windows.
