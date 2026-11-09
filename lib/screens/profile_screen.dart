import 'package:flutter/material.dart';

import 'about_screen.dart';
import 'login_screen.dart';

import '../core/theme.dart';
import '../widgets/spanish_decor.dart';
import '../core/l10n.dart';
import '../core/pane.dart';
import '../data/account.dart';
import '../data/entitlement.dart';
import '../data/purchase.dart';
import '../services/ko_reading.dart';
import '../services/learner_prefs.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cal,
      appBar: AppBar(title: Text(tr('프로필'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.rojoDeep, AppColors.rojo],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
            ),
            child: Row(
              children: [
                const TileBadge(text: 'DE', size: 60, color: AppColors.deutsch),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('학습자'),
                        style: TextStyle(
                          color: AppColors.cal,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        tr('Tag 1 · 입문 (A1)'),
                        style: TextStyle(
                          color: AppColors.gualdaBright,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // 학습자 프로필(일본어앱 learner_prefs) — 이름 → 회화의 {name} 자리, 성별 → 학습자 목소리·장면 그림(새 회화 구조부터)
          _SectionTitle(tr('학습자 프로필')),
          const SizedBox(height: 8),
          const _LearnerSection(),
          const SizedBox(height: 16),
          _SectionTitle(tr('계정')),
          const SizedBox(height: 8),
          const _AccountSection(),
          const SizedBox(height: 16),
          _SectionTitle(tr('설정')),
          const SizedBox(height: 8),
          ValueListenableBuilder<bool>(
            valueListenable: KoReadingPrefs.show,
            builder: (context, on, _) => _SettingsGroup(items: [
              _SettingItem(
                  icon: Icons.language,
                  title: tr('언어 / Language'),
                  subtitle: '${AppLangPrefs.lang.value.label}  →  ${AppLangPrefs.peekNext().label}',
                  onTap: AppLangPrefs.next),
              _SettingItem(
                  icon: Icons.subtitles_outlined,
                  title: tr('한글 독음'),
                  subtitle: on ? tr('표시 — 탭하면 숨김') : tr('숨김 — 탭하면 표시'),
                  onTap: () => KoReadingPrefs.toggleWithHint(context)),
            ]),
          ),
          const SizedBox(height: 16),
          _SectionTitle(tr('정보')),
          const SizedBox(height: 8),
          _SettingsGroup(items: [
            _SettingItem(
                icon: Icons.landscape_outlined,
                title: tr('앱 소개'),
                subtitle: tr('절벽구간 — 이 앱이 단어를 나누는 기준'),
                onTap: () => openPane(context, (_) => const AboutScreen())),
            _SettingItem(icon: Icons.info_outline, title: tr('앱 버전'), subtitle: '0.1.0 · alpha'),
            _SettingItem(icon: Icons.copyright, title: tr('저작권'), subtitle: tr('독일어유니버스 · 2026')),
          ]),
          const SizedBox(height: 20),
          const BandDivider(),
          const SizedBox(height: 12),
          const Center(child: SolMark(size: 28)),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Übung macht den Meister',
              style: TextStyle(
                color: AppColors.tintaLight,
                fontSize: 11,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 15,
        color: AppColors.tinta,
        letterSpacing: 2,
      ),
    );
  }
}

/// 학습자 이름·성별 — 회화의 「나」(A)와 목소리.
class _LearnerSection extends StatelessWidget {
  const _LearnerSection();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: LearnerPrefs.name,
        builder: (context, name, _) => ValueListenableBuilder<String>(
          valueListenable: LearnerPrefs.gender,
          builder: (context, gender, _) => _SettingsGroup(items: [
            _SettingItem(
                icon: Icons.badge_outlined,
                title: tr('이름'),
                subtitle: name.isNotEmpty ? trf('{0} — 회화 속 「나」로 나와요', [name]) : tr('없음 — 회화에서 「○○」로 보여요'),
                onTap: () => _editName(context)),
            _SettingItem(
                icon: gender == 'female' ? Icons.face_3 : Icons.face,
                title: tr('성별'),
                subtitle: gender == 'female' ? tr('여성 — 탭하면 남성') : tr('남성 — 탭하면 여성'),
                onTap: () => LearnerPrefs.setGender(gender == 'female' ? 'male' : 'female')),
          ]),
        ),
      );

  Future<void> _editName(BuildContext context) async {
    final c = TextEditingController(text: LearnerPrefs.name.value);
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('이름')),
        content: TextField(controller: c, autofocus: true, decoration: InputDecoration(hintText: tr('회화에서 불릴 이름'))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('취소'))),
          TextButton(onPressed: () => Navigator.pop(ctx, c.text), child: Text(tr('저장'))),
        ],
      ),
    );
    if (v != null) await LearnerPrefs.setName(v);
  }
}

