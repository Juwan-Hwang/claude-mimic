# Installation Guide for Claude Mimic (`claude-mimic`)

Claude Mimic adheres to the open **[Agent Skills](https://skills.sh)** specification (`SKILL.md`). Because it is structured as pure, tool-agnostic Markdown guidelines with optional automation scripts, it runs natively on **any modern AI coding assistant**.

Select your environment below to view quick setup instructions:

---

<details open>
<summary><strong>1. Skills CLI (Universal Package Manager)</strong></summary>

The fastest method to install across any compatible agent:

```bash
# Global install (available across all your local workspaces)
npx skills add Juwan-Hwang/claude-mimic --global

# Or install for current repository only
npx skills add Juwan-Hwang/claude-mimic
```

Specify target agents if desired:
```bash
npx skills add Juwan-Hwang/claude-mimic --agent cursor,windsurf,claude-code
```
</details>

<details>
<summary><strong>2. Claude Code CLI</strong></summary>

#### Option A: Official Plugin (Claude Code 2.1.142+)
```text
/plugin marketplace add Juwan-Hwang/claude-mimic
/plugin install claude-mimic
```

#### Option B: Manual Skill Folder
```bash
# Global skills directory
mkdir -p ~/.claude/skills/claude-mimic
cp SKILL.md ~/.claude/skills/claude-mimic/
```

Verify in chat:
```text
/skills
```
</details>

<details>
<summary><strong>3. Cursor</strong></summary>

#### Project-level rule:
Create `.cursor/rules/claude-mimic.mdc` in your repository:
```bash
mkdir -p .cursor/rules
cp SKILL.md .cursor/rules/claude-mimic.mdc
```

#### Global rule:
Open **Cursor Settings** → **General** → **Rules for AI**, and paste the contents of `SKILL.md`.
</details>

<details>
<summary><strong>4. Windsurf (Cascade)</strong></summary>

#### Project-level:
Append or link to `.windsurfrules` in the root of your project:
```bash
cat SKILL.md >> .windsurfrules
```

#### Global Memories:
Add `SKILL.md` to `~/.codeium/windsurf/memories/global_rules.md`.
</details>

<details>
<summary><strong>5. Cline & Roo Code</strong></summary>

#### Project-level instructions:
Create `.clinerules` or `.roomodes`:
```bash
cp SKILL.md .clinerules
```

When prompt instructs to commit or open PRs, Cline will automatically apply the Co-Authored trailer and formatting.
</details>

<details>
<summary><strong>6. Aider</strong></summary>

Add `SKILL.md` to your read-only context during startup:
```bash
aider --read SKILL.md
```

Or make it persistent in `.aider.conf.yml`:
```yaml
read:
  - path/to/claude-mimic/SKILL.md
```
</details>

<details>
<summary><strong>7. Google Antigravity & Gemini CLI</strong></summary>

Copy to global skills folder:
```bash
# Windows
Copy-Item "SKILL.md" -Destination "$env:USERPROFILE\.gemini\config\skills\claude-mimic\SKILL.md" -Force

# Linux / macOS
mkdir -p ~/.gemini/config/skills/claude-mimic
cp SKILL.md ~/.gemini/config/skills/claude-mimic/
```
</details>

<details>
<summary><strong>8. Zed Editor</strong></summary>

Zed's Agent reads Agent Skills natively:
1. In the Agent Panel, click **Create skill from URL** and provide the raw URL to `SKILL.md`.
2. Or copy locally:
```bash
mkdir -p ~/.config/zed/skills/claude-mimic
cp SKILL.md ~/.config/zed/skills/claude-mimic/
```
</details>

<details>
<summary><strong>9. OpenCode</strong></summary>

Add the skill to OpenCode global configuration:
```bash
opencode skill install Juwan-Hwang/claude-mimic
```
Or copy `SKILL.md` into `~/.opencode/skills/claude-mimic/SKILL.md`.
</details>

<details>
<summary><strong>10. OpenAI Codex CLI</strong></summary>

Add the skill definition to your Codex configuration:
```bash
codex skill add Juwan-Hwang/claude-mimic
```
</details>

<details>
<summary><strong>11. GitHub Copilot</strong></summary>

Add to `.github/copilot-instructions.md` in your repository:
```bash
cat SKILL.md >> .github/copilot-instructions.md
```
</details>

<details>
<summary><strong>12. Claude Desktop (App)</strong></summary>

1. Download or clone this repository as a `.zip`.
2. Go to **Claude Desktop Settings** → **Features** → **Skills**.
3. Click **Upload Skill** and select `SKILL.md`.
</details>

---

## Verification

Once installed, verify by asking your assistant:

> *"Show me how you would commit a fix to an asynchronous buffer using claude-mimic."*

The assistant should format the response with:
1. Concise 1–2 sentence causal explanation.
2. Verified pass commands.
3. `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` (separated by exactly one blank line).
4. `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.
