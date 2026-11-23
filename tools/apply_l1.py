#!/usr/bin/env python3
"""옛 L1 5편(assets/data/dialogues/L1.json, 번들 — 서버 받기 아님)에 Grok 대사를 넣는다.
  python3 tools/apply_l1.py l1_ep1 ...   최종본 data/review/final/<id>.txt(형식은 apply_rewrite.py 와 같음), 초안 data/drafts/L1/l1/<id>.json.
rd 는 tools/rd_de.py 로 채운다(형식 작업). 바꾼 뒤 assets/data/version.json 의 db 를 올리고 앱을 새로 빌드해야 폰에 나간다."""
import json, re, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from rd_de import rd
p = ROOT / 'assets/data/dialogues/L1.json'
L = json.load(open(p, encoding='utf-8'))
for id_ in sys.argv[1:]:
    ep = next(e for e in L['episodes'] if e['id'] == id_.replace('l1_', ''))
    dr = json.load(open(ROOT / f'data/drafts/L1/l1/{id_}.json', encoding='utf-8'))
    turns = []
    for l in open(ROOT / f'data/review/final/{id_}.txt', encoding='utf-8'):
        m = re.match(r'(\d+) ([A-Z]): (.*)', l.strip())
        if not m:
            continue
        parts = [x.strip() for x in m.group(3).split(' / ')]
        n = int(m.group(1)); old = dr['turns'][n - 1]
        t = {'num': n, 'speaker': m.group(2), 'es': parts[0], 'rd': rd(parts[0]), 'ko': parts[1],
             'note': parts[2] if len(parts) > 2 else '', 'tags': [], 'lemmas': []}
        emo = parts[3] if len(parts) > 3 else ''
        if ':' in emo:
            t['segs'] = [[x.split(':', 1)[0].strip(), x.split(':', 1)[1].strip()] for x in emo.split('|') if ':' in x]
        else:
            t['emotion'] = emo or old.get('emotion', 'neutral')
        turns.append(t)
    assert [(t['num'], t['speaker']) for t in turns] == [(t['num'], t['speaker']) for t in dr['turns']], id_
    ep['turns'] = turns
    ep['scenario'] = dr['scene']
    # 작업 기록(review·draft)은 앱 묶음·공개 원고에 넣지 않는다 — 출처(AI 이름) 공개 금지(uk 심사 점검 2026-11-23). 기록은 data/review 에.
    ep.pop('review', None)
    for t in ep['turns']:
        t['tags'] = [x for x in t.get('tags', []) if x != 'draft']
    print(id_, len(turns), '턴')
json.dump(L, open(p, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
