# HANDOFF — talkverse-de (독일어유니버스)

_2026-11-03 새로 씀. 앞 판(2026-10-11 메모·Zealot 확인 필요)은 이 판으로 대체 — 해결된 것은 지웠다._

## ⛔ 지금 지킬 것
- **회화·단어·예문·문법 설명 등 새 학습 콘텐츠 작성 금지**(2026-11-02 사용자 지시, 해제는 사용자 지시로). 회화 공통 원칙 링크·독일어 특이점은 CLAUDE.md 「화면 구성」.
- 아이콘은 talkverse.uk 세션 담당(`~/talkverse/branding/TONE.md`) — 아이콘 파일 직접 수정 금지.
- Grok 그림 요청은 한자 세션 경유(그림만, 글 시안은 이 세션이 직접). `~/talkverse/LANG_APP_REPLICATE_PROMPT.md` §9.

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
1. **단어 그림 리스트**(talkverse.uk 세션 요청, 미완): `talkverselab/talkversehanja` 에 `talkverse_art/words/de.csv`(rank,word,reading,ko,en,pos,level,picturable — 절벽 R1~R4 단어 전체) + `de_food.csv`(독일 대표 음식 50, rank,word,reading,ko,en,desc), 커밋 「words/de: 단어·음식 리스트」, 푸시 뒤 uk 세션에 한 줄(+ 캐릭터 시트 경로 `data/review/art/chars_de_v1.jpg`).
   - /cliff/ 수치(R1 153·R2 224·R3 525·R4 1,514, 2,500단어)를 낸 원본 `lang_de_top2500.csv` 는 분석 스크립트(`~/talkverse/ja/data/scripts/all17_cliff_analysis.py`)에 적힌 PC 경로 `D:\OneDrive\BOOKS\_assets\data\` 에 없다 — PC D: 전체 검색은 중간에 멈춤. 못 찾으면 지침 §10 대로 오픈소스 빈도 라이브러리(스크래치 venv)로 뽑는다(순위가 /cliff/ 와 조금 다를 수 있음 — uk 세션에 알릴 것). **파일·커밋에 라이브러리·말뭉치 이름 금지.**
   - 이건 단어 "그림 목록"이라 콘텐츠 금지와 별개로 사용자 지시가 있었다(2026-11-03).
2. 사용자 결정 대기:
   - 평생 이용권이 무엇을 여는지(없으면 App Store 심사 3.1.1 거절 위험). 정해지면 `Entitlement.premium` 으로 잠그고 `docs/store/review_notes.md` 의 구매 위치 문구 수정.
   - 과거 커밋 이력 정리(filter-repo + 강제 push) 여부.
   - 스토어 인앱 상품 등록(사용자) — 등록 전엔 결제 시트가 「스토어에 연결하는 중…」.
3. 회화 작업이 풀리면: 새 구조(R0~R4·주제별 편 JSON) + 턴 `nouns`·편 `register` 칸을 채우면 UX 칸 1·2 가 켜진다(`lib/services/dialogue_service.dart` NounInfo·registerAt). du/Sie 규칙·독음 표기표는 CLAUDE.md.
4. 장면 컷: 회화 편이 생기면 편당 4컷(§10) — `CHARACTERS.md` 첨부. 앱은 `/art/de/scene/manifest` 를 자동으로 읽는다.

## 배포 절차 요약
- Android: master 푸시 → CI(빌드 번호 = 실행 번호) → `tools/zealot_push.sh --ci "변경 한 줄"` → PC 백업. `**.md`·`tools/**`·`ios/**` 만 바뀐 푸시는 빌드 안 함.
- iOS: `bash tools/ios_release.sh`(백그라운드, 8~12분, 빌드 번호 = KST yymmddHHMM) → 끝나면 ipa 를 풀어 `codesign -d --entitlements :-` 에 `applesignin` 확인.
- 빌드 뒤 잡음(xcconfig·xcscheme·Podfile·swiftpm·launch_background 등 CRLF)은 커밋하지 않는다.
