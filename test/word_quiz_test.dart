import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:german_universe/core/prefs.dart';
import 'package:german_universe/screens/word_quiz_screen.dart';
import 'package:german_universe/services/word_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 일본어앱 `test/gairaigo_quiz_test.dart` 이식.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final words = [
    for (final w in const [
      ('Tisch', '티슈', '탁자', 'noun-m'), ('Tür', '튀어', '문', 'noun-f'), ('Haus', '하우스', '집', 'noun-n'),
      ('gehen', '게엔', '가다', 'verb'), ('essen', '에센', '먹다', 'verb'), ('groß', '그로스', '큰', 'adj'),
      ('klein', '클라인', '작은', 'adj'), ('heute', '호이테', '오늘', 'adv'), ('Kaffee', '카페', '커피', 'noun-m'),
      ('Milch', '밀히', '우유', 'noun-f'), ('Buch', '부흐', '책', 'noun-n'), ('schnell', '슈넬', '빠른', 'adj'),
    ])
      WordEntry(word: w.$1, reading: w.$2, ko: w.$3, pos: w.$4),
  ];

  testWidgets('단어 복습 퀴즈 — 보기 4개, 10문제 뒤 결과, 틀린 단어 기록, 폭 320 넘침 없음', (t) async {
    t.view.physicalSize = const Size(320, 700);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: WordQuizScreen(words: words, seed: 7)));
    await t.pumpAndSettle();
    for (var i = 0; i < kWordQuizSize; i++) {
      expect(t.takeException(), isNull);
      expect(find.byKey(const ValueKey('wq-opt-3')), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('wq-opt-0')));
      await t.pump();
      await t.ensureVisible(find.byKey(const ValueKey('wq-next')));
      await t.tap(find.byKey(const ValueKey('wq-next')));
      await t.pump();
    }
    expect(t.takeException(), isNull);
    expect(find.byKey(const ValueKey('wq-again')), findsOneWidget);
    expect(find.textContaining('문제 중'), findsOneWidget);
    final wrong = (await Prefs.getInstance()).getStringList('word_quiz_wrong');
    expect(wrong, isNotNull); // 맞힌 단어는 빠지고 틀린 단어만 남는다
    expect(wrong!.every((w) => words.any((e) => e.word.toLowerCase() == w)), isTrue);
  });

  test('명사는 관사를 붙여 보인다', () {
    expect(quizShown(words[0]), 'der Tisch');
    expect(quizShown(words[3]), 'gehen');
  });
}
