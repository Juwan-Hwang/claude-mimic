# Claude Mimic — launch film

58.5 s · 1920×1080 · 30 fps · H.264 High CRF 16 (yuv420p, BT.709) · AAC 256 kb/s 48 kHz · two-pass loudnorm to −14 LUFS · 120 BPM original score.
Two cuts, one language each: `deliver/claude-mimic-promo-en.mp4` and `deliver/claude-mimic-promo-zh.mp4` (rendered locally; MP4s, frames and font binaries are not committed).

**Message:** look like you're using Claude Code, even when you're not — one install line gives any agent Claude Code's exact Git and PR dialect, safely.

**Carry:** the logo's asterisk. It is the caret at the end of every typed line, the bullet of every caption, the cursor in the terminal and the reel, and finally the asterisk the mascot holds in the lockup. One owner per frame; it is the only accent-coloured thing on screen.

## Storyboard

| time (s) | shot | carry |
|---|---|---|
| 0.0–6.0 | 3D open (three.js, real shutter blur): the asterisk spins in from the dark and grows until it fills the frame | 3D asterisk → full-frame field |
| 6.0–12.0 | Field closes onto the caret; thesis typed: "Look like you're using Claude Code." / "Even when you're not." | caret |
| 12.0–16.0 | Terminal opens on the real session: `git log` of a commit co-authored by another model — "Every commit says who helped." | cursor |
| 16.0–20.0 | `npx skills add Juwan-Hwang/claude-mimic` installs into every agent — "One line. Every agent you use." | cursor |
| 20.0–26.0 | The agent runs status, diff and log before writing — "It reads the repo before it writes." | cursor |
| 26.0–30.0 | Push-in on the new commit's trailer — "Claude Code's exact Git dialect." | trailer caret |
| 30.0–34.0 | `gh-claude-pr` body: Summary, Test plan, 🤖 signature — "Pull requests, 1:1." | cursor |
| 34.0–38.0 | Model reel spins through the catalog and lands on `Claude Opus 5.5 <noreply@anthropic.com>` — "The right Claude for the job." | reel caret |
| 38.0–42.0 | Empty commit refused by the Git Safety Protocol; `.env` commit refused — "Safe by default." | cursor |
| 42.0–46.0 | The README's own numbers: 0% intelligence boost · 0% Anthropic API credits · 100% pure Claude aesthetic | stat bullet |
| 46.0–50.0 | "Nobody has to know." typed, then the camera dives through the asterisk into a full field | caret → field |
| 50.0–52.5 | 3D close: the asterisk swings in and lands, pixel-matched to the vector lockup | 3D asterisk |
| 52.5–58.5 | Lockup: the mascot comes out from behind the asterisk; Claude Mimic · `npx skills add Juwan-Hwang/claude-mimic` · github.com/Juwan-Hwang/claude-mimic · disclaimer | logo asterisk |

## Copy (EN | ZH)

Commands, terminal output, model names and the 0% / 0% / 100% figures are data and appear identically in both cuts.

| key | EN | ZH |
|---|---|---|
| `th1` | Look like you're | 让别人以为， |
| `th2` | using Claude Code. | 你一直在用 Claude Code |
| `th3` | Even when you're not. | 哪怕你压根没用 |
| `beforeH` | Every commit says who helped. | 每个提交，都写着是谁帮的忙 |
| `beforeS` | Co-authored-by: whatever your agent runs on. | Co-authored-by 一行，背后是哪个模型一目了然 |
| `instH` | One line. Every agent you use. | 一行安装，你用的 Agent 都能用 |
| `instS` | Cursor, Codex, Gemini CLI, OpenCode, Windsurf, Cline and more. | Cursor、Codex、Gemini CLI、OpenCode、Windsurf、Cline 等等 |
| `readH` | It reads the repo before it writes. | 先读懂仓库，再动笔 |
| `readS` | Status, diff and history first. The repo's own conventions win. | 先看 status、diff 和提交历史，仓库自己的规范优先 |
| `afterH` | Claude Code's exact Git dialect. | 一字不差的 Claude Code 提交格式 |
| `afterS` | Trailer on the last line, one blank line above, from noreply@anthropic.com. | 署名在最后一行，上方空一行，邮箱 noreply@anthropic.com |
| `prH` | Pull requests, 1:1. | PR 也一比一还原 |
| `prS` | A title under 70 characters. Summary, Test plan, signature. | 标题不超过 70 个字符，Summary、Test plan、署名一个不少 |
| `reelH` | The right Claude for the job. | 按活儿挑对 Claude |
| `reelS` | 22 catalog models, 37 valid forms, checked against Claude Code v2.1.310. | 22 个目录模型、37 种合法写法，对照 Claude Code v2.1.310 核验 |
| `safeH` | Safe by default. | 默认就安全 |
| `safeS` | No empty commits, no secrets, no amends, no force-push. | 不提交空改动，不提交密钥，不 amend，不强推 |
| `st1` | intelligence boost | 智商加成 |
| `st2` | Anthropic API credits | 官方额度 |
| `st3` | pure Claude aesthetic | 纯正 Claude 风味 |
| `fin` | Nobody has to know. | 没人会知道 |
| `disc` | An independent community project. Not affiliated with Anthropic. | 独立社区项目，与 Anthropic 无隶属关系 |

