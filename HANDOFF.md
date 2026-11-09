# HANDOFF — talkverse-de (독일어유니버스)

## 다음에 할 내용 (2026-11-09, 세션 종료 시점)

**현재 상태**: master `5fd0aca` 까지 푸시. 배포 = Zealot 빌드 16 https://apps.talkverse.uk/8itFp/426 · TestFlight 2611091216(같은 커밋). 이번에 들어간 것: 가격 확정표(uk 커밋 7423bac — lang_de_1m·3m·1y·life·all_1y·all_life, 결제 화면 규정 표기) · 스토어 차별화 문서 `docs/STORE_PRODUCTS.md`·`docs/store/review_notes.md` · 통합 앱 연결점(`lib/embed.dart`·`core/embed_env.dart`·`core/prefs.dart`, 패키지 `german_universe`, 콜백 `talkverse.de://auth`). 작업 트리의 남은 변경은 빌드 잡음뿐.

- ⚠ 이 빌드부터 설정 키·DB 파일·그림 폴더가 `de_` 이름으로 바뀐다(단독 앱은 처음 실행 때 옛 이름에서 한 번 옮김). 코드 확인·시뮬레이터 새 설치 실행만 했고 **옛 데이터가 있는 폰에서 업데이트 확인은 아직** — 학습 기록이 남는지 확인할 것.
- ⚠ 스토어 문서 작성 중 발견: 「동사 활용」 데이터 0개(화면이 계속 로딩), 「성·수」 준비 중 — 출시 전 채우거나 메뉴에서 뺀다(`docs/STORE_PRODUCTS.md` 체크리스트).
- 통합 앱(~/talkverse/talkverse-app) 연결은 talkverse-uk 가 한다 — 이 저장소에서 통합 앱을 고치거나 빌드하지 않는다.

**Grok 공지(2026-11-09, `~/logs/rc/RELAY_grok_20261109.md`)**: M4 uk 크롬(9231)에 옛 계정 재로그인(한도 남음, uk 방은 건드리지 말 것). 한자 세션 대행은 중단 — 이 세션이 자기 크롬(독일어 포트 미배정, 9233 예정)을 켜고 M4 에서 `/usr/bin/python3 ~/talkverse-uk/tools/grok_cookie_sync.py 9231 <자기 포트>`(ssh macmini4)로 쿠키를 맞춘 뒤 직접 처리. 요청 도구는 M6 `~/Hanja/tools/grok_req.py`·`grok_cdp.py` 를 복사해 쓴다.

**Grok 최소 프롬프트(사용자 지시 2026-11-09)**: 규칙은 `docs/GROK_RULES_de.md` 한 번, 방 첫 메시지 `python3 tools/rewrite_request.py --first`, 이후 편마다 파일 주소 한 줄(`data/review/grok/<편id>_prompt.md`). 그림이 처음과 달라지면 최초 통과 그림 기준(이미 만든 것은 그대로). 회화는 줄마다 감정 열 필수.

**회화 원칙 추가(2026-11-09)**: 일상 장면 안에서 반전·러브·플러팅을 다 넣는다(줄이지 않음, 비현실적 설정만 금지 — `docs/DIALOGUE_RULES_de.md` §8). **음성 생성은 새벽 01:00~07:00 에만**(전역 규칙, 사용자 지시 2026-11-09).

**남은 일(순서)**
1. **Grok 회화 재작성** — 11-09 13:30 재개(uk 공지), 사용자 지시 뒤. 준비물: 요청문 26편 `data/review/grok/<편id>_prompt.md`, 틀 `tools/prompts/rewrite_grok.md`, 반영 `tools/apply_rewrite.py`, 전송 `tools/grok_send.py` 등. 독일어 M4 Chrome 포트 미배정(기본값 9233) — 시작할 때 `~/talkverse/GROK_M4_LOGIN.md` 15행에 보태고 `~/chrome-grok-de` 생성. 샘플 1~2편 → 사용자 통과 → 본작업.
2. **사용자 결정 대기**: `docs/APP_STRATEGY_de.md` §7 결정 10개(M0 안드로이드 선행 여부·초안 노출·옛 L1 5편·학습 기록 보존 등), `docs/DIALOGUE_RULES_de.md` §3 세 가지(성별판 최소화·강세 부호 미표기·단어 상한 2,000 유지), 외계인 캐릭터 시트(A10).
3. **음성** — 독일어 음성 보류(사용자 지시), PC 순서 요청 금지. 재개되면 MOSS 개선판·VoxCPM2 중 사용자 선택 → `docs/AUDIO_QA_DE.md`.
4. **앱 M0 구조**(전략 §5) — 회화 R 폴더 로더·pubspec 주제 폴더·DB 시딩(학습 기록 보존 먼저)·레벨 선택·앱 소개 레벨표. 결정 1·2·5 뒤.
5. **알파벳과 발음 그림 교체** — `assets/images/ipa/` 는 출처 표기 없는 임시 그림(CC BY-SA). 출시 전 Grok 그림으로 바꿀 것.
6. 단어표 2,000위 확장(동결 해제됨, 원 말뭉치 재측정 필요) — 사용자 지시 뒤.

