import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/cliff.dart';
import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/art_service.dart';
import '../services/content_sync.dart';
import '../services/ko_reading.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';
import '../widgets/episode_play_pane.dart' show articleColor;

/// 절벽 단어 — 빈도순 단어를 절벽구간(R1~R5)별 **20어 단원**으로, 단어는 **네모 타일**로 보여 준다(일본어앱 2026-11-07 개편).
/// 위 버튼 「절벽구간 단어만 / 회화 단어 포함」 — 포함이면 회화에 나오지만 2,000위 밖인 단어(assets/data/freq/conv_words_de.json)가
/// 「회화」 구간으로 뒤에 붙는다. 단어장·회화 목록은 화면에서만 합친다.
class WordFreqScreen extends StatefulWidget {
  const WordFreqScreen({super.key});

  @override
  State<WordFreqScreen> createState() => _WordFreqScreenState();
}

class _WordFreqScreenState extends State<WordFreqScreen> {
  List<_Word> _words = const [];
  List<_Word> _conv = const [];
  bool _loading = true;
  bool _withConv = false;
  String _filter = 'ALL';
  String _query = '';

  static const _colors = {
    'R1': AppColors.beni,
    'R2': AppColors.beniLight,
    'R3': AppColors.kinDeep,
    'R4': AppColors.matcha,
    'R5': AppColors.muted,
    'C': AppColors.ai,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await WordService.instance.ensureLoaded();
    final words = [
      for (final e in WordService.instance.ranked)
        if (e.rank <= kWordCap) _Word(e.rank, e.word, e.reading, e.ko, e.article, e.level),
    ];
    final conv = <_Word>[];
    try {
      final j = json.decode(await rootBundle.loadString('assets/data/freq/conv_words_de.json')) as Map<String, dynamic>;
      var n = 0;
      for (final w in (j['words'] as List).cast<Map<String, dynamic>>()) {
        n++;
        final word = w['word'] as String;
        conv.add(_Word(n, word, '${w['rd'] ?? ''}', '${w['ko'] ?? ''}', WordService.instance.lookup(word)?.article ?? '', 'C'));
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _words = words;
      _conv = conv;
      _loading = false;
    });
  }

  /// 구간 칩 이름 — 순위 범위는 단어표에서 잰다(단어표가 늘면 저절로 바뀐다).
  String _chip(String key) {
    if (key == 'ALL') return tr('전체');
    if (key == 'C') return tr('회화');
    final r = _words.where((w) => w.level == key);
    return r.isEmpty ? key : '$key · ${r.first.rank}-${r.last.rank}';
  }

