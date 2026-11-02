import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'learner_prefs.dart';

/// 회화 리더(일본어앱 시안 02 「만화책 읽기형」)용 회화 모델 — 2026-11-02, 일본어앱 `dialogue_service.dart` 를 옮김.
///
/// 지금 데이터는 옛 `assets/data/dialogues/L1.json`(5편 × 8턴, 공용 키트 초안) 하나뿐이라 그것을 그대로 읽어 이 모양으로 바꾼다.
/// 회화 콘텐츠는 바꾸지 않는다(사용자 지시 2026-11-02 "회화는 아직 하지마") — 새 구조(R0~R4·주제별 편 파일)는 회화 작성이 풀리면.
/// 칸: tl = 독일어(옛 칸 이름 `es`), gloss = 문법 메모의 표제어 쪽(`du = 너(반말)` → `du`), rd = 한글 독음, ko = 한국어.
class DialogueTurn {
  final int num;
  final String speaker; // A·B
  final String tl;
  final String gloss;
  final String rd;
  final String ko;
  final String note;
  final List<String> tags;
  final String? art; // 장면 그림 URL(나중에 채움)
  final List<NounInfo> nouns; // 성 점·단어 시트(UX 시안 01 칸 1) — 데이터가 생기면 켜진다
  final String? register; // 이 턴부터 바뀌는 말투 du | Sie(UX 시안 01 칸 2)
  const DialogueTurn({
    required this.num,
    required this.speaker,
    required this.tl,
    required this.gloss,
    required this.rd,
    required this.ko,
    required this.note,
    required this.tags,
    this.art,
    this.nouns = const [],
    this.register,
  });

  factory DialogueTurn.fromL1(Map<String, dynamic> j) => DialogueTurn(
        num: j['num'] as int? ?? 0,
        speaker: j['speaker'] as String? ?? 'A',
        tl: j['es'] as String? ?? '',
        gloss: j['gloss'] as String? ?? j['note'] as String? ?? '', // 옛 데이터는 단어 뜻이 문법 메모(`du = 너(반말)`)에 있다
        rd: j['rd'] as String? ?? '',
        ko: j['ko'] as String? ?? '',
        note: j['note'] as String? ?? '',
        tags: (j['tags'] as List?)?.cast<String>() ?? const [],
        art: j['art'] as String?,
        nouns: [for (final n in (j['nouns'] as List? ?? const [])) NounInfo.fromJson(n as Map<String, dynamic>)],
        register: j['register'] as String?,
      );

  /// 그림 조회용 핵심 단어 후보: 문법 메모의 표제어(`Wort = 뜻` 의 왼쪽 낱말들).
  List<String> get pictureWords {
    final head = note.split('=').first;
    if (!note.contains('=')) return const [];
    return [for (final m in RegExp(r"[\p{L}]{2,}", unicode: true).allMatches(head)) m.group(0)!];
  }
}

/// 명사 한 개 — 성(der/die/das)·복수·복합어 분해·뜻. 턴의 `nouns: [{w, art, pl, parts, ko}]`.
class NounInfo {
  final String word; // 문장에 나온 꼴(Kaffee)
  final String article; // der | die | das
  final String plural; // die Kaffees (없으면 빈 값)
  final List<String> parts; // 복합명사 분해: ['der Apfel', 'der Kuchen']
  final String ko;
  const NounInfo({required this.word, required this.article, this.plural = '', this.parts = const [], this.ko = ''});

  factory NounInfo.fromJson(Map<String, dynamic> j) => NounInfo(
        word: j['w'] as String? ?? '',
        article: j['art'] as String? ?? '',
        plural: j['pl'] as String? ?? '',
        parts: (j['parts'] as List?)?.cast<String>() ?? const [],
        ko: j['ko'] as String? ?? '',
      );
}

class Dialogue {
  final String id;
  final String region; // 지금은 옛 레벨 이름(L1) 그대로 — R 재태그는 회화 작업 때
  final String topic; // 주제
  final String title;
  final String emoji;
  final String scene;
  final Map<String, String> speakers;
  final Map<String, String> genders;
  final List<String> expressions;
  final List<DialogueTurn> turns;
  final String? art;
  final String? register; // 편 처음 말투 du | Sie — 없으면 배지 없음
  const Dialogue({
    required this.id,
    required this.region,
    required this.topic,
    required this.title,
    required this.emoji,
    required this.scene,
    required this.speakers,
    required this.genders,
    required this.expressions,
    required this.turns,
    this.art,
    this.register,
  });

