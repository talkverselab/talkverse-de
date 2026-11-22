import 'dart:math';

import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/prefs.dart';
import '../core/theme.dart';
import '../services/ko_reading.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';

/// 단어 복습 퀴즈 — 4지선다(일본어앱 `gairaigo_quiz_screen.dart` 이식, 2026-11-22).
/// 두 꼴: 독일어 → 뜻 고르기, 뜻 → 독일어 고르기. 한 판 10문제. 틀린 단어는 다음 판에 먼저 나온다(Prefs `word_quiz_wrong`).
/// 단어 = 단어장(`WordService` — 절벽 단어 CSV + 여행 단어). 독음은 전역 한글독음 토글을 따른다.
const int kWordQuizSize = 10;
const String _kWrong = 'word_quiz_wrong';

/// 문제에 보일 꼴 — 명사는 관사를 붙인다(der Tisch).
String quizShown(WordEntry w) => w.article.isEmpty ? w.word : '${w.article} ${w.word}';

class _Q {
  final WordEntry w;
  final bool toKo; // true = 독일어 → 뜻, false = 뜻 → 독일어
  final List<WordEntry> options;
  const _Q(this.w, this.toKo, this.options);
}

class WordQuizScreen extends StatefulWidget {
  /// 비우면 단어장 전체에서 뽑는다(시험은 직접 넘긴다).
  final List<WordEntry>? words;
  final int? seed;
  const WordQuizScreen({super.key, this.words, this.seed});
  @override
  State<WordQuizScreen> createState() => _WordQuizScreenState();
}

class _WordQuizScreenState extends State<WordQuizScreen> {
  late final _rnd = Random(widget.seed);
  List<_Q>? _qs;
  int _i = 0;
  WordEntry? _picked;
  int _right = 0;
  final List<WordEntry> _missed = [];

  @override
  void initState() {
    super.initState();
    _build();
  }

  static String _id(WordEntry w) => w.word.toLowerCase();

  Future<void> _build() async {
    var words = widget.words;
    if (words == null) {
      await WordService.instance.ensureLoaded();
      words = WordService.instance.all;
    }
    final p = await Prefs.getInstance();
    final wrong = (p.getStringList(_kWrong) ?? const []).toSet();
    final uniq = <String, WordEntry>{for (final w in words) if (w.ko.trim().isNotEmpty) _id(w): w}.values.toList()..shuffle(_rnd);
    uniq.sort((a, b) => (wrong.contains(_id(b)) ? 1 : 0) - (wrong.contains(_id(a)) ? 1 : 0));
    final picked = uniq.take(kWordQuizSize).toList()..shuffle(_rnd);
    final qs = <_Q>[];
    for (var k = 0; k < picked.length; k++) {
      final w = picked[k];
      final toKo = k.isEven;
      // 틀린 보기 — 뜻(또는 낱말)이 겹치지 않는 다른 단어 셋. 같은 품사를 먼저 쓴다.
      final seen = {toKo ? w.ko : _id(w)};
      final others = <WordEntry>[];
      bool same(WordEntry o) => w.pos.isNotEmpty && o.pos == w.pos;
      final samePos = uniq.where((o) => !identical(o, w) && same(o)).toList()..shuffle(_rnd);
      final rest = uniq.where((o) => !identical(o, w) && !same(o)).toList()..shuffle(_rnd);
      for (final o in [...samePos, ...rest]) {
        if (others.length == 3) break;
        final key = toKo ? o.ko : _id(o);
        if (seen.add(key)) others.add(o);
      }
      qs.add(_Q(w, toKo, [w, ...others]..shuffle(_rnd)));
    }
    if (mounted) setState(() => _qs = qs);
  }

  Future<void> _record(WordEntry w, bool ok) async {
    final p = await Prefs.getInstance();
    final s = (p.getStringList(_kWrong) ?? const []).toSet();
    ok ? s.remove(_id(w)) : s.add(_id(w));
    await p.setStringList(_kWrong, s.toList());
  }

