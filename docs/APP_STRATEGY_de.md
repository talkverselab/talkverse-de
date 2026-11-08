# 독일어유니버스 앱 빌드 전략 (2026-11-08, Fable 초안 · 회화 본문은 Opus 몫)

바탕: `~/talkverse/INFLECTED_LANG_STRATEGY.md` §A ✔ 11항목 → `docs/DIALOGUE_RULES_de.md`. **「동결 해제 뒤」** 항목은 사용자가 회화 밖 콘텐츠 동결을 풀어야 착수한다. 사용자 지시가 다르면 사용자 지시가 우선.

> 초안 뒤 반영(같은 날, Opus 세션): 검사기에 R5·레벨 0~2 복수/Sie 검사·어휘 구간 보고(`tools/tier_report.py`)를 이미 넣었다. 레벨 0~5 샘플 6편도 준비됨(0·1·2·5 새로, 3·4 기존) — 사용자 검수 대기. 아래 §3② "고칠 것"과 M1 의 "0·5 신규 + 1·2 교정"은 이것으로 대체된다(1·2 는 교정 대신 새 편).

## 1. 목표와 범위

지금 앱은 옛 `assets/data/dialogues/L1.json` 5편만 읽고(`lib/services/dialogue_service.dart`, `lib/data/db/seed_loader.dart` 가 L1~L3 만 순회), R 폴더 초안은 `pubspec.yaml` 이 하위 폴더를 적지 않아 번들에 없다. 생성 음성은 R2 에만 있고 앱 재생 코드가 없다. 목표: ① 레벨 체계(회화 레벨 0~5 = 문법 단계, 절벽 R1~R5 = 어휘 상한)를 앱 구조에 넣고 ② 레벨별 핵심 회화가 검사·Grok·리뷰·음성을 거쳐 앱에 들어오는 길을 열고 ③ 동결이 풀리면 변형 카드(뺑뺑이)·격 자막·말 조각·페이월로 유료 전환이 되는 1.0 까지 간다. 단어·문법 콘텐츠·`tools/add_lemmas.py` 는 건드리지 않는다. 안드로이드·iOS 는 같은 커밋으로 Zealot+TestFlight.

## 2. 레벨 체계

| 레벨 | 이름 | 독일어 문법 단계 | 어휘 상한(앱 단어표 순위) | 문장 수(핵심:변형 1:9) | 요금 |
|---|---|---|---|---|---|
| 0 | 입문 | 통문장 인사·필러, 규칙 설명 0, 문자 카드 없음(A7) | ≤81 | 100 (10+90) | 무료 |
| 1 | 관사·격·활용 골격 | 관사+명사 주격 → 현재 동사 단수 → 대격 → 여격 → 전치사+격 → 분리동사 → 현재완료 → 화법조동사 → Konjunktiv II 고정형 씨앗 → 소유격 대신 von. 불규칙 10개는 통문장 트랙 | ≤81(검사기), 설계상 ≤111 | 500 (50+450) | 1·2묶음 무료 → 라임 직후 페이월 |
| 2 | 챗 실전 | 채팅 말투(du·단수), 표현 풀 재등장, `ui: bubble`·`at`·`read` | ≤280 | 500 | 유료 첫 구간 |
| 3 | 그래머2 | 레벨 1 핵심을 복수·Sie 로 갈아끼움, 새 단어 0. 가게·길·관공서 장면이 여기서 처음 | ≤280 | 500 | 유료 |
| 4 | 어려운 문법 | 접속법 II·간접화법·관계문·수동·종속절 어순 — 씨앗으로 | ≤822 | 500 | 유료 |
| 5 | 어휘 완주 | 문법 신규 0, 어휘만. "B1 준비 시작점" 정직 표기 | ≤1,500(상한 2,000) | 500 | 유료 |

- 숫자 출처 `lib/core/cliff.dart`. 2,000·3,000위 누적률은 지금 목록으로 못 잼 → 동결 해제 뒤 다시 잰다.
- 핵심 50 문장 ≈ 레벨 1 은 7편, 레벨 2 는 4~5편, 레벨 3·4·5 는 3~4편.
- 폴더 R = 회화 레벨, 단어 메뉴 R = 절벽 구간 → 화면은 「레벨 n」/「Rn 구간」으로 구분, 앱 소개에 명시.

## 3. 콘텐츠 파이프라인 (레벨마다 핵심을 먼저 통과받고 변형으로)