**주의**: 회화 28편은 모두 `draft: true`, 검사기 `tools/check_dialogues.py --align-rd`·`tools/level_grammar_check.py`·`tools/inflection_report.py`·`tools/tier_report.py`. 문법 배치 확정본 `docs/GRAMMAR_LEVELS_de.md`. 레마 도구 `tools/add_lemmas.py` 는 고치지 않는다(사용자 지시). 안드로이드·iOS 는 항상 같은 커밋으로 함께.

_2026-11-03 새로 씀. 앞 판(2026-10-11 메모·Zealot 확인 필요)은 이 판으로 대체 — 해결된 것은 지웠다._

## ⛔ 지금 지킬 것
- ~~새 학습 콘텐츠 작성 금지~~ — **2026-11-08 사용자 지시로 회화·회화 밖 콘텐츠 동결 모두 해제**(uk 전달 "둘 다 해제"). 회화 공통 원칙 링크·독일어 특이점은 CLAUDE.md 「화면 구성」.
- 아이콘은 talkverse.uk 세션 담당(`~/talkverse/branding/TONE.md`) — 아이콘 파일 직접 수정 금지.
- Grok 그림 요청은 한자 세션 경유(그림만, 글 시안은 이 세션이 직접). `~/talkverse/LANG_APP_REPLICATE_PROMPT.md` §9.
- **Grok·Gemini 를 직접 쓸 때(2026-11-03 사용자 지시)**: 사용자 지시가 있을 때만 켠다(M4 에 미리 켜 두지 않음). 쿠키 복사는 M4 안에서만(`~/chrome-grok` → `~/chrome-grok-de/Default/`), M4 에서 자기 포트(`GROK_CHROME_PORTS.md`)로 띄우고 M6 에서 `ssh -fN -L <로컬>:127.0.0.1:<포트> macmini4` 터널. 첨부는 M4 `/tmp/grok_att/de/`. 한 번에 한 작업, 연 탭은 끝나면 닫고 Chrome 도 끈다. 상세 `~/talkverse/GROK_M4_LOGIN.md`, 예 `~/talkverse/ko/tools/grok_base.py`.
  - 2026-11-03: M4 Grok 이 **새 계정**으로 로그인됨(원본 `~/chrome-grok`, 9222 — 예전 계정은 11/9 까지 한도, 새 계정엔 프로젝트·챗·GitHub 커넥터 없음). 시작할 때 순서: ① 쿠키를 M4 안에서 `~/chrome-grok` 에서 다시 복사 ② 샘플 1~2개 먼저 시험 ③ 결과를 사용자에게 알림(PushNotification)으로 통과 요청 ④ 통과 뒤 본작업. **사용자 지시 전엔 Grok 작업을 시작하지 않는다.**
  - Grok 회화 재작성·장면 컷 요청문 작성법: `/Users/talkverse/talkverse/GROK_PROMPT_GUIDE.md`(중국어앱이 돌려 통과한 방식 — 전문가 모델, 편마다 새 방, 답은 30초 뒤 다시 받기, 「판정 말고 재작성·모든 줄 새로」, 받은 재작성·컷은 그대로 쓰지 말고 리뷰, 컷은 한 요청에 1장). 틀 파일 `~/talkverse/zh/tools/`(prompts/rewrite_grok.md·rewrite_request.py·scene_prompts.py·grok_*.py)를 복사해 언어 코드만 바꾼다.
