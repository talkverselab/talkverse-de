# HANDOFF — talkverse-de (독일어유니버스)

_2026-11-03 새로 씀. 앞 판(2026-10-11 메모·Zealot 확인 필요)은 이 판으로 대체 — 해결된 것은 지웠다._

## ⛔ 지금 지킬 것
- **회화·단어·예문·문법 설명 등 새 학습 콘텐츠 작성 금지**(2026-11-02 사용자 지시, 해제는 사용자 지시로). 회화 공통 원칙 링크·독일어 특이점은 CLAUDE.md 「화면 구성」.
- 아이콘은 talkverse.uk 세션 담당(`~/talkverse/branding/TONE.md`) — 아이콘 파일 직접 수정 금지.
- Grok 그림 요청은 한자 세션 경유(그림만, 글 시안은 이 세션이 직접). `~/talkverse/LANG_APP_REPLICATE_PROMPT.md` §9.
- **Grok·Gemini 를 직접 쓸 때(2026-11-03 사용자 지시)**: 사용자 지시가 있을 때만 켠다(M4 에 미리 켜 두지 않음). 쿠키 복사는 M4 안에서만(`~/chrome-grok` → `~/chrome-grok-de/Default/`), M4 에서 자기 포트(`GROK_CHROME_PORTS.md`)로 띄우고 M6 에서 `ssh -fN -L <로컬>:127.0.0.1:<포트> macmini4` 터널. 첨부는 M4 `/tmp/grok_att/de/`. 한 번에 한 작업, 연 탭은 끝나면 닫고 Chrome 도 끈다. 상세 `~/talkverse/GROK_M4_LOGIN.md`, 예 `~/talkverse/ko/tools/grok_base.py`.
- **회화를 쓰게 되면(반전 비율, 원칙 §9)**: 카오스 30% 이상, 연애·플러팅 편마다 심쿵 한 줄(여성 주도 편 더 많이), 편마다 `twist_type`(chaos·slip·reveal·emotion·ignore), 새 편은 왕초보·초급 위주, 그림 = A·B 쌍 1컷(말풍선·글자 없음, `CHARACTERS.md` 첨부).