  void _again() => setState(() {
        _qs = null;
        _i = 0;
        _picked = null;
        _right = 0;
        _missed.clear();
        _build();
      });

  @override
  Widget build(BuildContext context) {
    final qs = _qs;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(title: Text(tr('단어 복습 퀴즈')), actions: const [KoReadingToggleAction()]),
      body: qs == null
          ? const Center(child: CircularProgressIndicator())
          : qs.isEmpty
              ? Center(child: Text(tr('단어를 불러오지 못했어요')))
              : _i >= qs.length
                  ? _summary(qs.length)
                  : _question(qs[_i], qs.length),
    );
  }

  Widget _summary(int n) => Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset(context)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🎉', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 10),
            Text(trf('{0}문제 중 {1}개 맞힘', [n, _right]), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.sumi)),
            if (_missed.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(tr('틀린 단어 — 다음 복습에 먼저 나와요'), style: const TextStyle(fontSize: 12, color: AppColors.sumiLight)),
              const SizedBox(height: 6),
              for (final w in _missed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('${quizShown(w)}  ·  ${w.ko}',
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.sumi)),
                ),
            ],
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              OutlinedButton(key: const ValueKey('wq-again'), onPressed: _again, child: Text(tr('한 번 더'))),
              const SizedBox(width: 10),
              FilledButton(onPressed: () => Navigator.of(context).maybePop(), style: FilledButton.styleFrom(backgroundColor: AppColors.sumi), child: Text(tr('나가기'))),
            ]),
          ]),
        ),
      );

  Widget _question(_Q q, int n) {
    final w = q.w;
    const readingStyle = TextStyle(fontSize: 13, color: AppColors.sumiLight);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset(context)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('${tr(q.toKo ? '뜻' : '독일어')} · ${_i + 1} / $n', style: const TextStyle(fontSize: 12, color: AppColors.sumiLight)),
        const SizedBox(height: 14),
        Text(
          q.toKo ? quizShown(w) : w.ko,
          key: const ValueKey('wq-stem'),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.sumi),
        ),
        if (q.toKo && w.reading.isNotEmpty) KoReadingText(w.reading, style: readingStyle),
        const SizedBox(height: 8),
        Text(tr(q.toKo ? '뜻으로 맞는 것을 고르세요.' : '독일어로 맞는 것을 고르세요.'), style: const TextStyle(fontSize: 14, color: AppColors.sumi)),
        const SizedBox(height: 14),
        for (var k = 0; k < q.options.length; k++) _option(q, k, readingStyle),
        if (_picked != null)
          FilledButton(
            key: const ValueKey('wq-next'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.sumi, minimumSize: const Size.fromHeight(48)),
            onPressed: () => setState(() {
              _i++;
              _picked = null;
            }),
            child: Text(tr('다음 →')),
          ),
      ]),
    );
  }

  Widget _option(_Q q, int k, TextStyle readingStyle) {
    final o = q.options[k];
    final isAnswer = identical(o, q.w);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        key: ValueKey('wq-opt-$k'),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          backgroundColor: _picked == null ? null : (isAnswer ? const Color(0x3336A35B) : (identical(o, _picked) ? const Color(0x33D83A3A) : null)),
          side: BorderSide(color: _picked != null && isAnswer ? AppColors.matcha : AppColors.line, width: 1.4),
        ),
        onPressed: _picked != null
            ? null
            : () {
                final ok = isAnswer;
                TtsService.instance.speak(q.w.word);
                _record(q.w, ok);
                setState(() {
                  _picked = o;
                  ok ? _right++ : _missed.add(q.w);
                });
              },
        child: Row(children: [
          SizedBox(width: 26, child: Text('${k + 1}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.sumiLight))),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(q.toKo ? o.ko : quizShown(o), style: TextStyle(fontSize: q.toKo ? 16 : 19, fontWeight: FontWeight.w800, color: AppColors.sumi)),
              if (!q.toKo && o.reading.isNotEmpty) KoReadingText(o.reading, style: readingStyle),
            ]),
          ),
        ]),
      ),
    );
  }
}
