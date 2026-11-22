import 'dart:convert';
import 'dart:math';

import '../core/prefs.dart';
import 'dialogue_service.dart';

/// 토크버스 커리큘럼 — 전 언어 공통 기준 `~/talkverse/CURRICULUM_SPEC.md`(uk, 2026-11-22).
/// 회화 레벨(R0~R5)에서 다이얼로그를 3·5·10편 골라 코스로 묶고, 편마다 연습 → 확인 문제, 틀린 것·연습한 줄은 간격 반복(1·3·7일),
/// 코스 시험 80% 이상이면 통과. 하루 목표 = 새 편 1·2·3 + 복습.
/// 저장 = 기기(Prefs 키 `curriculum_v1`, 형식은 문서 §7 — 서버 동기화는 나중에 uk 가 붙인다). `today` 칸은 하루 분량 집계용으로 더한 것.
const String kCurriculumKey = 'curriculum_v1';
const List<int> kCourseSizes = [3, 5, 10];
const List<int> kReviewDays = [1, 3, 7];
const int kPassPercent = 80;
const int kPracticeMaxQ = 10;
const int kExamMinPerDialogue = 3;
const int kExamMaxQ = 30;
const int kReviewSessionMax = 20;

/// 점수 = 정답 수 / 문제 수, 소수점 버림(문서 §5).
int scorePercent(int right, int total) => total <= 0 ? 0 : (right * 100) ~/ total;
bool isPass(int right, int total) => scorePercent(right, total) >= kPassPercent;

String dayKey(DateTime t) => '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);
String addDays(DateTime today, int n) => dayKey(_day(today).add(Duration(days: n)));

/// 하루 목표: 1 가볍게 · 2 보통 · 3 집중(새 편 수).
const Map<int, String> kDailyGoalKo = {1: '가볍게', 2: '보통', 3: '집중'};

class ReviewItem {
  final String lineId; // `<다이얼로그 id>#<줄 번호>`
  String due; // yyyy-mm-dd
  int step; // 0..2 = kReviewDays 의 자리
  ReviewItem(this.lineId, this.due, this.step);
  Map<String, dynamic> toJson() => {'lineId': lineId, 'due': due, 'step': step};
  factory ReviewItem.fromJson(Map j) => ReviewItem('${j['lineId']}', '${j['due']}', (j['step'] as num?)?.toInt() ?? 0);
}

class Course {
  final String id;
  final List<String> dialogueIds;
  final List<String> practiced;
  final List<int> examScores;
  String? passedAt;
  Course(this.id, this.dialogueIds, {List<String>? practiced, List<int>? examScores, this.passedAt})
      : practiced = practiced ?? [],
        examScores = examScores ?? [];
  bool get allPracticed => dialogueIds.every(practiced.contains);
  Map<String, dynamic> toJson() => {'id': id, 'dialogueIds': dialogueIds, 'practiced': practiced, 'examScores': examScores, 'passedAt': passedAt};
  factory Course.fromJson(Map j) => Course(
        '${j['id']}',
        [for (final d in (j['dialogueIds'] as List? ?? const [])) '$d'],
        practiced: [for (final d in (j['practiced'] as List? ?? const [])) '$d'],
        examScores: [for (final s in (j['examScores'] as List? ?? const [])) (s as num).toInt()],
        passedAt: j['passedAt'] as String?,
      );
}

/// 저장 형식 그대로의 상태 + 규칙(순수 계산 — 날짜는 밖에서 넘긴다, 시험용).
class CurriculumState {
  String? level;
  int dailyGoal;
  Course? course;
  final List<String> passedDialogues;
  final List<ReviewItem> review;
  int streakCount;
  String? streakLastDay;
  String? todayDay;
  int todayNew;
  int todayReview;

  CurriculumState({
    this.level,
    this.dailyGoal = 2,
    this.course,
    List<String>? passedDialogues,
    List<ReviewItem>? review,
    this.streakCount = 0,
    this.streakLastDay,
    this.todayDay,
    this.todayNew = 0,
    this.todayReview = 0,
  })  : passedDialogues = passedDialogues ?? [],
        review = review ?? [];

