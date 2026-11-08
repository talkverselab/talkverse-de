#!/usr/bin/env python3
"""세션이 리뷰한 최종본 data/review/final/<편id>.txt 를 편 JSON 에 넣는다(중국어앱 tools/grok/apply_final.py 를 옮김).
  python3 tools/apply_rewrite.py <편id>...
최종본 줄 형식: `번호 화자: 독일어 / 한국어 [/ note [/ 감정]]` — 감정은 16개 값 하나 또는 `감정:부분|감정:부분`(→ segs).
rd 는 비운다 → `python3 tools/check_dialogues.py --fix-rd --align-rd` 로 채운 뒤 틀린 곳만 손으로. 감정 계획은 `tools/tts/make_plan.py <편id>`."""
import glob, json, re, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
for id_ in sys.argv[1:]:
    p = glob.glob(str(ROOT / f'assets/data/dialogues/R*/*/{id_}.json'))[0]
    e = json.load(open(p, encoding='utf-8'))
    lines = [l.strip() for l in open(ROOT / f'data/review/final/{id_}.txt', encoding='utf-8') if l.strip() and re.match(r'\d+ ', l)]
    turns = []
    for l in lines:
        m = re.match(r'(\d+) ([A-Z]): (.*)', l)
        assert m, l
        parts = [x.strip() for x in m.group(3).split(' / ')]
        n = int(m.group(1)); old = e['turns'][n - 1] if n - 1 < len(e['turns']) else {'tags': []}
        t = {'num': n, 'speaker': m.group(2), 'es': parts[0], 'rd': '', 'ko': parts[1],
             'note': parts[2] if len(parts) > 2 and parts[2] else old.get('note', ''), 'tags': old.get('tags', [])}
        for k in ('ui', 'at', 'read'):
            if k in old:
                t[k] = old[k]
        emo = parts[3] if len(parts) > 3 else None
        if emo and ':' in emo:
            t['segs'] = [[x.split(':', 1)[0].strip(), x.split(':', 1)[1].strip()] for x in emo.split('|') if ':' in x]
        elif emo:
            t['emotion'] = emo.strip()
        elif old.get('segs'):
            t['segs'] = old['segs']
        else:
            t['emotion'] = old.get('emotion', 'neutral')
        turns.append(t)
    e['turns'] = turns
    e['review'] = {'grok_rewrite': f'data/review/grok/{id_}_rewrite.md', 'model': '전문가', 'final': f'data/review/final/{id_}.txt'}
    json.dump(e, open(p, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(id_, len(turns), '턴')
