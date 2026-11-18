#!/usr/bin/env python3
"""고침 차례(uk 11-19) 초안 손질: 새 36편 중 검사에 걸린 편의 data/drafts 초안에
표현 풀(data/expressions/top_expressions.csv) 낱말 3개를 words 앞에 넣고, R0~R2 는 복수·존댓말 금지 조건을 적는다.
대사는 Grok 이 다시 쓴다. 이 스크립트는 초안(상황·낱말 배치)만 고친다.   fix_drafts.py"""
import json, glob
ADD = {
 'r0_culture_a1': ['Wie bitte?', 'Echt?', 'Oh Mann'],
 'r0_friends_a2': ['Tut mir leid', 'Kein Problem', 'Echt?'],
 'r0_friends_a3': ['Lecker', 'Ich auch', 'Na?'],
 'r0_friends_a4': ['Tschüss', 'Bis dann', 'Oh Mann'],
 'r0_friends_a5': ['Echt jetzt?', 'Das ist mir peinlich', 'Tut mir leid'],
 'r0_life_a1': ['Hallo', 'Alles klar', 'Passt'],
 'r0_love_a2': ['Bis morgen', 'Wirklich?', 'Süß'],
 'r0_love_a3': ['Komm schon', 'Gerne', 'Zum Glück'],
 'r0_study_a1': ['Hallo', 'Klar', 'Ich auch'],
 'r0_travel_a1': ['Hallo', 'Das ist mir peinlich', 'Na?'],
 'r1_culture_a2': ['Gerne', 'Lecker', 'Moment mal'],
 'r1_friends_a4': ['Komm schon', 'Oh Mann', 'Hör auf'],
 'r1_friends_a5': ['Mist', 'Oh Mann', 'Keine Sorge'],
 'r1_life_a2': ['Mist', 'Ich hab\'s vergessen', 'Macht nichts'],
 'r1_life_a3': ['Keine Ahnung', 'Warte mal', 'Zum Glück'],
 'r1_love_a3': ['Süß', 'Wirklich?', 'Schlaf gut'],
 'r1_travel_a1': ['Warte mal', 'Keine Sorge', 'Genau'],
 'r1_work_a1': ['Lecker', 'Voll', 'Na ja'],
 'r2_culture_c2': ['Na klar', 'Mega', 'Mal sehen'],
 'r2_friends_c2': ['Oh Mann', 'Das ist mir peinlich', 'Egal'],
 'r2_friends_c3': ['Sag mal', 'Ernsthaft?', 'Das gibt\'s doch nicht'],
 'r2_life_c2': ['Alles klar', 'Geht klar', 'Ach komm'],
 'r2_love_c3': ['Ich auch', 'Eigentlich', 'Schlaf gut'],
 'r2_love_c4': ['Ehrlich?', 'Hör auf', 'Krass'],
 'r2_travel_c1': ['Gute Idee', 'Passt', 'Na und?'],
 'r3_life_b2': ['Guten Tag', 'Na ja', 'Eigentlich'],
 'r3_love_b1': ['Zusammen oder getrennt?', 'Stimmt so', 'Auf keinen Fall'],
 'r3_survival_b2': ['Entschuldigung', 'Das gibt\'s doch nicht', 'Zum Glück'],
 'r3_survival_b3': ['Guten Tag', 'Wie bitte?', 'Noch einmal, bitte'],
 'r3_travel_b2': ['Moment mal', 'Entschuldigung', 'Zum Glück'],
 'r3_work_b1': ['Guten Tag', 'Wollen wir uns duzen?', 'Gerne'],
}
BEAT = {  # R0~R2: 복수(wir)를 부르는 흐름 메모를 du·단수로
 ('r0_friends_a4', 2): '안녕 하고 손을 흔든다',
 ('r0_friends_a5', 2): '너도 먹으라고 케이크를 내민다',
 ('r1_friends_a4', 1): '한 판 더 할 거냐고 묻는다',
 ('r1_friends_a5', 5): '창문에서 Felix 가 공을 들고 이거 네 거냐고 묻는다',
 ('r1_love_a3', 6): '하나는 네 거, 하나는 내 거 — 다음 공연에도 오라는 뜻이라고 한다',
 ('r1_travel_a1', 7): '그럼 걷겠다고, 자전거보다 느리다고 투덜댄다',
 ('r1_work_a1', 8): '맛있다고, 다음엔 네가 컵에 넣어 보라고 한다',
 ('r2_culture_c2', 8): '방금 너도 올 거냐고 물은 거라고 한다(kommst du mit?)',
 ('r2_culture_c2', 9): '나도 간다고 한다(mitkommen)',
 ('r2_friends_c2', 1): 'Jonas 에게 쓰는 줄 알고 Lena 선물로 자전거 벨을 살 거라고, 너도 돈 낼 거냐고 보낸다',
 ('r2_travel_c1', 1): '주말에 함부르크 갈 건데 너도 올 거냐고 묻는다',
 ('r2_travel_c1', 5): '호텔은 싼 데가 좋다고 한다',
 ('r2_travel_c1', 10): '시간 되면 다 보고 싶다고 한다(wenn)',
}
NOPL = 'R0~R2: du·단수만 — wir·uns·unser·ihr·euch·euer·Sie 를 쓰지 않는다.'
for id_, add in ADD.items():
    p = glob.glob(f'data/drafts/R*/*/{id_}.json')[0]
    d = json.load(open(p))
    d['words'] = add + [w for w in d['words'] if w.lower() not in {a.lower() for a in add} and w != 'wir']
    d['must'] = ['표현 풀 낱말(words 앞 3개)을 대사에 그대로 넣는다.'] + ([NOPL] if d['region'] in ('R0', 'R1', 'R2') else [])
    for t in d['turns']:
        t['beat'] = BEAT.get((id_, t['num']), t['beat'])
    json.dump(d, open(p, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print(len(ADD), '편 손질')
