#!/usr/bin/env python3
"""편 JSON → Grok 재작성 요청문(tools/prompts/rewrite_grok.md 틀).  python3 tools/rewrite_request.py <편.json>... → data/review/grok/<편id>_prompt.md
레벨별 문법 조건(굴절어 전략, docs/DIALOGUE_RULES_de.md)과 한 턴 단어 수 상한을 넣는다."""
import json, re, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
tpl = re.search(r'```\n(.*?)```', (ROOT / 'tools/prompts/rewrite_grok.md').read_text(encoding='utf-8'), re.S).group(1)
REG = {'casual': '친구·연인 사이 du', 'chat': '채팅(du·줄임말·이모지)', 'polite': '처음 보는 사이·가게·관청(Sie)', 'mixed': '직원·낯선 사람은 Sie, 친구끼리는 du'}
LV = {  # (레벨 설명, 문법 조건, 한 턴 단어 상한)
    'R0': ('0 입문 — 인사·맞장구 수준의 아주 짧은 말', '아주 쉬운 단어만, du 와 단수(ich/du)만 — wir/ihr/Sie 금지', 6),
    'R1': ('1 기초 — 관사·격·현재형·현재완료·화법조동사까지', '쉬운 단어 위주, du 와 단수(ich/du/er/sie)만 — wir/ihr/uns/euch/Sie 금지, 종속절(weil/dass/관계문)·접속법 금지', 10),
    'R2': ('2 채팅 실전 — 메신저 대화', 'du 와 단수만 — wir/ihr/uns/euch/Sie 금지, 짧은 weil·dass·wenn 부문장은 가능, 관계문 금지, 명사 앞 형용사 어미 금지(서술형만), 과거는 현재완료로(war·hatte·konnte·wusste 만 과거형), 접속법은 고정형만, 채팅답게 짧게', 14),
    'R3': ('3 복수·존댓말 — 같은 기초 문법을 wir/ihr/Sie 로', 'wir·ihr·Sie 를 자연스럽게 쓰고 명사 앞 형용사 어미도 가능, 짧은 weil·dass·wenn 가능. 금지: 관계문·수동·접속법(고정형 제외)·일반동사 과거형(war·hatte·konnte·wusste 만 가능)', 18),
    'R4': ('4 어려운 문법 — 접속법 II·관계문·수동·종속절', '초안의 문법 포인트(접속법 II·관계문·수동 등)를 반드시 살릴 것. 과거는 현재완료로(일반동사 과거형 금지, war·hatte·konnte·wusste 는 가능)', 20),
    'R5': ('5 어휘 확장 — 새 문법 없이 생활 어휘', '문법은 이미 배운 것까지, 생활 어휘를 풍부하게(너무 드문 낱말은 피함)', 20),
}
for p in sys.argv[1:]:
    e = json.load(open(p, encoding='utf-8'))
    roles = ' / '.join(f"{k} = {'학습자(외국에서 온 20대, 국적은 정하지 않음 — 나라 이야기 금지, 이름 {name})' if v == '{name}' else v}" for k, v in e['speakers'].items())
    lines = '\n'.join(f"{t['num']} {t['speaker']}: {t['es']} / {t['ko']}" for t in e['turns'])
    lv = LV.get(e['region'], LV['R1'])
    txt = (tpl.replace('{code}', f"DE-{e['id']}").replace('{roles}', roles).replace('{scene}', e['scene'])
           .replace('{register}', REG.get(e.get('register'), e.get('register', ''))).replace('{level}', lv[0])
           .replace('{grammar}', lv[1]).replace('{words}', str(lv[2])).replace('{twist}', str(e.get('twist')))
           .replace('{n}', str(len(e['turns']))).replace('{lines}', lines))
    out = ROOT / f"data/review/grok/{e['id']}_prompt.md"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(txt, encoding='utf-8'); print(out.relative_to(ROOT))
