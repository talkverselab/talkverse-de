import 'dart:math';

import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/pane.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/curriculum_service.dart';
import '../services/dialogue_service.dart';
import '../services/ko_reading.dart';
import '../services/tts_service.dart';

/// 토크버스 커리큘럼 — 레벨 고르기 → 다이얼로그 골라 코스 → 편마다 연습·확인 문제 → 복습(1·3·7일) → 코스 시험 80%.
/// 기준 `~/talkverse/CURRICULUM_SPEC.md`(전 언어 공통, 2026-11-22). 일본어앱 기준 구현이 나오면 화면·문구를 맞춘다.
class CurriculumScreen extends StatefulWidget {
  /// 시험용 — 날짜를 고정한다.
  final DateTime Function()? clock;
  const CurriculumScreen({super.key, this.clock});
  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  final _svc = CurriculumService.instance;
  CurriculumState? _s;
  bool _pickLevel = false;
  bool _confirmDiscard = false;
  int _size = 5;
  final List<String> _chosen = [];
  String? _notice;

  DateTime get _now => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await DialogueService.instance.ensureLoaded();
    final s = await _svc.load();
    if (!mounted) return;
    setState(() {
      _s = s;
      _pickLevel = s.level == null || !_svc.availableLevels().contains(s.level);
    });
  }

  Future<void> _save() async {
    await _svc.save(_s!);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    return Scaffold(
      backgroundColor: AppColors.cal,
      appBar: AppBar(title: Text(tr('토크버스 커리큘럼'))),
      body: s == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context)),
              children: _pickLevel ? _levelPicker(s) : _courseView(s),
            ),
    );
  }

  // ── 레벨 고르기 ──
  List<Widget> _levelPicker(CurriculumState s) {
    final levels = _svc.availableLevels();
    return [
      Text(tr('회화 레벨을 고르세요'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.tinta)),
      const SizedBox(height: 4),
      Text(tr('처음이면 가장 낮은 레벨부터 권합니다.'), style: const TextStyle(color: AppColors.tintaLight)),
      const SizedBox(height: 12),
      if (levels.isEmpty) Text(tr('아직 회화가 없습니다.')),
      for (final l in levels)
        Card(
          child: ListTile(
            key: ValueKey('cur-level-$l'),
            leading: CircleAvatar(backgroundColor: AppColors.rojo, foregroundColor: Colors.white, child: Text(l)),
            title: Text('$l · ${tr(DialogueService.levelKo[l] ?? l)}', style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(trf('{0}편 · 통과 {1}', [
              _svc.dialoguesOf(l).length,
              _svc.dialoguesOf(l).where((d) => s.passedDialogues.contains(d.id)).length,
            ])),
            trailing: l == levels.first && s.level == null
                ? Chip(label: Text(tr('추천')), visualDensity: VisualDensity.compact)
                : (l == s.level ? const Icon(Icons.check, color: AppColors.oliva) : null),
            onTap: () async {
              s.level = l;
              _chosen.clear();
              _pickLevel = false;
              await _save();
            },
          ),
        ),
      if (s.level != null)
        TextButton(onPressed: () => setState(() => _pickLevel = false), child: Text(tr('돌아가기'))),
    ];
  }

  // ── 코스 화면 ──
  List<Widget> _courseView(CurriculumState s) {
    final level = s.level!;
    final c = s.course;
    return [
      Row(children: [
        Expanded(
          child: Text('$level · ${tr(DialogueService.levelKo[level] ?? level)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.tinta)),
        ),
        TextButton(key: const ValueKey('cur-change-level'), onPressed: () => setState(() => _pickLevel = true), child: Text(tr('레벨 바꾸기'))),
      ]),
      const SizedBox(height: 8),
      CurriculumTodayCard(state: s, now: _now),
      const SizedBox(height: 8),
      _goalChips(s),
      if (_notice != null) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.calDeep, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gualda)),
          child: Text(_notice!, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.matcha)),
        ),
      ],
      const SizedBox(height: 12),
      if (s.dueReviews(_now).isNotEmpty)
        FilledButton.icon(
          key: const ValueKey('cur-review'),
          onPressed: _openReview,
          icon: const Icon(Icons.replay),
          label: Text(trf('복습 {0}개 하기', [s.dueReviews(_now).length])),
        ),
      const SizedBox(height: 12),
      if (c == null) ..._builder(s) else ..._activeCourse(s, c),
    ];
  }

  Widget _goalChips(CurriculumState s) => Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text(tr('하루 목표'), style: const TextStyle(fontSize: 12, color: AppColors.tintaLight)),
        for (final g in kDailyGoalKo.keys)
          ChoiceChip(
            key: ValueKey('cur-goal-$g'),
            label: Text(trf('{0} · 새 편 {1}', [tr(kDailyGoalKo[g]!), g])),
            selected: s.dailyGoal == g,
            onSelected: (_) async {
              s.dailyGoal = g;
              await _save();
            },
          ),
      ]);

  List<Widget> _builder(CurriculumState s) {
    final ds = _svc.dialoguesOf(s.level!);
    final passed = s.passedDialogues.toSet();
    return [
      Text(tr('새 코스 — 다이얼로그 고르기'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.tinta)),
      const SizedBox(height: 6),
      Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text(tr('고를 개수'), style: const TextStyle(fontSize: 12, color: AppColors.tintaLight)),
        for (final n in kCourseSizes)
          ChoiceChip(
            key: ValueKey('cur-size-$n'),
            label: Text(trf('{0}편', [n])),
            selected: _size == n,
            onSelected: (_) => setState(() {
              _size = n;
              if (_chosen.length > n) _chosen.removeRange(n, _chosen.length);
            }),
          ),
      ]),
      const SizedBox(height: 6),
      Row(children: [
        Expanded(child: Text(trf('{0} / {1}편 고름', [_chosen.length, min(_size, ds.length)]))),
        OutlinedButton(
          key: const ValueKey('cur-recommend'),
          onPressed: () => setState(() {
            final r = recommendDialogues(ds, passed, _chosen, min(_size, ds.length));
            _chosen
              ..clear()
              ..addAll(r);
          }),
          child: Text(tr('추천으로 채우기')),
        ),
      ]),
      const SizedBox(height: 6),
      for (final d in ds)
        CheckboxListTile(
          key: ValueKey('cur-pick-${d.id}'),
          value: _chosen.contains(d.id),
          dense: true,
          contentPadding: EdgeInsets.zero,
          onChanged: (v) => setState(() {
            if (v == true && _chosen.length < _size) {
              _chosen.add(d.id);
            } else {
              _chosen.remove(d.id);
            }
          }),
          secondary: Text(d.emoji, style: const TextStyle(fontSize: 22)),
          title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text([tr(DialogueService.topicKo[d.topic] ?? d.topic), if (passed.contains(d.id)) tr('통과함')].join(' · ')),
        ),
      const SizedBox(height: 8),
      FilledButton(
        key: const ValueKey('cur-start'),
        onPressed: _chosen.isEmpty
            ? null
            : () async {
                s.course = Course('c${_now.millisecondsSinceEpoch}', [..._chosen]);
                _chosen.clear();
                _notice = null;
                await _save();
              },
        child: Text(tr('코스 시작')),
      ),
    ];
  }

  List<Widget> _activeCourse(CurriculumState s, Course c) {
    final done = c.practiced.length;
    return [
      Text(trf('지금 코스 · 연습 {0} / {1}편', [done, c.dialogueIds.length]),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.tinta)),
      if (c.examScores.isNotEmpty)
        Text(trf('지난 시험 {0}% — {1}% 이상이면 통과', [c.examScores.last, kPassPercent]), style: const TextStyle(color: AppColors.tintaLight)),
      const SizedBox(height: 6),
      for (final id in c.dialogueIds)
        if (_svc.dialogue(id) case final d?)
          Card(
            child: ListTile(
              key: ValueKey('cur-ep-$id'),
              leading: Text(d.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(c.practiced.contains(id) ? tr('연습 끝') : tr('연습 전')),
              trailing: Icon(c.practiced.contains(id) ? Icons.check_circle : Icons.play_circle_outline,
                  color: c.practiced.contains(id) ? AppColors.oliva : AppColors.rojo),
              onTap: () => _openPractice(d),
            ),
          ),
      const SizedBox(height: 8),
      FilledButton.icon(
        key: const ValueKey('cur-exam'),
        onPressed: c.allPracticed ? () => _openExam(c) : null,
        icon: const Icon(Icons.assignment_turned_in_outlined),
        label: Text(c.allPracticed ? tr('코스 시험 보기') : tr('모든 편을 연습하면 코스 시험')),
      ),
      const SizedBox(height: 8),
      if (!_confirmDiscard)
        TextButton(key: const ValueKey('cur-new'), onPressed: () => setState(() => _confirmDiscard = true), child: Text(tr('새 코스 시작')))
      else
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.calDeep, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gualda)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr('지금 코스를 버리고 새로 고를까요? 복습 대기열은 그대로 남습니다.')),
            const SizedBox(height: 8),
            Row(children: [
              FilledButton(
                key: const ValueKey('cur-discard-yes'),
                onPressed: () async {
                  s.course = null;
                  _confirmDiscard = false;
                  await _save();
                },
                child: Text(tr('버리고 새로')),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: () => setState(() => _confirmDiscard = false), child: Text(tr('취소'))),
            ]),
          ]),
        ),
    ];
  }

  Future<void> _openPractice(Dialogue d) async {
    final pool = _svc.dialoguesOf(d.region);
    final res = await openFull<List<(CurQuestion, bool)>>(context, (_) => CurPracticeScreen(dialogue: d, pool: pool));
    if (res == null || _s == null) return;
    final wrong = {for (final (q, ok) in res) if (!ok) q.lineId};
    _s!.finishPractice(d.id, [for (final t in d.turns) if (t.tl.trim().isNotEmpty) lineIdOf(d, t)], wrong, _now);
    _notice = null;
    await _save();
  }

  Future<void> _openReview() async {
    final s = _s!;
    final rnd = Random();
    final qs = <CurQuestion>[];
    for (final r in s.dueReviews(_now).take(kReviewSessionMax)) {
      final hit = _svc.line(r.lineId);
      if (hit == null) {
        s.review.remove(r); // 원고에서 빠진 줄
        continue;
      }
      final (d, t) = hit;
      qs.addAll(makeQuestions(d, rnd: rnd, maxQ: 1, pool: _svc.dialoguesOf(d.region), onlyNums: [t.num]));
    }
    if (qs.isEmpty) {
      await _save();
      return;
    }
    if (!mounted) return;
    final res = await openFull<List<(CurQuestion, bool)>>(context, (_) => CurQuizScreen(title: tr('복습'), questions: qs));
    if (res == null) return;
    for (final (q, ok) in res) {
      s.answerReview(q.lineId, ok, _now);
    }
    await _save();
  }

  Future<void> _openExam(Course c) async {
    final ds = [for (final id in c.dialogueIds) ?_svc.dialogue(id)];
    final qs = makeExam(ds, Random());
    if (qs.isEmpty) return;
    final res = await openFull<List<(CurQuestion, bool)>>(context, (_) => CurQuizScreen(title: tr('코스 시험'), questions: qs, exam: true));
    if (res == null || _s == null) return;
    final s = _s!;
    final right = res.where((r) => r.$2).length;
    final wrongDs = {for (final (q, ok) in res) if (!ok) q.dialogueId};
    final level = s.level!;
    final pass = s.finishExam(right, res.length, wrongDs, _now);
    final pct = scorePercent(right, res.length);
    if (pass) {
      final all = _svc.dialoguesOf(level).every((d) => s.passedDialogues.contains(d.id));
      final next = _svc.nextLevel(level);
      if (all && next != null) {
        s.level = next;
        _notice = trf('{0}% 통과! {1} 레벨을 모두 마쳐 {2} 레벨이 열렸습니다.', [pct, level, next]);
      } else {
        _notice = trf('{0}% 통과! 남은 편으로 다음 코스를 고르세요.', [pct]);
      }
    } else {
      _notice = trf('{0}% — 틀린 편을 다시 연습하고 시험을 다시 보세요.', [pct]);
    }
    await _save();
  }
}

