#!/usr/bin/env python3
"""회화 편 → Grok 에 보낼 뼈대(2026-11-18 「클로드 지문 없애기」, kk brief.py 참고).
상황·인물·반전·추천 표현·턴 수·감정만 남기고 대사(es·rd·ko·note)는 비운다 — 초안 문장을 베끼지 않게.
턴 수·화자 순서는 그대로(turn_lock: 턴 번호를 바꾸지 않는다).   grok_brief.py <편.json> <뼈대.json>"""
import json, sys
d = json.load(open(sys.argv[1]))
for k in ('draft', 'outline'):
    d.pop(k, None)
for t in d['turns']:
    for k in ('es', 'rd', 'ko', 'note'):
        t[k] = ''
    for k in ('segs', 'lemmas', 'tags'):
        t.pop(k, None)
d['note_for_writer'] = ('대사 칸(es·ko·note)은 비어 있다 — 장면·인물·반전·추천 표현·감정을 보고 네가 처음부터 쓴다. '
                        '턴 수와 화자 순서는 그대로 지킨다.')
json.dump(d, open(sys.argv[2], 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
