#!/usr/bin/env python3
"""레벨별 금지 문법 검사(사용자 결정 2026-11-08, docs/GRAMMAR_LEVELS_de.md).
  ~/.venvs/de/bin/python tools/level_grammar_check.py [편.json...]   (없으면 전편, 옛 초안 2편 제외)
- 부문장(weil·dass·wenn·ob…): 레벨 0~1 금지, 레벨 2부터 짧게.
- 관계문·수동: 레벨 4부터.   - 명사 앞 형용사 어미: 레벨 3부터.
- 과거형: war·hatte·konnte·wusste 등(sein·haben·화법조동사·wissen)만 통문장으로 레벨 1부터, 일반동사 과거형은 레벨 5.
- 접속법 II: möchte·hätte gern·würde gern 같은 고정형은 레벨 1부터, 그 밖은 레벨 4부터.
spaCy 소형 모델 근사값 — 나온 줄을 사람이 확인한다(명령형 등 오인식 있음)."""
import glob, json, re, sys
from pathlib import Path
import spacy
ROOT = Path(__file__).resolve().parent.parent
nlp = spacy.load('de_core_news_sm')
OLD = {'r1_survival_s1', 'r2_love_b1'}
N = {'R0': 0, 'R1': 1, 'R2': 2, 'R3': 3, 'R4': 4, 'R5': 5}
EASY_PAST = {'sein', 'haben', 'werden', 'können', 'müssen', 'wollen', 'sollen', 'dürfen', 'mögen', 'wissen'}
FIXED_K2 = {'möchte', 'möchtest', 'möchten', 'hätte', 'hätten', 'würde', 'würdest', 'könnte', 'könntest'}
files = sys.argv[1:] or [f for f in sorted(glob.glob(str(ROOT / 'assets/data/dialogues/R*/*/*.json'))) if Path(f).stem not in OLD]
bad = 0
for f in files:
    e = json.load(open(f, encoding='utf-8')); lv = N[e['region']]
    for t in e['turns']:
        doc = nlp(re.sub(r'\{[a-z_]+\}', 'Alex', t.get('es', '')))
        why = []
        for x in doc:
            if x.tag_ == 'KOUS' and lv < 2:
                why.append(f'부문장 {x.text}')
            if x.tag_ in ('PRELS', 'PRELAT') and lv < 4:
                why.append(f'관계문 {x.text}')
            if x.tag_ == 'ADJA' and lv < 3:
                why.append(f'명사 앞 형용사 {x.text}')
            if x.tag_ in ('VVFIN', 'VAFIN', 'VMFIN') and 'Past' in x.morph.get('Tense') and 'Sub' not in x.morph.get('Mood') and x.lemma_ not in EASY_PAST and lv < 5:
                why.append(f'일반동사 과거형 {x.text}')
            if ('Sub' in x.morph.get('Mood') or x.text.lower() in ('wäre', 'wären', 'wärst', 'käme', 'kämst', 'bräuchte')) and x.text.lower() not in FIXED_K2 and lv < 4:
                why.append(f'접속법 II {x.text}')
        if any(x.lemma_ == 'werden' for x in doc) and any(x.tag_ == 'VVPP' for x in doc) and lv < 4:
            why.append('수동')
        if why:
            bad += 1
            print(f"{e['region']} {e['id']}:{t['num']} {' · '.join(why)} | {t['es']}")
print('걸린 줄', bad)
