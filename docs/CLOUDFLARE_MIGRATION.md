# Supabase → Cloudflare 이관 — talkverse-de (독일어 앱)

**Supabase 사용 없음 — 확인 2026-10-26.**

- 코드(`lib/`)·안드로이드·iOS·웹 파일·스크립트(`tool/`, `tools/`)에 Supabase 주소·키·클라이언트가 없다. `pubspec.yaml` 에도 Supabase·HTTP 백엔드 패키지가 없다.
- 데이터는 전부 기기 안: 번들 에셋(`assets/data/**`) + 로컬 SQLite(drift·sqflite, 학습 기록) + `shared_preferences`. 로그인·계정·구독 없음, 저장소 버킷·RPC 없음.
- 외부 통신은 앱 업데이트(GitHub 릴리스 `latest.json`·APK)뿐.
- 옮길 것 없음. 나중에 계정·학습 기록 동기화를 붙이면 공용 `talkverse-accounts`·`talkverse-db`(태국어앱 설계 §2)를 따른다.