## 현재 상태 (2026-11-03 00:50)
| 항목 | 상태 |
|---|---|
| 캐릭터 시안 ① | **통과** 2026-11-03 — `data/review/art/chars_de_v1.jpg`, 고정 인물표 `data/review/art/CHARACTERS.md`(레나·미아·요나스·펠릭스 + 학습자 남녀, 베를린) |
| UX/UI 시안 ② | **통과** 2026-11-03 — 글 `data/review/uxui/sian_de_01.md`(직접 작성), 그림 `sian_de_01.jpg`. 일본어앱 시안 02 + 독일어 칸 2개(명사 성 점·단어 시트 / du·Sie 배지) |
| 아이패드 빌드 ③ | **완료** — 두 화면(레일·왼쪽 칸·오른쪽 칸), 만화책 읽기형 회화 리더, 그림 카드, 진행 탭 성과 데스크, 프로필 학습자 이름·성별. iPad Air 13 스크린샷 9장 넘침 0·예외 0(`integration_test/dialogue_pane_test.dart`, `tools/pane_shots.py`) |
| Talkverse ID 로그인·평생 이용권 | 코드 들어감(`lib/data/account.dart`·`purchase.dart`·`entitlement.dart`, 로그인·잠금 시트, 프로필 계정 칸). client_id `de`, 딥링크 `talkverse.de://auth`, 상품 iOS `com.talkverse.germanUniverse.lifetime` / Android `lang_de`. **잠긴 콘텐츠 없음** |
| Android | CI 빌드 9(`1a3fe72`) → Zealot 「독일어유니버스」 https://apps.talkverse.uk/8itFp/203 , PC `D:\OneDrive\app project\talkverse-de\` 백업 |
| iOS | TestFlight **2611030045**(Apple 로그인 entitlement 확인됨). 앞의 2611030035·2611030040 은 Apple 로그인 빠짐. ipa 백업 PC `D:\OneDrive\app project\german_universe\ios\` |
| 서명 키 | 원래 키 그대로(SHA-1 `9C:C4:…`), PC `D:\keys\talkverse-de\` 백업, Doppler `SIGNKEY_*` |
| 저작권 | 출처 이름 든 파서·주석 삭제(`2db89c2`). 과거 이력 9커밋에 이름이 남아 있음 — 정리 안 함 |
| 태그 | `pre-grok-uxui` = UX 시안 적용 전(`75cc18b`) |

## 다음 할 일 (순서대로)
1. ~~단어 그림 리스트~~ — **완료 2026-11-03**: `talkverselab/talkversehanja` `talkverse_art/words/de.csv`(1,500단어)·`de_food.csv`(음식 50), 커밋 `0e4b533`. 아래 「절벽 구간」 참고.
2. 사용자 결정 대기:
   - 평생 이용권이 무엇을 여는지(없으면 App Store 심사 3.1.1 거절 위험). 정해지면 `Entitlement.premium` 으로 잠그고 `docs/store/review_notes.md` 의 구매 위치 문구 수정.
   - 과거 커밋 이력 정리(filter-repo + 강제 push) 여부.
   - 스토어 인앱 상품 등록(사용자) — 등록 전엔 결제 시트가 「스토어에 연결하는 중…」.
3. 회화 작업이 풀리면: 새 구조(R0~R4·주제별 편 JSON) + 턴 `nouns`·편 `register` 칸을 채우면 UX 칸 1·2 가 켜진다(`lib/services/dialogue_service.dart` NounInfo·registerAt). du/Sie 규칙·독음 표기표는 CLAUDE.md.
4. 장면 컷: 회화 편이 생기면 편당 4컷(§10) — `CHARACTERS.md` 첨부. 앱은 `/art/de/scene/manifest` 를 자동으로 읽는다.

## 절벽 구간 (2026-11-03, 사용자 지시 — Opus 기준, 독일 자국 드라마·영화 입말)
- 원본 빈도표(`lang_de_top2500.csv`, 외국 영화 자막 기준)를 못 찾아 **새로 만듦**. 독일에서 만든 드라마·영화(번역 더빙·외국 작품 제외) 대사의 입말 빈도를 Opus 가 레마(기본형) 단위로 **추정**한 값 — 코퍼스 실측이 아니다.
- 방법: 후보 레마 1,693개 → 단어마다 「백만 단어당 빈도(fpm)」 추정 + 독음·뜻·영어·품사(명사는 성)·그림 가능 → 축약형·격변화형·중복·지명 정리(1,631개) → fpm 순 정렬 → 상위 1,500.
- 덮는 비율 = 누적 fpm ÷ 1,000,000(추정): **R1 1~103위(55%) · R2 104~159위(60%) · R3 160~512위(70%) · R4 513~1,500위(1,500위까지 72.6%)**. 80% 는 1,500단어 안에서 닿지 않음(추정 꼬리가 낮게 잡힌 탓일 수 있음).
- 참고: 옛 /cliff/ 값(표면형·외국 영화 자막) 55% 153 · 60% 224 · 70% 525 · 80% 1,514 — 레마로 세면 앞쪽이 줄어드는 것이 정상. 사이트 값을 이 값으로 바꿀지는 talkverse.uk 세션·사용자 결정.
- 그림 가능 Y 744 / N 756. 독음은 CLAUDE.md 표기표 기준(단, 모음 뒤 r 은 '아'로 줄여 쓴 것이 섞임 — warten 바텐).
- 자국 작품 대사 코퍼스가 생기면 실측으로 다시 낸다.

## 배포 절차 요약
- Android: master 푸시 → CI(빌드 번호 = 실행 번호) → `tools/zealot_push.sh --ci "변경 한 줄"` → PC 백업. `**.md`·`tools/**`·`ios/**` 만 바뀐 푸시는 빌드 안 함.
- iOS: `bash tools/ios_release.sh`(백그라운드, 8~12분, 빌드 번호 = KST yymmddHHMM) → 끝나면 ipa 를 풀어 `codesign -d --entitlements :-` 에 `applesignin` 확인.
- 빌드 뒤 잡음(xcconfig·xcscheme·Podfile·swiftpm·launch_background 등 CRLF)은 커밋하지 않는다.