/// 오늘 분량 카드 — 홈과 커리큘럼 화면 공용. 「오늘: 복습 N · 새 편 N」 + 진행 막대 + 연속 일수.
class CurriculumTodayCard extends StatelessWidget {
  final CurriculumState state;
  final DateTime now;
  const CurriculumTodayCard({super.key, required this.state, required this.now});

  @override
  Widget build(BuildContext context) {
    final due = state.dueReviews(now).length;
    final newLeft = state.newLeft(now);
    final doneN = state.todayNew + state.todayReview;
    final total = doneN + due + newLeft;
    final ratio = total == 0 ? 1.0 : doneN / total;
    final finished = state.dailyDone(now);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.rojoDeep, AppColors.rojo]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(
              finished ? tr('오늘 분량 끝') : trf('오늘: 복습 {0} · 새 편 {1}', [due, newLeft]),
              key: const ValueKey('cur-today'),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          Text(trf('🔥 {0}일', [state.streak(now)]), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(value: ratio, minHeight: 6, backgroundColor: AppColors.rojoDeep, color: Colors.white),
        ),
      ]),
    );
  }
}

/// 홈 카드 — 커리큘럼 오늘 분량을 보여 주고 누르면 커리큘럼으로.
class CurriculumHomeCard extends StatefulWidget {
  const CurriculumHomeCard({super.key});
  @override
  State<CurriculumHomeCard> createState() => _CurriculumHomeCardState();
}

