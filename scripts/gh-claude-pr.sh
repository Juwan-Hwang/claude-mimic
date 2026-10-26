#!/usr/bin/env bash
# Claude Mimic - Automated GitHub PR Creator
# Generates authentic, 1:1 Claude Code pull requests using the GitHub CLI (`gh`).
set -euo pipefail

usage() {
  cat << 'EOF'
Usage: ./gh-claude-pr.sh -t "<title>" [-b "<body>"] [options]

Required:
  -t <title>            PR title (under 70 chars, e.g. "fix(stream): close child stdin")

Content Options:
  -b <body>             Full markdown PR body (if omitted, official skeleton is generated)
  -T <type>             Template type if body is omitted: default (Variant A) or lean (Variant B)
  -s <summary>          Summary bullets/text
  -c <changes>          Key changes/fix details (used in bugfix/feature templates)
  -v, -p <testplan>     Test plan / verification checklist
  -C <changelog>        Changelog entry text (omitted by default; included before signature if provided)

Claude Attribution Options:
  -m <model>            Claude model identity:
                          opus55      - Claude Opus 5.5 (default; Claude Code default model since v2.1.280; native 1M)
                          opus55-1m   - Claude Opus 5.5 (1M context)
                          sonnet55    - Claude Sonnet 5.5 (fast everyday tier; native 1M)
                          haiku55     - Claude Haiku 5.5 (lightweight tier; native 1M)
                          sonnet5     - Claude Sonnet 5 (previous generation; native 1M)
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
  -S <signature_mode>   Signature mode:
                          standard   - Standard unadorned "🤖 Generated with [Claude Code](...)" (default)
                          surface    - Surface suffix "🤖 ... via <Surface>" (use with --surface)
                          remote     - Includes authentic session URL (use with --session)
                          enhanced   - Enhanced stats "(XX% N-shotted by model, N memories recalled)" (opt-in)
                          oneshot    - Alias for enhanced
                          changelog  - Legacy pre-v2.1.270 format: wraps release notes before signature
                          undercover - Completely omits AI signature
  --session <id>        Session ID or full URL for remote mode
  --surface <name>      Surface name: cowork, desktop, slack, teams, mobile, actions
  -P <prompt_count>     User prompt count for enhanced attribution (opt-in). Default: 0
  --percent <pct>       Claude contribution percentage for enhanced attribution. Default: 0
  -M <memories>         Memories recalled count. Default: 0
  --legacy-url          Use legacy product URL (https://claude.ai/code) for pre-Q3 2025 repos
  --reviewer <name>     GitHub reviewer handle (default: none; opt-in only)
  --no-reviewer         Legacy no-op flag for backwards compatibility
  --dry-run             Print the PR title and markdown body without executing `gh`
  --base <branch>       Base branch for the pull request (e.g. main, master)
  --draft               Create pull request as draft
  -h, --help            Show this help message
EOF
  exit 1
}

TITLE=""
BODY=""
TEMPLATE_TYPE="default"
SUMMARY=""
CHANGES=""
VERIFICATION=""
CHANGELOG_TEXT=""
MODEL="opus55"
SIG_MODE="standard"
SESSION_ID=""
SURFACE_ARG=""
PROMPT_COUNT=0
PERCENT=0
MEMORY_COUNT=0
USE_LEGACY_URL=false
REVIEWER=""
DRY_RUN=false
BASE_BRANCH=""
IS_DRAFT=false

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--title) TITLE="$2"; shift 2 ;;
    -b|--body) BODY="$2"; shift 2 ;;
    -T|--type) TEMPLATE_TYPE="$2"; shift 2 ;;
    -s|--summary) SUMMARY="$2"; shift 2 ;;
    -c|--changes) CHANGES="$2"; shift 2 ;;
    -v|-p|--verification|--test-plan) VERIFICATION="$2"; shift 2 ;;
    -C|--changelog) CHANGELOG_TEXT="$2"; shift 2 ;;
    -m|--model) MODEL="$2"; shift 2 ;;
    -S|--mode|--signature-mode) SIG_MODE="$2"; shift 2 ;;
    --session|--session-id) SESSION_ID="$2"; shift 2 ;;
    --surface) SURFACE_ARG="$2"; shift 2 ;;
    -P|--prompts|--prompt-count) PROMPT_COUNT="$2"; shift 2 ;;
    --percent) PERCENT="$2"; shift 2 ;;
    -M|--memories) MEMORY_COUNT="$2"; shift 2 ;;
    --legacy-url) USE_LEGACY_URL=true; shift ;;
    --reviewer) REVIEWER="$2"; shift 2 ;;
    --no-reviewer) REVIEWER=""; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --base) BASE_BRANCH="$2"; shift 2 ;;
    --draft) IS_DRAFT=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1" >&2; usage ;;
  esac
