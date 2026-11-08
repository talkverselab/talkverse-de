import 'dart:async';

import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/de_phonetics.dart';
import '../services/tts_service.dart';
import 'de_vowel_chart.dart';

/// 기기 TTS 로 읽기 — 실패(플러그인 없음·테스트)는 조용히 넘긴다.
void sayDe(String text) {
  unawaited(TtsService.instance.speak(text).then((_) {}, onError: (_) {}));
}

/// 알파벳 칸 탭 → 발음 상세 시트(일본어앱 kana_sound_sheet 와 같은 틀).
/// 열리면 1초 뒤 자동 재생 · 다시 듣기 · IPA · 소리 내는 법 · 모음 위치 / 조음 위치 그림 · 한국어 비교 · 예시 단어.
Future<void> showAlphabetSoundSheet(BuildContext context, {required DeSoundUnit unit, required Color color}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.washi,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => AlphabetSoundSheet(unit: unit, color: color),
  );
}

class AlphabetSoundSheet extends StatefulWidget {
  final DeSoundUnit unit;
  final Color color;
  const AlphabetSoundSheet({super.key, required this.unit, required this.color});

  @override
  State<AlphabetSoundSheet> createState() => _AlphabetSoundSheetState();
}

class _AlphabetSoundSheetState extends State<AlphabetSoundSheet> {
  Timer? _autoPlay;
  bool _showVowelImage = false;
  bool _showPlaceImage = true;

  @override
  void initState() {
    super.initState();
    _autoPlay = Timer(const Duration(seconds: 1), () => sayDe(widget.unit.speakText));
  }

  @override
  void dispose() {
    _autoPlay?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.unit;
    final color = widget.color;
    final place = u.place == null ? null : kPlaces[u.place];
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scroll) => SafeArea(
        top: false,
        child: ListView(
          controller: scroll,
          padding: EdgeInsets.fromLTRB(20, 12, 20, 32 + bottomInset(context)),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.sumiLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(u.glyph,
                        style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: AppColors.washi)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.ko, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
                      const SizedBox(height: 4),
                      Text('IPA [${u.ipa}]',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.sumi)),
                      if (u.name != null) ...[
                        const SizedBox(height: 2),
                        Text(trf('글자 이름: {0} ({1})', [u.name, u.nameKo]),
                            style: const TextStyle(fontSize: 12, color: AppColors.sumiLight)),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  iconSize: 44,
                  color: color,
                  tooltip: tr('다시 듣기'),
                  icon: const Icon(Icons.play_circle_fill),
                  onPressed: () => sayDe(u.speakText),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _section(tr('👄 소리 내는 법'), Text(u.how, style: _body), color),
            if (u.vowel != null) ...[
              const SizedBox(height: 14),
              _section(tr('📍 모음 위치 — 독일어 vs 한국어'), DeVowelChart(data: u.vowel!), color),
              _toggle(tr('IPA 모음 사각도 그림 보기'), _showVowelImage,
                  () => setState(() => _showVowelImage = !_showVowelImage), color),
              if (_showVowelImage) _picture('assets/images/ipa/ipa_vowel_chart.png', 960 / 778, const []),
            ],
            if (place != null) ...[
              const SizedBox(height: 14),
              _section(
                tr('📍 조음 위치'),
                Text(trf('{0} — 그림 {1}번', [place.label, place.numbers.join('·')]),
                    style: _body.copyWith(fontWeight: FontWeight.w700)),
                color,
              ),
              _toggle(tr('자음 조음 위치 그림 보기'), _showPlaceImage,
                  () => setState(() => _showPlaceImage = !_showPlaceImage), color),
              if (_showPlaceImage) _picture('assets/images/ipa/places_of_articulation.png', 960 / 1200, place.marks, color: color),
            ],
            const SizedBox(height: 14),
            _section(tr('🇰🇷 한국어와 비교'), Text(trf('비슷한 소리: {0}\n\n{1}', [u.korSim, u.korDiff]), style: _body), color),
            const SizedBox(height: 14),
            _section(
              tr('🔊 예시 단어'),
              Column(children: [for (final e in u.ex) _exampleRow(e, color)]),
              color,
            ),
          ],
        ),
      ),
    );
  }

  static const _body = TextStyle(fontSize: 13.5, height: 1.55, color: AppColors.sumi);

  Widget _exampleRow(DeExample e, Color color) {
    return InkWell(
      onTap: () => sayDe(e.word),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(Icons.volume_up, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(e.word, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.sumi)),
                  Text(e.reading, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700)),
                  Text(e.ko, style: const TextStyle(fontSize: 13, color: AppColors.sumiLight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggle(String label, bool open, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(open ? Icons.expand_less : Icons.expand_more, size: 18, color: color),
            Flexible(
              child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  /// 그림 + (조음 위치) 표시 고리.
  Widget _picture(String asset, double aspect, List<Offset> marks, {Color? color}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8),
            child: AspectRatio(
              aspectRatio: aspect,
              child: LayoutBuilder(
                builder: (context, c) => Stack(
                  children: [
                    Positioned.fill(child: Image.asset(asset, fit: BoxFit.fill)),
                    for (final m in marks)
                      Positioned(
                        left: m.dx * c.maxWidth - 16,
                        top: m.dy * c.maxHeight - 16,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (color ?? AppColors.beni).withValues(alpha: 0.18),
                            border: Border.all(color: color ?? AppColors.beni, width: 3),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, Widget body, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.washiDeep,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 8),
          body,
        ],
      ),
    );
  }
}