class _CurriculumHomeCardState extends State<CurriculumHomeCard> {
  CurriculumState? _s;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await DialogueService.instance.ensureLoaded();
    final s = await CurriculumService.instance.load();
    if (mounted) setState(() => _s = s);
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    return InkWell(
      key: const ValueKey('cur-home'),
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        await openPane(context, (_) => const CurriculumScreen());
        _load();
      },
      child: s == null || s.level == null
          ? Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.rojoDeep, AppColors.rojo]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tr('토크버스 커리큘럼'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(tr('레벨을 고르고 매일 분량으로 회화를 익혀요'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ]),
            )
          : CurriculumTodayCard(state: s, now: DateTime.now()),
    );
  }
}

/// 편 연습 — 1) 듣기·읽기(전체 재생, 줄마다 뜻) 2) 따라 말하기(줄 반복 듣기) 3) 확인 문제. 결과를 돌려준다.
class CurPracticeScreen extends StatefulWidget {
  final Dialogue dialogue;
  final List<Dialogue> pool;
  final int? seed;
  const CurPracticeScreen({super.key, required this.dialogue, this.pool = const [], this.seed});
  @override
  State<CurPracticeScreen> createState() => _CurPracticeScreenState();
}

class _CurPracticeScreenState extends State<CurPracticeScreen> {
  bool _showKo = true;
  int? _playing;
  bool _stop = false;