| 단계 | 하는 일 | 도구 |
|---|---|---|
| ① 핵심 회화 | Opus 초안. 턴마다 `es`·`rd`·`ko`·`emotion`/`segs`·`lemmas`, 편 메타 | 표현 풀 `data/expressions/top_expressions.csv`, 인물표 `data/review/art/CHARACTERS.md` |
| ② 검사기 | 턴 수·단어 수·표현 풀·반전·독음·감정·레벨 0~2 복수/Sie·어휘 구간 | `tools/check_dialogues.py`(`--align-rd`), `tools/tier_report.py` |
| ③ Grok 재작성 | 편 1개씩 새 방, 모든 줄 새로 쓰기 | 새로: `~/talkverse/zh/tools/` 의 prompts/rewrite_grok.md·rewrite_request.py·grok_*.py 복사. 11-10 한도 뒤, 사용자 지시 뒤 |
| ④ 리뷰 | 재작성 리뷰 → 리뷰 페이지 → 사용자 통과 → `approved` | `tools/review_html.py` → uk "REVIEW_de 갱신" |
| ⑤ 변형 카드 **(동결 해제 뒤)** | 핵심 1 → 슬롯 갈아끼움 후보 → 점수(빈도 20·격 35·양태 15·시제 10·단순성 15; 레벨 2·5 는 빈도 50) → 상위 9 → Claude 정제 | 새로 `tools/variants/slots_de.json`·`select_variants.py`, 출력 `assets/data/variants/R<레벨>/`. 말뭉치는 점수에만, 문장은 자체 작문 |
| ⑥ morph_tags | 모든 문장 Case·Gender·Number·Person·Tense + 역할 → Claude 검수 | 새로 `tools/morph_tags.py`(spaCy, `add_lemmas.py` 와 별도), 검수 `data/review/write/morph_review.csv` |
| ⑦ 음성 | 감정 열 → 계획 → PC → 검사(§5 기준) → mp4 → R2 + D1 | `tools/tts/make_plan.py`·`run_all.py`·`qa.py`·`pack.py`. D1 은 모델 선택 뒤 |
| ⑧ 앱 | 번들 + 시작 때 매니페스트 내려받기 | §4 |

성별판(A9): 사람 명사 턴에만 `es_f`·`rd_f`·`ko_f`, 음성은 모든 턴 남녀 두 판(사용자 답 대기).

## 4. 앱 변경

1. **회화 R 폴더 로더** — `lib/services/dialogue_service.dart`: AssetManifest 에서 `assets/data/dialogues/R[0-5]/*/*.json` 을 모두 읽는다(일본어앱 같은 파일 참고). `island`·`register`·`kind`·`twist`·`expressions`·`draft`·`emotion`·`level` 매핑, `levelKo` 를 레벨 이름으로.
2. **pubspec 자산** — 자산 폴더는 비재귀 → 주제 폴더마다 한 줄. 빠뜨림 방지용 `tools/asset_dirs.py`(검사기에서 불일치 오류).
3. **DB 시딩** — `seed_loader.dart` `_seedTurns` 에 R 폴더 추가 → 문장 카드·문장 말하기·청크 검색이 같이 받는다. `version.json` db 올림. ⚠ 지금 재시딩은 `userProgress` 를 지운다(130행) → 진행 키를 `(편id, 턴)` 으로 바꾸거나 재시딩 때 옮긴다.
4. **레벨 선택** — `dialogue_screen.dart` 레벨 머리를 번호·이름·문법 한 줄·어휘 상한·잠금 배지로. 레벨 메타는 새 `lib/core/levels.dart` 한 곳. 「학습」탭(`conversation_screen.dart`·`episode_screen.dart`)은 같은 서비스로 바꾸거나 레벨 선택으로 대체.
5. **변형 카드 (동결 해제 뒤)** — 새 `lib/services/variant_service.dart` + `lib/screens/variant_drill_screen.dart`(바뀐 슬롯만 색, 격 4색은 `theme.dart`), 홈 회화 묶음에 「뺑뺑이」 타일.
6. **격 자막·말 조각 (morph_tags 뒤)** — `DialogueTurn.morph`, `lib/widgets/case_caption.dart`·`chunk_cards.dart`, `episode_play_pane.dart` 토글 `_showCase`. UX 시안 01 칸 1·2.
7. **음성 동기화·재생** — `content_sync.dart` 에 음성 매니페스트, 새 `dialogue_audio.dart`(일본어앱 복사, `audioplayers` 는 이미 있음), `Dialogue.view(turn)`. 호출처 `episode_play_pane.dart`·`dialogue_card_screen.dart`·`dialogue_screen.dart`.
8. **앱 소개** — `about_screen.dart` 에 「회화 레벨 0~5 와 단어 구간 R1~R5 는 다르다」 + 레벨표.
9. **페이월 (동결 해제 뒤)** — `lib/data/entitlement.dart` `premium`·`showPaywall` 은 있음. `levels.dart` `isFree(level, bundle)`: 레벨 0 + 레벨 1 묶음 1·2 + 격 매핑표 + 코어 + 라임 = 무료. 라임 화면은 외계인 캐릭터 시트(A10) 뒤. 잠글 때 `docs/store/review_notes.md` 갱신.
10. **채팅 편 표시** — `episode_play_pane.dart` 에 `ui: bubble` 말풍선(시각·읽씹).
11. **번역 사전** — 새 문구는 `l10n_dict.dart` 세 사전 + 공용 원본.

