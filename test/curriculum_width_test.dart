import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:german_universe/screens/curriculum_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 커리큘럼 코스 고르기 — 3·5·10 칩 + 「추천으로 채우기」 줄이 좁은 폭에서 넘치지 않는다(몽골어앱 발견, Row → Wrap, 2026-11-22).
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({'de_curriculum_v1': '{"level":"R1","dailyGoal":2}'}));

  for (final size in const [Size(300, 800), Size(390, 844)]) {
    testWidgets('코스 고르기 ${size.width.toInt()}폭 — 칩·추천 줄 넘침 없음', (t) async {
      t.view.physicalSize = size;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.runAsync(() async {
        await t.pumpWidget(const MaterialApp(home: CurriculumScreen()));
        await Future<void>.delayed(const Duration(milliseconds: 1500)); // 번들 읽기는 진짜 시계에서
      });
      await t.pump();
      expect(find.byKey(const ValueKey('cur-recommend')), findsOneWidget);
      expect(find.byKey(const ValueKey('cur-count-10')), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.tap(find.byKey(const ValueKey('cur-recommend')));
      await t.pump();
      expect(t.takeException(), isNull);
    });
  }
}
