#!/bin/zsh
# 언어감각 과정 대화(급마다 10줄)를 Grok 「빠른」에 요청(PC 크롬 9258). 첫 요청에 규칙 docs/GROK_SENSE_de.md 첨부, 이후 한 줄 + 급 JSON.
#   zsh tools/grok_sense_run.sh [--chat <방>] L1 L2 …   결과 data/sense/out/<급>.md
cd "$(dirname "$0")/.."
export GROK_CDP_PORT=9258
chat=""; [[ $1 == --chat ]] && { chat=$2; shift 2; }
tmp=${TMPDIR:-/tmp}/grok_de_sense_first.txt
for id in "$@"; do
  out=data/sense/out/$id.md; src=data/sense/brief/$id.json
  [[ -s $out ]] && { echo "skip $id"; continue; }
  if [[ -z $chat ]]; then
    print -r -- "첨부한 GROK_SENSE_de.md 가 이 방의 규칙이다. 앞으로는 파일 이름 한 줄만 보내고 그 급 JSON 을 첨부한다. 첫 급: $id.json" > $tmp
    r=$(python3 tools/grok_text.py $tmp $out docs/GROK_SENSE_de.md $src 2>&1)
  else
    r=$(python3 tools/grok_text.py -m "$id.json" $out $src --chat "$chat" 2>&1)
  fi
  rc=$?
  echo "$(date +%H:%M) sense $id rc=$rc $(echo $r | grep -E '저장|LIMIT|없음' | tr '\n' ' ')" | tee -a data/review/grok/run.log
  [[ $rc -eq 3 ]] && { echo "LIMIT — 멈춤"; exit 3; }
  c=$(echo $r | grep '^CHAT ' | awk '{print $2}' | sed 's/?.*//'); [[ -n $c ]] && chat=$c
  sleep 20
done
echo "끝 $chat" | tee -a data/review/grok/run.log
