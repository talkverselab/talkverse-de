#!/bin/bash
# 가장 최근 release APK 를 Zealot(https://apps.talkverse.uk)에 올린다. 빌드는 하지 않는다.
# 사용: tools/zealot_push.sh ["변경 내용 한 줄"]        로컬에서 빌드한 APK(먼저 flutter build apk --release --build-number=<N>)
#       tools/zealot_push.sh --ci ["변경 내용 한 줄"]   GitHub latest 릴리스의 APK(CI 빌드)를 받아서 — 보통 이쪽
# 변경 내용을 안 주면 최근 커밋 제목.
set -euo pipefail

APP_NAME="독일어유니버스"
REPO="talkverselab/talkverse-de"
EXPECTED_SHA1="9cc4bc932638be43a3982df20b71c4750288476b"

cd "$(dirname "$0")/.."

if [ "${1:-}" = "--ci" ]; then
  shift
  mkdir -p build/zealot
  gh release download latest -R "$REPO" -p 'app-latest.apk' -D build/zealot --clobber
  APK="build/zealot/app-latest.apk"
else
  APK=$(ls -t build/app/outputs/flutter-apk/*-release.apk build/app/outputs/apk/release/*.apk 2>/dev/null | head -1 || true)
  if [ -z "$APK" ]; then
    echo "release APK 가 없습니다. 먼저 flutter build apk --release --build-number=<N> 하거나 --ci 를 쓰세요." >&2
    exit 1
  fi
fi

# 서명이 바뀐 APK 는 폰에서 덮어 설치가 안 된다(CLAUDE.md §1) — 올리기 전에 막는다.
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
APKSIGNER=$(ls "$SDK"/build-tools/*/apksigner 2>/dev/null | tail -1 || true)
if [ -n "$APKSIGNER" ]; then
  SHA1=$("$APKSIGNER" verify --print-certs "$APK" | grep 'SHA-1' | head -1 | awk '{print $NF}')
  if [ "$SHA1" != "$EXPECTED_SHA1" ]; then
    echo "서명이 다릅니다: $SHA1 (기대 $EXPECTED_SHA1) — 올리지 않습니다. CLAUDE.md §1 참고." >&2
    exit 1
  fi
else
  echo "apksigner 를 찾지 못해 서명 확인을 건너뜁니다." >&2
fi

NOTE="${1:-$(git log -1 --pretty=%s)}"
echo "올림: $APK"
exec "$HOME/bin/zealot-upload" "$APK" "$APP_NAME" -c "$NOTE"