  /// i 번째 턴(0부터)에서의 말투 — 편 처음 값에서 시작해 턴의 register 가 바꾼다.
  String? registerAt(int i) {
    var r = register;
    for (var k = 0; k <= i && k < turns.length; k++) {
      r = turns[k].register ?? r;
    }
    return r;
  }

  /// 화자 표시 이름. `{name}` 자리는 학습자 이름(없으면 「나」).
  String speakerName(String sp) {
    final raw = speakers[sp] ?? sp;
    if (raw.contains('{name}')) return LearnerPrefs.name.value.isNotEmpty ? LearnerPrefs.name.value : '나';
    return raw.replaceAll(RegExp(r'[{}]'), '');
  }

  /// 목소리 성별 — 지금 회화는 화자 이름·성별이 정해진 이야기(A 민준 남 · B 레나 여)라 데이터의 성별을 따른다.
  String voiceGender(String sp) => genders[sp] ?? LearnerPrefs.voiceGender(sp);
}

class DialogueService {
  DialogueService._();
  static final DialogueService instance = DialogueService._();

  static const topics = ['survival', 'friends', 'love', 'life', 'travel', 'culture', 'work', 'study'];
  static const topicKo = {
    'survival': '서바이벌',
    'friends': '친구',
    'love': '사랑',
    'life': '생활',
    'travel': '여행',
    'culture': '문화',
    'work': '일',
    'study': '학업',
  };
  static const topicEmoji = {
    'survival': '🆘',
    'friends': '🤝',
    'love': '💘',
    'life': '🏠',
    'travel': '✈️',
    'culture': '🎬',
    'work': '💼',
    'study': '🎓',
  };
  static const levelKo = {'L1': '이야기', 'R0': '왕초보', 'R1': '초보', 'R2': '중급', 'R3': '고급', 'R4': '최상급'};
  static const _prefLast = 'dialogue_last';

  final List<Dialogue> _all = [];
  String? _lastOpened;
  String? get lastOpenedId => _lastOpened;
  Future<void> setLastOpened(String id) async {
    _lastOpened = id;
    (await SharedPreferences.getInstance()).setString(_prefLast, id);
  }

  /// 넓은 화면에서 탭 두 개가 동시에 불러도 한 번만 읽는다(플래그 방식은 경쟁으로 목록이 두 번 찼다).
  Future<void>? _loading;
  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    _lastOpened = (await SharedPreferences.getInstance()).getString(_prefLast);
    try {
      final j = json.decode(await rootBundle.loadString('assets/data/dialogues/L1.json')) as Map<String, dynamic>;
      final chars = (j['characters'] as Map<String, dynamic>? ?? const {});
      final names = chars.map((k, v) => MapEntry(k, ((v as Map)['name'] ?? k).toString()));
      final genders = chars.map((k, v) => MapEntry(k, ((v as Map)['gender'] ?? 'female').toString()));
      final level = j['level'] as String? ?? 'L1';
      for (final e in (j['episodes'] as List? ?? const [])) {
        final m = e as Map<String, dynamic>;
        final turns = ((m['turns'] as List?) ?? const []).map((t) => DialogueTurn.fromL1(t as Map<String, dynamic>)).toList();
        if (turns.isEmpty) continue;
        _all.add(Dialogue(
          id: '${level}_${m['id']}',
          region: level,
          topic: 'love', // 옛 L1 = 언어교환 앱에서 시작하는 이야기(원칙: 기존 연애 서사는 love 주제)
          title: m['title'] as String? ?? m['id'] as String,
          emoji: m['emoji'] as String? ?? '💬',
          scene: m['scenario'] as String? ?? '',
          speakers: names,
          genders: genders,
          expressions: const [],
          turns: turns,
          register: m['register'] as String?,
        ));
      }
    } catch (_) {}
  }

  Dialogue? byId(String id) => _all.where((d) => d.id == id).firstOrNull;
  List<Dialogue> get all => List.unmodifiable(_all);
  List<String> get regions => _all.map((d) => d.region).toSet().toList();

  List<Dialogue> list({String? region, String? topic}) =>
      _all.where((d) => (region == null || d.region == region) && (topic == null || d.topic == topic)).toList();

  List<String> topicsOf(String region) {
    final has = _all.where((d) => d.region == region).map((d) => d.topic).toSet();
    return topics.where(has.contains).toList();
  }

  int count(String region) => _all.where((d) => d.region == region).length;
}
