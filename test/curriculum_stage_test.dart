import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:german_universe/services/curriculum_service.dart';
import 'package:german_universe/services/dialogue_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 커리큘럼 5단계 — 단계·편 목록은 JSON(서버 DB → 앱 안 기본값), 앱에 없는 편 건너뜀, 빈 단계 숨김(CURRICULUM_SPEC §12).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final svc = CurriculumService.instance;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    svc.resetForTest();
  });
  tearDown(() => svc.fetchOverride = null);

  test('옛 회화 레벨 값은 단계로 바꿔 읽음', () {
    expect(stageKeyOf('R0'), '1');
    expect(stageKeyOf('R1'), '1');
    expect(stageKeyOf('R4'), '4');
    expect(stageKeyOf(3), '3');
    expect(stageKeyOf(null), isNull);
    expect(CurriculumState.fromJson({'level': 'R2'}).level, '2');
    expect(CurPlan.parse('nope'), isNull);
    expect(CurPlan.parse('{"rev":1,"stages":[]}'), isNull);
  });

  testWidgets('서버 못 받으면 앱 안 기본값 5단계, 서버 rev 가 높으면 서버 것 — 없는 편 건너뜀·빈 단계 숨김', (t) async {
    await t.runAsync(() async {
      await DialogueService.instance.ensureLoaded();
      svc.fetchOverride = (_) async => null;
      await svc.ensureLoaded();
      expect(svc.levels, ['1', '2', '3', '4', '5']);
      expect(svc.levelList('1').length, 32);
      expect(svc.stageTitle('1'), '1단계');

      final real = svc.levelList('3').first.id;
      svc.fetchOverride = (_) async => json.encode({
            'rev': 99,
            'stages': [
              {'n': 1, 'title': '1단계', 'dialogueIds': [real, 'no_such_ep']},
              {'n': 2, 'title': '2단계', 'dialogueIds': []},
              {'n': 3, 'title': '3단계', 'dialogueIds': ['no_such_ep']},
              {'n': 4, 'title': '4단계', 'dialogueIds': [real]},
            ],
            'prep': [],
          });
      expect(await svc.refreshPlan(), isTrue);
      expect(svc.levels, ['1', '4']);
      expect(svc.levelList('1').map((d) => d.id), [real]);
      expect(svc.nextLevel('1'), '4');
      expect(svc.poolFor(svc.levelList('4').first).length, greaterThanOrEqualTo(1));
      // 같은 rev 는 다시 받지 않음
      expect(await svc.refreshPlan(), isFalse);
    });
  });

  testWidgets('단계 JSON 의 pass·daily 를 씀(없으면 80 · 1·2·3)', (t) async {
    await t.runAsync(() async {
      await DialogueService.instance.ensureLoaded();
      svc.fetchOverride = (_) async => null;
      await svc.ensureLoaded();
      final ids = [for (final d in svc.levelList('1')) d.id];
      svc.fetchOverride = (_) async => json.encode({
            'rev': 99,
            'stages': [
              {'n': 1, 'dialogueIds': ids, 'pass': 70, 'daily': {'light': 2, 'normal': 4, 'focus': 6}, 'pick': [2, 4]},
              {'n': 2, 'dialogueIds': ids},
            ],
          });
      expect(await svc.refreshPlan(), isTrue);
      expect(svc.passFor('1'), 70);
      expect(svc.passFor('2'), 80);
      expect(svc.pickSizes('1'), [2, 4]);
      expect(svc.stageTitle('2'), '2단계');
      svc.state
        ..level = '1'
        ..dailyGoal = 2;
      svc.applyStage();
      expect(svc.state.newLeft('2026-11-23'), 4);
      svc.state.level = '2';
      svc.applyStage();
      expect(svc.state.newLeft('2026-11-23'), 2);
      final st = CurriculumState(course: Course('c', ['a'], practiced: ['a']));
      expect(st.recordExam(7, 10, {}, '2026-11-23', pass: 70), isTrue);
    });
  });
}
