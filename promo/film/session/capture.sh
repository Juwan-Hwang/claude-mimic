#!/usr/bin/env bash
# Record the film's terminal for real: one tmux pane (100×30), a clean bash with HOME=session/home, every command
# typed with send-keys and the pane captured with colours (capture-pane -e) after it settles → caps/NN-name.ansi
set -euo pipefail
cd "$(dirname "$0")"
./setup_demo.sh >/dev/null
S=mimic; W=108; H=30
export HOME="$PWD/home" GIT_CONFIG_GLOBAL="$PWD/home/.gitconfig"
mkdir -p caps
tmux kill-session -t $S 2>/dev/null || true
tmux new-session -d -s $S -x $W -y $H -c "$PWD/demo" "env -i HOME=$HOME GIT_CONFIG_GLOBAL=$GIT_CONFIG_GLOBAL TERM=xterm-256color TZ=Asia/Shanghai npm_config_yes=true npm_config_update_notifier=false PATH=$HOME/bin:/usr/local/bin:/usr/bin:/bin LANG=C.UTF-8 PS1='\$ ' bash --norc --noprofile"
sleep 0.5
run() {  # run NAME WAIT CMD  (clear first so each capture is one beat)
  local name=$1 wait=$2; shift 2
  tmux send-keys -t $S "clear" Enter; sleep 0.3; tmux clear-history -t $S
  tmux send-keys -t $S -l "$*"; tmux send-keys -t $S Enter
  sleep "$wait"
  tmux capture-pane -t $S -S -300 -e -p > "caps/$name.ansi"
  tmux capture-pane -t $S -S -300 -p > "caps/$name.txt"
  echo "== $name"; cat "caps/$name.txt" | sed '/^$/d'
}
run 01-before 1 'git log -1 plain'
run 02-install 60 'npx skills add Juwan-Hwang/claude-mimic -g -y'
run 03-status 1 'git status'
run 04-diff 1 'git diff HEAD'
run 05-log 1 'git log --oneline -10'
run 06-add 1 'git add src/token.js'
run 07-commit 2 'git-claude-commit -t "fix(auth): handle token expiration gracefully" \
  -b "Expired tokens threw instead of returning null, so callers could not refresh."'
run 08-after 1 'git log -1'
run 09-pr 2 'gh-claude-pr --dry-run -t "fix(auth): handle token expiration gracefully" \
  -s "- Handle expired session tokens gracefully in auth middleware" -p "- [x] Run unit test suite"'
run 10-empty 1 'git-claude-commit -t "chore: tidy up" -b "Nothing to see here."'
tmux send-keys -t $S 'printf "DEBUG=1\\n" > .env' Enter; sleep 0.3
run 11-env 1 'git add .env && git-claude-commit -t "chore: add env" -b "Local settings."'
tmux send-keys -t $S "git reset -q .env && rm .env" Enter; sleep 0.3
tmux kill-session -t $S
