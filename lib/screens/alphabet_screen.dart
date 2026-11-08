import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/de_phonetics.dart';
import '../services/ko_reading.dart';
import '../services/tts_service.dart';
import '../widgets/alphabet_sound_sheet.dart';

/// 그룹별 색.
Color alphabetGroupColor(String g) => switch (g) {
      'vowel' => AppColors.beni,
      'umlaut' => AppColors.fem,
      'diph' => AppColors.oliva,
      'cons' => AppColors.mar,
      'cluster' => AppColors.irregular,
      _ => AppColors.rojoDeep,
    };

/// 알파벳과 발음 — 일본어앱 「50음도와 발음」의 독일어판.
/// 그룹 칩 · 글자 칸(예시 단어, 한글 독음 토글) · 칸 탭 → 발음 상세 시트.
class AlphabetScreen extends StatefulWidget {
  const AlphabetScreen({super.key});

  @override
  State<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen> {
  String _group = 'all';

  @override
  void dispose() {
    TtsService.instance.stop().then((_) {}, onError: (_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _group == 'all' ? kDeGroups : [_group];
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tr('알파벳과 발음'),
                style: const TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(tr('탭하면 발음·IPA 상세'),
                style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
        actions: const [KoReadingToggleAction()],
      ),
      body: Column(
        children: [
          _chips(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final cols = ((c.maxWidth - 24) / 92).floor().clamp(3, 8);
                return ListView(
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 40 + bottomInset(context)),
                  children: [
                    for (final g in groups) ...[
                      _header(g),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: cols,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                        children: [
                          for (final u in kDeUnits.where((u) => u.group == g)) _cell(u, alphabetGroupColor(g)),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chips() {
    final keys = ['all', ...kDeGroups];
    return Container(
      color: AppColors.washiDeep,
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          for (final k in keys)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _group = k),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _group == k ? AppColors.beni : AppColors.washi,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.beni, width: _group == k ? 1.5 : 0.8),
                  ),
                  child: Text(
                    k == 'all'
                        ? '${tr('전체')} ${kDeUnits.length}'
                        : '${deGroupLabel(k)} ${kDeUnits.where((u) => u.group == k).length}',
                    style: TextStyle(
                      color: _group == k ? AppColors.washi : AppColors.beni,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header(String g) {
    final color = alphabetGroupColor(g);
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Row(
        children: [
          Container(width: 4, height: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(deGroupLabel(g),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _cell(DeSoundUnit u, Color color) {
    return InkWell(
      onTap: () => showAlphabetSoundSheet(context, unit: u, color: color),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.washi,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.7)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(1, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(u.glyph,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.sumi, height: 1.1)),
              ),
            ),
            Text(u.ex.first.word,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10.5, color: AppColors.sumiLight)),
            KoReadingText(u.ko, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
