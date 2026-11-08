// 2026-11-08 알파벳과 발음 — 칸·칩·발음 시트, 예시 단어 독음이 단어 목록(csv)과 같은지.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:german_universe/screens/alphabet_screen.dart';
import 'package:german_universe/services/de_phonetics.dart';
import 'package:german_universe/services/ko_reading.dart';
import 'package:german_universe/widgets/alphabet_sound_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    KoReadingPrefs.show.value = false;
    // 기기 TTS 는 테스트에서 아무것도 하지 않는다.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (call) async => 1);
  });

  Future<void> pumpAt(WidgetTester t, Size size) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: AlphabetScreen()));
    await t.pump();
  }

  // 칩 줄은 가로 스크롤 — 안 보이면 밀어서 찾는다.
  Future<void> tapChip(WidgetTester t, String label) async {
    final chips = find.byType(Scrollable).first;
    for (var i = 0; i < 12 && find.text(label).evaluate().isEmpty; i++) {
      await t.drag(chips, Offset(i < 6 ? -150 : 150, 0));
      await t.pump();
    }
    await t.ensureVisible(find.text(label));
    await t.pump();
    await t.tap(find.text(label));
    await t.pump();
  }

  Finder sheetScroll() =>
      find.descendant(of: find.byType(AlphabetSoundSheet), matching: find.byType(Scrollable)).first;

  test('예시 단어 독음·뜻 = lang_de_top.csv', () {
    final rows = <String, (String, String)>{};
    final lines = File('assets/data/freq/lang_de_top.csv').readAsLinesSync().skip(1);
    for (final l in lines) {
      final c = l.split(',');
      if (c.length < 4) continue;
      rows.putIfAbsent(c[1], () => (c[2], c[3]));
    }
    for (final u in kDeUnits) {
      expect(u.ex, isNotEmpty, reason: u.id);
      for (final e in u.ex) {
        expect(rows[e.word], isNotNull, reason: '${u.id}: ${e.word} 이 csv 에 없음');
        expect(rows[e.word]!.$1, e.reading, reason: '${u.id}: ${e.word} 독음');
        expect(rows[e.word]!.$2, e.ko, reason: '${u.id}: ${e.word} 뜻');
      }
      if (u.place != null) expect(kPlaces[u.place], isNotNull, reason: u.id);
    }
    expect(kDeUnits.map((u) => u.id).toSet().length, kDeUnits.length);
  });

  for (final size in const [Size(300, 800), Size(390, 844), Size(900, 1200)]) {
    final w = size.width.toInt();

    testWidgets('알파벳 $w폭 — 그룹·칩 필터·독음 토글, 넘침 없음', (t) async {
      await pumpAt(t, size);
      expect(find.text('알파벳과 발음'), findsOneWidget);
      expect(find.text('모음'), findsOneWidget); // 전체 = 그룹 머리글 전부
      expect(find.text('a'), findsOneWidget);

      // 칩: 자음만
      await tapChip(t, '자음 21');
      expect(find.text('b'), findsOneWidget);
      expect(find.text('a'), findsNothing);

      // 칩: 자음 묶음만
      await tapChip(t, '자음 묶음 11');
      expect(find.text('sch'), findsOneWidget);
      expect(find.text('b'), findsNothing);
      expect(find.text('ch'), findsNWidgets(2));

      // 칩: 움라우트
      await tapChip(t, '움라우트·ß 4');
      expect(find.text('ü'), findsOneWidget);
      expect(find.text('sch'), findsNothing);

      // 독음 토글 — 기본 숨김
      expect(find.text('위'), findsNothing);
      await t.tap(find.byType(KoReadingToggleAction));
      await t.pump();
      expect(find.text('위'), findsOneWidget);
      await t.pump(const Duration(seconds: 4)); // 스낵바
    });

    testWidgets('발음 시트 $w폭 — 모음(ü)·자음(w) 시트, 넘침 없음', (t) async {
      await pumpAt(t, size);
      await tapChip(t, '움라우트·ß 4');
      await t.tap(find.text('ü'));
      await t.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.byType(AlphabetSoundSheet), findsOneWidget);
      expect(find.text('IPA [yː · ʏ]'), findsOneWidget);
      expect(find.text('📍 모음 위치 — 독일어 vs 한국어'), findsOneWidget);
      await t.scrollUntilVisible(find.text('IPA 모음 사각도 그림 보기'), 200, scrollable: sheetScroll());
      await t.tap(find.text('IPA 모음 사각도 그림 보기'));
      await t.pump();
      await t.pump(const Duration(seconds: 2)); // 1초 자동 재생 타이머
      await t.scrollUntilVisible(find.text('Glück'), 300,
          scrollable: sheetScroll());
      await t.pump();
      expect(find.text('Glück'), findsOneWidget);

      // 닫고 자음 시트
      Navigator.of(t.element(find.byType(AlphabetSoundSheet))).pop();
      await t.pumpAndSettle();
      await tapChip(t, '자음 21');
      await t.tap(find.text('w'));
      await t.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('IPA [v]'), findsOneWidget);
      expect(find.textContaining('아랫입술 + 윗니'), findsOneWidget);
      await t.pump(const Duration(seconds: 2));
      await t.scrollUntilVisible(find.text('wie'), 300,
          scrollable: sheetScroll());
      await t.pump();
      expect(find.text('wie'), findsOneWidget);
    });
  }
}
