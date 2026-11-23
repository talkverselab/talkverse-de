import 'package:flutter/material.dart';
import '../core/prefs.dart';

import '../screens/paywall_screen.dart';
import 'account.dart';
import 'purchase.dart';

/// 무료/유료 구분 — Talkverse ID 평생 이용권(lang 'de', 2026-11-02 한자 앱 구조를 옮김).
/// `premium` = 기기 제작용 스위치 OR Talkverse 계정 이용권(auth.talkverse.uk) OR 이 기기에서 산·복원한 스토어 이용권.
/// 무료/유료 범위 = `~/talkverse/PAYWALL_SPEC.md`(사용자 「1 2 모두 진행」 2026-11-23): 커리큘럼·회화 1단계·문법 1~2스텝·언어감각 1급 무료, 나머지 유료.
/// 잠금 값은 서버 커리큘럼 JSON(free·freeSteps·freeSenseLevels). 잠긴 곳은 숨기지 않고 자물쇠 → [gate].
class Entitlement {
  Entitlement._();
  static const lang = 'de';
  static bool _local = false;
  static bool get premium => _local || Account.has(lang) || Purchase.owns(lang);

  static Future<void> load() async => _local = (await Prefs.getInstance()).getBool('premium') ?? false;

  static Future<void> showPaywall(BuildContext context) => PaywallScreen.show(context);

  /// 잠긴 곳을 눌렀을 때 — 무료이거나 이용권이 있으면 true, 아니면 결제 화면을 띄우고 닫힌 뒤의 상태를 돌려준다.
  static Future<bool> gate(BuildContext context, {required bool free}) async {
    if (free || premium) return true;
    await showPaywall(context);
    return premium;
  }

  /// 시험용 — 이용권 있음/없음을 바꿔 끼운다.
  @visibleForTesting
  static set debugPremium(bool v) => _local = v;
}
