#!/usr/bin/env bash
# Git commit helper script for Claude Mimic
# Adheres to Claude Code's official Git Safety Protocol
set -euo pipefail

usage() {
  cat << 'EOF'
Usage: ./git-claude-commit.sh -t "<title>" -b "<body>" [-m <model>] [options]

Required:
  -t <title>            Commit title (e.g. "fix(evals): close child stdin")
  -b <body>             Commit body (1-2 sentences focusing on 'why')

Options:
  -m <model>            Model tier:
                          sonnet5     - Claude Sonnet 5 (default everyday workhorse; native 1M)
                          sonnet46    - Claude Sonnet 4.6 (previous generation)
                          sonnet46-1m - Claude Sonnet 4.6 (1M context)
                          sonnet45    - Claude Sonnet 4.5
                          sonnet45-1m - Claude Sonnet 4.5 (1M context)
                          sonnet4     - Claude Sonnet 4
                          sonnet4-1m  - Claude Sonnet 4 (1M context)
                          fable5      - Claude Fable 5 (native 1M)
                          fable51     - Claude Fable 5.1 (native 1M)
                          opus5       - Claude Opus 5
                          opus5-1m    - Claude Opus 5 (1M context)
                          opus48      - Claude Opus 4.8
                          opus48-1m   - Claude Opus 4.8 (1M context)
                          opus47      - Claude Opus 4.7
                          opus47-1m   - Claude Opus 4.7 (1M context)
                          opus46      - Claude Opus 4.6
                          opus46-1m   - Claude Opus 4.6 (1M context)
                          opus45      - Claude Opus 4.5
                          opus45-1m   - Claude Opus 4.5 (1M context)
                          opus41      - Claude Opus 4.1
                          opus41-1m   - Claude Opus 4.1 (1M context)
                          opus4       - Claude Opus 4
                          opus4-1m    - Claude Opus 4 (1M context)
                          haiku45     - Claude Haiku 4.5
                          haiku45-1m  - Claude Haiku 4.5 (1M context)
                          sonnet37    - Claude Sonnet 3.7
                          sonnet35    - Claude Sonnet 3.5
                          haiku35     - Claude Haiku 3.5
                          mythos5     - Claude Mythos 5 (native 1M)
                          mythos51    - Claude Mythos 5.1 (native 1M)
                          claudecode  - Claude Code (universal third-party/unknown fallback)
                          claude      - Generic Claude (fable codename/internal fallback)
  -s, --session <id>    Session ID for remote web session (appends Claude-Session: trailer)
  --auto-session        Automatically generate a 32-character Claude session ID
  -l, --lowercase       Use lowercase 'Co-authored-by:' format (for repositories requiring lowercase trailers)
  -n                    Pass --no-gpg-sign to git commit
  --dry-run             Display the constructed commit message without committing
  -h, --help            Show this help message
EOF
  exit 1
}

TITLE=""
BODY=""
MODEL="sonnet5"
SESSION_ID=""
AUTO_SESSION=false
USE_LOWERCASE=false
NO_GPGSIGN=false
DRY_RUN=false

# Authentic 32-character Claude Bitcoin Base58 Session ID Generator (session_01 + 22 chars)
# Alphabet: 58 characters [1-9, A-Z excl I/O, a-z excl l]
generate_claude_session() {
  local chars="123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
  local id="session_01"
  for i in $(seq 1 22 2>/dev/null || echo 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22); do
    local rand_val=${RANDOM:-$$}
    local idx=$(( rand_val % 58 ))
    id="${id}${chars:$idx:1}"
  done
  echo "$id"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t) TITLE="$2"; shift 2 ;;
    -b) BODY="$2"; shift 2 ;;
    -m) MODEL="$2"; shift 2 ;;
    -s|--session) SESSION_ID="$2"; shift 2 ;;
    --auto-session) AUTO_SESSION=true; shift ;;
    -l|--lowercase) USE_LOWERCASE=true; shift ;;
    -n) NO_GPGSIGN=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1" >&2; usage ;;
  esac
done

if [[ -z "$TITLE" || -z "$BODY" ]]; then
  echo "Error: -t (title) and -b (body) are required." >&2
  usage
fi

