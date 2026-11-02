import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/paywall_screen.dart';
import 'account.dart';
import 'purchase.dart';

/// 무료/유료 구분 — Talkverse ID 평생 이용권(lang 'de', 2026-11-02 한자 앱 구조를 옮김).
/// `premium` = 기기 제작용 스위치 OR Talkverse 계정 이용권(auth.talkverse.uk) OR 이 기기에서 산·복원한 스토어 이용권.
/// 지금은 잠긴 콘텐츠가 없다 — 무엇을 유료로 둘지는 사용자 결정(HANDOFF.md). 잠글 때 `premium` 을 보고 `showPaywall` 을 띄운다.
class Entitlement {
  Entitlement._();
  static const lang = 'de';
  static bool _local = false;
  static bool get premium => _local || Account.has(lang) || Purchase.owns(lang);

  static Future<void> load() async => _local = (await SharedPreferences.getInstance()).getBool('premium') ?? false;

  static Future<void> showPaywall(BuildContext context) => PaywallScreen.show(context);
}
