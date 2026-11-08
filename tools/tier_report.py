#!/usr/bin/env python3
"""회화 편의 어휘가 레벨 상한(절벽 구간) 안인지 본다 — 굴절어 전략 B3. 경고용(검사기 오류 아님).
  ~/.venvs/de/bin/python tools/tier_report.py <편.json>...
레벨 → 상한(앱 단어표 순위): R0·R1 81 · R2·R3 280 · R4 822 · R5 1,500. 상한 밖 내용어는 편당 3개까지(턴의 `new` 와 note 에 뜻).
표현 풀 낱말·등장인물 이름·{변수}는 세지 않는다. 기본형은 spaCy 독일어 소형 모델."""
import csv, json, re, sys
from pathlib import Path
import spacy
ROOT = Path(__file__).resolve().parent.parent
CAP = {'R0': 81, 'R1': 81, 'R2': 280, 'R3': 280, 'R4': 822, 'R5': 1500}
KEEP = {'NOUN', 'VERB', 'ADJ', 'ADV', 'AUX'}
rank = {}
for r in csv.DictReader(open(ROOT / 'assets/data/freq/lang_de_top.csv', encoding='utf-8')):
    rank.setdefault(r['word'].lower(), int(r['rank']))
pool = set()
for r in csv.DictReader(open(ROOT / 'data/expressions/top_expressions.csv', encoding='utf-8')):
    pool |= {w.lower() for w in re.findall(r"[A-Za-zÄÖÜäöüß]+", r['expr'])}
nlp = spacy.load('de_core_news_sm')


def best(tok):
    t = tok.text.lower(); b = (tok.lemma_ or tok.text).lower()
    c = [x for x in (b, t, t + 'en', t[:-1] + 'en', t[:-2] + 'en', t[:-1], t[:-2], t[:-3]) if len(x) > 1 and x in rank]
    return min((rank[x], x) for x in c) if c else (None, b)


for f in sys.argv[1:]:
    e = json.load(open(f, encoding='utf-8')); cap = CAP.get(e['region'], 9999)
    names = {str(v).lower() for v in e['speakers'].values()}
    out = {}
    for t in e['turns']:
        for tok in nlp(re.sub(r'\{[a-z_]+\}', ' ', t.get('es', ''))):
            if tok.pos_ not in KEEP or tok.text.lower() in pool or tok.text.lower() in names or not re.search(r'[A-Za-zÄÖÜäöüß]', tok.text):
                continue
            r, w = best(tok)
            if r is None or r > cap:
                out.setdefault(w, (r, t['num']))
    flag = '  ← 3개 초과' if len(out) > 3 else ''
    print(f"{e['id']} 상한 {cap}: 밖 {len(out)}개 {sorted(out.items(), key=lambda x: x[1][1])}{flag}")
