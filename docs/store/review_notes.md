# 심사 메모(App Review Notes) · 개인정보처리방침 추가 문안 — 독일어유니버스 (2026-11-02)

> 4.3 대비 문단(영문)·스크린샷 순서·출시 전 체크리스트는 `docs/STORE_PRODUCTS.md` §2 — 아래 메모 끝에 그 문단을 붙여 넣는다. 원본: 한자 앱 `docs/store/review_notes.md`. Talkverse ID 로그인(선택) + 인앱 구입(상품 6개 `lang_de_1m`·`lang_de_3m`·`lang_de_1y`·`lang_de_life`·`all_1y`·`all_life`, 2026-11-09 확정; 옛 `com.talkverse.germanUniverse.lifetime`·`lang_de` 는 판매 중지·복원 때 `lang_de_life` 로 인정). 출시는 통합 앱(com.talkverse.app) — 단독 앱 제출 시에만 이 메모를 그대로 쓴다.
> ⚠ **지금 이 앱은 이용권이 여는 콘텐츠가 없다**(무엇을 유료로 둘지 사용자 결정 대기 — HANDOFF.md). 아무것도 열지 않는 인앱 구입은 심사(3.1.1)에서 거절될 수 있으니,
> 잠금 대상을 정하고 아래 [인앱 구입] 문단의 "어디서 사는지"를 그 화면으로 고친 뒤 제출할 것.

## App Store Connect "심사 정보 → 메모"

```
[로그인] 로그인은 선택입니다. 모든 학습 기능은 로그인 없이 사용할 수 있고, 로그인은 구매 복원과 기기 간 이용권 공유에만 쓰입니다.
- 로그인 화면: 홈 오른쪽 위 사람 아이콘(프로필 · 설정) → 계정 → 로그인. Apple로 로그인 + 이메일 로그인(심사·테스트용).
- 데모 계정(이메일 로그인): review@talkverse.uk / 비밀번호: <Doppler keys/prd TALKVERSE_REVIEW_ACCOUNT 에서 복사해 여기 입력> — 이 계정에는 독일어 평생 이용권(lang_de_life)이 들어 있습니다.
- 계정 삭제: 프로필 · 설정 → 계정 → 계정 삭제(확인 창) → 서버에서 개인정보가 삭제되고 모든 기기에서 로그아웃됩니다.
[인앱 구입] 자동 갱신 구독 lang_de_1m·lang_de_3m·lang_de_1y·all_1y, 비소모성 lang_de_life·all_life(평생 = 서비스 운영 기간 동안). 프로필 · 설정 → 계정 → 이용권 → 상품 선택, [구매 복원]. 결제 시트에 자동 갱신·해지 방법, 이용약관·개인정보처리방침 링크가 있습니다. Sandbox 계정으로 시험할 수 있고, 로그인 없이도 구매·복원이 됩니다.
[음성] 발음은 기기 음성 합성(TTS)을 씁니다. 말하기 연습은 마이크·음성 인식 권한을 요청합니다(인식은 기기의 음성 인식 서비스가 처리하고, 앱 서버로는 보내지 않습니다).

[Sign-in] Optional. Every learning feature works without an account; sign-in is only for restoring purchases across devices.
- Where: person icon at the top right of Home (Profile · Settings) → Account → Sign in (Sign in with Apple, or email sign-in for review/testing).
- Demo account (email sign-in): review@talkverse.uk / password: <paste from Doppler> — it already owns the German lifetime pass (lang_de_life).
- Account deletion: Profile · Settings → Account → Delete account (confirmation) → personal data is deleted server-side and all sessions are revoked.
[IAP] Auto-renewable subscriptions lang_de_1m / lang_de_3m / lang_de_1y / all_1y and non-consumables lang_de_life / all_life ("lifetime" = for as long as the service operates). Profile · Settings → Account → Pass → choose a plan, [Restore purchases]. The sheet shows auto-renewal and cancellation terms with Terms of Use and Privacy Policy links. Works with a Sandbox account; sign-in is not required to buy or restore.
[Audio] Pronunciation uses on-device text-to-speech. Speaking practice asks for microphone and speech-recognition permission; recognition is done by the system speech service and nothing is sent to our servers.
[Not a re-skin — Guideline 4.3] <docs/STORE_PRODUCTS.md §2 "심사 메모 문단" 을 출시 판 숫자로 채워 붙여 넣기>
```

## App Store "앱 개인정보 보호"·Google Play 데이터 보안
→ `docs/store/data_safety.md`.

## 개인정보처리방침 페이지에 추가할 문안 (talkverse.uk 세션 반영 — 언어앱 방침 페이지)
```
계정(선택)
독일어유니버스는 로그인 없이 쓸 수 있습니다. Talkverse 계정으로 로그인하면 다음을 처리합니다.
- 수집 항목: 이메일 주소, 이름(Apple·Google 등 로그인 제공자가 전달하는 범위), 계정 ID, 로그인 시각·기기 식별 토큰.
- 목적: 로그인 유지, 구매(이용권) 복원과 기기 간 공유, 고객 문의 응대.
- 보관: 계정 삭제 시 즉시 삭제(구매·주문 기록은 관계 법령에 따라 회계 목적으로 사용자 ID 만 남깁니다).
- 삭제 방법: 앱 → 프로필 · 설정 → 계정 → 계정 삭제, 또는 https://talkverse.uk/account/delete 안내, 또는 talkverse.lab@gmail.com 으로 요청.
- 처리 위탁·국외 이전: 계정 서버는 Cloudflare(미국 등 글로벌 리전)에서 운영됩니다.

결제
이용권(구독·평생) 결제는 Apple App Store 또는 Google Play 가 처리하며, 앱은 카드 정보를 받지 않습니다. 앱은 구매 영수증(거래 번호·상품 ID)만 확인해 이용권을 적용합니다.
```

## IAP 상품 심사 스크린샷
- 이용권 시트(프로필 · 설정 → 계정 → 이용권 — 정가 취소선·할인가, 자동 갱신 안내) 캡처를 상품 등록 화면 "심사 정보 → 스크린샷"에 올린다.