- **회화를 쓰게 되면(반전 비율, 원칙 §9)**: 카오스 30% 이상, 연애·플러팅 편마다 심쿵 한 줄(여성 주도 편 더 많이), 편마다 `twist_type`(chaos·slip·reveal·emotion·ignore), 새 편은 왕초보·초급 위주, 그림 = A·B 쌍 1컷(말풍선·글자 없음, `CHARACTERS.md` 첨부).

## 2026-11-04 추가 변경(일본어앱 8가지, 공통 프롬프터 §5-1) — 적용 상태
| # | 변경 | 이 앱 |
|---|---|---|
| ① | 말풍선 → 그림 아래 띠 | `SceneCut` `bubble` = `_LineStrip`(화자 이름표 + 한 줄), 재생 화면 컷엔 띠 없음(아래 캡션). du/Sie 배지는 작은 표식으로 그림 왼쪽 위에 남김 |
| ② | 그림 카드 앞면 한국어 | `dialogue_card_screen.dart` `_CardText` — 한국어 뜻 크게 + 「이 말을 독일어로 해 보세요」 |
| ③ | 문장 레마 ↔ 단어장 | `tools/add_lemmas.py`(spaCy 독일어 소형 모델, venv `~/.venvs/de`) → `L1.json` 턴 `lemmas`. 단어장 = `WordService`(번들 `assets/data/freq/lang_de_top.csv` 1,500 + `travel_words.json`), 칩 `lib/widgets/lemma_chips.dart` → `word_sheet.dart`. 내용어 94개 중 94% 단어장에 있음, 없는 5개 `data/review/write/missing_lemmas.csv`(Samstag·Apfelkuchen·Favorit·Museum·Okay → uk 세션) |
| ④ | 시작 때 그림 기기 내려받기 | `lib/services/content_sync.dart`(art/de), `lib/screens/sync_screen.dart`, `main.dart` `syncFirst`, 모든 그림 `artProvider()`. 장면 컷 조회는 `ContentSync.sceneIndex` 먼저 |
| ⑤ | DB 업데이트 번호 | `assets/data/version.json` `db: 3`(옛 `db_seeded_v2` 폐지). 번호가 다르면 단어·동사·회화 전부 다시 채움(`SeedLoader`). **데이터를 바꾸면 이 번호만 올린다** |
| ⑥ | 이름 없으면 묻기 | `lib/widgets/learner_setup_dialog.dart` `ensureLearnerName` — `{name}` 있는 편을 열 때. 지금 회화 5편은 이름이 고정(Minjun)이라 아직 안 뜸 |
| ⑦ | 여자 학습자 컷 | `ArtService.sceneCut` — 성별 여자면 `<편id>_f` 먼저. 컷은 아직 없음 |
| ⑧ | 조연 캐릭터 시트 | **미완** — 회화·반복 조연이 아직 없고 Grok 작업은 사용자 지시 전 대기. 회화가 생기면 Grok(한자 세션 경유)으로 2장 |
- 빈도 단어 화면: 그동안 비어 있던 `lang_es_top.csv` 를 지우고 절벽 1,500단어(`lang_de_top.csv`)를 `words` 표에 채움(region = R1~R5).

## 2026-11-07 단어·메뉴 개편(일본어앱 `docs/MENU_WORDS_2026-11-07.md` §1~§6) — 적용 상태
- **§1 절벽 단어**(`word_freq_screen.dart`): 20어 단원 · 네모 타일(순위·독음·그림·관사+단어·뜻, 탭=발음) · 「절벽구간 단어만 / 회화 단어 포함 (+6)」. 숫자는 `lib/core/cliff.dart` 한 곳. 회화 목록 `tools/conv_words.py` → `assets/data/freq/conv_words_de.json`.
  **R5 상한은 2,000(`kWordCap`)이지만 단어표는 1,500까지** — 1,501위 이후 새 단어는 콘텐츠 동결이라 쓰지 않았다. 동결이 풀리면 `lang_de_top.csv` 를 2,000위까지 늘리고 `kWordListEnd`·`kWordListEndPct`·앱 소개 문구를 고친다.