case "$MODEL" in
  sonnet5)     MODEL_NAME="Claude Sonnet 5" ;;
  sonnet46)    MODEL_NAME="Claude Sonnet 4.6" ;;
  sonnet46-1m) MODEL_NAME="Claude Sonnet 4.6 (1M context)" ;;
  sonnet45)    MODEL_NAME="Claude Sonnet 4.5" ;;
  sonnet45-1m) MODEL_NAME="Claude Sonnet 4.5 (1M context)" ;;
  sonnet4)     MODEL_NAME="Claude Sonnet 4" ;;
  sonnet4-1m)  MODEL_NAME="Claude Sonnet 4 (1M context)" ;;
  fable5)      MODEL_NAME="Claude Fable 5" ;;
  fable51)     MODEL_NAME="Claude Fable 5.1" ;;
  opus5)       MODEL_NAME="Claude Opus 5" ;;
  opus5-1m)    MODEL_NAME="Claude Opus 5 (1M context)" ;;
  opus48)      MODEL_NAME="Claude Opus 4.8" ;;
  opus48-1m)   MODEL_NAME="Claude Opus 4.8 (1M context)" ;;
  opus47)      MODEL_NAME="Claude Opus 4.7" ;;
  opus47-1m)   MODEL_NAME="Claude Opus 4.7 (1M context)" ;;
  opus46)      MODEL_NAME="Claude Opus 4.6" ;;
  opus46-1m)   MODEL_NAME="Claude Opus 4.6 (1M context)" ;;
  opus45)      MODEL_NAME="Claude Opus 4.5" ;;
  opus45-1m)   MODEL_NAME="Claude Opus 4.5 (1M context)" ;;
  opus41)      MODEL_NAME="Claude Opus 4.1" ;;
  opus41-1m)   MODEL_NAME="Claude Opus 4.1 (1M context)" ;;
  opus4)       MODEL_NAME="Claude Opus 4" ;;
  opus4-1m)    MODEL_NAME="Claude Opus 4 (1M context)" ;;
  haiku45)     MODEL_NAME="Claude Haiku 4.5" ;;
  haiku45-1m)  MODEL_NAME="Claude Haiku 4.5 (1M context)" ;;
  sonnet37)    MODEL_NAME="Claude Sonnet 3.7" ;;
  sonnet35)    MODEL_NAME="Claude Sonnet 3.5" ;;
  haiku35)     MODEL_NAME="Claude Haiku 3.5" ;;
  mythos5)     MODEL_NAME="Claude Mythos 5" ;;
  mythos51)    MODEL_NAME="Claude Mythos 5.1" ;;
  claudecode|claude-code) MODEL_NAME="Claude Code" ;;
  claude)      MODEL_NAME="Claude" ;;
  *)
    echo "Unknown model '$MODEL'. Defaulting to Claude Code." >&2
    MODEL_NAME="Claude Code"
    ;;
esac

PREFIX="Co-Authored-By"
if $USE_LOWERCASE; then
  PREFIX="Co-authored-by"
fi

TRAILER="${PREFIX}: ${MODEL_NAME} <noreply@anthropic.com>"

SUPPRESS_SESSION="${CLAUDE_CODE_SUPPRESS_SESSION_ATTRIBUTION:-0}"
if [[ "$SUPPRESS_SESSION" != "1" && "$SUPPRESS_SESSION" != "true" ]]; then
  if [[ -z "$SESSION_ID" && "$AUTO_SESSION" = true ]]; then
    SESSION_ID=$(generate_claude_session)
  fi
  if [[ -n "$SESSION_ID" ]]; then
    if [[ "$SESSION_ID" =~ ^https:// ]]; then
      SESSION_URL="$SESSION_ID"
    else
      SESSION_URL="https://claude.ai/code/$SESSION_ID"
    fi
    TRAILER="${TRAILER}
Claude-Session: ${SESSION_URL}"
  fi
fi

COMMIT_MSG=$(cat <<EOF
$TITLE

$BODY

$TRAILER
EOF
)

if $DRY_RUN; then
  echo "=========================================="
  echo "Claude Mimic - Commit Dry Run"
  echo "=========================================="
  echo "$COMMIT_MSG"
  echo "=========================================="
  exit 0
fi

# Git Safety Protocol: Ensure git repository
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "Error: Not inside a git repository." >&2
  exit 1
fi

# Git Safety Protocol: Check if staged changes exist
if git diff --cached --quiet; then
  echo "Git Safety Protocol: No staged changes found. Claude Code will not create empty commits." >&2
  echo "Please stage files using 'git add' before committing." >&2
  exit 1
fi

# Git Safety Protocol: Check for likely secret files
STAGED_SECRETS=$(git diff --cached --name-only | grep -E "(\.env|\.credentials|credentials\.json|id_rsa|private_key|\.pem)$" || true)
if [[ -n "$STAGED_SECRETS" ]]; then
  echo "Git Safety Protocol Warning: The following staged files likely contain secrets:" >&2
  echo "$STAGED_SECRETS" >&2
  echo "Commit aborted to protect sensitive credentials." >&2
  exit 1
fi

echo "Creating commit with:"
echo "$TRAILER"

COMMIT_ARGS=("-m" "$COMMIT_MSG")
if $NO_GPGSIGN; then
  COMMIT_ARGS+=("--no-gpg-sign")
fi

git commit "${COMMIT_ARGS[@]}"
