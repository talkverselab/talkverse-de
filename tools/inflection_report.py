#!/usr/bin/env python3
"""굴절 반복 점검(굴절어 전략 — 같은 낱말이 여러 격·인칭 형태로 반복돼 몸에 붙게, 사용자 지시 2026-11-08).
  ~/.venvs/de/bin/python tools/inflection_report.py [편.json...]   (없으면 전편)
편마다: 두 가지 이상 형태로 나온 낱말 묶음(관사·대명사·동사·형용사), 나온 격(Nom/Acc/Dat/Gen)·인칭(1/2/3) 종류.
기준(경고용): 묶음 3개 이상, 레벨 1 이상은 격 2종 이상. 기본형·격은 spaCy 독일어 소형 모델(오류 있음 — 사람이 판단)."""
import collections, glob, json, re, sys
from pathlib import Path
import spacy
ROOT = Path(__file__).resolve().parent.parent
nlp = spacy.load('de_core_news_sm')
PRON = {'ich': 'ich', 'mich': 'ich', 'mir': 'ich', 'du': 'du', 'dich': 'du', 'dir': 'du', 'er': 'er', 'ihn': 'er', 'ihm': 'er',
        'wir': 'wir', 'uns': 'wir', 'ihr': 'ihr', 'euch': 'ihr', 'sie': 'sie', 'ihnen': 'sie', 'Sie': 'Sie', 'Ihnen': 'Sie'}
files = sys.argv[1:] or sorted(glob.glob(str(ROOT / 'assets/data/dialogues/R*/*/*.json')))
rows = []
for f in files:
    e = json.load(open(f, encoding='utf-8'))
    forms = collections.defaultdict(set); cases = set(); persons = set()
    for t in e['turns']:
        for tok in nlp(re.sub(r'\{[a-z_]+\}', 'Alex', t.get('es', ''))):
            w = tok.text
            if not re.search(r'[A-Za-zÄÖÜäöüß]', w):
                continue
            m = tok.morph
            cases |= set(m.get('Case')); persons |= set(m.get('Person'))
            if tok.pos_ in ('DET',) and w.lower() in ('der', 'die', 'das', 'den', 'dem', 'des', 'ein', 'eine', 'einen', 'einem', 'einer', 'kein', 'keine', 'keinen', 'keinem', 'mein', 'meine', 'meinen', 'meinem', 'dein', 'deine', 'deinen', 'deinem'):
                key = 'ART:' + ('der' if w.lower() in ('der', 'die', 'das', 'den', 'dem', 'des') else re.sub(r'(e|en|em|er)$', '', w.lower()))
            elif w in PRON or w.lower() in PRON:
                key = 'PRON:' + PRON.get(w, PRON.get(w.lower()))
            elif tok.pos_ in ('VERB', 'AUX', 'ADJ'):
                key = tok.pos_ + ':' + tok.lemma_.lower()
            else:
                continue
            forms[key].add(w.lower())
    groups = {k: sorted(v) for k, v in forms.items() if len(v) >= 2}
    rows.append((e['region'], e['id'], len(groups), sorted(cases), sorted(persons), groups))
for lv, id_, n, cs, ps, g in sorted(rows):
    warn = []
    if n < 3: warn.append('묶음<3')
    if lv not in ('R0',) and len(set(cs) & {'Nom', 'Acc', 'Dat'}) < 2: warn.append('격<2')
    show = '; '.join(f"{k.split(':')[1]}={'/'.join(v)}" for k, v in sorted(g.items(), key=lambda x: -len(x[1]))[:6])
    print(f"{lv} {id_:16} 묶음 {n:2} 격 {','.join(cs) or '-':15} 인칭 {','.join(ps) or '-':6} {'⚠ ' + ' '.join(warn) if warn else ''}\n    {show}")
