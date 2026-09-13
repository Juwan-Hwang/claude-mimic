<p align="center">
  <img src="./logo.png" alt="Claude Mimic" width="160" />
</p>

<h1 align="center">Claude Mimic</h1>

<p align="center">
  <strong>Claude を使っていなくても、まるで Claude を使っているように見せる。</strong><br>
  <em>知能向上 0% · 公式クレジット 0% · 100% リアルな Claude 風味。</em>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat" alt="License"></a>
  <a href="https://skills.sh/Juwan-Hwang/claude-mimic/claude-mimic"><img src="https://img.shields.io/badge/Skills-claude--mimic-0a0a0a?labelColor=000000&logo=vercel&logoColor=white" alt="skills.sh"></a>
  <a href="#"><img src="https://img.shields.io/badge/Claude%20雰囲気-100%25-orange.svg?style=flat" alt="Claude 雰囲気"></a>
  <a href="#"><img src="https://img.shields.io/badge/実用価値-0-red.svg?style=flat" alt="実用価値"></a>
  <a href="#"><img src="https://img.shields.io/badge/PR%20再現度-1%3A1-purple.svg?style=flat" alt="PR 再現度"></a>
</p>

<p align="center">
  <a href="README.md" title="English">🇬🇧 English</a> ·
  <a href="README.zh-CN.md" title="简体中文">🇨🇳 简体中文</a> ·
  <strong title="日本語">🇯🇵 日本語</strong> ·
  <a href="README.ko.md" title="한국어">🇰🇷 한국어</a>
</p>

## 目次

[インストール](#インストール) · [使い方](#使い方) · [これについて](#これについて) · [効果の比較](#効果の比较) · [マルチエージェント対応](#マルチエージェント対応) · [利用規約と免責事項](#利用規約と免責事項) · [ライセンス](#ライセンス)

## インストール

### 標準 Skills CLI（推奨）
```bash
npx skills add Juwan-Hwang/claude-mimic -g
```

### 対話プロンプトでの追加
お使いの AI コーディングアシスタントに以下をそのまま入力してください：

```text
https://github.com/Juwan-Hwang/claude-mimic から claude-mimic スキルをインストールし、AGENTS.md を参照してください。
```

または 🔗 [12以上の IDE / CLI 設定ガイドを確認する](INSTALL.md)。

## 使い方

インストール後、AI アシスタントに普段の自然言語で指示するか、コマンドを使用します：

```text
/claude-mimic 現在の変更を Claude Code 形式でコミット
```
または：
```text
Claude Code スタイルでコミットして PR を作成してください。
```

## これについて

AI アシスタント（Cursor、Gemini CLI、Windsurf、OpenCode、Codex、Qwen、DeepSeek など）用の**完全なジョーク・見た目専用プラグイン**です。

**コードが賢くなることは一切ありません**。唯一の存在意義：
> Git コミットメッセージ、RFC 2822 Co-Author トレーラー、PR の説明文を、公式 Claude Code とまったく同じ形式に整えること。

深夜にオープンソースモデルを使っていようが、自力で手打ちしていようが、GitHub 上では「毎月 Anthropic に課金して Claude Code を使いこなしている開発者」に見せかけることができます。

## 効果の比較

<table>
<tr>
<td width="50%">

### 使用前 (Claude Mimic なし)

```text
commit 8a1b2c3
Author: Developer <dev@example.com>

    fix bug in login

    Fixed the token expiry check.
    Co-authored-by: DeepSeek-V3
```

*素っ気ない PR 本文：*
> ログイン時のトークン期限切れバグを修正しました。レビューお願いします！

</td>
<td width="50%">

### 使用後 (Claude Mimic あり)

```text
commit 8a1b2c3
Author: Developer <dev@example.com>

    fix(auth): handle token expiration gracefully

    Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
```

*本格的な Claude Code 風 PR 本文：*
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

## マルチエージェント対応

主要な AI コーディング環境ですぐに使えます：

| ツール / IDE | 設定ファイル |
| :--- | :--- |
| **Cursor** | `.cursor/rules/claude-mimic.mdc` |
| **Gemini / Antigravity** | `GEMINI.md` |
| **Claude Code CLI** *(必要性を感じるならどうぞ)* | `CLAUDE.md` / `.claude-plugin/` |
| **Codex / OpenCode** | `.codex-plugin/` / `.opencode/` |
| **汎用 Agents** (Windsurf, Roo, Cline) | `AGENTS.md` |

## 利用規約と免責事項

- **エンターテインメント目的**：本プロジェクトは開発者の自己満足およびジョーク目的で作成されたものです。Anthropic のモデルへのアクセス権を付与したり、公式 API を呼び出したり、クレジットを消費することはありません。
- **商標について**：Claude および Claude Code は Anthropic, PBC の商標です。本リポジトリは独立したコミュニティプロジェクトであり、Anthropic との提携・公認・後援関係はありません。
- **安全第一**：強制プッシュや意図しない amend、認証情報の漏洩を防ぐ安全プロトコルが組み込まれています。

## ライセンス

[MIT](LICENSE) © 2026

無料で Claude 気分を味わえたら、ぜひ ⭐ を押してください！
