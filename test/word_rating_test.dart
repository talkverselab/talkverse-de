import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 12+ 등급 — 단어표(단어 화면·퀴즈·카드가 읽는 CSV)에 비속어가 없어야 한다(uk 심사 점검 2026-11-23).
void main() {
  test('절벽 단어 CSV 에 비속어 없음', () {
    const block = {'scheiße', 'scheisse', 'verdammt', 'arsch', 'arschloch', 'geil', 'ficken', 'fotze', 'hure', 'wichser', 'schlampe', 'nutte', 'fick'};
    final rows = File('assets/data/freq/lang_de_top.csv').readAsLinesSync().skip(1);
    final words = [for (final r in rows) if (r.split(',').length > 2) r.split(',')[1].trim().toLowerCase()];
    expect(words.length, greaterThan(1400));
    expect(words.where(block.contains), isEmpty);
  });
}