  Map<String, dynamic> toJson() => {
        'level': level,
        'dailyGoal': dailyGoal,
        'course': course?.toJson(),
        'passedDialogues': passedDialogues,
        'review': [for (final r in review) r.toJson()],
        'streak': {'count': streakCount, 'lastDay': streakLastDay},
        'today': {'day': todayDay, 'new': todayNew, 'review': todayReview},
      };

  factory CurriculumState.fromJson(Map j) {
    final s = (j['streak'] as Map?) ?? const {};
    final t = (j['today'] as Map?) ?? const {};
    return CurriculumState(
      level: j['level'] as String?,
      dailyGoal: ((j['dailyGoal'] as num?)?.toInt() ?? 2).clamp(1, 3),
      course: j['course'] is Map ? Course.fromJson(j['course'] as Map) : null,
      passedDialogues: [for (final d in (j['passedDialogues'] as List? ?? const [])) '$d'],
      review: [for (final r in (j['review'] as List? ?? const [])) if (r is Map) ReviewItem.fromJson(r)],
      streakCount: (s['count'] as num?)?.toInt() ?? 0,
      streakLastDay: s['lastDay'] as String?,
      todayDay: t['day'] as String?,
      todayNew: (t['new'] as num?)?.toInt() ?? 0,
      todayReview: (t['review'] as num?)?.toInt() ?? 0,
    );
  }

  void _rollDay(DateTime now) {
    final k = dayKey(now);
    if (todayDay != k) {
      todayDay = k;
      todayNew = 0;
      todayReview = 0;
    }
  }

  List<ReviewItem> dueReviews(DateTime now) {
    final k = dayKey(now);
    return review.where((r) => r.due.compareTo(k) <= 0).toList()..sort((a, b) => a.due.compareTo(b.due));
  }

  int newLeft(DateTime now) {
    _rollDay(now);
    return max(0, dailyGoal - todayNew);
  }

  bool dailyDone(DateTime now) => newLeft(now) == 0 && dueReviews(now).isEmpty;

  /// 줄을 복습 대기열에 넣는다(이미 있으면 그대로 — 틀렸으면 1일 뒤로 당긴다).
  void enqueue(String lineId, DateTime now, {bool wrong = false}) {
    final have = review.where((r) => r.lineId == lineId).firstOrNull;
    if (have == null) {
      review.add(ReviewItem(lineId, addDays(now, kReviewDays[0]), 0));
    } else if (wrong) {
      have
        ..step = 0
        ..due = addDays(now, kReviewDays[0]);
    }
  }

  /// 복습 답 — 맞히면 다음 간격(1→3→7일, 7일 단계를 맞히면 대기열에서 뺌), 틀리면 1일로.
  void answerReview(String lineId, bool right, DateTime now) {
    _rollDay(now);
    final r = review.where((x) => x.lineId == lineId).firstOrNull;
    if (r == null) return;
    todayReview++;
    if (!right) {
      r
        ..step = 0
        ..due = addDays(now, kReviewDays[0]);
    } else if (r.step + 1 >= kReviewDays.length) {
      review.remove(r);
    } else {
      r.step++;
      r.due = addDays(now, kReviewDays[r.step]);
    }
    _touchStreak(now);
  }

  /// 편 연습 끝 — 줄을 대기열에 넣고, 틀린 줄은 1일 뒤. 처음 연습한 편이면 오늘 새 편 +1.
  void finishPractice(String dialogueId, List<String> lineIds, Set<String> wrongLineIds, DateTime now) {
    _rollDay(now);
    final c = course;
    // 새 편 = 통과한 적 없고, 이 코스에서 아직 연습 안 했고, 시험 전(시험에 떨어져 다시 하는 연습은 새 편이 아님)
    final isNew = !passedDialogues.contains(dialogueId) && !(c?.practiced.contains(dialogueId) ?? false) && (c?.examScores.isEmpty ?? true);
    if (c != null && !c.practiced.contains(dialogueId)) c.practiced.add(dialogueId);
    if (isNew) todayNew++;
    for (final l in lineIds) {
      enqueue(l, now, wrong: wrongLineIds.contains(l));
    }
    _touchStreak(now);
  }

