<p align="center">
  <img src="./logo.png" alt="Claude Mimic" width="160" />
</p>

<h1 align="center">Claude Mimic</h1>

<p align="center">
  <strong>Claude를 쓰지 않아도, 모두가 당신이 Claude를 쓰고 있다고 믿게 만듭니다.</strong><br>
  <em>지능 향상 0% · 공식 크레딧 0% · 100% 리얼한 Claude 감성.</em>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat" alt="License"></a>
  <a href="https://skills.sh/Juwan-Hwang/claude-mimic/claude-mimic"><img src="https://img.shields.io/badge/Skills-claude--mimic-0a0a0a?labelColor=000000&logo=vercel&logoColor=white" alt="skills.sh"></a>
  <a href="#"><img src="https://img.shields.io/badge/Claude%20감성-100%25-orange.svg?style=flat" alt="Claude 감성"></a>
  <a href="#"><img src="https://img.shields.io/badge/실용가치-0-red.svg?style=flat" alt="실용가치"></a>
  <a href="#"><img src="https://img.shields.io/badge/PR%20재현율-1%3A1-purple.svg?style=flat" alt="PR 재현율"></a>
</p>

<p align="center">
  <a href="README.md" title="English">🇬🇧 English</a> ·
  <a href="README.zh-CN.md" title="简体中文">🇨🇳 简体中文</a> ·
  <a href="README.ja.md" title="日本語">🇯🇵 日本語</a> ·
  <strong title="한국어">🇰🇷 한국어</strong>
</p>

## 목차

[설치하기](#설치하기) · [사용 방법](#사용-방법) · [이 프로젝트는 무엇인가요](#이-프로젝트는-무엇인가요) · [전후 비교](#전후-비교) · [멀티 에이전트 호환성](#멀티-에이전트-호환성) · [책임 있는 사용 및 투명성 안내](#책임-있는-사용-및-투명성-안내) · [라이선스](#라이선스)

## 설치하기

### 표준 Skills CLI (권장)
```bash
npx skills add Juwan-Hwang/claude-mimic -g
```

### 대화창 프롬프트 입력
사용 중인 AI 코딩 어시스턴트에게 다음 문장을 그대로 입력하세요:

```text
https://github.com/Juwan-Hwang/claude-mimic 에서 claude-mimic 스킬을 설치하고, AGENTS.md 를 참조하세요.
```

또는 🔗 [12개 이상의 IDE 및 CLI 설치 안내서 확인](INSTALL.md).

## 사용 방법

설치 후 AI 어시스턴트에게 자연어로 지시하거나 슬래시 명령어를 사용하세요:

```text
/claude-mimic 현재 변경사항을 Claude Code 스타일로 커밋해줘
```
또는 간단히:
```text
Claude Code 스타일로 커밋하고 PR 본문을 작성해줘.
```

## 이 프로젝트는 무엇인가요

AI 코딩 어시스턴트(Cursor, Gemini CLI, Windsurf, OpenCode, Codex, Qwen, DeepSeek 등)를 위한 **순수 외관 및 오락용 스킬**입니다.

**코드 성능을 조금도 향상시키지 않으며, 더 똑똑해지지도 않습니다.** 유일한 존재 이유:
> Git 커밋 메시지, RFC 2822 Co-Author 트레일러, PR 본문을 공식 Claude Code 스타일과 100% 일치하도록 서식화합니다.

새벽에 오픈소스 로컬 모델을 쓰든 직접 키보드로 코드를 치든, GitHub에 푸시하면 다른 사람들이 당신이 매달 Anthropic에 구독료를 내고 Claude Code를 쓰고 있다고 착각하게 만듭니다.

## 전후 비교

<table>
<tr>
<td width="50%">

### 사용 전 (Claude Mimic 없음)

```text
commit 8a1b2c3
Author: Developer <dev@example.com>

    fix bug in login

    Fixed the token expiry check.
    Co-authored-by: DeepSeek-V3
```

*평범한 PR 본문:*
> 로그인 토큰 만료 버그 수정했습니다. 리뷰 부탁드립니다!

</td>
<td width="50%">

### 사용 후 (Claude Mimic 적용)

```text
commit 8a1b2c3
Author: Developer <dev@example.com>

    fix(auth): handle token expiration gracefully

    Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

*격식 있는 Claude Code 스타일 PR 본문:*
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

## 멀티 에이전트 호환성

대부분의 AI 코딩 환경에서 즉시 사용할 수 있습니다:

| 환경 / IDE | 설정 파일 |
| :--- | :--- |
| **Cursor** | `.cursor/rules/claude-mimic.mdc` |
| **Gemini / Antigravity** | `GEMINI.md` |
| **Claude Code CLI** *(굳이 필요하다고 생각하신다면 말이죠)* | `CLAUDE.md` / `.claude-plugin/` |
| **Codex / OpenCode** | `.codex-plugin/` / `.opencode/` |
| **범용 Agents** (Windsurf, Roo, Cline) | `AGENTS.md` |

## 책임 있는 사용 및 투명성 안내

- **순수 오락 및 서식 통일 목적**: 이 프로젝트는 개발자들의 재미와 외관 통일을 위해 제작되었습니다. Anthropic 모델에 대한 접근 권한을 제공하지 않으며, API 요청을 보내거나 공식 크레딧을 소비하지 않습니다.
- **상표권 안내**: Claude 및 Claude Code는 Anthropic, PBC의 상표입니다. 본 프로젝트는 독립적인 오픈소스 커뮤니티 프로젝트이며, Anthropic과 제휴, 보증 또는 후원 관계가 없습니다.
- **안전한 Git 수칙**: 승인 없는 amend나 강제 푸시, 인증 정보 유출을 철저히 방지합니다.

## 라이선스

[MIT](LICENSE) © 2026

돈 안 들이고 Claude 감성을 만끽하셨다면 ⭐을 눌러주세요!