- **§2 문자 기준**: 일본어·중국어만 — 해당 없음.
- **§3 앱 소개**(`about_screen.dart`): 레일 맨 아래 + 프로필 → 정보. 단어 기준 · 산출 방식 · 쓰는 곳. 표는 앱 단어표 경계 81·111·280·822, 머리글·주석은 공식 89·130·317·1,084. 누적 끝값 약 84%(원 목록 약 1,950항목).
- **§4 메뉴**: 홈을 기초 → 문법 → 회화 → 단어 → 참고 묶음으로. 프로필에서 앱 업데이트 타일·TTS·변종·테마·Stack 삭제. **학습 탭(`ConversationScreen`)은 남겼다** — 빼면 탭 자리가 비고 「오늘의 학습」이 쓰는 화면이라 새 회화가 생길 때 정리. 「앱 업데이트」 화면 코드(`update_screen.dart`)는 남아 있고 타일만 없다 → CLAUDE.md §2·§6 의 폰 업데이트 설명은 옛 내용(Zealot 으로 받는다).
- **§5**: 「말하기」→「문장 말하기」, 부제 「한글 보고 독일어로」, 회화 바로 다음 칸. 단계 시간은 이 앱 값(10·5·2초) 그대로.
- **§6**: 회화 문장 내용어 탭 → 단어창(`GenderText` `lemmas`, 단어장에 있으면 밑줄). 한글 독음 전역 토글 `KoReadingPrefs` 기본 미표시, 켤 때 스낵바, 회화·카드·절벽 단어 앱바 + 프로필 설정. 길게 누르기(한자 시트)는 해당 없음.

## 2026-11-07 회화 초안(사용자 지시, uk 전달)

- 처음 지시는 전체 초안이었으나 **굴절어는 레벨별 1편만**으로 줄었다. 쓴 것 4편(`draft: true`): `r1_survival_s1`·`r2_love_b1`·`r3_life_b1`(du 전환 장면)·`r4_work_b1`. 더 쓰지 말고 uk 지시를 기다린다.
- 앱은 아직 `L1.json` 만 읽고 `R*/` 는 번들에 없어서 앱에 안 나온다. Grok 재작성은 주간 한도로 11-10 까지 막힘 — 사용자 지시 뒤 재작성.
- 새 도구: `tools/check_dialogues.py`, `tools/rd_de.py`(단어장 독음 우선, 규칙은 단어장과 74% 일치 — 독음은 손으로 쓰고 대조용으로 쓴다), 표현 풀 `data/expressions/top_expressions.csv`.
- 앞으로 쓰는 회화는 턴마다 `emotion`(`~/talkverse/ja/data/tts/PLAN_GUIDE.md` 의 16개), 감정이 바뀌는 턴은 `segs` 를 함께 쓴다(사용자 지시, uk 전달). 초안 4편은 `data/tts/plan/` 에 감정 계획이 있다.
- 감정 계획은 손으로 쓰지 않는다: 회화 파일의 `emotion`·`segs` → `tools/tts/make_plan.py` → `data/tts/plan/`(run_all 이 시작할 때 부름). 고정 인물·조연의 목소리는 `data/tts/voices.json` 의 `cast`. 검사기가 감정 없는 턴을 오류로 잡는다.
- 음성: 4편 86조각 생성 끝(100줄, 약 347초), R2 에만 올렸고 D1 `audio_lines` 에는 넣지 않았다(`NO_DB=1`, 초안이라서). 넣으려면 `tools/tts/pack.py <wav폴더> <편id>... --upload`. 작업 폴더 `~/tts_work/de`.
- 사용자 청취 "독일어 품질 안좋아" → 점검 결과·개선안 `docs/AUDIO_QA_DE.md`. 전편·재생성 순서는 uk 가 잡는다. 11번 재생성 "지금 시작" 도 이 개선안 결정 뒤로 본다.
- 개선 시험 끝(2026-11-08): `r1_survival_s1` 은 MOSS·VoxCPM2 두 판, r2 11번 재생성 완료. 사용자 청취로 모델을 고른 뒤 r2~r4 를 `TTS_OUT` 을 나눠 다시 만든다(`make_plan.py` 가 문장 단위로 쪼개므로 옛 wav 와 이름이 다르다).
- 레마는 `tools/add_lemmas.py` 그대로(사용자 지시로 고치지 않음). 소형 모델 오류(Taß·Hättest·Gute)가 남아 있다.

