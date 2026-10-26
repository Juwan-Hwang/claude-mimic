#!/bin/sh
# One-time setup (safe to re-run): Python deps + Chromium, three.js r170, earshot @ 925ebe5, fonts, and the logo.
# No font binary is committed on this branch: PingFang SF comes from github.com/Juwan-Hwang/PingFang-SF (or $PFSF),
# JetBrains Mono from its v2.304 release. The logo is this repo's own logo.png (two folders up).
set -e
cd "$(dirname "$0")"
pip install -q -r requirements.txt
python3 -m playwright install --with-deps chromium || python3 -m playwright install chromium
command -v tmux >/dev/null || echo "note: tmux is only needed to re-record the session (RECAPTURE=1)"
fc-list | grep -qi "Noto Color Emoji" || echo "note: install fonts-noto-color-emoji so the 🤖 in the PR body renders"
[ -d film/node_modules/three ] || npm install --silent --no-save --prefix film three@0.170.0
mkdir -p film/fonts film/brand
cp ../../logo.png film/brand/logo.png
if [ ! -f film/fonts/PingFangSF.ttf ]; then
  if [ -n "$PFSF" ]; then cp "$PFSF" film/fonts/PingFangSF.ttf
  else curl -fsSL -o film/fonts/PingFangSF.ttf "https://github.com/Juwan-Hwang/PingFang-SF/raw/main/PingFang-SF%20Medium.ttf"; fi
fi
if [ ! -f film/fonts/JetBrainsMono-Regular.ttf ]; then
  curl -fsSL -o /tmp/jbm.zip https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
  python3 -c "import zipfile;z=zipfile.ZipFile('/tmp/jbm.zip');[open('film/fonts/'+n.split('/')[-1],'wb').write(z.read(n)) for n in z.namelist() if n.endswith(('ttf/JetBrainsMono-Regular.ttf','ttf/JetBrainsMono-Bold.ttf'))]"
fi
# the film was rendered with these exact files
sha256sum -c fonts.sha256 || echo "warning: a font differs from the one the film was rendered with (metrics may shift)"
if [ ! -d repos/earshot ]; then
  git clone -q https://github.com/Leonxlnx/earshot repos/earshot
  git -C repos/earshot checkout -q 925ebe56a1b755e5d354ab642bb8f344440cfa9c
fi
pip install -q --no-deps -e repos/earshot
[ -f film/data/star.json ] || python3 gen/trace_star.py ../../logo.png film/data/star.json
echo "setup ok: python3 -m http.server 8777 --directory film, then open http://localhost:8777/comp.html?lang=en&t=0"
