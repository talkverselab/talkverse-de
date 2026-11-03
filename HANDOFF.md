# HANDOFF — talkverse-de (독일어유니버스)

_2026-11-03 새로 씀. 앞 판(2026-10-11 메모·Zealot 확인 필요)은 이 판으로 대체 — 해결된 것은 지웠다._

## ⛔ 지금 지킬 것
- **회화·단어·예문·문법 설명 등 새 학습 콘텐츠 작성 금지**(2026-11-02 사용자 지시, 해제는 사용자 지시로). 회화 공통 원칙 링크·독일어 특이점은 CLAUDE.md 「화면 구성」.
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

## 현재 상태 (2026-11-03 00:50)
| 항목 | 상태 |
|---|---|
| 캐릭터 시안 ① | **통과** 2026-11-03 — `data/review/art/chars_de_v1.jpg`, 고정 인물표 `data/review/art/CHARACTERS.md`(레나·미아·요나스·펠릭스 + 학습자 남녀, 베를린) |
| UX/UI 시안 ② | **통과** 2026-11-03 — 글 `data/review/uxui/sian_de_01.md`(직접 작성), 그림 `sian_de_01.jpg`. 일본어앱 시안 02 + 독일어 칸 2개(명사 성 점·단어 시트 / du·Sie 배지) |
| 아이패드 빌드 ③ | **완료** — 두 화면(레일·왼쪽 칸·오른쪽 칸), 만화책 읽기형 회화 리더, 그림 카드, 진행 탭 성과 데스크, 프로필 학습자 이름·성별. iPad Air 13 스크린샷 9장 넘침 0·예외 0(`integration_test/dialogue_pane_test.dart`, `tools/pane_shots.py`) |
| Talkverse ID 로그인·평생 이용권 | 코드 들어감(`lib/data/account.dart`·`purchase.dart`·`entitlement.dart`, 로그인·잠금 시트, 프로필 계정 칸). client_id `de`, 딥링크 `talkverse.de://auth`, 상품 iOS `com.talkverse.germanUniverse.lifetime` / Android `lang_de`. **잠긴 콘텐츠 없음** |
| Android | CI 빌드 11(`2a5c9d5`, 11-04 변경 7가지 + 단어 1,505) → Zealot 「독일어유니버스」 https://apps.talkverse.uk/8itFp/255 , PC `D:\OneDrive\app project\talkverse-de\` 백업. 그 전 빌드 10 https://apps.talkverse.uk/8itFp/251 , 9 /8itFp/203 |
| iOS | TestFlight **2611040312**(`eb0904f`, 11-04 변경 7가지, 단어 5개 추가 전). 그 전 2611030045(Apple 로그인 entitlement 확인됨), 2611030035·2611030040 은 Apple 로그인 빠짐. ipa 백업 PC `D:\OneDrive\app project\german_universe\ios\` |
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
