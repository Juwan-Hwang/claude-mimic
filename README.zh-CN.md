<p align="center">
  <img src="./logo.png" alt="Claude Mimic" width="160" />
</p>

<h1 align="center">Claude Mimic</h1>

<p align="center">
  <strong>就算你压根没用 Claude，也能让别人以为你一直在用。</strong><br>
  <em>0% 智商加成 · 0% 官方额度 · 100% 纯正 Claude 风味。</em>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat" alt="License"></a>
  <a href="https://skills.sh/Juwan-Hwang/claude-mimic/claude-mimic"><img src="https://img.shields.io/badge/Skills-claude--mimic-0a0a0a?labelColor=000000&logo=vercel&logoColor=white" alt="skills.sh"></a>
  <a href="#"><img src="https://img.shields.io/badge/Claude%20氛围感-100%25-orange.svg?style=flat" alt="Claude 氛围感"></a>
  <a href="#"><img src="https://img.shields.io/badge/实用价值-0-red.svg?style=flat" alt="实用价值"></a>
  <a href="#"><img src="https://img.shields.io/badge/PR%20拟真度-1%3A1-purple.svg?style=flat" alt="PR 拟真度"></a>
</p>

<p align="center">
  <a href="README.md" title="English">🇬🇧 English</a> ·
  <strong title="简体中文">🇨🇳 简体中文</strong> ·
  <a href="README.ja.md" title="日本語">🇯🇵 日本語</a> ·
  <a href="README.ko.md" title="한국어">🇰🇷 한국어</a>
</p>

https://github.com/user-attachments/assets/289cf15b-c220-43a3-9c0d-bfd6b64e7a41

## 目录

[安装方式](#安装方式) · [使用方法](#使用方法) · [这是什么](#这是什么) · [效果对比](#效果对比) · [多平台-agent-兼容性](#多平台-agent-兼容性) · [负责任使用与透明度说明](#负责任使用与透明度说明) · [开源协议](#开源协议)

## 安装方式

### 标准 Skills 命令行（推荐）
```bash
npx skills add Juwan-Hwang/claude-mimic -g
```

### 助手对话框安装
直接把下面这句复制粘贴发给你正在用的 AI 编程助手：

```text
从 https://github.com/Juwan-Hwang/claude-mimic 安装 claude-mimic 技能，参考仓库 AGENTS.md 即可。
```

或者 🔗 [查看 12+ 款 IDE 与 CLI 的详细配置指南](INSTALL.md)。

## 使用方法

安装完成后，在对话中直接自然语言吩咐助手，或使用快捷指令：

```text
/claude-mimic 用 Claude Code 风格提交当前修改
```
或者直接对助手说：
```text
帮我按 Claude Code 规范提交改动并创建 PR。
```

## 这是什么

这是一个给各类 AI 编程助手（Cursor、Gemini CLI、Windsurf、OpenCode、Codex、Qwen、DeepSeek 等）使用的**纯娱乐外观件**。

它**没有任何实际技术加成**，也**不会让你的代码变得更聪明**。它活着的唯一意义就是：
> 把你的 Git Commit 提交信息、RFC 2822 Co-Author 署名和 GitHub PR 正文，调教成跟官方 Claude Code 毫无二致的排版风格。

哪怕你大半夜用的是白嫖的开源模型，或者纯纯你自己手敲的代码，只要挂上它推到 GitHub 上，别人看你的提交记录和 PR，都以为你在按月给 Anthropic 充巨额订阅费。

## 效果对比

<table>
<tr>
<td width="50%">

### 使用前 (没有 Claude Mimic)

```text
commit 8a1b2c3
Author: Developer <dev@example.com>

    fix bug in login

    Fixed the token expiry check.
    Co-authored-by: DeepSeek-V3
```

*简陋随意的 PR 正文：*
> 修了个登录 token 过期的 bug，求 review 谢谢！

</td>
<td width="50%">

### 使用后 (装了 Claude Mimic)

```text
commit 8a1b2c3
Author: Developer <dev@example.com>

    fix(auth): handle token expiration gracefully

    Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

*地道优雅的 Claude Code PR 正文：*
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

## 多平台 Agent 兼容性

开箱即用，支持市面上几乎所有的 AI 编程助手：

| 平台 / IDE | 配置文件入口 |
| :--- | :--- |
| **Cursor** | `.cursor/rules/claude-mimic.mdc` |
| **Gemini / Antigravity** | `GEMINI.md` |
| **Claude Code CLI** *(如果你觉得有必要的话)* | `CLAUDE.md` / `.claude-plugin/` |
| **Codex / OpenCode** | `.codex-plugin/` / `.opencode/` |
| **通用 Agents** (Windsurf, Roo, Cline) | `AGENTS.md` |

## 负责任使用与透明度说明

- **纯娱乐与排版用途**：本项目纯属开发者自娱自乐与外观统一，不提供任何 Anthropic 模型访问权限，不发起任何 Anthropic API 请求，也不会消耗官方额度。
- **商标声明**：Claude 和 Claude Code 是 Anthropic, PBC 的注册商标。本项目为独立的第三方社区开源项目，与 Anthropic 没有任何隶属、赞助或背书关系。
- **Git 安全兜底**：内置严苛的安全协议，严禁非授权 amend、强推以及泄露本地凭据。

## 开源协议

[MIT](LICENSE) © 2026

如果让你免费拥有了 Claude 级别的排版逼格，请顺手点个 ⭐ 吧！