done

if [[ -z "$TITLE" ]]; then
  echo "Error: -t (title) is required." >&2
  usage
fi

# Claude Code Title Length Rule: < 70 chars
if [[ ${#TITLE} -gt 70 ]]; then
  echo "Notice: PR title exceeds 70 characters (${#TITLE} chars). Claude Code guidelines keep titles under 70 characters." >&2
fi

PRODUCT_URL="https://claude.com/claude-code"
if $USE_LEGACY_URL; then
  PRODUCT_URL="https://claude.ai/code"
fi

# Map model identifiers.
# MODEL_SLUG mirrors the external-repo name Claude Code v2.1.310 prints in the P2
# "-shotted by" line: the first entry of its model table whose key the model ID
# contains, else "claude" (legacy IDs like claude-3-7-sonnet-* match no entry).
case "$MODEL" in
  opus55)       MODEL_SLUG="claude-opus-5-5";   MODEL_NAME="Claude Opus 5.5" ;;
  opus55-1m)    MODEL_SLUG="claude-opus-5-5";   MODEL_NAME="Claude Opus 5.5 (1M context)" ;;
  sonnet55)     MODEL_SLUG="claude-sonnet-5-5"; MODEL_NAME="Claude Sonnet 5.5" ;;
  haiku55)      MODEL_SLUG="claude-haiku-5-5";  MODEL_NAME="Claude Haiku 5.5" ;;
  sonnet5)      MODEL_SLUG="claude-sonnet-5";   MODEL_NAME="Claude Sonnet 5" ;;
  sonnet46)     MODEL_SLUG="claude-sonnet-4-6"; MODEL_NAME="Claude Sonnet 4.6" ;;
  sonnet46-1m)  MODEL_SLUG="claude-sonnet-4-6"; MODEL_NAME="Claude Sonnet 4.6 (1M context)" ;;
  sonnet45)     MODEL_SLUG="claude-sonnet-4-5"; MODEL_NAME="Claude Sonnet 4.5" ;;
  sonnet45-1m)  MODEL_SLUG="claude-sonnet-4-5"; MODEL_NAME="Claude Sonnet 4.5 (1M context)" ;;
  sonnet4)      MODEL_SLUG="claude-sonnet-4"  ; MODEL_NAME="Claude Sonnet 4" ;;
  sonnet4-1m)   MODEL_SLUG="claude-sonnet-4"  ; MODEL_NAME="Claude Sonnet 4 (1M context)" ;;
  sonnet37)     MODEL_SLUG="claude"           ; MODEL_NAME="Claude Sonnet 3.7" ;;
  sonnet35)     MODEL_SLUG="claude"           ; MODEL_NAME="Claude Sonnet 3.5" ;;
  fable5)       MODEL_SLUG="claude-fable-5";    MODEL_NAME="Claude Fable 5" ;;
  fable51)      MODEL_SLUG="claude-fable-5-1";  MODEL_NAME="Claude Fable 5.1" ;;
  opus5)        MODEL_SLUG="claude-opus-5";     MODEL_NAME="Claude Opus 5" ;;
  opus5-1m)     MODEL_SLUG="claude-opus-5";     MODEL_NAME="Claude Opus 5 (1M context)" ;;
  opus48)       MODEL_SLUG="claude-opus-4-8";   MODEL_NAME="Claude Opus 4.8" ;;
  opus48-1m)    MODEL_SLUG="claude-opus-4-8";   MODEL_NAME="Claude Opus 4.8 (1M context)" ;;
  opus47)       MODEL_SLUG="claude-opus-4-7";   MODEL_NAME="Claude Opus 4.7" ;;
  opus47-1m)    MODEL_SLUG="claude-opus-4-7";   MODEL_NAME="Claude Opus 4.7 (1M context)" ;;
  opus46)       MODEL_SLUG="claude-opus-4-6";   MODEL_NAME="Claude Opus 4.6" ;;
  opus46-1m)    MODEL_SLUG="claude-opus-4-6";   MODEL_NAME="Claude Opus 4.6 (1M context)" ;;
  opus45)       MODEL_SLUG="claude-opus-4-5";   MODEL_NAME="Claude Opus 4.5" ;;
  opus45-1m)    MODEL_SLUG="claude-opus-4-5";   MODEL_NAME="Claude Opus 4.5 (1M context)" ;;
  opus41)       MODEL_SLUG="claude-opus-4-1";   MODEL_NAME="Claude Opus 4.1" ;;
  opus41-1m)    MODEL_SLUG="claude-opus-4-1";   MODEL_NAME="Claude Opus 4.1 (1M context)" ;;
  opus4)        MODEL_SLUG="claude-opus-4"  ;   MODEL_NAME="Claude Opus 4" ;;
  opus4-1m)     MODEL_SLUG="claude-opus-4"  ;   MODEL_NAME="Claude Opus 4 (1M context)" ;;
  haiku45)      MODEL_SLUG="claude-haiku-4-5";  MODEL_NAME="Claude Haiku 4.5" ;;
  haiku45-1m)   MODEL_SLUG="claude-haiku-4-5";  MODEL_NAME="Claude Haiku 4.5 (1M context)" ;;
  haiku35)      MODEL_SLUG="claude"          ;  MODEL_NAME="Claude Haiku 3.5" ;;
  mythos5)      MODEL_SLUG="claude-mythos-5";   MODEL_NAME="Claude Mythos 5" ;;
  mythos51)     MODEL_SLUG="claude-mythos-5-1"; MODEL_NAME="Claude Mythos 5.1" ;;
  claudecode|claude-code) MODEL_SLUG="claude-code"; MODEL_NAME="Claude Code" ;;
  claude)       MODEL_SLUG="claude";            MODEL_NAME="Claude" ;;
  *)
    MODEL_SLUG="claude"
    MODEL_NAME="Claude Code"
    ;;
