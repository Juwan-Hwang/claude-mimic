"""tmux captures (session/caps/*.ansi, recorded by session/capture.sh) → film/data/term.json for the comp's terminal.
Each capture is one beat of the real session. Rows are styled spans (scripts/ansi2json.py). The command rows ('$ ', '> ')
are split from the output rows. Output is shown verbatim; the only edit is cutting rows, marked with an inserted '│  …' row
(the npx skills install: the skill description, the summary/security tables and the two agents that do not support -g)."""
import json, sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))
from ansi2json import parse
CAPS = sys.argv[1] if len(sys.argv) > 1 else 'session/caps'
OUT = sys.argv[2] if len(sys.argv) > 2 else 'film/data/term.json'
def load(name):
    rows = parse(open(f'{CAPS}/{name}.ansi', encoding='utf-8').read())
    txt = lambda r: ''.join(s['t'] for s in r)
    while rows and not txt(rows[0]).strip(): rows.pop(0)
    while rows and txt(rows[-1]).strip() in ('', '$'): rows.pop()
    cmd = []
    while rows and (txt(rows[0]).startswith('$ ') or txt(rows[0]).startswith('> ')):
        cmd.append(txt(rows.pop(0)).rstrip())
    return cmd, rows
ELL = [{'t': '│  …', 'fg': '#666666', 'bg': None, 'b': 0, 'd': 0, 'i': 0, 'inv': 0}]
beats = {}
for name in ['01-before', '03-status', '04-diff', '05-log', '06-add', '07-commit', '08-after', '09-pr', '10-empty', '11-env']:
    beats[name] = load(name)
cmd, rows = load('02-install')
txt = lambda r: ''.join(s['t'] for s in r)
keep = []
for i, r in enumerate(rows):
    keep.append((i, r))
# row indices in the capture (after the command row was split off): see the printout below
T = [txt(r) for r in rows]
def idx(prefix, start=0):
    for i in range(start, len(T)):
        if T[i].startswith(prefix): return i
    raise SystemExit('not found ' + prefix)
a = idx('●  Skill: claude-mimic'); b = idx('◇  79 agents'); c = idx('●  Installing to all agents')
d = idx('◇  Installed 1 skill'); e = idx('├', d); f = idx('└  Done!')
sel = rows[:a + 1] + [ELL] + rows[b - 1:c + 1] + [ELL] + rows[d:e + 1] + [ELL] + rows[f:f + 1]
sel = [r for k, r in enumerate(sel) if not (k == 0 and not txt(r).strip())]
beats['02-install'] = (cmd, sel)
json.dump({k: {'cmd': v[0], 'out': v[1]} for k, v in beats.items()}, open(OUT, 'w'), ensure_ascii=False)
for k, (c_, o) in beats.items():
    print('==', k, c_)
    for j, r in enumerate(o): print('  ', j, txt(r)[:100])
