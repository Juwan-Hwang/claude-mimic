"""Trace the orange asterisk out of the repo's logo.png into an SVG path (the film's carry element and 3D geometry).

1. mask = the logo's own orange (#E97F57 ± tolerance), lightly closed;
2. the mascot's two hands overlap two arms (and leave a shadow notch): every arm is fitted with a tapered capsule
   (PCA axis, robust per-slice widths) and the capsules, shrunk by 2 px, are OR-ed into the mask, which fills the dents
   without moving any edge the hands don't touch;
3. smoothed at 4×, traced with OpenCV, simplified to ~0.35 px.
Output: film/data/star.json {d, w, h, cx, cy, bbox, color, arms} in logo pixels (y down)."""
import json, sys
import numpy as np, cv2
from PIL import Image
src, out = sys.argv[1], sys.argv[2]
im = np.asarray(Image.open(src).convert('RGBA')).astype(int)
r, g, b, a = im[..., 0], im[..., 1], im[..., 2], im[..., 3]
m = ((r > 200) & (g > 90) & (g < 150) & (b > 50) & (b < 120) & (a > 200)).astype(np.uint8) * 255
col = np.median(im[m > 0][:, :3], axis=0).astype(int)
m = cv2.morphologyEx(m, cv2.MORPH_CLOSE, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7, 7)))
n, lab, stats, _ = cv2.connectedComponentsWithStats(m)
m = (lab == 1 + np.argmax(stats[1:, cv2.CC_STAT_AREA])).astype(np.uint8) * 255
M = cv2.moments(m); cx, cy = M['m10'] / M['m00'], M['m01'] / M['m00']
ys, xs = np.nonzero(m); ang = np.degrees(np.arctan2(ys - cy, xs - cx)) % 360; rad = np.hypot(xs - cx, ys - cy)
# arm directions: peaks of the outer radius per degree
rmax = np.zeros(360)
for d in range(360):
    sel = (np.abs(((ang - d + 180) % 360) - 180) < 0.5)
    rmax[d] = rad[sel].max() if sel.any() else 0
sm = np.convolve(np.r_[rmax[-5:], rmax, rmax[:5]], np.ones(5) / 5, 'same')[5:-5]
peaks = [d for d in range(360) if sm[d] == max(sm[(d + k) % 360] for k in range(-12, 13)) and sm[d] > 300]
arms = []
K = np.zeros_like(m)
for i, p in enumerate(peaks):
    lo, hi = peaks[i - 1], peaks[(i + 1) % len(peaks)]
    gl, gh = ((p - lo) % 360) / 2, ((hi - p) % 360) / 2
    dd = (ang - p + 180) % 360 - 180
    sel = (dd > -gl * 0.8) & (dd < gh * 0.8) & (rad > 230)
    P = np.stack([xs[sel], ys[sel]], 1).astype(float); c0 = P.mean(0)
    u, s_, vt = np.linalg.svd(P - c0, full_matrices=False); ax = vt[0]
    if np.dot(ax, c0 - [cx, cy]) < 0: ax = -ax
    nrm = np.array([-ax[1], ax[0]])
    tt = (P - c0) @ ax; ss = (P - c0) @ nrm
    t0, t1 = tt.min(), tt.max(); bins = np.linspace(t0 + 0.15 * (t1 - t0), t1 - 0.12 * (t1 - t0), 16)
    L, R, T = [], [], []
    for k in range(len(bins) - 1):
        q = (tt >= bins[k]) & (tt < bins[k + 1])
        if q.sum() < 20: continue
        L.append(ss[q].min()); R.append(ss[q].max()); T.append((bins[k] + bins[k + 1]) / 2)
    L, R, T = np.array(L), np.array(R), np.array(T)
    W = R - L; good = W >= np.percentile(W, 40)
    A = np.polyfit(T[good], W[good] / 2, 1); mid = np.median(((L + R) / 2)[good])
    base = c0 + ax * (t0 - 60) + nrm * mid; hw0 = np.polyval(A, t0 - 60)
    wt = np.polyval(A, t1); tipc = c0 + ax * (t1 - wt) + nrm * mid
    hw1 = np.polyval(A, t1 - wt)
    poly = np.array([base + nrm * hw0, tipc + nrm * hw1, tipc - nrm * hw1, base - nrm * hw0])
    S = 4
    cv2.fillConvexPoly(K, np.round(poly * S).astype(np.int32) if False else np.round(poly).astype(np.int32), 255)
    cv2.circle(K, tuple(np.round(tipc).astype(int)), int(round(hw1)), 255, -1)
    arms.append({'deg': p, 'tip': tipc.tolist(), 'hw': [float(hw0), float(hw1)]})
K = cv2.erode(K, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5)))
m2 = np.maximum(m, K)
m2 = cv2.morphologyEx(m2, cv2.MORPH_OPEN, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (9, 9)))   # drop any remaining finger bumps
S = 4
big = cv2.resize(m2, None, fx=S, fy=S, interpolation=cv2.INTER_LINEAR)
big = cv2.GaussianBlur(big, (0, 0), 2.5 * S)
_, big = cv2.threshold(big, 127, 255, cv2.THRESH_BINARY)
cs, _ = cv2.findContours(big, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
c = max(cs, key=cv2.contourArea)
c = cv2.approxPolyDP(c, 0.35 * S, True)[:, 0, :] / S
d = 'M' + 'L'.join(f'{x:.2f} {y:.2f}' for x, y in c) + 'Z'
x0, y0 = c.min(0); x1, y1 = c.max(0)
json.dump({'d': d, 'n': len(c), 'w': im.shape[1], 'h': im.shape[0], 'cx': cx, 'cy': cy, 'arms': arms,
           'bbox': [float(x0), float(y0), float(x1), float(y1)], 'color': '#%02X%02X%02X' % tuple(col)}, open(out, 'w'))
print('arms', len(arms), 'points', len(c), 'centre', round(cx, 1), round(cy, 1), 'bbox', x0, y0, x1, y1, 'colour', col, 'filled px', int(((m2 > 0) & (m == 0)).sum()))
