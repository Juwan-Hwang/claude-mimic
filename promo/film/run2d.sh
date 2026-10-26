#!/bin/sh
# 2D frames for both cuts. Real shutter blur, enough samples that nothing strobes: 16 sub-frames whenever the camera,
# the carry or the reel travels more than 12 px across the 180° shutter; 24 on the two full-frame field zooms.
cd "$(dirname "$0")"
for L in ${LANGS:-en zh}; do
  python3 render_film.py --comp "comp.html?lang=$L" --out film/out/frames_$L --workers 2 --from 180 --to 192 --sub 24 --gap 6 --max-seconds 100000
  python3 render_film.py --comp "comp.html?lang=$L" --out film/out/frames_$L --workers 2 --from 1466 --to 1500 --sub 24 --gap 6 --max-seconds 100000
  python3 render_film.py --comp "comp.html?lang=$L" --out film/out/frames_$L --workers 2 --sub 16 --gap 12 --max-seconds 100000
done
echo R2D_DONE
