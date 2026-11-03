#!/usr/bin/env python3
"""편 JSON 의 턴마다 `lemmas`(내용어 [표면형, 기본형, 한글 독음]) 를 채운다 — 문장 레마 ↔ 단어장 연결(사용자 지시 2026-11-04).
독일어 형태소 분석은 spaCy 독일어 소형 모델(기본형·품사). 내용어 = 명사·동사·형용사·부사(관사·대명사·전치사·조동사·접속사·불변화사·숫자·고유명사 제외).
독음은 단어장(assets/data/freq/lang_de_top.csv)에 있으면 거기서, 없으면 빈 값. 단어장에 없는 레마는 data/review/write/missing_lemmas.csv 로(uk 세션에 넘김).
  ~/.venvs/de/bin/python tools/add_lemmas.py        (venv: pip install spacy && python -m spacy download de_core_news_sm)"""
import csv, glob, json, re, sys
from collections import Counter
from pathlib import Path

import spacy

ROOT = Path(__file__).resolve().parent.parent
VAR = re.compile(r'\{[a-z_]+\}')
KEEP = {'NOUN', 'VERB', 'ADJ', 'ADV'}
nlp = spacy.load('de_core_news_sm')

# 단어장: 소문자 기본형 → (표기, 독음)
db = {}
with open(ROOT / 'assets/data/freq/lang_de_top.csv', encoding='utf-8') as f:
    for r in csv.DictReader(f):
        db.setdefault(r['word'].lower(), (r['word'], r['reading']))
try:
    tw = json.load(open(ROOT / 'assets/data/vocab/travel_words.json', encoding='utf-8'))
    for t in tw.get('themes', []):
        for s in t.get('sections', []):
            for w in s.get('words', []):
                if w.get('tx'): db.setdefault(w['tx'].lower(), (w['tx'], w.get('rd', '')))
except FileNotFoundError:
    pass

def norm(tok):
    base = tok.lemma_ or tok.text
    if tok.pos_ == 'NOUN':
        base = base[:1].upper() + base[1:]
    elif tok.pos_ in ('VERB', 'ADJ', 'ADV'):
        base = base.lower()
    return base

def resolve(tok, base):
    """소형 모델의 기본형 오류(kommst→kommsen) 보정: 단어장에 있는 후보를 찾는다 — 없으면 모델 기본형 그대로."""
    t = tok.text.lower()
    cands = [base, t, t + 'en', t[:-1] + 'en', t[:-2] + 'en', t[:-3] + 'en', t[:-1], t[:-2], t[:-3]]
    for c in cands:
        if len(c) >= 2 and c.lower() in db:
            return db[c.lower()][0]
    return base

miss = Counter(); ex = {}; tot = hit = 0
files = sorted(glob.glob(str(ROOT / 'assets/data/dialogues/*.json')) + glob.glob(str(ROOT / 'assets/data/dialogues/R*/*/*.json')))
for fpath in files:
    d = json.load(open(fpath, encoding='utf-8'))
    units = d.get('episodes') or ([d] if 'turns' in d else [])
    names = {str(v.get('name', '')).lower() for v in (d.get('characters') or {}).values() if isinstance(v, dict)}
    ch = False
    for ep in units:
        for t in ep.get('turns', []):
            text = t.get('tl') or t.get('es') or ''
            out = []
            for tok in nlp(VAR.sub(' ', text)):
                if tok.pos_ not in KEEP or not re.search(r'[A-Za-zÄÖÜäöüß]', tok.text):
                    continue
                if tok.text.lower() in names:  # 등장인물 이름(소형 모델이 명사로 잡음)
                    continue
                base = resolve(tok, norm(tok))
                if len(base) < 2:
                    continue
                e = db.get(base.lower())
                rd = e[1] if e else ''
                if e: base = e[0]
                out.append([tok.text, base, rd]); tot += 1
                if e: hit += 1
                else:
                    miss[base] += 1; ex.setdefault(base, text)
            if t.get('lemmas') != out:
                t['lemmas'] = out; ch = True
    if ch:
        open(fpath, 'w', encoding='utf-8').write(json.dumps(d, ensure_ascii=False, indent=1) + '\n')
(ROOT / 'data/review/write').mkdir(parents=True, exist_ok=True)
with open(ROOT / 'data/review/write/missing_lemmas.csv', 'w', encoding='utf-8', newline='') as fo:
    w = csv.writer(fo); w.writerow(['lemma', 'count', 'example'])
    for b, n in miss.most_common(): w.writerow([b, n, ex[b]])
print(f'내용어 {tot} · 단어장 있음 {hit / tot:.0%} · 없는 레마 {len(miss)} → data/review/write/missing_lemmas.csv' if tot else '내용어 없음')