  /// 코스 시험 결과. 통과면 코스를 닫고 편을 통과 목록에 넣는다. 아니면 틀린 편의 연습 표시를 지워 다시 연습하게 한다.
  bool finishExam(int right, int total, Set<String> wrongDialogues, DateTime now) {
    final c = course;
    if (c == null) return false;
    final pct = scorePercent(right, total);
    c.examScores.add(pct);
    if (pct >= kPassPercent) {
      c.passedAt = dayKey(now);
      for (final d in c.dialogueIds) {
        if (!passedDialogues.contains(d)) passedDialogues.add(d);
      }
      course = null;
      return true;
    }
    c.practiced.removeWhere(wrongDialogues.contains);
    return false;
  }

  void _touchStreak(DateTime now) {
    if (!dailyDone(now)) return;
    final k = dayKey(now);
    if (streakLastDay == k) return;
    streakCount = streakLastDay == addDays(now, -1) ? streakCount + 1 : 1;
    streakLastDay = k;
  }

  /// 연속 일수(어제·오늘 끊기지 않았을 때만).
  int streak(DateTime now) => (streakLastDay == dayKey(now) || streakLastDay == addDays(now, -1)) ? streakCount : 0;
}

/// 「추천으로 채우기」 — 아직 통과 안 한 편에서 주제가 겹치지 않게 돌아가며 고른다(이미 고른 편은 그대로 두고 채움).
List<String> recommendDialogues(List<Dialogue> levelDialogues, Set<String> passed, List<String> already, int size) {
  final out = [...already];
  final pool = levelDialogues.where((d) => !passed.contains(d.id) && !out.contains(d.id)).toList();
  final used = {for (final id in out) levelDialogues.where((d) => d.id == id).firstOrNull?.topic};
  while (out.length < size && pool.isNotEmpty) {
    final pick = pool.where((d) => !used.contains(d.topic)).firstOrNull ?? pool.first;
    out.add(pick.id);
    used.add(pick.topic);
    pool.remove(pick);
    if (pool.every((d) => used.contains(d.topic))) used.clear();
  }
  // 남은 새 편이 모자라면 통과한 편으로 채운다
  for (final d in levelDialogues) {
    if (out.length >= size) break;
    if (!out.contains(d.id)) out.add(d.id);
  }
  return out;
}

/// 확인 문제 한 개 — 뜻 고르기(독일어 → 한국어) 또는 빈칸 낱말 고르기.
class CurQuestion {
  final String lineId;
  final String dialogueId;
  final String prompt; // 보여 줄 문장(빈칸이면 ____ 이 들어감)
  final String hint; // 빈칸 문제의 뜻(한국어)
  final bool blank;
  final List<String> options;
  final int answer;
  const CurQuestion(this.lineId, this.dialogueId, this.prompt, this.hint, this.blank, this.options, this.answer);
}

String lineIdOf(Dialogue d, DialogueTurn t) => '${d.id}#${t.num}';

final _wordRe = RegExp(r"[\p{L}][\p{L}'’-]*", unicode: true);