## 5. 출시 단계 (각 단계 끝에 같은 커밋으로 Zealot + TestFlight)

| 마일스톤 | 내용 | 완료 기준 |
|---|---|---|
| M0 구조(지금 가능) | §4 ①②③④⑦⑧⑪ + `asset_dirs.py` + 진행 기록 보존 | 레벨 샘플이 앱 회화 홈에 레벨별로 뜨고 문장 카드·말하기·청크 검색에 포함, 아이패드 넘침 0, 음성 없으면 TTS 폴백 |
| M1 핵심 6편 | 샘플 통과 → Grok(11-10 뒤) → 리뷰 통과 → 음성(모델 선택 뒤, D1) → 장면 컷 | 6편 `approved`, D1 `audio_lines`, 앱에서 음성 재생 |
| M2 레벨 1 완성 + 페이월(동결 해제 뒤) | 어휘표·코어 40 → 슬롯 → 핵심 50 → 변형 450 → morph_tags → §4 ⑤⑥⑨, 라임 | 레벨 1 500문장, 뺑뺑이·격 자막·말 조각, 묶음 3 부터 잠금 |
| M3 레벨 2·3 | 챗 실전 + 그래머2 | 말풍선 UI, Sie·복수 해금 |
| M4 레벨 4·5 → 1.0 | 어려운 문법·어휘 완주, 단어표 2,000위 | 전 레벨·음성, 스토어 심사 제출 |

## 6. 위험과 대응

- **서명**: M6 의 `~/.android/debug.keystore` 는 다른 키 — `android/app/signing-key.jks`(SHA-1 `9C:C4:…:47:6B`)만, 원칙은 CI 빌드.
- **버전 코드**: 로컬 빌드는 `--build-number` 필수.
- **자산 비재귀**: 폴더 빠뜨리면 편이 조용히 사라짐 → `asset_dirs.py`.
- **재시딩이 학습 기록을 지움**: M0 에서 고치는 것이 싸다.
- **iOS 정지**: 다른 세션 몫. 복구 즉시 같은 커밋으로 TestFlight.
- **Grok**: 한도·새 계정·사용자 지시 전 시작 금지.
- **음성 품질**: 두 판을 사용자가 고른 뒤에만 재생성.
- **spaCy 소형 모델 오류**: morph_tags 도 검수 CSV 필수.
- **공개 저장소**: 변형 선별기가 말뭉치 문장을 내보내지 않게, 출처 이름 금지.
- **App Store 3.1.1**: 이용권이 아무것도 안 열면 거절 → 잠금과 심사 메모를 같이.
- **용어 혼동**: 「레벨 n」/「Rn 구간」.

## 7. 사용자 결정이 필요한 것

1. M0 를 iOS 정지 중에 안드로이드만 먼저 올려도 되는지.
2. 초안 편을 앱에 「초안」 리본으로 보일지, 통과 전엔 숨길지.
3. 옛 `L1.json` 5편(이름 고정)을 남길지 지울지.
4. 레벨당 문장 수(0=100, 1~5=500) 승인.
5. 재시딩 때 학습 기록 보존 방식 변경 승인.
6. `DIALOGUE_RULES_de.md` §3 세 가지(성별판 최소화·강세 부호 미표기·단어 상한 2,000 유지).
7. 회화 밖 콘텐츠 동결 해제 시점(M2 조건).
8. 평생 이용권이 여는 범위(라임 직후부터) 승인, 스토어 인앱 상품 등록.
9. 외계인 캐릭터 시트 위치(A10).
10. Grok 재작성 시작 지시(11-10 뒤) + 음성 모델(MOSS vs VoxCPM2) 선택.
