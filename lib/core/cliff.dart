/// 절벽구간 숫자 한 곳 — 절벽 단어 화면·앱 소개가 같이 쓴다(2026-11-07).
/// 공식 경계(레마+품사 원 순위): 89 · 130 · 317 · 1,084(누적 55/60/70/80%).
/// 앱 단어표는 같은 기본형을 합치고 이름을 뺀 목록이라 경계가 앞당겨진다 — `kWordCliffs`.
const kRawCliffs = [89, 130, 317, 1084];
const kWordCliffs = [81, 111, 280, 822];

/// R5 상한. 단어표는 지금 `kWordListEnd` 까지만 있다(새 단어 작성 동결 — 풀리면 2,000위까지 채운다).
const kWordCap = 2000;
const kWordListEnd = 1500;
const kWordListEndPct = 84; // 원 목록 약 1,950항목 누적

/// 한 단원 = 20어.
const kWordUnit = 20;
