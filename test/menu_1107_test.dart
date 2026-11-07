// 2026-11-07 단어·메뉴 개편 — 절벽 단어(단원·타일·회화 단어) · 앱 소개 · 문장 레마 탭 · 독음 기본값.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:german_universe/screens/about_screen.dart';
import 'package:german_universe/screens/word_freq_screen.dart';
import 'package:german_universe/services/dialogue_service.dart';
import 'package:german_universe/services/ko_reading.dart';
import 'package:german_universe/services/word_service.dart';
import 'package:german_universe/widgets/episode_play_pane.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  setUpAll(() => WordService.instance.ensureLoaded()); // 가짜 시계 안에서 처음 부르면 끝나지 않는다

  Future<void> pumpAt(WidgetTester t, Widget w, Size size) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.runAsync(() async {
      await t.pumpWidget(MaterialApp(home: w)); // 번들 읽기는 진짜 시계에서
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
  }

  Future<void> settle(WidgetTester t) async {
    await t.runAsync(() async {
      await WordService.instance.ensureLoaded();
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
  }

  for (final size in const [Size(300, 800), Size(390, 844), Size(900, 1200)]) {
    testWidgets('절벽 단어 ${size.width.toInt()}폭 — 단원·구간·회화 단어, 넘침 없음', (t) async {
      await pumpAt(t, const WordFreqScreen(), size);
      await settle(t);
      expect(find.text('1단원'), findsOneWidget);
      expect(find.text('#1-20'), findsOneWidget);
      await t.tap(find.textContaining('회화 단어 포함 (+6)'));
      await t.pump();
      await t.dragUntilVisible(find.text('회화'), find.byType(ListView).first, const Offset(-120, 0));
      await t.pump();
      await t.tap(find.text('회화').last);
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      expect(find.text('회화 1-6'), findsOneWidget);
      expect(find.text('Samstag'), findsOneWidget);
    });

    testWidgets('앱 소개 ${size.width.toInt()}폭 — 구간표, 넘침 없음', (t) async {
      await pumpAt(t, const AboutScreen(), size);
      await t.pump();
      expect(find.text('1-81'), findsOneWidget);
      expect(find.text('281-822'), findsOneWidget);
      expect(find.text('823-1500'), findsOneWidget);
    });
  }

  testWidgets('문장 레마 — 단어장에 있는 말을 누르면 단어창', (t) async {
    await pumpAt(
      t,
      const Scaffold(
        body: GenderText('Ich gehe geradeaus.', nouns: [], lemmas: [Lemma('gehe', 'gehen', '게엔')], style: TextStyle(fontSize: 16)),
      ),
      const Size(390, 844),
    );
    await settle(t);
    await t.tap(find.text('gehe'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('gehen'), findsOneWidget);
  });

  test('한글 독음 기본 미표시', () async {
    await KoReadingPrefs.load();
    expect(KoReadingPrefs.show.value, isFalse);
  });
}