## 2026-11-08 알파벳과 발음(공통 프롬프터 §5-3)

- 홈 「기초」 첫 칸 `lib/screens/alphabet_screen.dart` + `lib/widgets/alphabet_sound_sheet.dart`·`de_vowel_chart.dart`, 데이터 `lib/services/de_phonetics.dart`(6묶음 57단위, 예시 단어는 단어장 그대로). 글자 탭 = 1초 뒤 기기 TTS·다시 듣기·IPA·조음 위치·모음 비교·한국어 비교.
- `assets/images/ipa/` 두 장은 일본어앱에서 복사한 **임시 그림 — 출처 표기 없음(사용자 지시 "출처표기삭제 어차피 출시전 삭제")**. 출시 전에 Grok 그림으로 바꿀 것(CC BY-SA 그림이라 표기 없이 출시하면 안 된다).

## 2026-11-08 회화 전편 초안 · 음성 보류 · Grok 준비

- 회화 초안 28편(레벨 0~5, `docs/DIALOGUE_RULES_de.md` §5·§6), 리뷰 페이지 REVIEW_de 게시(uk). 앱 빌드 전략 `docs/APP_STRATEGY_de.md`(Fable) — 결정 10개 대기.
- **독일어 음성은 보류(사용자 지시 2026-11-08) — PC 순서 요청도 하지 않는다.** MOSS 개선판·VoxCPM2 비교본은 R2 에 있음(`docs/AUDIO_QA_DE.md`).
- Grok 재작성 준비 끝(실행은 사용자 지시 뒤, 주간 한도 11-10): 틀 `tools/prompts/rewrite_grok.md`, 요청문 26편 `data/review/grok/<편id>_prompt.md`(`tools/rewrite_request.py`), 반영 `tools/apply_rewrite.py`, 전송 `tools/grok_send.py`·`grok_fetch.py`·`grok_wait.py`(중국어앱 복사). 독일어용 M4 Chrome 포트는 아직 배정 전 — 스크립트 기본값 9233(비어 있음), 시작할 때 `GROK_M4_LOGIN.md` 15행에 보태고 M4 `~/chrome-grok-de` 를 만든다. 순서: 샘플 1~2편 → 사용자 통과 → 본작업, 편마다 새 대화방, 「전문가」 모델.

