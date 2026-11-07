import 'package:flutter/material.dart';

import '../core/cliff.dart';
import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../widgets/spanish_decor.dart';

/// 앱 소개 — 이 앱의 뼈대인 **절벽구간**을 설명한다(일본어앱 2026-11-07, 두 화면은 레일 맨 아래·폰은 프로필 → 정보).
/// 공개 저장소 규칙: 말뭉치 제공처·작품 이름은 적지 않는다.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.washi,
        appBar: AppBar(
          title: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(tr('앱 소개'), style: const TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(tr('절벽구간 — 이 앱이 단어를 나누는 기준'), style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 1)),
          ]),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context)),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.washiDeep, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(8)),
              child: Text(
                tr('독일어권 영화·드라마 대사에서 자주 나오는 말은 아주 적습니다. 처음 89개 낱말이 대사의 55%를 차지하고, 1,084개면 80%입니다. 그 뒤로는 단어를 아무리 더 외워도 들리는 비율이 조금씩만 오릅니다 — 이 급한 경사를 「절벽」이라 부르고, 절벽이 끝나는 자리마다 구간(R1~R5)을 나눕니다.'),
                style: const TextStyle(color: AppColors.sumi, fontSize: 14, height: 1.6),
              ),
            ),
            const SizedBox(height: 18),
            _H(tr('1. 단어 기준')),
            const _CliffTable(),
            const SizedBox(height: 18),
            _H(tr('2. 산출 방식')),
            _P(tr('말뭉치 — 독일·오스트리아·스위스에서 제작한 영화·드라마의 대사 자막 약 2만 8천 개(1억 2,700만 토큰). 외국 작품의 번역 더빙은 뺐습니다.')),
            _P(tr('빈도 — 각 단어의 등장 횟수 ÷ 전체 등장 횟수. 가중치 없음.')),
            _P(tr('구간 — 빈도순으로 누적해 55%·60%·70%·80%에 처음 닿는 순위가 R1·R2·R3·R4 의 끝. 80% 밖은 R5. 이 네 비율은 Talkverse 19개 언어 공통 기준입니다(2026-11-03).')),
            const SizedBox(height: 18),
            _H(tr('3. 앱에서 쓰는 곳')),
            _P(tr('절벽 단어 — R1→R5 순서로 20어씩 한 단원. 「회화 단어 포함」을 누르면 이 앱의 회화에 나오는 단어가 「회화」 구간으로 뒤에 붙습니다.')),
            _P(tr('회화 — 문장의 낱말을 누르면 단어창이 열립니다. 밑줄이 있는 말이 단어장에 있는 말입니다.')),
            const SizedBox(height: 24),
            const BrushDivider(),
            const SizedBox(height: 10),
            Center(child: Text(tr('절벽 v2 · 2026-11-03'), style: const TextStyle(color: AppColors.sumiLight, fontSize: 11, letterSpacing: 2))),
          ],
        ),
      );
}

class _H extends StatelessWidget {
  final String text;
  const _H(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
      );
}

class _P extends StatelessWidget {
  final String text;
  const _P(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(color: AppColors.sumiLight, fontSize: 13, height: 1.55)),
      );
}

/// 구간표 — R1~R5: 순위 범위 · 개수 · 누적 %. 막대는 구간 등폭 5칸.
class _CliffTable extends StatelessWidget {
  const _CliffTable();

  static const _pct = ['55%', '60%', '70%', '80%'];
  static const _colors = [AppColors.beni, AppColors.beniLight, AppColors.kinDeep, AppColors.matcha, AppColors.muted];

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String, String, String)>[];
    var prev = 0;
    for (var i = 0; i < 4; i++) {
      final end = kWordCliffs[i];
      rows.add(('R${i + 1}', '${prev + 1}-$end', '${end - prev}', _pct[i]));
      prev = end;
    }
    rows.add(('R5', '${prev + 1}-$kWordListEnd', '${kWordListEnd - prev}', trf('약 {0}%', [kWordListEndPct])));
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: Row(children: [
            for (var i = 0; i < 5; i++)
              Expanded(
                child: Container(height: 10, margin: EdgeInsets.only(right: i < 4 ? 2 : 0), decoration: BoxDecoration(color: _colors[i], borderRadius: BorderRadius.circular(2))),
              ),
          ]),
        ),
        for (var i = 0; i < rows.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.line, width: i == 0 ? 0 : 0.6))),
            child: Row(children: [
              Container(
                width: 30,
                padding: const EdgeInsets.symmetric(vertical: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _colors[i], borderRadius: BorderRadius.circular(2)),
                child: Text(rows[i].$1, style: const TextStyle(color: AppColors.washi, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(rows[i].$2, style: const TextStyle(color: AppColors.sumi, fontSize: 13, fontWeight: FontWeight.w700))),
              SizedBox(width: 56, child: Text(trf('{0}어', [rows[i].$3]), textAlign: TextAlign.right, style: const TextStyle(color: AppColors.sumiLight, fontSize: 12))),
              SizedBox(width: 92, child: Text(trf('누적 {0}', [rows[i].$4]), textAlign: TextAlign.right, style: const TextStyle(color: AppColors.sumi, fontSize: 12, fontWeight: FontWeight.w700))),
            ]),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          child: Text(
            tr('사전형 1개 = 단어 1개(관사·전치사도 각각). 품사별로 세면 경계는 89·130·317·1,084위이고, 같은 사전형을 합치고 이름을 뺀 이 앱 단어표에서는 81·111·280·822위입니다. R5 상한은 2,000위이고 단어표는 지금 1,500위까지 있습니다.'),
            style: const TextStyle(color: AppColors.sumiLight, fontSize: 11, height: 1.5),
          ),
        ),
      ]),
    );
  }
}