  @override
  void dispose() {
    _stop = true;
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _say(DialogueTurn t) =>
      TtsService.instance.speakAs(t.tl, gender: widget.dialogue.voiceGender(t.speaker));

  Future<void> _playAll() async {
    _stop = false;
    final turns = widget.dialogue.turns;
    for (var i = 0; i < turns.length && !_stop && mounted; i++) {
      setState(() => _playing = i);
      await _say(turns[i]);
      // 기기 TTS 는 끝날 때까지 기다리지 않으므로 말하는 동안 기다린다(최대 15초)
      for (var k = 0; k < 75 && !_stop && TtsService.instance.isSpeaking(turns[i].tl); k++) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (mounted) setState(() => _playing = null);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dialogue;
    return Scaffold(
      backgroundColor: AppColors.cal,
      appBar: AppBar(title: Text(d.title)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomInset(context)),
        children: [
          if (d.scene.isNotEmpty) Text(d.scene, style: const TextStyle(color: AppColors.tintaLight)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 6, children: [
            FilledButton.icon(
              key: const ValueKey('cur-play-all'),
              onPressed: _playing == null
                  ? _playAll
                  : () {
                      _stop = true;
                      TtsService.instance.stop();
                      setState(() => _playing = null);
                    },
              icon: Icon(_playing == null ? Icons.play_arrow : Icons.stop),
              label: Text(_playing == null ? tr('전체 듣기') : tr('멈추기')),
            ),
            OutlinedButton(onPressed: () => setState(() => _showKo = !_showKo), child: Text(_showKo ? tr('뜻 가리기') : tr('뜻 보기'))),
          ]),
          const SizedBox(height: 4),
          Text(tr('줄을 누르면 다시 들려줍니다 — 따라 말해 보세요.'), style: const TextStyle(fontSize: 12, color: AppColors.tintaLight)),
          const SizedBox(height: 8),
          for (var i = 0; i < d.turns.length; i++) _line(d, i),
          const SizedBox(height: 12),
          FilledButton(
            key: const ValueKey('cur-to-quiz'),
            onPressed: () async {
              _stop = true;
              TtsService.instance.stop();
              final qs = makeQuestions(d, rnd: Random(widget.seed), pool: widget.pool);
              final res = await Navigator.of(context).push<List<(CurQuestion, bool)>>(
                MaterialPageRoute(builder: (_) => CurQuizScreen(title: tr('확인 문제'), questions: qs)),
              );
              if (res != null && context.mounted) Navigator.of(context).pop(res);
            },
            child: Text(tr('확인 문제 풀기')),
          ),
        ],
      ),
    );
  }

  Widget _line(Dialogue d, int i) {
    final t = d.turns[i];
    final on = _playing == i;
    return InkWell(
      onTap: () => _say(t),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: on ? AppColors.rojo.withValues(alpha: 0.08) : AppColors.calDeep,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: on ? AppColors.rojo : AppColors.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d.speakerName(t.speaker), style: const TextStyle(fontSize: 11, color: AppColors.tintaLight, fontWeight: FontWeight.w700)),
          Text(t.tl, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.tinta)),
          if (t.rd.isNotEmpty) KoReadingText(t.rd, style: const TextStyle(fontSize: 12, color: AppColors.tintaLight)),
          if (_showKo) Text(t.ko, style: const TextStyle(fontSize: 13, color: AppColors.mar)),
        ]),
      ),
    );
  }
}

