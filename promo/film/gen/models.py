"""The model reel: every trailer name in claude-mimic's references/model-matrix.md table
("22 Official Catalog Models — 37 Valid Forms & Fallbacks"), in table order → film/data/models.json"""
import json, re, sys
src, out = sys.argv[1], sys.argv[2]
names = []
for line in open(src, encoding='utf-8'):
    m = re.match(r'\|\s*\*\*`([^`]+)`\*\*\s*\|', line)
    if m: names.append(m.group(1))
json.dump(names, open(out, 'w'), indent=0)
print(len(names), names[:3], names[-3:])
