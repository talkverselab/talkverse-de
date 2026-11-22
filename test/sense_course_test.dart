import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:german_universe/screens/sense_course_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 일본어앱 `test/sense_course_test.dart` 이식 — 임시 과정 데이터(L1: 암기 1회 + 참고 1)로 본다.
Future<void> settle(WidgetTester t, Finder until) async {
  for (var i = 0; i < 100 && until.evaluate().isEmpty; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await t.pump();
  }
  await t.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('표시 풀기 — {조각|번호} 를 걷어내고, 같은 번호는 같은 색', () {
    expect(plainMarked('Ich nehme {einen|1} Kaffee {mit|2} Milch.'), 'Ich nehme einen Kaffee mit Milch.');
    const base = TextStyle(fontSize: 10);
    final de = markedSpans('{Der|1} Kuchen {ist|2} frisch.', base).cast<TextSpan>();
    final ko = markedSpans('케이크{는|1} 신선{해요|2}.', base).cast<TextSpan>();
    expect(de.map((s) => s.text).join(), 'Der Kuchen ist frisch.');
    expect(ko.map((s) => s.text).join(), '케이크는 신선해요.');
    final deMarks = de.where((s) => s.style != null).toList();
    final koMarks = ko.where((s) => s.style != null).toList();
    expect(deMarks.length, 2);
    expect(deMarks[0].style!.color, koMarks[0].style!.color);
    expect(deMarks[1].style!.color, koMarks[1].style!.color);
    expect(deMarks[0].style!.color, isNot(deMarks[1].style!.color));
  });

  for (final w in const [320.0, 900.0]) {
    testWidgets('언어감각 목록 폭 $w — 암기 1회 + 참고, 넘침 없음', (t) async {
      t.view.physicalSize = Size(w, 2000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: SenseCourseScreen()));
      await settle(t, find.byKey(const ValueKey('sense-L1-talk')));
      expect(t.takeException(), isNull);
      expect(find.byKey(const ValueKey('sense-L1-talk')), findsOneWidget);
      expect(find.byKey(const ValueKey('sense-L1-ref')), findsOneWidget);
      expect(find.text('0/10회 마침'), findsOneWidget);
    });
  }

  testWidgets('암기 회차 — 영상 자리, 표시 글자 안 남음, 마침 기록', (t) async {
    t.view.physicalSize = const Size(320, 3000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: SenseLessonScreen(index: 0)));
    await settle(t, find.byKey(const ValueKey('sense-finish')));
    expect(t.takeException(), isNull);
    expect(find.byKey(const ValueKey('memorize-video')), findsOneWidget);
    expect(find.textContaining('{', findRichText: true), findsNothing);
    expect(find.textContaining('Tasche ist wirklich', findRichText: true), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('sense-finish')));
    await t.pump(const Duration(milliseconds: 500));
    expect(await SenseCourse.done(), contains('L1-talk'));
  });

  testWidgets('참고 — 닫기는 기록 안 함', (t) async {
    t.view.physicalSize = const Size(320, 3000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: SenseLessonScreen(index: 1)));
    await settle(t, find.text('닫기'));
    expect(t.takeException(), isNull);
    expect(find.textContaining('der · die · das'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('sense-finish')));
    await t.pump(const Duration(milliseconds: 300));
    expect(await SenseCourse.done(), isNot(contains('L1-ref')));
  });
}
