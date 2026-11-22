import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:german_universe/screens/grammar_lesson_screen.dart';
import 'package:german_universe/screens/sense_course_screen.dart';
import 'package:german_universe/services/script_sync.dart';

/// 문법 스텝 1~10 — 내용은 서버 원고(있으면) → 앱에 묶은 것, 빈 스텝은 숨김(사용자 지시 2026-11-23).
String sha(String s) => sha1.convert(utf8.encode(s)).toString().substring(0, 12);

String lesson(int n, String title, {int patterns = 1}) => json.encode({
      'lesson': n,
      'title': title,
      'stages': [],
      'patterns': [
        for (var i = 0; i < patterns; i++) {'id': 'p$i', 'key': 'k', 'label': 'l', 'explanation': 'e', 'stage': 1, 'examples': []}
      ],
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  final orig = ScriptSync.instance;
  setUp(() => dir = Directory.systemTemp.createTempSync('grammar_sync'));
  tearDown(() {
    ScriptSync.instance = orig;
    SenseCourse.clearCache();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  Map<String, dynamic> bundled() => {'rev': 2, 'files': {'grammar/lesson1.json': 'old', 'grammar/lesson2.json': 'old2'}};

  test('서버를 못 받으면 묶음 목록 — 묶음 파일이 있는 스텝만', () async {
    final s = ScriptSync.forTest(dir: dir, fetch: (_) async => null, baseline: {'rev': 1, 'files': {'grammar/lesson1.json': 'x'}});
    ScriptSync.instance = s;
    expect(await s.refresh(), isFalse);
    final ls = await GrammarLesson.loadAll();
    expect(ls.map((l) => l.number), [1]);
  });

  test('서버 목록 그대로 — 스텝 1 덮어쓰기, 2 는 빠져서 안 보임, 3·15·16 은 더해져 보임(개수 고정 없음), 패턴 빈 5 는 숨김', () async {
    final files = {
      'grammar/lesson1.json': lesson(1, '서버 1'),
      'grammar/lesson3.json': lesson(3, '서버 3'),
      'grammar/lesson5.json': lesson(5, '빈 5', patterns: 0),
      'grammar/lesson15.json': lesson(15, '서버 15', patterns: 2),
      'grammar/lesson16.json': lesson(16, '서버 16'),
    };
    Future<String?> fetch(String url) async {
      if (url.endsWith('/index.json')) return json.encode({'rev': 9, 'files': {for (final e in files.entries) e.key: sha(e.value)}});
      for (final e in files.entries) {
        if (url.endsWith(e.key) || url.contains('${e.key}?')) return e.value;
      }
      return null;
    }

    final s = ScriptSync.forTest(dir: dir, fetch: fetch, baseline: bundled());
    ScriptSync.instance = s;
    expect(await s.refresh(), isTrue);
    final ls = await GrammarLesson.loadAll();
    expect(ls.map((l) => l.number), [1, 3, 15, 16]);
    expect(ls.first.title, '서버 1');
    expect(ls[2].patterns.length, 2);
  });

  test('언어감각 — 급 목록은 파일에서, 회차가 빈 급은 숨김', () async {
    const sense = 'grammar/sense_course.json';
    final body = json.encode({
      'title': 't',
      'levels': [
        {'id': 'L1', 'title': '하나', 'lessons': [{'id': 'L1-talk'}]},
        {'id': 'L2', 'title': '빈 급', 'lessons': []},
        {'id': 'L3', 'title': '셋', 'lessons': [{'id': 'L3-talk'}]},
      ],
    });
    Future<String?> fetch(String url) async {
      if (url.endsWith('/index.json')) return json.encode({'rev': 9, 'files': {sense: sha(body)}});
      return url.contains(sense) ? body : null;
    }

    final s = ScriptSync.forTest(dir: dir, fetch: fetch, baseline: {'rev': 2, 'files': {sense: 'old'}});
    ScriptSync.instance = s;
    expect(await s.refresh(), isTrue);
    SenseCourse.clearCache();
    final d = await SenseCourse.load();
    expect([for (final l in d['levels'] as List) l['id']], ['L1', 'L3']);
  });
}