  @override
  Widget build(BuildContext context) {
    final pool = _withConv ? [..._words, ..._conv] : _words;
    final q = _query.trim().toLowerCase();
    final shown = pool.where((w) {
      if (_filter != 'ALL' && w.level != _filter) return false;
      return q.isEmpty || w.word.toLowerCase().contains(q) || w.ko.contains(q) || w.reading.contains(q);
    }).toList();
    final units = <List<_Word>>[
      for (var i = 0; i < shown.length; i += kWordUnit) shown.sublist(i, (i + kWordUnit).clamp(0, shown.length)),
    ];
    final keys = ['ALL', 'R1', 'R2', 'R3', 'R4', 'R5', if (_withConv) 'C'];
    final top = _words.isEmpty ? 0 : _words.last.rank;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(tr('절벽 단어'), style: const TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(trf('회화 빈도 {0}위 · {1}어 단원 · 탭하면 발음', [top, kWordUnit]), style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 1)),
        ]),
        actions: const [KoReadingToggleAction()],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : Column(children: [
              Container(
                color: AppColors.washiDeep,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Column(children: [
                  Row(children: [
                    _ModeButton(
                        label: tr('절벽구간 단어만'),
                        selected: !_withConv,
                        onTap: () => setState(() {
                              _withConv = false;
                              if (_filter == 'C') _filter = 'ALL';
                            })),
                    const SizedBox(width: 8),
                    _ModeButton(label: trf('회화 단어 포함 (+{0})', [_conv.length]), selected: _withConv, onTap: () => setState(() => _withConv = true)),
                  ]),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    child: ListView(scrollDirection: Axis.horizontal, children: [
                      for (final k in keys)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _filter = k),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _filter == k ? (_colors[k] ?? AppColors.sumi) : AppColors.washi,
                                border: Border.all(color: _colors[k] ?? AppColors.sumi, width: _filter == k ? 1.5 : 0.8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(_chip(k), style: TextStyle(color: _filter == k ? AppColors.washi : (_colors[k] ?? AppColors.sumi), fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                          ),
                        ),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: tr('단어 / 뜻 검색'),
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 16 + bottomInset(context)),
                  itemCount: units.length,
                  itemBuilder: (context, i) => _UnitBlock(index: i + 1, words: units[i], color: _colors[units[i].first.level] ?? AppColors.sumi),
                ),
              ),
            ]),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.sumi : AppColors.washi,
              border: Border.all(color: selected ? AppColors.sumi : AppColors.line),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(label, style: TextStyle(color: selected ? AppColors.washi : AppColors.sumi, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ),
      );
}

/// 한 단원 = 20어. 머리줄(단원 번호·순위 범위·구간) + 네모 타일 격자. 칸 수 = 내 칸 너비 ÷ 112(3~8칸).
class _UnitBlock extends StatelessWidget {
  final int index;
  final List<_Word> words;
  final Color color;
  const _UnitBlock({required this.index, required this.words, required this.color});

  @override
  Widget build(BuildContext context) {
    final first = words.first;
    final conv = first.level == 'C';
    final range = conv ? trf('회화 {0}-{1}', [first.rank, words.last.rank]) : '#${first.rank}-${words.last.rank}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 6, 2, 6),
          child: Row(children: [
            Text(trf('{0}단원', [index]), style: const TextStyle(color: AppColors.sumi, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Text(range, style: const TextStyle(color: AppColors.sumiLight, fontSize: 11)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              child: Text(conv ? tr('회화') : first.level, style: const TextStyle(color: AppColors.washi, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
        LayoutBuilder(builder: (context, c) {
          final cols = (c.maxWidth / 112).floor().clamp(3, 8);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 6, crossAxisSpacing: 6),
            itemCount: words.length,
            itemBuilder: (context, i) => _WordTile(w: words[i], color: color),
          );
        }),
      ]),
    );
  }
}

/// 네모 타일 — 순위·독음 · 그림(있으면) · 관사+단어 · 뜻 한 줄. 탭하면 발음.
class _WordTile extends StatelessWidget {
  final _Word w;
  final Color color;
  const _WordTile({required this.w, required this.color});

  @override
  Widget build(BuildContext context) {
    final conv = w.level == 'C';
    return InkWell(
      onTap: () => TtsService.instance.speak(w.article.isEmpty ? w.word : '${w.article} ${w.word}'),
      child: Container(
        decoration: BoxDecoration(color: AppColors.washi, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(8), boxShadow: kCardShadow),
        padding: const EdgeInsets.all(6),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(children: [
              Text(conv ? tr('회화') : '#${w.rank}', style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w800)),
              const SizedBox(width: 4),
              Expanded(child: KoReadingText(w.reading, textAlign: TextAlign.right, style: const TextStyle(fontSize: 9, color: AppColors.sumiLight))),
            ]),
            Expanded(child: _WordArt(word: w.word, rank: conv ? null : w.rank)),
            if (w.article.isNotEmpty) Text(w.article, style: TextStyle(fontSize: 9, height: 1.1, fontWeight: FontWeight.w800, color: articleColor(w.article))),
            FittedBox(fit: BoxFit.scaleDown, child: Text(w.word, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.sumi))),
            if (w.ko.isNotEmpty) Text(w.ko, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.sumiLight)),
        ]),
      ),
    );
  }
}

/// 단어 그림 — 있으면 그리고, 없으면 빈 칸.
class _WordArt extends StatefulWidget {
  final String word;
  final int? rank;
  const _WordArt({required this.word, this.rank});
  @override
  State<_WordArt> createState() => _WordArtState();
}

class _WordArtState extends State<_WordArt> {
  late final Future<String?> _url = ArtService.instance.urlFor(widget.word, rank: widget.rank);
  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
        future: _url,
        builder: (context, snap) => snap.data == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Image(image: artProvider(snap.data!), fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox.shrink()),
              ),
      );
}

class _Word {
  final int rank;
  final String word, reading, ko, article, level; // level: R1~R5 · C(회화 단어)
  const _Word(this.rank, this.word, this.reading, this.ko, this.article, this.level);
}
