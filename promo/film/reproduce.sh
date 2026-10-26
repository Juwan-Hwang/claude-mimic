#!/bin/sh
# Rebuild both cuts of the claude-mimic launch film from committed inputs.
#   sh reproduce.sh                 → deliver/claude-mimic-promo-{en,zh}.rebuild.mp4
#   LANGS=zh sh reproduce.sh        → one cut
#   RECAPTURE=1 sh reproduce.sh     → also re-record the terminal session for real (tmux + network for npx skills add);
#                                     hashes and dates in the output will then differ from the committed film
# The 3D frames (film/frames/{open,end}) are not committed; they are rendered here from film/m3d.html (~6 min).
# Audio is seeded (score rng 7, SFX jitter 11, room 3); existing frames are skipped (resumable).
set -e
cd "$(dirname "$0")"
sh setup.sh
(python3 -m http.server 8777 --directory film >/tmp/mimic-film-http.log 2>&1 &)
sleep 1
if [ "${RECAPTURE:-0}" = 1 ]; then sh session/capture.sh && python3 gen/term_data.py session/caps film/data/term.json; fi
[ "$(ls film/frames/end 2>/dev/null | wc -l)" -ge 75 ] || sh run3d.sh
python3 scripts/dump_events.py --comp "comp.html?lang=en" --out audio/events_en.json
python3 music.py --events audio/events_en.json --out audio            # one score for both cuts (identical hits)
for L in ${LANGS:-en zh}; do
  python3 scripts/dump_events.py --comp "comp.html?lang=$L" --out "audio/events_$L.json"
  python3 sound.py --events "audio/events_$L.json" --music audio/music.wav --out "audio/mix_$L.wav"
  LANGS=$L sh run2d.sh
  ./encode.sh "film/out/frames_$L" "audio/mix_$L.wav" "deliver/claude-mimic-promo-$L.rebuild.mp4"
done
