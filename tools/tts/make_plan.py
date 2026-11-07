#!/usr/bin/python3
"""회화 파일의 emotion·segs → 감정 계획 data/tts/plan/<편id>.json 을 자동으로 만든다(감정을 손으로 다시 적지 않게, 사용자 지시 2026-11-07).
  python3 tools/tts/make_plan.py [편id...]     없으면 회화 파일 전부. run_all.py 가 시작할 때 부른다.
턴: "emotion": "gentle" 하나, 또는 감정이 바뀌면 "segs": [[감정, 본문], [감정, 본문, 읽기]]. 성별판은 턴의 "m"·"f"(text·rd·ko·segs).
목소리: 편의 "cast" 가 먼저, 없으면 voices.json 의 cast(인물 이름 → 목소리). 자리 채움은 편의 "fill".
감정이 없는 턴이 있거나 인물의 목소리를 모르면 그 편의 계획은 쓰지 않고 오류를 알린다. 소리 낼 글이 없는 턴은 감정이 없어도 된다."""
import glob, json, os, sys
import ttslib as L


def build(ep):
    d = json.load(open(L.EP[ep], encoding='utf-8')); errs = []
    cast = {}
    for k, who in d['speakers'].items():
        if k == 'A':
            continue
        v = d.get('cast', {}).get(k) or L.V.get('cast', {}).get(who)
        if v in L.V['voices']:
            cast[k] = v
        else:
            errs.append(f'{k}={who} 목소리 없음')
    turns = {}
    for t in d['turns']:
        sound = L.SIL.sub('', t.get('es', ''))
        segs = t.get('segs') or ([[t['emotion'], t['es']]] if t.get('emotion') else None)
        if not segs:
            if sound:
                errs.append(f"턴 {t['num']} 감정 없음")
            segs = [['neutral', t.get('es', '')]]
        T = {'segs': segs}
        for g in 'mf':
            if t.get(g):
                T[g] = t[g]
        turns[str(t['num'])] = T
    P = {'ep': ep, 'cast': cast, 'turns': turns}
    if d.get('fill'):
        P['fill'] = d['fill']
    return P, errs


def main():
    ids = sys.argv[1:] or sorted(L.EP)
    bad = 0
    os.makedirs(f'{L.R}/data/tts/plan', exist_ok=True)
    for ep in ids:
        P, errs = build(ep)
        if errs:
            bad += 1
            print(ep, *errs[:6], sep='\n  ')
            continue
        json.dump(P, open(f'{L.R}/data/tts/plan/{ep}.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print('계획', len(ids) - bad, '오류', bad)
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
