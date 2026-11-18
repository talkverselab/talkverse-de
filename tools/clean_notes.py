#!/usr/bin/env python3
"""회화 메모(note) 칸의 작성용 표시를 지운다(uk 공통 알림 2026-11-19). 메모는 앱에 💡 로 보인다.
학습자에게 뜻이 되는 풀이(문법·말투 설명)는 남기고, 이야기 구성 표시(반전·마무리·카오스·심쿵·비트·「X 넣고」…)만 지운다.
대사(es·ko)는 건드리지 않는다.   clean_notes.py [--dry]"""
import glob, json, re, sys
DROP = [  # 통째로 지울 조각(쉼표로 나눈 한 조각이 이것뿐이면)
    r'반전( 공개| 카오스| 실수.*| 준비)?', r'감정 반전', r'카오스', r'심쿵( 고백)?', r'마무리', r'여성이 먼저', r'추천 표현 사용',
    r'단어 포함', r'장면 시작', r'callback', r'punchline', r'setup',
]
SUB = [  # 조각 안에서 지울 말
    r"[A-Za-zÄÖÜäöüß'’?!.,\s]+ 넣고\s*", r'표현 그대로 넣고\s*', r'필수\s*', r'\s*새로 (씀|작성|썼다)',
    r'반전 지점에 맞춰\s*', r'반전 준비로\s*', r'\s*반전으로', r'(재미있게|부드럽게|정중히|다정한)?\s*마무리(하며)?', r'으?로 마무리',
    r'\S+ 비트에 맞춰\s*', r'\S+ 비트로\s*', r'\S+ (성격|설정) 살(려|린)\s*', r'wir 피하고\s*', r'\s*단수로', r'장면 시작으로\s*',
    r',?\s*Handy 언급 없이 시작', r'\s*킥으로', r'여성이 먼저 다가가며 시작', r'\s*추천 표현 사용',
]
FIX = {  # 규칙으로 자르면 어색해지는 줄은 직접
    'wir 피하고 둘 다 웃으라는 다정한 마무리': '둘 다 웃으라는 다정한 말',
    'Lena 자전거 성격 살려 투덜대게': '투덜대며',
    '웃는 킥으로 마무리하며': '',
    '한 모금 비트로': '한 모금 마셔 보며',
    '웃음을 위한 킥으로 사실 공개': '사실을 털어놓음',
    'Oh Mann·Das ist mir peinlich 넣고 당황스럽게': '당황스럽게',
    'weil 넣고 Lena 자전거 성격 살려': '',
    '웃으며 마무리해': '웃으며',
    'pssst·dass 넣고 단호하게': '단호하게',
    '감정 반전으로 수줍게': '수줍게',
}
def clean(n):
    if n in FIX:
        return FIX[n]
    parts = [p.strip() for p in n.split(',')]
    out = []
    for p in parts:
        if any(re.fullmatch(d, p) for d in DROP):
            continue
        for s in SUB:
            p = re.sub(s, ' ', p)
        p = re.sub(r'\s+', ' ', p).strip(' ,·-—')
        if p and not any(re.fullmatch(d, p) for d in DROP):
            out.append(p)
    return ', '.join(out)
dry = '--dry' in sys.argv
n = 0
for f in sorted(glob.glob('assets/data/dialogues/R*/*/*.json')):
    d = json.load(open(f)); ch = False
    for t in d['turns']:
        o = t.get('note', ''); c = clean(o)
        if c != o:
            n += 1; ch = True
            if dry: print(f.split('/')[-1], t['num'], repr(o), '→', repr(c))
            t['note'] = c
    if ch and not dry:
        json.dump(d, open(f, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print(n, '줄', '(미리보기)' if dry else '고침')
