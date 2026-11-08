#!/usr/bin/env python3
"""독일어 문법 요소가 회화에 레벨별로 몇 번 나오는지 센다(2026-11-08, 문법 배치 결정용).
  ~/.venvs/de/bin/python tools/grammar_report.py [--detail 항목]
spaCy 독일어 소형 모델(STTS 태그) 기준 근사값 — 사람이 확인한다. 옛 초안 r1_survival_s1·r2_love_b1 은 뺀다."""
import collections, glob, json, re, sys
from pathlib import Path
import spacy
ROOT = Path(__file__).resolve().parent.parent
nlp = spacy.load('de_core_news_sm')
OLD = {'r1_survival_s1', 'r2_love_b1'}
PART = {'doch', 'mal', 'ja', 'halt', 'denn', 'eben', 'schon', 'wohl', 'eigentlich'}
SUBJ = {'weil', 'dass', 'wenn', 'ob', 'als', 'obwohl', 'damit', 'bevor', 'nachdem', 'während', 'bis'}
cnt = collections.defaultdict(collections.Counter); ex = collections.defaultdict(list); neps = collections.Counter()
detail = sys.argv[sys.argv.index('--detail') + 1] if '--detail' in sys.argv else None
for f in sorted(glob.glob(str(ROOT / 'assets/data/dialogues/R*/*/*.json'))):
    e = json.load(open(f, encoding='utf-8'))
    if e['id'] in OLD:
        continue
    lv = e['region']; neps[lv] += 1
    if e.get('duzen'):
        cnt[lv]['du→Sie 전환'] += 1
    for t in e['turns']:
        doc = nlp(re.sub(r'\{[a-z_]+\}', 'Alex', t.get('es', '')))
        for s in doc.sents:
            toks = [x for x in s if not x.is_punct and not x.is_space]
            if not toks:
                continue
            hit = set()
            fin = [i for i, x in enumerate(toks) if x.tag_ in ('VVFIN', 'VAFIN', 'VMFIN')]
            if fin and fin[0] >= 1 and toks[0].tag_ not in ('PPER', 'PIS', 'PDS', 'NE', 'NN', 'ART', 'KON', 'PWS', 'PWAV', 'PWAT', 'ITJ', 'PTKANT') and not toks[0].text.lower() in SUBJ:
                if toks[fin[0] - 1] is toks[0] or fin[0] <= 3:
                    hit.add('V2 도치(주어 아닌 말 + 동사)')
            if any(x.dep_ == 'svp' or x.tag_ == 'PTKVZ' for x in toks):
                hit.add('분리동사(앞철 떨어짐)')
            if any(x.tag_ == 'KOUS' for x in toks):
                hit.add('부문장(weil/dass/wenn…, 동사 끝)')
            if any(x.tag_ in ('PRELS', 'PRELAT') for x in toks):
                hit.add('관계문')
            if any(x.tag_ == 'ADJA' for x in toks):
                hit.add('형용사 어미(명사 앞)')
            if any(x.tag_ == 'VMFIN' for x in toks):
                hit.add('화법조동사')
            if any(x.tag_ == 'VAFIN' and x.lemma_ in ('haben', 'sein') for x in toks) and any(x.tag_ == 'VVPP' for x in toks):
                hit.add('현재완료')
            past = [x for x in toks if x.tag_ in ('VVFIN', 'VAFIN', 'VMFIN') and 'Past' in x.morph.get('Tense') and 'Sub' not in x.morph.get('Mood')]
            if past:
                hit.add('과거형(Präteritum)' + (' sein/haben/조동사' if all(x.lemma_ in ('sein', 'haben', 'werden', 'können', 'müssen', 'wollen', 'sollen', 'dürfen', 'mögen', 'wissen') for x in past) else ' 일반동사'))
            if any('Sub' in x.morph.get('Mood') for x in toks) or any(x.text.lower() in ('würde', 'würdest', 'wäre', 'hätte', 'hättest', 'könnte', 'möchte', 'möchtest') for x in toks):
                hit.add('접속법 II(würde·wäre·hätte·möchte)')
            if any(x.lemma_ == 'werden' for x in toks) and any(x.tag_ == 'VVPP' for x in toks):
                hit.add('수동(werden + 과거분사)')
            if any(x.text.lower() in PART and x.tag_ in ('ADV', 'PTKMA') for x in toks):
                hit.add('말맛 조사(doch·mal·ja·halt·denn…)')
            if any('Gen' in x.morph.get('Case') and x.tag_ in ('ART', 'NN') for x in toks):
                hit.add('소유격(Genitiv)')
            if any(x.text == 'Sie' and x.i > s.start for x in toks):
                hit.add('Sie(존댓말)')
            for h in hit:
                cnt[lv][h] += 1
                if detail and detail in h:
                    ex[lv].append(f"{e['id']}:{t['num']} {s.text}")
keys = sorted({k for c in cnt.values() for k in c})
lvs = sorted(neps)
print('항목'.ljust(34) + ''.join(f'{l}({neps[l]}편)'.rjust(10) for l in lvs))
for k in keys:
    print(k.ljust(34) + ''.join(str(cnt[l][k]).rjust(10) for l in lvs))
if detail:
    for l in lvs:
        for x in ex[l][:6]:
            print(l, x)
