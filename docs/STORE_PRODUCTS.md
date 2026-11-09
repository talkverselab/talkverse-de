# 스토어 상품·차별화 — 독일어유니버스 (2026-11-09)

출시는 **Talkverse 통합 앱 하나**(com.talkverse.app)로 한다(uk 공지). 이 앱은 통합 앱 안의 독일어 패키지이자, 개발·시험용 단독 앱(Zealot·TestFlight)이다. 가격 = `~/talkverse/PRICING.md`(사용자 확정 2026-11-09) 의 앱 정가 / 앱 할인가. **등록은 사용자가** App Store Connect·Google Play Console 에서 한다.

## 1. 상품

| 상품 ID | 이름(한국어 표시) | 종류 | 기간 | 앱 정가 | 스토어 판매가(할인가) |
|---|---|---|---|---|---|
| `lang_de_1m` | 독일어 1개월 | 자동 갱신 구독 | 1개월 | 5,500 | **3,900** |
| `lang_de_3m` | 독일어 3개월 | 자동 갱신 구독 | 3개월 | 12,900 | **9,000** |
| `lang_de_1y` | 독일어 1년 | 자동 갱신 구독 | 1년 | 28,500 | **19,900** |
| `lang_de_life` | 독일어 평생 이용권(서비스 운영 기간 동안) | 비소모성 | — | 69,900 | **49,000** |
| `all_1y` | 종합 패키지 1년 — 모든 언어 | 자동 갱신 구독 | 1년 | 112,900 | **79,000** |
| `all_life` | 종합 패키지 평생 — 모든 언어(서비스 운영 기간 동안) | 비소모성 | — | 469,000 | **329,000** |

- 앱 결제 시트는 정가를 취소선으로, 스토어 가격을 크게 보여 준다(`lib/main.dart` 의 `Purchase.configure` 플랜 목록, `lib/data/purchase.dart`, `lib/screens/paywall_screen.dart`). 앱 안에서 사이트 가격을 안내·유도하지 않는다.
- 옛 평생 상품 `com.talkverse.germanUniverse.lifetime`(App Store)·`lang_de`(Play) 는 판매 중지, 앱은 복원 때 `lang_de_life` 로 인정한다(`purchase.dart` `_legacy`).
- 약관 https://talkverse.uk/terms/ · 개인정보처리방침 https://talkverse.uk/talkverse/de/privacy/ (`lib/widgets/legal_links.dart`)
- 통합 앱에서는 공용 결제가 스토어 스트림을 듣고 이 언어 상품을 패키지로 넘긴다(EMBED_GUIDE 5단계). `all_*` 의 등록·인정 방식은 uk 가 정한다.
- **아직 잠근 기능이 없다** — 무엇을 유료로 할지 사용자 결정 대기. 아무것도 열지 않는 인앱 구입은 3.1.1 반려 위험 → 잠금 대상을 정한 뒤 제출.

## 2. 차별화(애플 지침 4.3 대비, `~/talkverse/STORE_DIFFERENTIATION.md`)

고유 축 = **V2 어순 · 분리동사 · 관사 격**(+ 한국어에 없는 ü·ö·ch 발음).

### 스토어 설명 첫 줄(안)
> 동사는 늘 둘째 자리, 분리동사는 앞머리를 문장 끝으로 보내고(mitkommen → Kommst du mit?), 관사는 der·die·das 로 성과 격을 바꾸는 말 — 독일어 어순과 관사를 한국어 소리·어순과 견주며, 자주 쓰는 단어 순서대로 배웁니다.

### 독일어 전용 학습 도구(지금 앱에 실제로 동작하는 것만)
1. **알파벳과 발음**(`lib/services/de_phonetics.dart`) — 6묶음 53단위: 모음 5(a·e·i·o·u, 장단 구별) · 움라우트·ß 4(ä·ö·ü·ß) · 이중모음 4(ei/ai·ie·eu/äu·au) · 자음 21 · 자음 묶음 11(ich 의 ch[ç]와 ach 의 ch[x] 구별, sch, 낱말 첫 sp·st[ʃp·ʃt], pf, qu, ng, tsch, ck, chs) · 음절 끝 규칙 8(-er·-r → 「어」, 끝 b·d·g → ㅍ·ㅌ·ㅋ, -ig → 이히, 모음 앞 s → ㅈ, 모음+h = 길게). 칸을 누르면 1초 뒤 글자 이름과 예시 낱말을 자동 재생, IPA, 조음 위치 그림(37단위), ü·-er 은 한국어 「이·우」「아·어」와 겹친 모음 비교도, 한국어 소리와 같은 점·다른 점. 한글 독음은 토글.
2. **절벽 단어 R1~R5**(`lib/core/cliff.dart`) — 독일어 구어 말뭉치를 레마+품사로 센 순위: 89단어로 55%, 130단어 60%, 317단어 70%, 1,084단어 80%. 앱 단어표는 1,500위(누적 약 84%)까지, 20어 단원 타일, 관사(der/die/das)와 함께 표시.
3. **회화 리더** — 문장 속 낱말을 누르면 기본형(동사 원형 — 분리동사·활용형도 원형으로)으로 단어창이 열린다(관사+단어·독음·뜻·품사·절벽 구간). 한글 독음 전역 토글.
4. **문법 강의·테스트** — 독일어 기본 문형 10패턴(sein·haben·möchten·können·Wo ist…?·war 등) 예문·독음. 문법 레벨 배치는 독일어 전용으로 결정(`docs/GRAMMAR_LEVELS_de.md`): V2 도치 = 레벨 1 골격, 분리동사 = 레벨 1, weil·dass·wenn 부문장 = 레벨 2 노출·4 정리, 명사 앞 형용사 어미 = 레벨 3, 현재완료 중심 과거(war·hatte·konnte·wusste 만 통문장), du→Sie 전환 = 레벨 3.

