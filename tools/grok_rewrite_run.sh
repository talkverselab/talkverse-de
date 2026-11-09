#!/bin/zsh
# 회화 Grok 재작성 회차(PC 크롬 9258, 전문가 모드 — hu 회차 스크립트를 옮김). 방 하나에 N편(10편 이하) — 첫 메시지만 규칙 첨부, 이후 파일 이름 한 줄 + 그 편 JSON 첨부.
#   zsh tools/grok_rewrite_run.sh [--chat <방 주소>] <편id>...   결과 data/review/grok/out/<id>.md, 로그 data/review/grok/run.log
cd "$(dirname "$0")/.."
export GROK_CDP_PORT=9258
chat=""; [[ $1 == --chat ]] && { chat=$2; shift 2; }
tmp=${GROK_TMP:-${TMPDIR:-/tmp}}/grok_de_first.txt
for id in "$@"; do
  out=data/review/grok/out/$id.md
  [[ -s $out ]] && { echo "skip $id"; continue; }
  src=$(ls assets/data/dialogues/R*/*/$id.json 2>/dev/null | head -1)
  [[ -z $src ]] && { echo "없음 $id"; continue; }
  if [[ -z $chat ]]; then
    print -r -- "첨부한 GROK_RULES_de.md 가 이 방의 규칙이다. 앞으로는 파일 이름 한 줄만 보내고 그 파일을 첨부한다. 첫 편: $id.json" > $tmp
    r=$(python3 tools/grok_text.py $tmp $out docs/GROK_RULES_de.md $src 2>&1)
  else
    r=$(python3 tools/grok_text.py -m "$id.json" $out $src --chat "$chat" 2>&1)
  fi
  rc=$?
  echo "$(date +%H:%M) $id rc=$rc $(echo $r | grep -E '저장|LIMIT|전문가' | tr '\n' ' ')" | tee -a data/review/grok/run.log
  [[ $rc -eq 3 ]] && { echo "LIMIT — 멈춤"; exit 3; }
  c=$(echo $r | grep '^CHAT ' | awk '{print $2}' | sed 's/?.*//'); [[ -n $c ]] && chat=$c
  sleep 20
done
echo "끝 $chat" | tee -a data/review/grok/run.log
