// 아이패드 두 화면 + 만화책 읽기형 회화 확인용 스크린샷 흐름 — 2026-11-03(일본어·인도네시아어앱 dialogue_pane_test 를 옮김).
// 실행: python3 tools/pane_shots.py <아이패드 UDID> <출력폴더> integration_test/dialogue_pane_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:german_universe/core/l10n.dart';
import 'package:german_universe/data/db/app_database.dart';
import 'package:german_universe/data/db/seed_loader.dart';
import 'package:german_universe/main.dart';
import 'package:german_universe/screens/main_screen.dart';
import 'package:german_universe/services/achievement_service.dart';
import 'package:german_universe/services/ko_reading.dart';
import 'package:german_universe/services/learner_prefs.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  Future<void> wait(WidgetTester t, int ms) async {
    final end = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(end)) {
      await t.pump(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> shot(WidgetTester t, String name) async {
    await wait(t, 2000);
    // ignore: avoid_print
    print('SHOT:$name');
    await wait(t, 3000);
  }

  Finder rail(String label) => find.descendant(of: find.byType(NavigationRail), matching: find.text(label));

  testWidgets('dialogue pane', timeout: const Timeout(Duration(minutes: 10)), (t) async {
    // 앱 시작 순서는 main() 과 같게(로그인·결제는 화면 확인에 필요 없어 뺀다)
    appDb = AppDatabase();
    await SeedLoader(appDb).seedIfNeeded();
    await KoReadingPrefs.load();
    await AppLangPrefs.load();
    await LearnerPrefs.load();
    await AchievementService.instance.load();
    await t.pumpWidget(const GermanUniverseApp());
    await wait(t, 1500);
    await shot(t, '01_home_wide');

    await t.tap(find.descendant(of: find.byType(GridView), matching: find.text('회화')).first);
    await wait(t, 2500);
    await shot(t, '02_dialogue_home_right');

    await t.tap(find.text('사랑').first);
    await wait(t, 1200);
    await shot(t, '03_topic_list');

    await t.tap(find.text('첫 인사').first);
    await wait(t, 1500);
    await shot(t, '04_reader');

    await t.tap(find.text('재생').first);
    await wait(t, 6000);
    await shot(t, '05_reader_playing');

    await t.tap(find.byTooltip('그림 카드(글자 없이)'));
    await wait(t, 1500);
    await shot(t, '06_card_front');
    await t.tap(find.text('탭해서 확인'));
    await wait(t, 800);
    await shot(t, '07_card_back');
    await t.pageBack();
    await wait(t, 1200);

    await t.tap(rail('진행'));
    await wait(t, 1500);
    await shot(t, '08_progress_achievements');

    await t.tap(rail('프로필'));
    await wait(t, 1500);
    await shot(t, '09_profile');

    // 2026-11-07 개편 — 앱 소개(레일 맨 아래) · 절벽 단어(단원·타일·회화 단어) · 독음 토글
    await t.tap(rail('앱 소개'));
    await wait(t, 1500);
    await shot(t, '10_about');

    await t.tap(rail('홈'));
    await wait(t, 1000);
    final home = find.descendant(of: find.byType(HomeScreen), matching: find.byType(Scrollable)).first;
    await t.dragUntilVisible(find.text('절벽 단어'), home, const Offset(0, -200));
    await wait(t, 500);
    await shot(t, '11_home_menu_lower');
    await t.tap(find.text('절벽 단어'));
    await wait(t, 2500);
    await shot(t, '12_word_units');
    await t.tap(find.textContaining('회화 단어 포함'));
    await wait(t, 500);
    await t.tap(find.text('회화').last);
    await wait(t, 800);
    await shot(t, '13_word_conv');
    await t.tap(find.byTooltip('한글독음 표시'));
    await wait(t, 500);
    await shot(t, '14_reading_on_snack');
  });
}
