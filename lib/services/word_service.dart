import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

/// 단어장 항목 — 절벽 단어 목록(`assets/data/freq/lang_de_top.csv`, 1,500단어) + 여행 단어(`vocab/travel_words.json`).
class WordEntry {
  final String word; // 기본형(명사는 대문자)
  final String reading; // 한글 독음
  final String ko;
  final String en;
  final String pos; // noun-m/f/n/pl · verb · adj · adv …
  final String level; // R1~R5, 여행 단어는 빈 값
  final int rank; // 절벽 순위, 여행 단어는 0
  const WordEntry({required this.word, required this.reading, required this.ko, this.en = '', this.pos = '', this.level = '', this.rank = 0});

  /// 명사면 관사(der/die/das), 아니면 빈 값.
  String get article => switch (pos) { 'noun-m' => 'der', 'noun-f' => 'die', 'noun-n' => 'das', 'noun-pl' => 'die', _ => '' };
  String get gloss => ko;
}

/// 단어장(앱 번들) — 문장 레마 칩이 기본형으로 찾는다(사용자 지시 2026-11-04 "문장 레마별로 단어장이랑 연결").
/// DB 가 아니라 번들 CSV 를 한 번 읽어 메모리에 둔다(1,500 + 40 항목).
class WordService {
  WordService._();
  static final WordService instance = WordService._();

  final Map<String, WordEntry> _byKey = {}; // 소문자 기본형 → 항목
  Future<void>? _loading;
  bool get isLoaded => _byKey.isNotEmpty;

  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('assets/data/freq/lang_de_top.csv');
      final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(raw);
      // header: rank,word,reading,ko,en,pos,level,picturable
      for (var i = 1; i < rows.length; i++) {
        final r = rows[i];
        if (r.length < 7) continue;
        final w = '${r[1]}'.trim();
        if (w.isEmpty) continue;
        _byKey.putIfAbsent(w.toLowerCase(), () => WordEntry(word: w, reading: '${r[2]}', ko: '${r[3]}', en: '${r[4]}', pos: '${r[5]}', level: '${r[6]}', rank: int.tryParse('${r[0]}') ?? 0));
      }
    } catch (_) {}
    try {
      final j = json.decode(await rootBundle.loadString('assets/data/vocab/travel_words.json')) as Map<String, dynamic>;
      for (final t in (j['themes'] as List? ?? const [])) {
        for (final s in ((t as Map)['sections'] as List? ?? const [])) {
          for (final w in ((s as Map)['words'] as List? ?? const [])) {
            final m = w as Map;
            final tx = '${m['tx'] ?? ''}'.trim();
            if (tx.isEmpty) continue;
            _byKey.putIfAbsent(tx.toLowerCase(), () => WordEntry(word: tx, reading: '${m['rd'] ?? ''}', ko: '${m['ko'] ?? ''}'));
          }
        }
      }
    } catch (_) {}
  }

  /// 기본형(대소문자 무관)으로 단어장 항목 찾기 — 문장 레마 칩용. 반환: 기본형 → 항목.
  Future<Map<String, WordEntry>> byLemmas(Iterable<String> bases) async {
    await ensureLoaded();
    final out = <String, WordEntry>{};
    for (final b in bases) {
      if (b.isEmpty) continue;
      final e = _byKey[b.toLowerCase()];
      if (e != null) out[b] = e;
    }
    return out;
  }

  WordEntry? lookup(String word) => _byKey[word.toLowerCase()];
}
