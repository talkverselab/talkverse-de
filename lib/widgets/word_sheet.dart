import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';

/// 단어 정보 시트 열기(레마 칩 → 단어장).
Future<void> showWordSheet(BuildContext context, WordEntry word) => showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.washi,
      showDragHandle: true,
      builder: (_) => WordSheet(word: word),
    );

/// 단어 1개 — 관사+단어 · 독음 · 뜻 · 품사 · 절벽 구간.
class WordSheet extends StatelessWidget {
  final WordEntry word;
  const WordSheet({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final w = word;
    final head = w.article.isEmpty ? w.word : '${w.article} ${w.word}';
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 20 + bottomInset(context)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: Text(head, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.sumi))),
            IconButton(onPressed: () => TtsService.instance.speak(head), icon: const Icon(Icons.volume_up, color: AppColors.beni, size: 28)),
          ]),
          if (w.reading.isNotEmpty) Text(w.reading, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
          const SizedBox(height: 10),
          Text(w.ko, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.sumiLight, height: 1.4)),
          const SizedBox(height: 12),
          Wrap(spacing: 6, runSpacing: 6, children: [
            if (w.pos.isNotEmpty) _tag(w.pos),
            if (w.level.isNotEmpty) _tag(w.level == 'R5' ? tr('절벽 밖') : '${w.level} · ${w.rank}${tr('위')}'),
            if (w.en.isNotEmpty) _tag(w.en, muted: true),
          ]),
        ]),
      ),
    );
  }

  Widget _tag(String t, {bool muted = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: muted ? AppColors.washiDeep : AppColors.beni.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: muted ? AppColors.line : AppColors.beni.withValues(alpha: 0.4))),
        child: Text(t, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: muted ? AppColors.muted : AppColors.beniDeep)),
      );
}
