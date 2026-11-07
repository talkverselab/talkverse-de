#!/usr/bin/env python3
"""회화 검사기(독일어, 2026-11-07) — 공통 프롬프터 §12·회화 공통 원칙(턴 수·턴 길이·독음·반전·카오스 30%+·표현 풀·du/Sie).

  python3 tools/check_dialogues.py [--fix-rd] [--level R1] [--island love]
--fix-rd: 비어 있는 rd 만 tools/rd_de.py 로 채운다(작성자가 쓴 독음은 덮지 않는다).
독음에서 단어장 낱말이 단어장 독음과 다르면 경고로 알린다. 오류가 0 이어야 다음 단계로 간다.
"""
import csv
import glob
import json
import os
import re
import sys
from collections import Counter, defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rd_de import rd  # noqa: E402

TURNS = {'R0': (4, 8), 'R1': (6, 8), 'R2': (8, 12), 'R3': (12, 16), 'R4': (12, 16)}
WORDS = {'R0': 6, 'R1': 10, 'R2': 14, 'R3': 18, 'R4': 20}
CHAT_WORDS = 8
TWISTS = {'chaos', 'slip', 'reveal', 'emotion', 'ignore'}
REQ = ('id', 'region', 'island', 'kind', 'title', 'emoji', 'scene', 'speakers', 'register', 'twist', 'twist_type', 'expressions', 'turns')
W = r"[A-Za-zÄÖÜäöüß]+"
EMOTIONS = set(json.load(open(os.path.join(ROOT, 'data/tts/voices.json'), encoding='utf-8'))['emotions'])
RANK = {}
with open(os.path.join(ROOT, 'assets/data/freq/lang_de_top.csv'), encoding='utf-8') as f:
    for r in csv.DictReader(f):
        RANK.setdefault(r['word'].lower(), int(r['rank']))
POOL = []
pool_file = os.path.join(ROOT, 'data/expressions/top_expressions.csv')
if os.path.exists(pool_file):
    with open(pool_file, encoding='utf-8') as f:
        POOL = [r['expr'].lower() for r in csv.DictReader(f)]


def nwords(t):
    return len(re.findall(W, re.sub(r'\{[a-z_]+\}', ' x ', t)))


def main():
    fix = '--fix-rd' in sys.argv
    lv_only = sys.argv[sys.argv.index('--level') + 1] if '--level' in sys.argv else None
    is_only = sys.argv[sys.argv.index('--island') + 1] if '--island' in sys.argv else None
    bad = 0
    stat = defaultdict(Counter)
    seen_lines = Counter()
    for f in sorted(glob.glob(os.path.join(ROOT, 'assets/data/dialogues/R*/*/*.json'))):
        try:
            ep = json.load(open(f, encoding='utf-8'))
        except ValueError as e:
            print(f'✗ {os.path.basename(f)}: JSON 오류 {e}')
            bad += 1
            continue
        if (lv_only and ep.get('region') != lv_only) or (is_only and ep.get('island') != is_only):
            continue
        msg = [f'{k} 없음' for k in REQ if k not in ep]
        if msg:
            print(f'✗ {ep.get("id", f)}: ' + ' · '.join(msg))
            bad += 1
            continue
        lv, eid = ep['region'], ep['id']
        if os.path.basename(f) != eid + '.json':
            msg.append('파일 이름과 id 다름')
        lo, hi = TURNS.get(lv, (1, 99))
        turns = ep['turns']
        if not lo <= len(turns) <= hi:
            msg.append(f'턴 수 {len(turns)}(기준 {lo}~{hi})')
        if ep['twist_type'] not in TWISTS:
            msg.append(f'twist_type {ep["twist_type"]}')
        if not 1 <= int(ep['twist']) <= len(turns):
            msg.append('twist 턴 번호 범위 밖')
        stat[lv][ep['twist_type']] += 1
        stat[f'{lv}/{ep["island"]}'][ep['twist_type']] += 1
        if [t.get('num') for t in turns] != list(range(1, len(turns) + 1)):
            msg.append('num 순서')
        whole = ' '.join(t.get('es', '') for t in turns).lower()
        hits = sum(1 for e in POOL if re.search(r'(?<![a-zäöüß])' + re.escape(e) + r'(?![a-zäöüß])', whole))
        if POOL and hits < 2:
            msg.append(f'표현 풀 {hits}개(최소 2)')
        wmax = CHAT_WORDS if ep['kind'] == 'chat' and lv in ('R0', 'R1') else WORDS.get(lv, 99)
        changed = False
        all_emo = set()
        for t in turns:
            es = t.get('es', '')
            n = nwords(es)
            if n > wmax:
                msg.append(f'{t["num"]}번 {n}단어(최대 {wmax})')
            if re.search(W, es) and not (t.get('emotion') or t.get('segs')):
                msg.append(f'{t["num"]}번 emotion·segs 없음')
            emos = [x[0] for x in t.get('segs') or []] + ([t['emotion']] if t.get('emotion') else [])
            if any(x not in EMOTIONS for x in emos):
                msg.append(f'{t["num"]}번 감정 {emos}')
            all_emo.update(emos)
            if not t.get('ko'):
                msg.append(f'{t["num"]}번 ko 없음')
            if t.get('speaker') not in ep['speakers']:
                msg.append(f'{t["num"]}번 speaker {t.get("speaker")}')
            if not t.get('rd') and re.search(W, es):
                if fix:
                    t['rd'] = rd(es)
                    changed = True
                else:
                    msg.append(f'{t["num"]}번 rd 없음')
            elif re.search(r'[A-Za-zÄÖÜäöüß]', re.sub(r'\{[a-z_]+\}', '', t.get('rd', ''))):
                msg.append(f'{t["num"]}번 rd 에 로마자')
            if es:
                seen_lines[es] += 1
            low = re.findall(W, es.lower())
            if ep['register'] == 'polite' and t['speaker'] in ('A', 'B') and ('du' in low or 'dir' in low or 'dich' in low) and not ep.get('duzen'):
                msg.append(f'{t["num"]}번 polite 편에 du')
            if ep['register'] in ('casual', 'chat') and 'Sie' in re.findall(W, es)[1:] and not ep.get('duzen'):
                msg.append(f'{t["num"]}번 casual 편에 Sie?')
        if all_emo == {'neutral'}:
            msg.append('감정이 neutral 뿐')
        if '{name}' not in json.dumps(ep['speakers'], ensure_ascii=False):
            msg.append('A 가 {name} 아님')
        if changed:
            json.dump(ep, open(f, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
        if msg:
            bad += 1
            print(f'✗ {eid}: ' + ' · '.join(msg))
    print()
    for k in sorted(stat):
        c = stat[k]
        n = sum(c.values())
        p = c.get('chaos', 0) * 100 / n
        print(f'{k:14} {n:3}편 | 카오스 {p:3.0f}% | ' + ' '.join(f'{t}:{c.get(t, 0)}' for t in sorted(TWISTS)) + ('  ← 카오스 30% 미만' if p < 30 else ''))
    dup = [(k, v) for k, v in seen_lines.items() if v >= 4 and nwords(k) >= 3]
    if dup:
        print('자주 반복된 줄(경고):', sorted(dup, key=lambda x: -x[1])[:8])
    print(f'\n문제 있는 편 {bad}')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
