#!/usr/bin/env python3
"""독일어 → 한글 독음(rd) — CLAUDE.md 독음 표기표 그대로(2026-11-07 초안, 원어민 검수 전).

낱말은 단어장(assets/data/freq/lang_de_top.csv)의 독음을 먼저 쓰고, 없으면 규칙으로 만든다.
  python3 tools/rd_de.py "Ich möchte einen Kaffee, bitte."
라이브러리로: from rd_de import rd
"""
import csv
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CHO = 'ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ'
JUNG = 'ㅏㅐㅑㅒㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ'
JONG = ['', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ', 'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ']


def syl(c, v, j=''):
    return chr(0xAC00 + (CHO.index(c) * 21 + JUNG.index(v)) * 28 + JONG.index(j))


# 모음(긴 것부터)
VOW = [('aa', ['ㅏ']), ('ee', ['ㅔ']), ('oo', ['ㅗ']), ('ie', ['ㅣ']), ('ei', ['ㅏ', 'ㅣ']), ('ai', ['ㅏ', 'ㅣ']), ('ay', ['ㅏ', 'ㅣ']),
       ('eu', ['ㅗ', 'ㅣ']), ('äu', ['ㅗ', 'ㅣ']), ('au', ['ㅏ', 'ㅜ']), ('ah', ['ㅏ']), ('eh', ['ㅔ']), ('ih', ['ㅣ']), ('oh', ['ㅗ']), ('uh', ['ㅜ']),
       ('äh', ['ㅔ']), ('öh', ['ㅚ']), ('üh', ['ㅟ']), ('a', ['ㅏ']), ('e', ['ㅔ']), ('i', ['ㅣ']), ('o', ['ㅗ']), ('u', ['ㅜ']),
       ('ä', ['ㅔ']), ('ö', ['ㅚ']), ('ü', ['ㅟ']), ('y', ['ㅟ'])]
# 첫소리(긴 것부터): (철자, 앞에 붙는 자음 음절들, 초성)
ONS = [('tsch', ['ㅊ', 'ㅣ'], None), ('sch', 'ㅅ', 'sh'), ('pf', 'ㅍ', None), ('ph', 'ㅍ', None), ('qu', 'ㅋ', 'w'), ('ch', 'ㅎ', None),
       ('th', 'ㅌ', None), ('ck', 'ㅋ', None), ('tz', 'ㅊ', None), ('ss', 'ㅅ', None), ('ß', 'ㅅ', None), ('dt', 'ㅌ', None),
       ('b', 'ㅂ', None), ('c', 'ㅋ', None), ('d', 'ㄷ', None), ('f', 'ㅍ', None), ('g', 'ㄱ', None), ('h', 'ㅎ', None), ('j', 'ㅇ', 'y'),
       ('k', 'ㅋ', None), ('l', 'ㄹ', None), ('m', 'ㅁ', None), ('n', 'ㄴ', None), ('p', 'ㅍ', None), ('r', 'ㄹ', None), ('s', 'ㅈ', None),
       ('t', 'ㅌ', None), ('v', 'ㅍ', None), ('w', 'ㅂ', None), ('x', 'ㅋ', None), ('z', 'ㅊ', None)]
YV = {'ㅏ': 'ㅑ', 'ㅔ': 'ㅖ', 'ㅗ': 'ㅛ', 'ㅜ': 'ㅠ', 'ㅓ': 'ㅕ'}
WV = {'ㅏ': 'ㅘ', 'ㅔ': 'ㅞ', 'ㅣ': 'ㅟ', 'ㅓ': 'ㅝ'}
SHV = {'ㅏ': 'ㅑ', 'ㅔ': 'ㅖ', 'ㅗ': 'ㅛ', 'ㅜ': 'ㅠ'}
CODA_J = {'n': 'ㄴ', 'm': 'ㅁ', 'l': 'ㄹ', 'ng': 'ㅇ', 'b': 'ㅂ', 'p': 'ㅂ', 'k': 'ㄱ', 't': 'ㅅ', 'd': 'ㅅ'}
# 끝소리를 별도 음절로 적는 자음
CODA_S = {'b': '프', 'd': '트', 'g': '크', 'k': '크', 'ck': '크', 'p': '프', 't': '트', 'dt': '트', 'th': '트', 'f': '프', 'ff': '프', 'pf': '프', 'v': '프', 'w': '프',
          's': '스', 'ss': '스', 'ß': '스', 'z': '츠', 'tz': '츠', 'ts': '츠', 'x': '크스', 'chs': '크스', 'sch': '슈', 'tsch': '치', 'r': '어', 'h': ''}
VSET = 'aeiouäöüy'


def norm(w):
    """철자를 소리에 가깝게 고친다: 겹자음 하나로, -ig·-lich·-tion, 모음 사이 h 묵음, 끝 -er·-ern."""
    w = w.lower()
    w = re.sub(r'ig$', 'ich', w)
    w = re.sub(r'ige(n|r|s|m)?$', lambda m: 'ige' + (m.group(1) or ''), w)
    w = re.sub(r'tion(en)?$', lambda m: 'zion' + (m.group(1) or ''), w)
    w = re.sub(r'([aeouäöü])h(e|en|er|t|st)$', r'\1\2', w)
    w = re.sub(r'(ff|pp|tt|bb|dd|gg|kk|rr)', lambda m: m.group(1)[0], w)
    return w


def cluster(w, i):
    """자음 + l/r 앞 자음은 으 음절로(블·클·프·그·드·트). l 은 앞 음절 받침 ㄹ 을 더해 ㄹㄹ 로."""
    for a, s in (('schl', '슐'), ('schr', '슈'), ('schw', '슈'), ('schm', '슈'), ('schn', '슈')):
        if w.startswith(a, i):
            return s, 3 + (0 if a[3] in 'wmnr' else 1) if a[3] == 'l' else 3
    for a, s in (('bl', '블'), ('kl', '클'), ('pl', '플'), ('fl', '플'), ('gl', '글'),
                 ('br', '브'), ('kr', '크'), ('pr', '프'), ('fr', '프'), ('gr', '그'), ('dr', '드'), ('tr', '트')):
        if w.startswith(a, i) and i + 2 < len(w) and w[i + 2] in VSET:
            return s, (2 if a[1] == 'l' else 1)
    return None, 0


def word_rule(w):
    w = norm(w)
    out = []
    i = 0
    n = len(w)
    first = True

    def vowel(k):
        for s, v in VOW:
            if w.startswith(s, k):
                if s[-1] == 'h' and k + len(s) < n and w[k + len(s)] in VSET:
                    continue
                return s, v
        return None, None

    while i < n:
        # 낱말 끝 -er / -e / -en / -el
        rest = w[i:]
        s, v = vowel(i)
        if s:
            if i > 0 and rest in ('er',):
                out.append('어'); i = n; break
            i += len(s)
            nxt = _coda(w, i)
            cj, used = nxt
            for x in v[:-1]:
                out.append(syl('ㅇ', x))
            out.append(syl('ㅇ', v[-1], cj)); i += used
            first = False
            continue
        # 자음군
        cs, cu = cluster(w, i)
        if cs:
            out.append(cs); i += cu
            if cs.endswith(('블', '클', '플', '글', '슐')):
                s2, v2 = vowel(i)
                if s2:
                    k3 = i + len(s2)
                    if k3 == n - 1 and s2 == 'e' and w[k3] == 'r':
                        out.append('러'); i = n; break
                    cj, used = _coda(w, k3)
                    if len(v2) == 2:
                        out.append(syl('ㄹ', v2[0])); out.append(syl('ㅇ', v2[1], cj))
                    else:
                        out.append(syl('ㄹ', v2[0], cj))
                    i = k3 + used
            first = False
            continue
        if first and w.startswith(('st', 'sp'), i) and i + 2 < n:
            out.append('슈'); i += 1
            first = False
            continue
        o = next(((a, b, c) for a, b, c in ONS if w.startswith(a, i)), None)
        if not o:
            i += 1
            continue
        a, c, mod = o
        k = i + len(a)
        if a == 'ch' and i > 0 and w[i - 1] in 'aou' or a == 'ch' and k >= n:
            c = 'ㅎ'
        s, v = vowel(k)
        if a == 'h' and i > 0 and not first and not s:
            i = k; continue
        if isinstance(c, list):
            out.append('치'); i = k; continue
        if s:
            v = list(v)
            if mod == 'y': v[0] = YV.get(v[0], v[0])
            if mod == 'w': v[0] = WV.get(v[0], v[0])
            if mod == 'sh': v[0] = SHV.get(v[0], v[0])
            k2 = k + len(s)
            # 낱말 끝 -er
            if k2 == n - 1 and s == 'e' and w[k2] == 'r':
                out.append(syl(c, 'ㅓ')); i = n; break
            cj, used = _coda(w, k2)
            if len(v) == 2:
                out.append(syl(c, v[0])); out.append(syl('ㅇ', v[1], cj))
            else:
                out.append(syl(c, v[0], cj))
            i = k2 + used
        else:
            if a in CODA_S and CODA_S[a]:
                out.append(CODA_S[a])
            elif a == 'ch':
                out.append('히' if i > 0 and w[i - 1] not in 'aou' else '흐')
            elif a in ('l', 'm', 'n', 'r'):
                if out and a == 'r':
                    out.append('어')
                elif out and a in 'lmn' and _nojong(out[-1]):
                    out[-1] = _addj(out[-1], CODA_J[a])
                else:
                    out.append({'l': '르', 'm': '므', 'n': '느'}.get(a, ''))
            else:
                out.append(syl(c, 'ㅡ'))
            i = k
        first = False
    return ''.join(out)


def _nojong(ch):
    return 0xAC00 <= ord(ch) <= 0xD7A3 and (ord(ch) - 0xAC00) % 28 == 0


def _addj(ch, j):
    return chr(ord(ch) + JONG.index(j))


def _coda(w, k):
    """k 자리부터 받침으로 먹을 자음 — 다음이 모음이면 받침 없음."""
    n = len(w)
    if w.startswith('ng', k) and (k + 2 >= n or w[k + 2] not in VSET or True):
        return 'ㅇ', 2
    for c in ('nn', 'mm', 'll'):
        if w.startswith(c, k):
            return CODA_J[c[0]], (1 if k + 2 < n and w[k + 2] in VSET else 2)
    if k < n and w[k] in 'nml' and (k + 1 >= n or w[k + 1] not in VSET):
        return CODA_J[w[k]], 1
    return '', 0


def _load():
    d = {}
    try:
        with open(ROOT / 'assets/data/freq/lang_de_top.csv', encoding='utf-8') as f:
            for r in csv.DictReader(f):
                if r['reading']:
                    d.setdefault(r['word'].lower(), r['reading'])
    except FileNotFoundError:
        pass
    d.update(EXTRA)
    return d


# 변화형·구어 — 단어장에 없고 규칙으로 틀리는 낱말(늘려 간다)
EXTRA = {
    'ich': '이히', 'nicht': '니히트', 'du': '두', 'bin': '빈', 'bist': '비스트', 'ist': '이스트', 'sind': '진트', 'seid': '자이트',
    'hab': '합', 'habe': '하베', 'hast': '하스트', 'hat': '하트', 'haben': '하벤', 'kann': '칸', 'kannst': '칸스트', 'will': '빌', 'willst': '빌스트',
    'möchte': '뫼히테', 'möchtest': '뫼히테스트', 'mir': '미어', 'dir': '디어', 'mich': '미히', 'dich': '디히', 'wir': '비어', 'ihr': '이어',
    'der': '데어', 'die': '디', 'das': '다스', 'dem': '뎀', 'den': '덴', 'des': '데스', 'ein': '아인', 'eine': '아이네', 'einen': '아이넨', 'einem': '아이넴', 'einer': '아이너',
    'kein': '카인', 'keine': '카이네', 'keinen': '카이넨', 'mein': '마인', 'meine': '마이네', 'meinen': '마이넨', 'dein': '다인', 'deine': '다이네', 'deinen': '다이넨',
    'und': '운트', 'oder': '오더', 'aber': '아버', 'auch': '아우흐', 'noch': '노흐', 'doch': '도흐', 'nach': '나흐', 'mal': '말', 'ja': '야', 'nein': '나인', 'nee': '네',
    'was': '바스', 'wer': '베어', 'wie': '비', 'wo': '보', 'wann': '반', 'warum': '바룸', 'hier': '히어', 'da': '다', 'jetzt': '예츠트', 'schon': '숀', 'sehr': '제어',
    'bitte': '비테', 'danke': '당케', 'hallo': '할로', 'tschüss': '취스', 'okay': '오케이', 'ok': '오케이', 'gut': '구트', 'gern': '게른', 'gerne': '게르네',
    'ach': '아흐', 'oh': '오', 'na': '나', 'hm': '흠', 'hmm': '흠', 'äh': '에', 'ähm': '엠', 'haha': '하하', 'hey': '헤이', 'hi': '하이', 'krass': '크라스', 'echt': '에히트',
    'sag': '자크', 'komm': '콤', 'geht': '게트', 'gibt': '깁트', 'weiß': '바이스', 'macht': '마흐트', 'mach': '마흐', 'nichts': '니히츠', 'etwas': '에트바스', 'alles': '알레스',
    'entschuldigung': '엔트슐디궁', 'kaffee': '카페', 'wasser': '바서', 'heute': '호이테', 'morgen': '모르겐',
}
TABLE = _load()


def rd_word(w):
    k = w.lower()
    return TABLE.get(k) or word_rule(k)


TOK = re.compile(r"\{[a-z_]+\}|[A-Za-zÄÖÜäöüß]+(?:'[a-z]+)?")


def rd(text):
    def sub(m):
        t = m.group(0)
        if t.startswith('{'):
            return t
        return rd_word(t.replace("'", ''))
    return TOK.sub(sub, text)


if __name__ == '__main__':
    print(rd(' '.join(sys.argv[1:])))