## What is real

Every terminal screen is a real tmux capture of claude-mimic at `main` (4a1e894) — `session/capture.sh` records it into `session/caps/`, `gen/term_data.py` turns it into `film/data/term.json`. Model names and counts come from the repo's `references/model-matrix.md` via `gen/models.py`. Secrets are masked; `scripts/scan_secrets.py .` reports 0 findings.

## How it was made

- `film/comp.html` — one deterministic, seekable timeline (`__ready`, `__meta`, `__seek`, `__motion`, `__events`, `__handoff`, `__copy`); `?lang=en|zh` picks the cut.
- `film/m3d.html` + `r3d_seq.py` — offline three.js r170 bookends with shutter blur; the end shot reads `__handoff()` so its last frame lands on the vector lockup.
- `render_film.py` — Playwright/Chromium frame renderer with adaptive motion blur averaged in linear light; resumable (skips existing frames, atomic writes) and time-boxed.
- `music.py` — numpy score, 120 BPM, seeded; hits taken from `__events()`. `sound.py` — earshot SFX (pinned to 925ebe56a1b755e5d354ab642bb8f344440cfa9c) placed by measured peak through one shared room.
- `encode.sh` — two-pass loudnorm, H.264 High CRF 16, AAC 256k.
- QA: `scripts/contact_sheet.py`, `stills.py`, `qa_accent.py`, `lint_copy.py`, `handoff_check.py`, `qa_audio.py`, `scan_secrets.py`.

## Rebuild

```sh
cd promo/film
sh setup.sh          # deps, Chromium, three.js r170, earshot @925ebe5, PingFang SF + JetBrains Mono (downloaded, never committed)
sh reproduce.sh      # → deliver/claude-mimic-promo-{en,zh}.rebuild.mp4
```

Versions and seeds are pinned (`requirements.txt`, `fonts.sha256`, score rng 7, SFX jitter 11, room 3). A different Chromium build may move edge pixels slightly, never content or timing. A full rebuild was not re-verified for this delivery.

*An independent community project. Not affiliated with Anthropic.*

## QA (delivered cuts)

| check | EN | ZH |
|---|---|---|
| duration / video | 58.5 s · 1920×1080 · 30 fps · H.264 High · yuv420p · BT.709 | same |
| audio | AAC LC 256 kb/s · 48 kHz · −14.0 LUFS · −1.4 dBTP · LRA 4.8 LU | AAC LC 256 kb/s · 48 kHz · −14.0 LUFS · −1.7 dBTP · LRA 4.8 LU |
| hits (`qa_audio.py`) | 13 of 14 at +20 ms (AAC priming); 46 s reads −60 ms because the detector catches the pre-hit swell — the score's energy steps at 46.00–46.02 s | same |
| handoff (`handoff_check.py`) | 3D end frame vs vector lockup: max edge error 1 px | same layout |
| accent (`qa_accent.py`) | ≤ 1 accent blob per frame except the caret's own motion streaks on the thesis glides | same |
| copy (`lint_copy.py`) | clean | clean |
| secrets (`scan_secrets.py`) | 0 findings | — |

Fixed during QA: the finale dive unwound ~24 rad of accumulated spin in one second (a 4 rev/s wagon wheel that showed as stacked petal copies) — it now keeps the slow spin; the full field got a 20 % size margin (a petal gap left a notch at the frame edge for 4 frames); the typing caret is flagged as a discrete step so the renderer no longer blends two caret positions into a double asterisk; loudnorm targets −2.0 dBTP so the AAC file stays under −1 dBTP.
