import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:german_universe/screens/curriculum_screen.dart';
import 'package:german_universe/services/curriculum_service.dart';
import 'package:german_universe/services/dialogue_service.dart';

/// 토크버스 커리큘럼(CURRICULUM_SPEC §8) — 80% 경계, 간격 반복 날짜, 코스 흐름, 문제 생성, 문제 화면.
Dialogue _d(String id, String topic, int n) => Dialogue(
      id: id,
      region: 'R1',
      topic: topic,
      title: id,
      emoji: '💬',
      scene: '',
      speakers: const {'A': 'A', 'B': 'B'},
      genders: const {},
      expressions: const [],
      turns: [
        for (var i = 1; i <= n; i++)
          DialogueTurn(num: i, speaker: i.isOdd ? 'A' : 'B', tl: 'Satz$id nummer$i heute bitte', gloss: '', rd: '', ko: '$id 뜻 $i', note: '', tags: const []),
      ],
    );

void main() {
  test('점수 80% 경계 — 소수점 버림', () {
    expect(scorePercent(8, 10), 80);
    expect(isPass(8, 10), isTrue);
    expect(isPass(4, 5), isTrue);
    expect(isPass(24, 30), isTrue);
    expect(scorePercent(23, 29), 79); // 79.31 → 79
    expect(isPass(23, 29), isFalse);
    expect(isPass(7, 9), isFalse); // 77.7
    expect(isPass(0, 0), isFalse);
  });

  test('간격 반복 1 → 3 → 7일, 틀리면 1일로', () {
    final s = CurriculumState();
    final d0 = DateTime(2026, 11, 22, 21);
    s.enqueue('x#1', d0);
    expect(s.review.single.due, '2026-11-23');
    expect(s.dueReviews(d0), isEmpty);
    final d1 = DateTime(2026, 11, 23, 8);
    expect(s.dueReviews(d1).length, 1);
    s.answerReview('x#1', true, d1);
    expect(s.review.single.due, '2026-11-26');
    s.answerReview('x#1', false, DateTime(2026, 11, 26));
    expect(s.review.single.due, '2026-11-27');
    expect(s.review.single.step, 0);
    s.answerReview('x#1', true, DateTime(2026, 11, 27));
    s.answerReview('x#1', true, DateTime(2026, 11, 30));
    expect(s.review.single.due, '2026-12-07'); // 달 넘김
    s.answerReview('x#1', true, DateTime(2026, 12, 7));
    expect(s.review, isEmpty);
  });

  test('코스 — 연습·오늘 새 편·시험 미달은 틀린 편만 다시, 통과면 닫힘·저장 형식', () {
    final now = DateTime(2026, 11, 22);
    final s = CurriculumState(level: 'R1', dailyGoal: 2)..course = Course('c1', ['a', 'b']);
    expect(s.newLeft(now), 2);
    s.finishPractice('a', ['a#1', 'a#2'], {'a#2'}, now);
    s.finishPractice('a', ['a#1', 'a#2'], {}, now); // 다시 연습은 새 편 아님
    s.finishPractice('b', ['b#1'], {}, now);
    expect(s.todayNew, 2);
    expect(s.course!.allPracticed, isTrue);
    expect(s.dailyDone(now), isTrue); // 복습은 내일부터
    expect(s.streak(now), 1);
    expect(s.finishExam(7, 10, {'b'}, now), isFalse);
    expect(s.course!.practiced, ['a']);
    s.finishPractice('b', ['b#1'], {}, now);
    expect(s.todayNew, 2); // 시험 뒤 다시 연습도 새 편 아님
    expect(s.finishExam(8, 10, {}, now), isTrue);
    expect(s.course, isNull);
    expect(s.passedDialogues, ['a', 'b']);
    final j = json.decode(json.encode(s.toJson())) as Map;
    expect(j.keys, containsAll(['level', 'dailyGoal', 'course', 'passedDialogues', 'review', 'streak']));
    final back = CurriculumState.fromJson(j);
    expect(back.review.length, s.review.length);
    expect(back.streakCount, 1);
  });

  test('추천으로 채우기 — 통과한 편 빼고 주제 겹치지 않게', () {
    final ds = [_d('a', 'love', 3), _d('b', 'love', 3), _d('c', 'life', 3), _d('d', 'travel', 3)];
    final r = recommendDialogues(ds, {'c'}, [], 3);
    expect(r, ['a', 'd', 'b']);
  });

  test('문제 생성 — 보기 4개·정답 하나·편당 최대 10, 시험 편당 3 이상 30 이하', () {
    final ds = [for (var i = 0; i < 10; i++) _d('e$i', 'love', 12)];
    final qs = makeQuestions(ds.first, rnd: Random(1), pool: ds);
    expect(qs.length, kPracticeMaxQ);
    for (final q in qs) {
      expect(q.options.length, 4);
      expect(q.options.toSet().length, 4);
      expect(q.answer, inInclusiveRange(0, 3));
    }
    expect(qs.any((q) => q.blank), isTrue);
    final exam = makeExam(ds, Random(2));
    expect(exam.length, kExamMaxQ);
    for (final d in ds) {
      expect(exam.where((q) => q.dialogueId == d.id).length, greaterThanOrEqualTo(kExamMinPerDialogue));
    }
  });

  testWidgets('문제 화면 — 폭 320 넘침 없음, 끝나면 결과 돌려줌', (t) async {
    t.view.physicalSize = const Size(320, 700);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final ds = [_d('a', 'love', 6), _d('b', 'life', 6)];
    final qs = makeQuestions(ds.first, rnd: Random(3), pool: ds);
    List<(CurQuestion, bool)>? got;
    await t.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => TextButton(
          onPressed: () async => got = await Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => CurQuizScreen(title: 'T', questions: qs, exam: true))),
          child: const Text('go'),
        ),
      ),
    ));
    await t.tap(find.text('go'));
    await t.pumpAndSettle();
    for (var i = 0; i < qs.length; i++) {
      expect(t.takeException(), isNull);
      await t.tap(find.byKey(ValueKey('cur-opt-${qs[i].answer}')));
      await t.pump();
      await t.ensureVisible(find.byKey(const ValueKey('cur-next')));
      await t.tap(find.byKey(const ValueKey('cur-next')));
      await t.pump();
    }
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('통과'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('cur-done')));
    await t.pumpAndSettle();
    expect(got!.length, qs.length);
    expect(got!.every((r) => r.$2), isTrue);
  });

  testWidgets('오늘 분량 카드 — 「오늘: 복습 N · 새 편 N」', (t) async {
    final now = DateTime(2026, 11, 23);
    final s = CurriculumState(level: 'R1', dailyGoal: 3)..enqueue('a#1', DateTime(2026, 11, 22));
    await t.pumpWidget(MaterialApp(home: Scaffold(body: CurriculumTodayCard(state: s, now: now))));
    expect(find.text('오늘: 복습 1 · 새 편 3'), findsOneWidget);
  });
}