/// 그 편 줄로 문제를 만든다(줄 수만큼, 최대 [maxQ]). 보기는 같은 편 → 다른 편([pool]) 순으로 채운다.
List<CurQuestion> makeQuestions(Dialogue d, {required Random rnd, int maxQ = kPracticeMaxQ, List<Dialogue> pool = const [], Iterable<int>? onlyNums}) {
  final turns = d.turns.where((t) => t.tl.trim().isNotEmpty && t.ko.trim().isNotEmpty && (onlyNums == null || onlyNums.contains(t.num))).toList()..shuffle(rnd);
  final allKo = <String>{for (final t in d.turns) t.ko.trim(), for (final o in pool) for (final t in o.turns) t.ko.trim()}..removeWhere((s) => s.isEmpty);
  final allWords = <String>{
    for (final t in [...d.turns, for (final o in pool) ...o.turns])
      for (final m in _wordRe.allMatches(t.tl)) if (m.group(0)!.length >= 4) m.group(0)!,
  };
  final out = <CurQuestion>[];
  for (final t in turns.take(maxQ)) {
    final i = out.length;
    final words = [for (final m in _wordRe.allMatches(t.tl)) if (m.group(0)!.length >= 4) m];
    final useBlank = i.isOdd && words.isNotEmpty;
    if (useBlank) {
      final m = words[rnd.nextInt(words.length)];
      final w = m.group(0)!;
      final wrong = (allWords.where((x) => x.toLowerCase() != w.toLowerCase()).toList()..shuffle(rnd)).take(3).toList();
      if (wrong.length == 3) {
        final opts = [w, ...wrong]..shuffle(rnd);
        final prompt = '${t.tl.substring(0, m.start)}____${t.tl.substring(m.end)}';
        out.add(CurQuestion(lineIdOf(d, t), d.id, prompt, t.ko, true, opts, opts.indexOf(w)));
        continue;
      }
    }
    final right = t.ko.trim();
    final wrong = (allKo.where((x) => x != right).toList()..shuffle(rnd)).take(3).toList();
    if (wrong.length < 3) continue;
    final opts = [right, ...wrong]..shuffle(rnd);
    out.add(CurQuestion(lineIdOf(d, t), d.id, t.tl, '', false, opts, opts.indexOf(right)));
  }
  return out;
}

/// 코스 시험 — 편당 최소 3문제, 모두 합쳐 최대 30문제.
List<CurQuestion> makeExam(List<Dialogue> ds, Random rnd) {
  if (ds.isEmpty) return const [];
  final per = max(kExamMinPerDialogue, kExamMaxQ ~/ ds.length);
  final out = <CurQuestion>[for (final d in ds) ...makeQuestions(d, rnd: rnd, maxQ: per, pool: ds)];
  out.shuffle(rnd);
  return out.take(kExamMaxQ).toList();
}

/// 상태 읽기·쓰기 + 다이얼로그 찾기.
class CurriculumService {
  CurriculumService._();
  static final CurriculumService instance = CurriculumService._();

  static const levels = ['R0', 'R1', 'R2', 'R3', 'R4', 'R5'];

  Future<CurriculumState> load() async {
    final raw = (await Prefs.getInstance()).getString(kCurriculumKey);
    if (raw == null || raw.isEmpty) return CurriculumState();
    try {
      return CurriculumState.fromJson(json.decode(raw) as Map);
    } catch (_) {
      return CurriculumState();
    }
  }

  Future<void> save(CurriculumState s) async => (await Prefs.getInstance()).setString(kCurriculumKey, json.encode(s.toJson()));

  /// 이 앱에 편이 있는 회화 레벨만.
  List<String> availableLevels() => levels.where((l) => DialogueService.instance.count(l) > 0).toList();

  List<Dialogue> dialoguesOf(String level) => DialogueService.instance.list(region: level);

  Dialogue? dialogue(String id) => DialogueService.instance.byId(id);

  /// lineId → (편, 줄).
  (Dialogue, DialogueTurn)? line(String lineId) {
    final i = lineId.lastIndexOf('#');
    if (i < 0) return null;
    final d = dialogue(lineId.substring(0, i));
    final n = int.tryParse(lineId.substring(i + 1));
    final t = d?.turns.where((x) => x.num == n).firstOrNull;
    return (d == null || t == null) ? null : (d, t);
  }

  /// 레벨 다음(없으면 null).
  String? nextLevel(String level) {
    final av = availableLevels();
    final i = av.indexOf(level);
    return (i >= 0 && i + 1 < av.length) ? av[i + 1] : null;
  }
}
