#!/usr/bin/env python3
"""Grok 답(data/review/grok/out/<편>.md) → data/review/final/<편>.txt. 형식만 바꾼다: 화자 이름(Lena) → 글자(B).
턴 번호·화자 순서가 원본(assets 또는 data/drafts)과 다르면 쓰지 않고 MISMATCH.   grok_final.py <편>..."""
import json, glob, re, sys
for id_ in sys.argv[1:]:
    src = (glob.glob(f'assets/data/dialogues/R*/*/{id_}.json') + glob.glob(f'data/drafts/*/*/{id_}.json'))[0]
    d = json.load(open(src))
    inv = {v: k for k, v in d['speakers'].items()} | {k: k for k in d['speakers']} | {'{name}': 'A'}
    out, bad, rec = [], [], ''
    for l in open(f'data/review/grok/out/{id_}.md', encoding='utf-8'):
        l = l.strip()
        m = re.match(r'(\d+) ([^:/]+?): (.*)', l)
        if m:
            s = inv.get(m.group(2).strip())
            if not s: bad.append(m.group(2)); continue
            out.append((int(m.group(1)), s, f'{m.group(1)} {s}: {m.group(3)}'))
        elif l.startswith('추천 표현:'):
            rec = l
    ok = [(n, s) for n, s, _ in out] == [(t['num'], t['speaker']) for t in d['turns']]
    short = [x[0] for x in out if len(x[2].split(' / ')) < 4]
    print(id_, len(out), len(d['turns']), 'OK' if ok and not short else 'MISMATCH', bad or '', short or '')
    if ok and not short:
        open(f'data/review/final/{id_}.txt', 'w', encoding='utf-8').write('\n'.join(x[2] for x in out) + '\n' + (rec + '\n' if rec else ''))
