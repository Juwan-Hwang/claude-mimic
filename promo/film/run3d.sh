#!/bin/sh
# 3D frames: open 6 s (5-sample shutter, 14 on the spin-open swing), end 2.5 s (7 samples), handoff read from the comp.
# Needs the film/ folder served on :8777 (reproduce.sh starts it).
cd "$(dirname "$0")"
python3 r3d_seq.py open 6.0 film/frames/open --page m3d.html --sub 5 --to 57
python3 r3d_seq.py open 6.0 film/frames/open --page m3d.html --sub 14 --from 57 --to 105
python3 r3d_seq.py open 6.0 film/frames/open --page m3d.html --sub 6 --from 105
python3 r3d_seq.py end 2.5 film/frames/end --page m3d.html --sub 7 --handoff "comp.html?lang=en"
echo R3D_DONE