/// 4지선다 문제 풀기(연습·복습·시험 공용). 끝나면 (문제, 맞음) 목록을 돌려준다.
class CurQuizScreen extends StatefulWidget {
  final String title;
  final List<CurQuestion> questions;
  final bool exam;
  const CurQuizScreen({super.key, required this.title, required this.questions, this.exam = false});
  @override
  State<CurQuizScreen> createState() => _CurQuizScreenState();
}

class _CurQuizScreenState extends State<CurQuizScreen> {
  int _i = 0;
  int? _picked;
  final List<(CurQuestion, bool)> _res = [];

  @override
  Widget build(BuildContext context) {
    final qs = widget.questions;
    final finished = _i >= qs.length;
    return Scaffold(
      backgroundColor: AppColors.cal,
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context)),
        children: finished ? _result() : _question(qs[_i]),
      ),
    );
  }

  List<Widget> _result() {
    final right = _res.where((r) => r.$2).length;
    final pct = scorePercent(right, _res.length);
    return [
      const SizedBox(height: 24),
      Center(child: Text('$pct%', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: AppColors.tinta))),
      Center(child: Text(trf('{0}문제 중 {1}개 맞음', [_res.length, right]))),
      if (widget.exam)
        Center(
          child: Text(pct >= kPassPercent ? tr('통과') : trf('{0}% 이상이면 통과', [kPassPercent]),
              style: TextStyle(fontWeight: FontWeight.w800, color: pct >= kPassPercent ? AppColors.matcha : AppColors.fem)),
        ),
      const SizedBox(height: 20),
      FilledButton(key: const ValueKey('cur-done'), onPressed: () => Navigator.of(context).pop(_res), child: Text(tr('마치기'))),
    ];
  }

  List<Widget> _question(CurQuestion q) => [
        Text('${_i + 1} / ${widget.questions.length}', style: const TextStyle(color: AppColors.tintaLight)),
        const SizedBox(height: 8),
        Text(q.prompt, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.tinta)),
        if (q.blank) ...[
          const SizedBox(height: 4),
          Text(q.hint, style: const TextStyle(color: AppColors.mar)),
        ],
        const SizedBox(height: 8),
        Text(q.blank ? tr('빈칸에 맞는 낱말을 고르세요.') : tr('뜻으로 맞는 것을 고르세요.'), style: const TextStyle(color: AppColors.sumi)),
        const SizedBox(height: 12),
        for (var k = 0; k < q.options.length; k++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              key: ValueKey('cur-opt-$k'),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(14),
                backgroundColor: _picked == null
                    ? null
                    : k == q.answer
                        ? AppColors.matcha.withValues(alpha: 0.12)
                        : (k == _picked ? AppColors.fem.withValues(alpha: 0.12) : null),
              ),
              onPressed: _picked == null
                  ? () => setState(() {
                        _picked = k;
                        _res.add((q, k == q.answer));
                      })
                  : null,
              child: Text(q.options[k], style: const TextStyle(fontSize: 15, color: AppColors.tinta)),
            ),
          ),
        if (_picked != null)
          FilledButton(
            key: const ValueKey('cur-next'),
            onPressed: () => setState(() {
              _i++;
              _picked = null;
            }),
            child: Text(tr('다음')),
          ),
      ];
}