esac

# Map Surface Name strictly to the Claude Code surface switch (iRr() in v2.1.270, Rpi() in v2.1.310; cases unchanged)
get_surface_display() {
  case "$1" in
    cowork|remote_cowork|local-agent) echo "Cowork" ;;
    desktop|claude-desktop|claude-desktop-3p|remote_desktop) echo "Claude Desktop" ;;
    slack|claude_in_slack|claude-in-slack) echo "Claude Tag in Slack" ;;
    teams|claude-in-teams) echo "Claude Tag in Teams" ;;
    mobile|remote_mobile) echo "Mobile" ;;
    actions|claude-code-github-action) echo "GitHub Actions" ;;
    *) echo "$1" ;;
  esac
}

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

if [[ -n "$SESSION_ID" && "$SIG_MODE" == "standard" ]]; then
  SIG_MODE="remote"
fi
if [[ -n "$SURFACE_ARG" && "$SIG_MODE" == "standard" ]]; then
  SIG_MODE="surface"
fi

# Generate Signature Block
generate_signature() {
  case "$SIG_MODE" in
    standard)
      printf "\n🤖 Generated with [Claude Code](%s)" "$PRODUCT_URL"
      ;;
    surface)
      local sName
      sName=$(get_surface_display "${SURFACE_ARG:-cowork}")
      printf "\n🤖 Generated with [Claude Code](%s) via %s" "$PRODUCT_URL" "$sName"
      ;;
    remote)
      local session_url
      if [[ -n "$SESSION_ID" ]]; then
        if [[ "$SESSION_ID" =~ ^https:// ]]; then
          session_url="$SESSION_ID"
        else
          session_url="https://claude.ai/code/$SESSION_ID"
        fi
      else
        local session_id
        session_id=$(generate_claude_session)
        session_url="https://claude.ai/code/$session_id"
      fi
      printf "\n🤖 Generated with [Claude Code](%s)\n\n%s" "$PRODUCT_URL" "$session_url"
      ;;
    enhanced|oneshot)
      if [[ "$PERCENT" -eq 0 && "$PROMPT_COUNT" -eq 0 && "$MEMORY_COUNT" -eq 0 ]]; then
        printf "\n🤖 Generated with [Claude Code](%s)" "$PRODUCT_URL"
      else
        local mem_suffix=""
        if [[ "$MEMORY_COUNT" -gt 0 ]]; then
          if [[ "$MEMORY_COUNT" -eq 1 ]]; then
            mem_suffix=", 1 memory recalled"
          else
            mem_suffix=", ${MEMORY_COUNT} memories recalled"
          fi
        fi
        printf "\n🤖 Generated with [Claude Code](%s) (%s%% %s-shotted by %s%s)" "$PRODUCT_URL" "$PERCENT" "$PROMPT_COUNT" "$MODEL_SLUG" "$mem_suffix"
      fi
      ;;
    remote_attached|hosted|mode8|p8)
      local sid="${SESSION_ID:-$(generate_claude_session)}"
      [[ "$sid" != http* ]] && sid="https://claude.ai/code/$sid"
      printf "\n🤖 Generated with [Claude Code](%s)\n\n%s\n\n---\n_Generated by [Claude Code](%s)_" "$PRODUCT_URL" "$sid" "$sid"
      ;;
    changelog)
      printf "\n🤖 Generated with [Claude Code](%s)" "$PRODUCT_URL"
      ;;
    undercover)
      printf ""
      ;;
    *)
      printf "\n🤖 Generated with [Claude Code](%s)" "$PRODUCT_URL"
      ;;
  esac
}

