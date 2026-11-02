import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:german_universe/services/dialogue_service.dart';
import 'package:german_universe/widgets/episode_play_pane.dart';

// UX 시안 01 칸 1·2 — 데이터가 생기면 켜지는 자리가 실제로 동작하는지(지금 회화 데이터엔 명사·말투 칸이 없다).
void main() {
  const apfel = NounInfo(word: 'Apfelkuchen', article: 'der', plural: 'die Apfelkuchen', parts: ['der Apfel', 'der Kuchen'], ko: '사과 케이크');

  testWidgets('명사 데이터가 없으면 그냥 글자', (t) async {
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: GenderText('Ist der Apfelkuchen hier gut?', nouns: [], style: TextStyle()))));
    expect(find.text('Ist der Apfelkuchen hier gut?'), findsOneWidget);
  });

  testWidgets('명사에 성 점 → 누르면 단어 시트(복수·분해)', (t) async {
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: GenderText('Ist der Apfelkuchen hier gut?', nouns: [apfel], style: TextStyle(fontSize: 16)))));
    final noun = find.descendant(of: find.byType(GenderText), matching: find.byType(GestureDetector));
    expect(noun, findsOneWidget); // 명사 하나에만 성 점·탭
    await t.tap(noun);
    await t.pumpAndSettle();
    expect(find.text('der Apfelkuchen'), findsOneWidget);
    expect(find.text('die Apfelkuchen'), findsOneWidget);
    expect(find.text('der Apfel + der Kuchen'), findsOneWidget);
  });

  test('말투는 편 처음 값에서 시작해 턴이 바꾼다', () {
    DialogueTurn turn(int n, {String? reg}) => DialogueTurn(num: n, speaker: 'A', tl: '', gloss: '', rd: '', ko: '', note: '', tags: const [], register: reg);
    final d = Dialogue(id: 'x', region: 'L1', topic: 'love', title: '', emoji: '', scene: '', speakers: const {}, genders: const {}, expressions: const [], turns: [turn(1), turn(2), turn(3, reg: 'du'), turn(4)], register: 'Sie');
    expect([for (var i = 0; i < 4; i++) d.registerAt(i)], ['Sie', 'Sie', 'du', 'du']);
  });

  testWidgets('du/Sie 배지 문구', (t) async {
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: Column(children: [RegisterBadge(register: 'du'), RegisterBadge(register: 'Sie')]))));
    expect(find.text('du · 친구 사이'), findsOneWidget);
    expect(find.text('Sie · 처음 보는 사람'), findsOneWidget);
  });
}