## 현재 상태 (2026-11-03 00:50)
| 항목 | 상태 |
|---|---|
| 캐릭터 시안 ① | **통과** 2026-11-03 — `data/review/art/chars_de_v1.jpg`, 고정 인물표 `data/review/art/CHARACTERS.md`(레나·미아·요나스·펠릭스 + 학습자 남녀, 베를린) |
| UX/UI 시안 ② | **통과** 2026-11-03 — 글 `data/review/uxui/sian_de_01.md`(직접 작성), 그림 `sian_de_01.jpg`. 일본어앱 시안 02 + 독일어 칸 2개(명사 성 점·단어 시트 / du·Sie 배지) |
| 아이패드 빌드 ③ | **완료** — 두 화면(레일·왼쪽 칸·오른쪽 칸), 만화책 읽기형 회화 리더, 그림 카드, 진행 탭 성과 데스크, 프로필 학습자 이름·성별. iPad Air 13 스크린샷 9장 넘침 0·예외 0(`integration_test/dialogue_pane_test.dart`, `tools/pane_shots.py`) |
| Talkverse ID 로그인·평생 이용권 | 코드 들어감(`lib/data/account.dart`·`purchase.dart`·`entitlement.dart`, 로그인·잠금 시트, 프로필 계정 칸). client_id `de`, 딥링크 `talkverse.de://auth`, 상품 iOS `com.talkverse.germanUniverse.lifetime` / Android `lang_de`. **잠긴 콘텐츠 없음** |
| Android | CI 빌드 16(`5fd0aca`, 가격표·통합 앱 연결점) → Zealot https://apps.talkverse.uk/8itFp/426 , PC 백업. 그 전 14 /8itFp/371(알파벳과 발음), 13 /8itFp/349
| iOS | TestFlight **2611091216**(`5fd0aca`, Apple 로그인 entitlement 확인). 그 전 2611081703(알파벳과 발음) |
| 서명 키 | 원래 키 그대로(SHA-1 `9C:C4:…`), PC `D:\keys\talkverse-de\` 백업, Doppler `SIGNKEY_*` |
| 저작권 | 출처 이름 든 파서·주석 삭제(`2db89c2`). 과거 이력 9커밋에 이름이 남아 있음 — 정리 안 함 |
| 태그 | `pre-grok-uxui` = UX 시안 적용 전(`75cc18b`) |

## 다음 할 일 (순서대로)
1. ~~단어 그림 리스트~~ — **완료 2026-11-03**: `talkverselab/talkversehanja` `talkverse_art/words/de.csv`(1,500단어, 실측 기준으로 교체)·`de_food.csv`(음식 50). 아래 「절벽 구간」 참고.
2. 사용자 결정 대기:
   - 평생 이용권이 무엇을 여는지(없으면 App Store 심사 3.1.1 거절 위험). 정해지면 `Entitlement.premium` 으로 잠그고 `docs/store/review_notes.md` 의 구매 위치 문구 수정.
   - 과거 커밋 이력 정리(filter-repo + 강제 push) 여부.
   - 스토어 인앱 상품 등록(사용자) — 등록 전엔 결제 시트가 「스토어에 연결하는 중…」.
3. 회화 작업이 풀리면: 새 구조(R0~R4·주제별 편 JSON) + 턴 `nouns`·편 `register` 칸을 채우면 UX 칸 1·2 가 켜진다(`lib/services/dialogue_service.dart` NounInfo·registerAt). du/Sie 규칙·독음 표기표는 CLAUDE.md.
4. 장면 컷: 회화 편이 생기면 편당 4컷(§10) — `CHARACTERS.md` 첨부. 앱은 `/art/de/scene/manifest` 를 자동으로 읽는다.

## 절벽 구간 (2026-11-03, 사용자 지시 "실측값으로 바꿔")
- **실측**: 독일·오스트리아·스위스에서 만든 영화·드라마(번역 더빙·외국 작품 제외) 자막 28,337개, 1억 2,746만 토큰을 레마+품사 단위로 센 값 — 러시아어앱 세션이 만든 분석(`~/talkverse/ru/_opus_build/analysis_de_domestic/`: `cliff_summary.txt`·`top5000_lemma.csv`). 자국 작품은 작품 번호를 제작 국가 정보로 거꾸로 조회해 걸렀다(방법은 러시아어앱 세션, 출처 이름은 파일에 적지 않는다).
- **공식 경계(레마+품사, 원 순위)**: R1 89(55%) · R2 130(60%) · R3 317(70%) · R4 1,084(80%). /cliff/ 사이트 값으로 쓸 것은 이 숫자.
- **그림용 목록 `de.csv`**(talkversehanja `talkverse_art/words/de.csv`): 원 목록 상위 1,960항목의 자동 레마 오류를 고치고(komm→kommen, mir→ich, 명사 대문자·성), 이름·외국어·감탄음을 빼고 같은 레마를 합친 1,500단어. 수준은 원 경계의 **빈도 문턱**(89위 217,803회 · 130위 124,937회 · 317위 38,199회 · 1,084위 8,423회) 이상이면 그 구간 → **R1 1~81 · R2 82~111 · R3 112~280 · R4 281~822 · R5 823~1,500(절벽 밖)**. 같은 레마를 합쳐서 원 순위보다 앞당겨진다. 그림 가능 Y 504.
- 처음 낸 Opus 추정치(R1 103·R2 159·R3 512)는 이 실측값으로 대체.

## 배포 절차 요약
- Android: master 푸시 → CI(빌드 번호 = 실행 번호) → `tools/zealot_push.sh --ci "변경 한 줄"` → PC 백업. `**.md`·`tools/**`·`ios/**` 만 바뀐 푸시는 빌드 안 함.
- iOS: `bash tools/ios_release.sh`(백그라운드, 8~12분, 빌드 번호 = KST yymmddHHMM) → 끝나면 ipa 를 풀어 `codesign -d --entitlements :-` 에 `applesignin` 확인.
- 빌드 뒤 잡음(xcconfig·xcscheme·Podfile·swiftpm·launch_background 등 CRLF)은 커밋하지 않는다.