/// Talkverse 계정·평생 이용권(2026-11-02, 한자 앱 me_screen 계정 칸을 옮김) — 로그인은 선택.
/// 로그인 전: 로그인 타일 / 로그인 후: 이름·이메일, 로그아웃, 계정 삭제(스토어 심사 요구). 아래에 이용권·구매 복원.
class _AccountSection extends StatelessWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: Account.user,
      builder: (context, u, _) => ValueListenableBuilder<Map<String, int>>(
        valueListenable: Purchase.owned,
        builder: (context, _, _) => _SettingsGroup(items: [
          if (u == null)
            _SettingItem(
                icon: Icons.account_circle_outlined,
                title: tr('로그인'),
                subtitle: tr('Talkverse 계정 하나로 모든 앱에서'),
                onTap: () => LoginScreen.open(context))
          else ...[
            _SettingItem(
                icon: Icons.account_circle,
                title: (u['display_name'] as String?) ?? tr('이름 없음'),
                subtitle: (u['email'] as String?) ?? ''),
            _SettingItem(icon: Icons.logout, title: tr('로그아웃'), subtitle: '', onTap: Account.signOut),
            _SettingItem(
                icon: Icons.person_remove_outlined,
                title: tr('계정 삭제'),
                subtitle: tr('계정과 로그인 정보를 지웁니다'),
                onTap: () => _confirmDelete(context)),
          ],
          _SettingItem(
              icon: Icons.workspace_premium_outlined,
              title: tr('이용권'),
              subtitle: Entitlement.premium ? tr('이용 중') : tr('1개월 · 3개월 · 1년 · 평생'),
              onTap: Entitlement.premium ? null : () => Entitlement.showPaywall(context)),
          _SettingItem(icon: Icons.restore, title: tr('구매 복원'), subtitle: tr('이전에 산 이용권을 다시 엽니다'), onTap: () => _restore(context)),
        ]),
      ),
    );
  }

  /// 구매 복원 — 결과(복원됨/없음/오류)를 아래 알림으로.
  void _restore(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    void onStatus() {
      final st = Purchase.status.value;
      if (st == null || st == 'pending') return;
      Purchase.status.removeListener(onStatus);
      messenger.showSnackBar(SnackBar(
          content: Text(switch (st) {
        'restored' || 'done' => tr('이용권을 복원했습니다.'),
        'nothing' => tr('복원할 구매가 없습니다.'),
        _ => tr('복원하지 못했습니다. 잠시 후 다시 시도해 주세요.'),
      })));
    }

    Purchase.status.value = null;
    Purchase.status.addListener(onStatus);
    Purchase.restore();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(tr('계정을 삭제할까요?')),
        content: Text(tr('Talkverse 계정과 이름·이메일·로그인 정보가 지워지고 모든 기기에서 로그아웃됩니다. 이 기기의 학습 기록은 그대로 남습니다. 되돌릴 수 없습니다.')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(tr('취소'))),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(tr('삭제'), style: const TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await Account.deleteAccount();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('삭제하지 못했습니다. 네트워크를 확인하고 다시 시도해 주세요.'))));
      }
    }
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingItem> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cal,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gualda.withValues(alpha: 0.5)),
      ),
      // ListTile 은 가장 가까운 Material 에 물결을 그린다 — 색 있는 상자 안에 투명 Material 을 둔다
      child: Material(
        type: MaterialType.transparency,
        child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            ListTile(
              onTap: items[i].onTap,
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.rojo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.rojo, width: 0.8),
                ),
                child: Icon(items[i].icon, color: AppColors.rojo, size: 18),
              ),
              title: Text(items[i].title,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.tinta)),
              subtitle: Text(items[i].subtitle,
                  style: const TextStyle(color: AppColors.tintaLight, fontSize: 11)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.rojo, size: 18),
            ),
            if (i < items.length - 1)
              Container(height: 0.5, color: AppColors.gualda.withValues(alpha: 0.3)),
          ],
        ],
      ),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  _SettingItem({required this.icon, required this.title, required this.subtitle, this.onTap});
}
