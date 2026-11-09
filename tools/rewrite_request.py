#!/usr/bin/env python3
"""Grok 재작성 요청 — 최소 프롬프트(사용자 지시 2026-11-09 "프롬프터 최소화").
규칙은 docs/GROK_RULES_de.md 에 한 번만. 방 첫 메시지 = 규칙 주소 + 약속, 그다음은 편마다 회화 파일 주소 한 줄.
  python3 tools/rewrite_request.py --first            → 방 첫 메시지(한 번)
  python3 tools/rewrite_request.py <편.json>...        → 편마다 한 줄(data/review/grok/<편id>_prompt.md 에도 저장)
주소는 공개 저장소 raw(master) — 파일을 고쳤으면 푸시한 뒤 보낸다."""
import json, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
RAW = 'https://raw.githubusercontent.com/talkverselab/talkverse-de/master/'
if sys.argv[1:] == ['--first']:
    print(f'[DE] 이 방 규칙: {RAW}docs/GROK_RULES_de.md — 읽고 그대로 따라 줘. 앞으로는 회화 파일 주소 한 줄만 보낼게. 각 파일을 규칙대로 모든 줄 새로 써서 규칙의 답 형식으로만 답해 줘.')
    sys.exit()
for p in sys.argv[1:]:
    p = Path(p).resolve()
    e = json.load(open(p, encoding='utf-8'))
    line = f"[DE-{e['id']}] {RAW}{p.relative_to(ROOT).as_posix()}"
    out = ROOT / f"data/review/grok/{e['id']}_prompt.md"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(line + '\n', encoding='utf-8'); print(line)
