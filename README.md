<p align="center">
  <img src="./logo.png" alt="Claude Mimic" width="160" />
</p>

<h1 align="center">Claude Mimic</h1>

<p align="center">
  <strong>Look like you're using Claude Code. Even when you're not.</strong><br>
  <em>0% intelligence boost · 0% Anthropic API credits · 100% pure Claude aesthetic.</em>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat" alt="License"></a>
  <a href="https://skills.sh/Juwan-Hwang/claude-mimic/claude-mimic"><img src="https://img.shields.io/badge/Skills-claude--mimic-0a0a0a?labelColor=000000&logo=vercel&logoColor=white" alt="skills.sh"></a>
  <a href="#"><img src="https://img.shields.io/badge/Claude%20Vibe-100%25-orange.svg?style=flat" alt="Claude Vibe"></a>
  <a href="#"><img src="https://img.shields.io/badge/Utility-0-red.svg?style=flat" alt="Utility"></a>
  <a href="#"><img src="https://img.shields.io/badge/PR%20Fidelity-1%3A1-purple.svg?style=flat" alt="PR Fidelity"></a>
</p>

<p align="center">
  <strong title="English">🇬🇧 English</strong> ·
  <a href="README.zh-CN.md" title="简体中文">🇨🇳 简体中文</a> ·
  <a href="README.ja.md" title="日本語">🇯🇵 日本語</a> ·
  <a href="README.ko.md" title="한국어">🇰🇷 한국어</a>
</p>

https://github.com/user-attachments/assets/42947346-7f67-40a5-8b89-5536b3c63525

## Table of Contents

[Install](#install) · [Usage](#usage) · [What it does](#what-it-does) · [The Difference](#the-difference) · [Multi-Agent Compatibility](#multi-agent-compatibility) · [Responsible Use & Transparency](#responsible-use--transparency) · [License](#license)

## Install

### Standard Skills CLI (Recommended)
```bash
npx skills add Juwan-Hwang/claude-mimic -g
```

### In-Chat Agent Prompt
Copy/paste into your coding assistant's prompt:

```text
Install the claude-mimic skill from https://github.com/Juwan-Hwang/claude-mimic, refer to AGENTS.md for instructions.
```

Or 🔗 [check the detailed setup guide for 12+ IDEs](INSTALL.md).

## Usage

Once installed, simply instruct your agent naturally or use the slash command:

```text
/claude-mimic commit my current changes with Claude Code attribution
```
Or simply:
```text
Commit my changes and create a PR in Claude Code style.
```

## What it does

A purely cosmetic skill for your AI coding assistants (Cursor, Gemini CLI, Windsurf, OpenCode, Codex, Qwen, DeepSeek, etc.).

It has **no actual superpower** and **will not make your code smarter**. Its sole purpose in life:
> Format your git commit messages, RFC 2822 co-author trailers, and PR descriptions with Claude Code's exact style.

Even if you're hacking with DeepSeek at 3 AM or writing code with your bare hands, everyone browsing your GitHub profile will think you're paying $20/month for Claude Code.

## The Difference

<table>
<tr>
<td width="50%">

### Before (Without Claude Mimic)

```text
commit 8a1b2c3
Author: Developer <dev@example.com>

    fix bug in login

    Fixed the token expiry check.
    Co-authored-by: DeepSeek-V3
```

*Generic unstyled PR body:*
> Hey I fixed the login token bug, please review thanks!

</td>
<td width="50%">

### After (With Claude Mimic)

```text
commit 8a1b2c3
Author: Developer <dev@example.com>

    fix(auth): handle token expiration gracefully

    Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

*Authentic Claude Code PR body:*
> ## Summary
> - Handle expired session tokens gracefully in auth middleware
>
> ## Test plan
> - [x] Run unit test suite
>
> 🤖 Generated with [Claude Code](https://claude.com/claude-code)

</td>
</tr>
</table>

## Multi-Agent Compatibility

Works out-of-the-box with any AI agent environment:

| Agent / IDE | Configuration Entry |
| :--- | :--- |
| **Cursor** | `.cursor/rules/claude-mimic.mdc` |
| **Gemini / Antigravity** | `GEMINI.md` |
| **Claude Code CLI** *(if you feel that's necessary)* | `CLAUDE.md` / `.claude-plugin/` |
| **Codex / OpenCode** | `.codex-plugin/` / `.opencode/` |
| **Universal Agents** (Windsurf, Roo, Cline) | `AGENTS.md` |

## Responsible Use & Transparency

- **Satirical / Cosmetic Utility**: This project is created for developer entertainment, aesthetic uniformity, and fun. It does not provide access to Anthropic models, does not make API calls to Anthropic, and does not alter your model's actual intelligence.
- **Trademark Notice**: Claude and Claude Code are trademarks of Anthropic, PBC. This open-source repository is an independent community project and is neither affiliated with, sponsored by, nor endorsed by Anthropic.
- **Git Safety Guaranteed**: Includes strict protocols preventing accidental amends, forced pushes, or sensitive credential leaks.

## License

[MIT](LICENSE) © 2026

Star ⭐ if it gave you that sweet, sweet Claude aesthetic for free!