### 출시 전에 채울 것(지금은 없음 — 설명·심사 메모에 쓰지 않는다)
- [ ] **회화**: R0~R5 폴더 28편·332턴은 전부 초안(`draft: true`, R0 2·R1 8·R2 6·R3 4·R4 4·R5 4) — Grok 재작성·사용자 통과 뒤 앱에 연결. 지금 앱은 옛 `assets/data/dialogues/L1.json` 5편만 읽는다.
- [ ] **회화 음성**: 독일어 녹음은 보류 중(D1 에 녹음 줄 0). 지금은 기기 TTS 뿐 — "recorded audio" 라고 쓰지 않는다.
- [ ] **IPA 그림 교체**: `assets/images/ipa/ipa_vowel_chart.png`·`places_of_articulation.png` 는 출처 표기 없는 임시 그림 — 자체 제작 그림으로 바꾼다.
- [ ] **「준비 중」 없애기(지침 2.1)**: 홈 「성·수」 메뉴는 `_ComingSoon` 화면(`lib/screens/main_screen.dart`) — 채우거나 메뉴에서 뺀다. 회화 탭(`conversation_screen.dart`)은 편이 없는 레벨에 「준비 중」을 띄운다 — R 회화 연결 뒤 빈 레벨이 없어야 한다.
- [ ] **동사 활용**: `assets/data/grammar/verbs_core.json` 의 동사가 0개(「콘텐츠 대기」)라 화면이 로딩 표시만 돈다 — 핵심 동사(분리동사·강변화 포함)를 채우거나 메뉴에서 뺀다. 채우기 전에는 전용 도구로 쓰지 않는다.
- [ ] **문법**: 강의 1개(10패턴)뿐 — 레벨 배치대로 V2·분리동사·관사 격 강의를 늘리면 설명의 문법 항목을 그 이름으로 바꾼다.
- [ ] 유료 잠금 대상 결정(§1).

### 실측 숫자(출시 때 다시 확인)
- 절벽: R1 89 · R2 130 · R3 317 · R4 1,084 레마(누적 55/60/70/80%), R5 상한 2,000위. 앱 단어표 1,500위 ≈ 84%.
- 발음: 6묶음 53단위.
- 회화: 앱 5편(옛 초안) / R 초안 28편·332턴(목표 — 출시 판 숫자로 바꿀 것). 음성 줄: 0(보류).

### 심사 메모 문단(영문, 지금 참인 숫자만 — [ ] 는 출시 판에서 채움)
> This app is one of a family of language-specific apps by Universal Talking Lab (Talkverse). Each app is built from scratch for one target language for Korean speakers and is NOT a re-skin: the German app has its own alphabet & pronunciation module (53 units in 6 groups — vowels with long/short contrast, umlauts and ß, diphthongs, consonants, clusters such as the two "ch" sounds [ç]/[x], sch and initial sp/st, and syllable-final rules like final-devoicing and vocalised -er — each with IPA, a place-of-articulation picture, a comparison with Korean sounds and auto-play), its own grammar tools [fill with the lessons actually shipped — planned: verb-second inversion, separable verbs sent to the end of the clause, articles by gender and case, the du/Sie switch], nouns always shown with their colour-coded article (der/die/das), a conversation reader where every word opens its dictionary form (separable and inflected verbs map back to the infinitive), [N] original conversation episodes written for this language, and a vocabulary list measured from a German conversation corpus (89 / 130 / 317 / 1,084 lemmas cover 55 / 60 / 70 / 80 %). Content, curriculum and UI flows differ between apps; we keep them separate because learners search for and buy one language at a time.

- 문법 칸: 지금 앱 강의는 기본 문형 10패턴 1개뿐이라 V2·분리동사·관사 격을 "있다"고 쓸 수 없다 — 그 강의를 넣은 판에서 대괄호를 실제 강의 이름으로 바꾼다.
- 녹음 음성이 들어간 판이면 "[N] original conversation episodes **with recorded audio**" 로 바꾼다. 지금은 "with recorded audio" 를 쓰지 않는다.

### 스크린샷 순서(고유 화면 먼저)
1. 알파벳과 발음 — 묶음 칩·격자(ü 배지) (iPad 촬영본 `15_alphabet`)
2. 알파벳과 발음 — ü 발음 시트(IPA·조음 위치·「이·우」 모음 비교·한국어 비교) (`16_alphabet_sheet_u`)
3. 절벽 단어 — 89/130/317/1,084 표와 20어 단원 타일 (`12_word_units`)
4. 회화 리더 — 낱말 탭 단어창(분리동사·활용형 → 원형) — R 회화 연결 뒤 촬영
5. 문법 강의(V2 어순·분리동사 패턴)
6. 결제 시트(정가 취소선·할인가) — 마지막. 홈·프로필로 시작하지 않는다.
