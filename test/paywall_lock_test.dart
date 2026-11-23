import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:german_universe/data/entitlement.dart';
import 'package:german_universe/data/purchase.dart';
import 'package:german_universe/screens/paywall_screen.dart';
import 'package:german_universe/services/curriculum_service.dart';
import 'package:german_universe/services/dialogue_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 이용권 잠금 경계(PAYWALL_SPEC §5) — 1단계 열림 · 2단계 잠김 · 이용권 있으면 열림, 결제 화면은 상품을 못 받으면 「다시 시도」+닫기.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final svc = CurriculumService.instance;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    svc.resetForTest();
    Entitlement.debugPremium = false;
  });
  tearDown(() {
    svc.fetchOverride = null;
    Entitlement.debugPremium = false;
  });

  testWidgets('묶음 JSON rev 2 — 1단계 무료, 2단계 이상 잠김, 회화 R0·R1 무료·R2 이상 잠김, 문법 2스텝·언어감각 1급', (t) async {
    await t.runAsync(() async {
      await DialogueService.instance.ensureLoaded();
      svc.fetchOverride = (_) async => null;
      await svc.ensureLoaded();
      expect(svc.plan!.rev, greaterThanOrEqualTo(2));
      expect(svc.stageFree('1'), isTrue);
      expect(svc.stageFree('2'), isFalse);
      expect(svc.stageFree('5'), isFalse);
      final r1 = DialogueService.instance.list(region: 'R1').first, r2 = DialogueService.instance.list(region: 'R2').first;
      expect(svc.dialogueFree(r1), isTrue);
      expect(svc.dialogueFree(r2), isFalse);
      expect(svc.freeSteps, 2);
      expect(svc.freeSenseLevels, 1);

      // 서버가 2단계도 무료로 바꾸면 그대로 따른다
      svc.fetchOverride = (_) async => json.encode({
            'rev': 99,
            'freeSteps': 3,
            'stages': [
              {'n': 1, 'free': true, 'dialogueIds': [r1.id]},
              {'n': 2, 'free': true, 'dialogueIds': [r2.id]},
            ],
          });
      expect(await svc.refreshPlan(), isTrue);
      expect(svc.stageFree('2'), isTrue);
      expect(svc.dialogueFree(r2), isTrue);
      expect(svc.freeSteps, 3);
    });
  });

  testWidgets('잠긴 곳 gate — 이용권 없으면 결제 화면이 뜨고 false, 있으면 바로 true', (t) async {
    Purchase.productsTried.value = true; // 상품 못 받은 상태 → 「다시 시도」+닫기
    bool? got;
    await t.pumpWidget(MaterialApp(
      home: Builder(builder: (ctx) => TextButton(onPressed: () async => got = await Entitlement.gate(ctx, free: false), child: const Text('go'))),
    ));
    await t.tap(find.text('go'));
    await t.pumpAndSettle();
    expect(find.byType(PaywallScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('pw-retry-msg')), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('pw-close')));
    await t.pumpAndSettle();
    expect(got, isFalse);

    expect(await Entitlement.gate(t.element(find.text('go')), free: true), isTrue);
    Entitlement.debugPremium = true;
    expect(await Entitlement.gate(t.element(find.text('go')), free: false), isTrue);
  });
}
