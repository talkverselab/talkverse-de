#!/usr/bin/env python3
"""회화 단어 목록 — 회화 편의 레마 중 절벽 단어표 2,000위 밖이면서 단어장에 있는 것(일본어앱 tools/freq/conv_words.py 와 같은 규칙).
절벽 단어 화면의 「회화 단어 포함」이 읽는다(2026-11-07). 레마는 tools/add_lemmas.py 가 채운 값이고, 등장인물 이름은 거기서 이미 빠진다.
  python3 tools/conv_words.py   → assets/data/freq/conv_words_de.json"""
import collections, csv, glob, json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CAP = 2000
db = {}
with open(ROOT / 'assets/data/freq/lang_de_top.csv', encoding='utf-8') as f:
    for r in csv.DictReader(f):
        db.setdefault(r['word'].lower(), {'word': r['word'], 'rd': r['reading'], 'ko': r['ko'], 'pos': r['pos'], 'rank': int(r['rank'])})
tw = json.load(open(ROOT / 'assets/data/vocab/travel_words.json', encoding='utf-8'))
for t in tw.get('themes', []):
    for s in t.get('sections', []):
        for w in s.get('words', []):
            if w.get('tx'):
                db.setdefault(w['tx'].lower(), {'word': w['tx'], 'rd': w.get('rd', ''), 'ko': w.get('ko', ''), 'pos': '', 'rank': 0})
n = collections.Counter()
files = glob.glob(str(ROOT / 'assets/data/dialogues/*.json')) + glob.glob(str(ROOT / 'assets/data/dialogues/R*/*/*.json'))
for fp in files:
    d = json.load(open(fp, encoding='utf-8'))
    for ep in d.get('episodes') or ([d] if 'turns' in d else []):
        for t in ep.get('turns', []):
            for l in t.get('lemmas', []):
                n[l[1].lower()] += 1
out = []
for k, c in n.most_common():
    e = db.get(k)
    if e and (e['rank'] == 0 or e['rank'] > CAP):
        out.append({'word': e['word'], 'rd': e['rd'], 'ko': e['ko'], 'pos': e['pos'], 'n': c})
p = ROOT / 'assets/data/freq/conv_words_de.json'
p.write_text(json.dumps({'_meta': '회화 레마 중 절벽 단어표(2,000위) 밖이면서 단어장에 있는 것 · tools/conv_words.py', 'words': out}, ensure_ascii=False, indent=0) + '\n', encoding='utf-8')
print(len(n), '→', len(out), [w['word'] for w in out])
