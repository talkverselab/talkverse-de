#!/usr/bin/env python3
"""언어감각 과정 데이터 assets/data/grammar/sense_course.json 을 만든다(ja 꼴, 독일어 키 de·rd·ko·who).
  python3 tools/build_sense.py
- 외울 대화(memorize): Grok 「빠른」 답 data/sense/out/<급>.md 그대로(줄·{조각|번호} 손대지 않음). rd 는 tools/rd_de.py 로 채움(형식).
- 참고(ref): 요점(head·tip)은 설명 글, 예문은 이미 앱에 있는 Grok 회화 줄에서 정규식으로 골라 온다(새 문장을 쓰지 않음)."""
import glob, json, re, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from rd_de import rd

REF = {  # 급 → [(head, tip, 예문 정규식)]
 'L1': [('der · die · das', '독일어 명사는 남성·여성·중성 셋 중 하나. 뜻으로 맞히기 어려우니 관사와 함께 통째로 외워요 (der Kaffee, die Tasche, das Buch).', r'\b(der|die|das) [A-ZÄÖÜ]\w+'),
        ('ein · eine', '「하나의/어떤」. 남성·중성은 ein, 여성은 eine (ein Kaffee, eine Brezel).', r'\b(ein|eine) [A-ZÄÖÜ]\w+'),
        ('kein · keine', '명사를 부정할 때는 nicht 대신 kein (Ich habe keine Zeit = 시간이 없어).', r'\bkeine?n? [A-ZÄÖÜ]\w+')],
 'L2': [('ich -e · du -st · er/sie -t', '주어에 따라 동사 끝이 바뀌어요: ich komme, du kommst, sie kommt.', r'\b(du \w+st|ich \w+e)\b'),
        ('sein · haben', '가장 많이 쓰는 두 동사는 모양이 불규칙: bin·bist·ist / habe·hast·hat.', r'\b(bin|bist|hast)\b')],
 'L3': [('동사는 둘째 자리', '문장 맨 앞에 무엇이 오든 동사는 두 번째. 시간·장소가 앞에 오면 주어가 동사 뒤로 (Heute gehe ich …).', r'^(Heute|Dann|Morgen|Jetzt|Am \w+) \w+ (ich|du|wir)\b')],
 'L4': [('떨어지는 동사', 'mitkommen·aufstehen·anrufen 같은 동사는 앞토막이 문장 끝으로 가요 (Kommst du mit?).', r'\b\w+ (du|ich) .*\b(mit|auf|an|ein|zurück)[?.!]')],
 'L5': [('조동사 + 끝 동사', 'können·müssen·wollen·dürfen이 둘째 자리, 진짜 동사는 원형으로 맨 끝 (Ich kann das tragen).', r'\b(kann|kannst|muss|musst|will|willst|darf)\b.*\b\w+en[.?!]$')],
 'L6': [('4격 — 을/를', '목적어가 되면 남성 관사만 바뀌어요: der → den, ein → einen. 대명사는 mich·dich·ihn.', r'\b(den|einen|dich|mich)\b'),
        ('für + 4격', 'für(~를 위해) 뒤는 늘 4격 (für dich, für den Kaffee).', r'\bfür (dich|mich|den|einen)\b')],
 'L7': [('3격 — 에게', '「~에게」는 3격: mir·dir·ihm·ihr, dem·der. mit·bei·von·zu 뒤도 3격 (mit dir).', r'\b(mit|bei|von|zu) (dir|mir|dem|der)\b'),
        ('helfen · gefallen', '이 동사들은 목적어를 3격으로 받아요 (Ich helfe dir, Das gefällt mir).', r'\b(gefällt|helfe|hilfst|hilft) (mir|dir|ihm|ihr)\b')],
 'L8': [('했어 — haben + ge-', '말할 때 과거는 대부분 현재완료: haben 이 둘째 자리, ge-…-t/-en 이 끝 (Ich habe gegessen).', r'\b(habe|hast|hat) .*\bge\w+(t|en)[.?!]'),
        ('이동·변화는 sein', 'gehen·fahren·kommen처럼 움직이거나 바뀌면 sein (Ich bin gefahren).', r'\b(bin|bist|ist) .*\bge\w+en[.?!]')],
 'L9': [('weil · dass · wenn — 동사 끝', '이 접속사 뒤 문장은 동사가 맨 끝으로 (…, weil ich müde bin).', r'\b(weil|dass|wenn|ob)\b')],
 'L10': [('Sie — 존댓말', '처음 보는 어른·가게·관청에서는 Sie. 동사는 복수 모양 (Können Sie …?).', r'\b(Sie|Ihnen)\b'),
         ('du 로 바꾸기', '「Wollen wir uns duzen?」 — 이제 반말로 하자는 말. 보통 나이가 많거나 윗사람이 먼저 꺼내요.', r'\bduzen\b')],
}
TITLE = {}