SIG=$(generate_signature)

if [[ -n "$BODY" ]]; then
  FINAL_BODY="$BODY"
  if [[ ("$SIG_MODE" == "changelog" || -n "$CHANGELOG_TEXT") && "$FINAL_BODY" != *"<!-- CHANGELOG:START -->"* ]]; then
    CHANGELOG_SECTION=$(printf "\n\n## Changelog\n<!-- CHANGELOG:START -->\n- %s\n<!-- CHANGELOG:END -->" "${CHANGELOG_TEXT:-$TITLE}")
    FINAL_BODY="${FINAL_BODY}${CHANGELOG_SECTION}"
  fi
  if [[ -n "$SIG" && "$FINAL_BODY" != *"Generated with"* ]]; then
    FINAL_BODY="${FINAL_BODY}

${SIG#$'\n'}"
  fi
else
  # Default fallbacks (matching official Claude Code placeholders)
  [[ -z "$SUMMARY" ]] && SUMMARY="<1-3 bullet points>"
  [[ -z "$VERIFICATION" ]] && VERIFICATION="[Bulleted markdown checklist of TODOs for testing the pull request...]"

  # Changelog is omitted by default; only included if explicitly requested or provided
  CHANGELOG_SECTION=""
  if [[ "$SIG_MODE" == "changelog" || -n "$CHANGELOG_TEXT" ]]; then
    CHANGELOG_SECTION=$(printf "\n\n## Changelog\n<!-- CHANGELOG:START -->\n- %s\n<!-- CHANGELOG:END -->" "${CHANGELOG_TEXT:-$TITLE}")
  fi

  case "$TEMPLATE_TYPE" in
    lean)
      [[ "$SUMMARY" == "<1-3 bullet points>" ]] && SUMMARY="<1-2 plain sentences: what this change does and why>"
      [[ "$VERIFICATION" == "[Bulleted markdown checklist of TODOs for testing the pull request...]" ]] && VERIFICATION="<1-2 lines: what you verified and how (commands run, behavior observed); note anything unverified>"
      FINAL_BODY=$(cat <<EOF
## Summary
$SUMMARY

## Test plan
$VERIFICATION$CHANGELOG_SECTION
$SIG
EOF
)
      ;;
    *)
      FINAL_BODY=$(cat <<EOF
## Summary
$SUMMARY

## Test plan
$VERIFICATION$CHANGELOG_SECTION
$SIG
EOF
)
      ;;
  esac
fi

if $DRY_RUN; then
  echo "=========================================="
  echo "Claude Mimic - PR Dry Run"
  echo "Title: $TITLE (${#TITLE} chars)"
  if [[ -n "$BASE_BRANCH" ]]; then echo "Base:  $BASE_BRANCH"; fi
  if $IS_DRAFT; then echo "Draft: Yes"; fi
  echo "=========================================="
  echo "$FINAL_BODY"
  echo "=========================================="
  exit 0
fi

# Ensure gh is available
if ! command -v gh &>/dev/null; then
  echo "Error: GitHub CLI ('gh') is not installed or not in PATH." >&2
  exit 1
fi

# Check if PR already exists
EXISTING_PR=$(gh pr view --json number -q .number 2>/dev/null || true)

if [[ -n "$EXISTING_PR" ]]; then
  echo "Existing PR #$EXISTING_PR found. Updating via 'gh pr edit'..."
  EDIT_ARGS=("--title" "$TITLE" "--body" "$FINAL_BODY")
  if [[ -n "$REVIEWER" ]]; then
    EDIT_ARGS+=("--add-reviewer" "$REVIEWER")
  fi
  gh pr edit "$EXISTING_PR" "${EDIT_ARGS[@]}"
else
  echo "Creating new authentic Claude Code Pull Request via 'gh pr create'..."
  CREATE_ARGS=("--title" "$TITLE" "--body" "$FINAL_BODY")
  if [[ -n "$BASE_BRANCH" ]]; then
    CREATE_ARGS+=("--base" "$BASE_BRANCH")
  fi
  if $IS_DRAFT; then
    CREATE_ARGS+=("--draft")
  fi
  if [[ -n "$REVIEWER" ]]; then
    CREATE_ARGS+=("--reviewer" "$REVIEWER")
  fi
  gh pr create "${CREATE_ARGS[@]}"
fi