def lines_of(f):
    out, guide = [], ''
    for l in open(f, encoding='utf-8'):
        l = l.strip()
        m = re.match(r'(\d+) ([^:]+): (.*?) / (.*)$', l)
        if m:
            de = m.group(3).strip(); plain = re.sub(r'\{([^|}]+)\|\d+\}', r'\1', de)
            out.append({'who': m.group(2).strip(), 'de': de, 'rd': rd(plain), 'ko': m.group(4).strip()})
        elif l.startswith('한 줄 안내:'):
            guide = l.split(':', 1)[1].strip()
    return out, guide


def examples(rx, n=2):
    hits = []
    for f in sorted(glob.glob(str(ROOT / 'assets/data/dialogues/R*/*/*.json'))):
        for t in json.load(open(f, encoding='utf-8'))['turns']:
            es = t.get('es', '')
            if '{name}' in es or len(es.split()) > 9:
                continue
            if re.search(rx, es) and es not in [h['de'] for h in hits]:
                hits.append({'de': es, 'rd': t.get('rd') or rd(es), 'ko': t['ko']})
            if len(hits) >= n:
                return hits
    return hits


def main():
    levels = []
    for b in sorted(glob.glob(str(ROOT / 'data/sense/brief/L*.json')), key=lambda p: int(re.search(r'L(\d+)', p).group(1))):
        br = json.load(open(b, encoding='utf-8')); id_ = br['id']
        f = ROOT / f'data/sense/out/{id_}.md'
        if not f.exists():
            print('없음', id_); continue
        sents, guide = lines_of(f)
        if len(sents) != 10:
            print('줄 수', id_, len(sents)); continue
        lessons = [{'id': f'{id_}-talk', 'title': br['title'], 'kind': 'memorize', 'video': '',
                    'note': guide or '일부러 설명하지 않았어요. 문장을 외우면 저절로 익히게 돼요.', 'sentences': sents}]
        def ex(rx):  # 앱 회화에 없으면 이 급의 외울 대화에서(마커 뺀 꼴)
            got = examples(rx)
            if not got:
                for s in sents:
                    plain = re.sub(r'\{([^|}]+)\|\d+\}', r'\1', s['de'])
                    if re.search(rx, plain):
                        got.append({'de': plain, 'rd': s['rd'], 'ko': re.sub(r'\{([^|}]+)\|\d+\}', r'\1', s['ko'])})
                    if len(got) >= 2:
                        break
            return got
        pts = [{'head': h, 'tip': tip, 'sentences': ex(rx)} for h, tip, rx in REF.get(id_, [])]
        if pts:
            lessons.append({'id': f'{id_}-ref', 'kind': 'ref', 'title': f'{br["title"]} 한눈에', 'points': pts})
        levels.append({'id': id_, 'title': br['title'], 'lessons': lessons})
    d = {'title': '언어감각 익히기', 'subtitle': '정규과정 · 대화 통째로 외우기 → 참고', 'levels': levels,
         'review': {'grok': 'data/sense/out/<급>.md', 'model': '빠른'}}
    p = ROOT / 'assets/data/grammar/sense_course.json'
    json.dump(d, open(p, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print('급', len(levels), '→', p)


main()
