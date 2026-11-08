import 'dart:ui' show Offset;

import '../core/l10n.dart';

/// 독일어 알파벳·발음 단위 — IPA · 소리 내는 법 · 한국어 비교 · 예시 단어.
///
/// 예시 단어의 독음·뜻은 `assets/data/freq/lang_de_top.csv` 와 똑같이 적는다
/// (test/alphabet_test.dart 가 대조한다). 독음 규칙은 CLAUDE.md 「한글 독음 표기표」.
/// 설명 문장은 콘텐츠라 번역하지 않는다(CLAUDE.md §5) — 그룹·장소 이름 같은 화면 문구만 tr().

class DeExample {
  final String word, reading, ko;
  const DeExample(this.word, this.reading, this.ko);
}

/// 모음 사다리꼴 위 한 점. x: 0 전설 → 1 후설, y: 0 고 → 1 저.
class VowelPoint {
  final double x, y;
  final String ipa, label;
  const VowelPoint(this.x, this.y, this.ipa, this.label);
}

class DeVowelChartData {
  final List<VowelPoint> de; // 독일어(빨강) — 첫 점이 기준
  final List<VowelPoint> ko; // 한국어(파랑)
  final String note;
  final bool glide; // 이중모음: de[0] → de[1] 화살표
  const DeVowelChartData({required this.de, required this.ko, required this.note, this.glide = false});
}

/// 조음 위치 — places_of_articulation.png 의 번호와 그림 위 표시점(가로·세로 비율).
class DePlace {
  final String key;
  final List<int> numbers;
  final List<Offset> marks; // 그림 크기에 대한 비율(0~1)
  const DePlace(this.key, this.numbers, this.marks);

  String get label => switch (key) {
        'bilabial' => tr('두 입술 (양순음)'),
        'labiodental' => tr('아랫입술 + 윗니 (순치음)'),
        'alveolar' => tr('윗잇몸 (치경음)'),
        'postalveolar' => tr('잇몸 뒤 (후치경음)'),
        'palatal' => tr('센입천장 (경구개음)'),
        'velar' => tr('여린입천장 (연구개음)'),
        'uvular' => tr('목젖 (구개수음)'),
        _ => tr('성대 (성문음)'),
      };
}

// 그림 960×1200 기준 번호 위치.
const Map<String, DePlace> kPlaces = {
  'bilabial': DePlace('bilabial', [1], [Offset(85 / 960, 487 / 1200), Offset(40 / 960, 866 / 1200)]),
  'labiodental': DePlace('labiodental', [2, 3], [Offset(210 / 960, 528 / 1200), Offset(97 / 960, 795 / 1200)]),
  'alveolar': DePlace('alveolar', [4], [Offset(267 / 960, 487 / 1200), Offset(122 / 960, 735 / 1200)]),
  'postalveolar': DePlace('postalveolar', [5], [Offset(313 / 960, 470 / 1200)]),
  'palatal': DePlace('palatal', [7], [Offset(497 / 960, 450 / 1200), Offset(330 / 960, 664 / 1200)]),
  'velar': DePlace('velar', [8], [Offset(623 / 960, 475 / 1200), Offset(534 / 960, 681 / 1200)]),
  'uvular': DePlace('uvular', [9], [Offset(697 / 960, 590 / 1200)]),
  'glottal': DePlace('glottal', [11], [Offset(822 / 960, 1095 / 1200)]),
};

class DeSoundUnit {
  final String id;
  final String glyph; // 칸의 큰 글자
  final String group; // vowel · umlaut · diph · cons · cluster · final
  final String ko; // 한글 독음(칸 아래, 토글)
  final String ipa;
  final String? name; // 글자 이름(단일 글자만) 예: 'Jot'
  final String? nameKo; // '요트'
  final String? speakName; // TTS 로 읽힐 글자 이름 텍스트
  final String how;
  final String korSim;
  final String korDiff;
  final String? place; // kPlaces 키
  final DeVowelChartData? vowel;
  final List<DeExample> ex;

  const DeSoundUnit({
    required this.id,
    required this.glyph,
    required this.group,
    required this.ko,
    required this.ipa,
    this.name,
    this.nameKo,
    this.speakName,
    required this.how,
    required this.korSim,
    required this.korDiff,
    this.place,
    this.vowel,
    required this.ex,
  });

  /// 자동 재생·다시 듣기 문장 — 글자 이름(있으면) + 첫 예시 단어.
  String get speakText => speakName == null ? ex.first.word : '$speakName. ${ex.first.word}';
}

const kDeGroups = ['vowel', 'umlaut', 'diph', 'cons', 'cluster', 'final'];

String deGroupLabel(String g) => switch (g) {
      'vowel' => tr('모음'),
      'umlaut' => tr('움라우트·ß'),
      'diph' => tr('이중모음'),
      'cons' => tr('자음'),
      'cluster' => tr('자음 묶음'),
      'final' => tr('음절 끝 규칙'),
      _ => tr('전체'),
    };

// ── 모음 위치(한국어 기준점) ──
const _kA = VowelPoint(0.5, 0.82, 'ɐ', '아');
const _kE = VowelPoint(0.03, 0.5, 'e̞', '에');
const _kI = VowelPoint(0.02, 0.02, 'i', '이');
const _kO = VowelPoint(1.0, 0.36, 'o', '오');
const _kU = VowelPoint(1.0, 0.04, 'u', '우');
const _kEo = VowelPoint(0.96, 0.64, 'ʌ', '어');

const _chartUe = DeVowelChartData(
  de: [VowelPoint(0.08, 0.0, 'yː', 'ü'), VowelPoint(0.2, 0.16, 'ʏ', 'ü(짧게)')],
  ko: [_kI, _kU],
  note: 'ü 는 혀는 「이」 자리(앞·위), 입술은 「우」처럼 둥글게. 한국어 「이」와 같은 자리에서 입술만 오므린다.',
);

const _chartEr = DeVowelChartData(
  de: [VowelPoint(0.5, 0.78, 'ɐ', '-er')],
  ko: [_kA, _kEo],
  note: '-er·끝 r 은 입안 한가운데의 약한 「어」[ɐ]. 한국어 「아」와 「어」 사이, 힘을 빼고 짧게.',
);

const List<DeSoundUnit> kDeUnits = [
  // ───────── 모음 ─────────
  DeSoundUnit(
    id: 'a', glyph: 'a', group: 'vowel', ko: '아', ipa: 'aː · a', name: 'A', nameKo: '아', speakName: 'A',
    how: '입을 크게 벌리고 혀를 낮게 둔다(저모음). 길게 [aː](haben, Tag) 또는 짧게 [a](dass). 뒤에 자음이 하나면 대개 길고, 둘 이상이면 짧다.',
    korSim: '아',
    korDiff: "한국어 '아'와 거의 같다. 다만 길이를 꼭 지킨다 — 긴 a 는 확실히 끌고, 짧은 a 는 딱 끊는다. 길이로 뜻이 갈리는 말이 많다.",
    vowel: DeVowelChartData(
      de: [VowelPoint(0.5, 1.0, 'aː', 'a'), VowelPoint(0.45, 0.94, 'a', 'a(짧게)')],
      ko: [_kA],
      note: '독일어 a 는 한국어 「아」보다 조금 더 아래(입을 더 벌림). 긴 a·짧은 a 의 자리는 거의 같고 길이만 다르다.',
    ),
    ex: [DeExample('haben', '하벤', '가지다'), DeExample('Tag', '탁', '날'), DeExample('dass', '다스', '~라는 것')],
  ),
  DeSoundUnit(
    id: 'e', glyph: 'e', group: 'vowel', ko: '에', ipa: 'eː · ɛ · ə', name: 'E', nameKo: '에', speakName: 'E',
    how: '긴 e[eː]는 입꼬리를 옆으로 당기고 혀를 높여 「에」와 「이」 사이. 짧은 e[ɛ]는 입을 조금 더 벌린 「에」. 강세 없는 끝 -e 는 힘을 뺀 약한 [ə].',
    korSim: '에',
    korDiff: "긴 e 는 한국어 '에'보다 혀가 높아 '이'에 가깝게 들린다. 짧은 e 는 한국어 '에'와 같다. 끝 -e(danke)는 앱 독음으로 '에'라고 적지만 약하게 흘린다.",
    vowel: DeVowelChartData(
      de: [VowelPoint(0.0, 0.33, 'eː', 'e'), VowelPoint(0.0, 0.66, 'ɛ', 'e(짧게)'), VowelPoint(0.5, 0.5, 'ə', '-e')],
      ko: [_kE, _kI],
      note: '긴 e[eː]는 「에」보다 위(「이」 쪽), 짧은 e[ɛ]는 「에」보다 조금 아래. 끝 -e[ə]는 입안 한가운데.',
    ),
    ex: [DeExample('gehen', '게엔', '가다'), DeExample('denn', '덴', '왜냐하면'), DeExample('danke', '당케', '고마워')],
  ),
  DeSoundUnit(
    id: 'i', glyph: 'i', group: 'vowel', ko: '이', ipa: 'iː · ɪ', name: 'I', nameKo: '이', speakName: 'I',
    how: '혀를 앞·위로 높이고 입술을 옆으로 편다. 긴 i[iː](Musik)는 팽팽하게, 짧은 i[ɪ](Kind, mit)는 조금 느슨하게.',
    korSim: '이',
    korDiff: "긴 i 는 한국어 '이'를 길게 끈 소리. 짧은 i[ɪ]는 혀가 조금 내려와 '이'와 '에' 사이로 들린다.",
    vowel: DeVowelChartData(
      de: [VowelPoint(0.0, 0.0, 'iː', 'i'), VowelPoint(0.15, 0.16, 'ɪ', 'i(짧게)')],
      ko: [_kI, _kE],
      note: '긴 i 는 「이」와 같은 자리. 짧은 i[ɪ]는 조금 아래·안쪽 — 「이」와 「에」 사이.',
    ),
    ex: [DeExample('Musik', '무지크', '음악'), DeExample('Kind', '킨트', '아이'), DeExample('mit', '미트', '~와 함께')],
  ),
  DeSoundUnit(
    id: 'o', glyph: 'o', group: 'vowel', ko: '오', ipa: 'oː · ɔ', name: 'O', nameKo: '오', speakName: 'O',
    how: '혀를 뒤로, 입술을 둥글게. 긴 o[oː](so, rot)는 입술을 작게 모아 끈다. 짧은 o[ɔ](kommen)는 입을 더 벌린다.',
    korSim: '오',
    korDiff: "긴 o 는 한국어 '오'보다 입술을 더 오므려 '우' 쪽으로, 끝까지 '오' 하나(오우 X). 짧은 o[ɔ]는 '오'와 '어' 사이.",
    vowel: DeVowelChartData(
      de: [VowelPoint(1.0, 0.33, 'oː', 'o'), VowelPoint(1.0, 0.66, 'ɔ', 'o(짧게)')],
      ko: [_kO, _kEo],
      note: '긴 o 는 「오」와 거의 같은 자리(조금 위). 짧은 o[ɔ]는 「오」보다 아래 — 「어」 높이에서 입술만 둥글게.',
    ),
    ex: [DeExample('so', '조', '그렇게'), DeExample('rot', '로트', '빨간'), DeExample('kommen', '코멘', '오다')],
  ),
  DeSoundUnit(
    id: 'u', glyph: 'u', group: 'vowel', ko: '우', ipa: 'uː · ʊ', name: 'U', nameKo: '우', speakName: 'U',
    how: '혀를 뒤·위로, 입술을 동그랗게 앞으로 내민다. 긴 u[uː](gut, du), 짧은 u[ʊ](und)는 조금 느슨하게.',
    korSim: '우',
    korDiff: "긴 u 는 한국어 '우'보다 입술을 더 내밀고 길게. 짧은 u[ʊ]는 힘을 뺀 '우'.",
    vowel: DeVowelChartData(
      de: [VowelPoint(1.0, 0.0, 'uː', 'u'), VowelPoint(0.84, 0.16, 'ʊ', 'u(짧게)')],
      ko: [_kU, _kO],
      note: '긴 u 는 「우」와 같은 자리. 짧은 u[ʊ]는 조금 아래·앞 — 「우」와 「오」 사이.',
    ),
    ex: [DeExample('gut', '구트', '좋은'), DeExample('du', '두', '너'), DeExample('und', '운트', '그리고')],
  ),

  // ───────── 움라우트 · ß ─────────
  DeSoundUnit(
    id: 'ae', glyph: 'ä', group: 'umlaut', ko: '에', ipa: 'ɛː · ɛ', name: 'Ä', nameKo: '에', speakName: 'Ä',
    how: '혀를 앞에 두고 입을 「에」보다 조금 더 벌린다. 길게 [ɛː](spät), 짧게 [ɛ](Geschäft).',
    korSim: '에 (애)',
    korDiff: "한국어 '에'·'애'와 거의 같다. 긴 e[eː]와 헷갈리지 말 것 — ä 는 입을 더 벌린다.",
    vowel: DeVowelChartData(
      de: [VowelPoint(0.0, 0.66, 'ɛː', 'ä')],
      ko: [_kE],
      note: 'ä 는 「에」보다 조금 아래(입을 더 벌림). 긴 e[eː]보다 확실히 낮다.',
    ),
    ex: [DeExample('spät', '슈페트', '늦은'), DeExample('Geschäft', '게셰프트', '가게'), DeExample('erklären', '에어클레렌', '설명하다')],
  ),
  DeSoundUnit(
    id: 'oe', glyph: 'ö', group: 'umlaut', ko: '외', ipa: 'øː · œ', name: 'Ö', nameKo: '외', speakName: 'Ö',
    how: '혀는 「에」 자리(앞)에 두고, 입술만 「오」처럼 동그랗게 내민다. 길게 [øː](schön), 짧게 [œ](können)는 입을 조금 더 벌린다.',
    korSim: '외',
    korDiff: "'외'를 '오+에'(웨)로 미끄러지지 말고 한 소리로. '에'를 말하면서 입술만 '오'로 모은 채 끝까지 유지한다.",
    vowel: DeVowelChartData(
      de: [VowelPoint(0.08, 0.33, 'øː', 'ö'), VowelPoint(0.1, 0.66, 'œ', 'ö(짧게)')],
      ko: [_kE, _kO],
      note: 'ö 는 「에」와 같은 앞쪽 자리에서 입술만 둥글게. 「오」(뒤쪽)와는 혀 위치가 다르다.',
    ),
    ex: [DeExample('schön', '쇤', '아름다운'), DeExample('hören', '회렌', '듣다'), DeExample('können', '쾨넨', '할 수 있다')],
  ),
  DeSoundUnit(
    id: 'ue', glyph: 'ü', group: 'umlaut', ko: '위', ipa: 'yː · ʏ', name: 'Ü', nameKo: '위', speakName: 'Ü',
    how: '혀는 「이」 자리(앞·위)에 두고, 입술은 「우」처럼 동그랗게 내민다. 길게 [yː](für, über), 짧게 [ʏ](Glück).',
    korSim: '위',
    korDiff: "입술은 '우', 혀는 '이'. '위'를 '우+이'로 미끄러지지 말고 처음부터 끝까지 같은 입모양. '이'를 길게 말하면서 입술만 오므려 보자.",
    vowel: _chartUe,
    ex: [DeExample('für', '퓌어', '~를 위해'), DeExample('über', '위버', '~위에'), DeExample('Glück', '글뤽', '행운')],
  ),
  DeSoundUnit(
    id: 'sz', glyph: 'ß', group: 'umlaut', ko: 'ㅅ', ipa: 's', name: 'Eszett', nameKo: '에스체트', speakName: 'Eszett',
    how: '혀끝을 윗잇몸 가까이 대고 좁은 틈으로 바람을 낸다(무성 치경 마찰음 [s]). 긴 모음·이중모음 뒤에 쓰고(groß, heißen), 짧은 모음 뒤에는 ss(dass)를 쓴다.',
    korSim: 'ㅅ / ㅆ',
    korDiff: "한국어 'ㅅ'·'ㅆ' 사이의 날카로운 [s]. 모음 사이에서도 절대 울리지 않는다(s 와 달리 'ㅈ'가 되지 않음). 대문자가 거의 없어 단어 첫머리에는 나오지 않는다.",
    place: 'alveolar',
    ex: [DeExample('groß', '그로스', '큰'), DeExample('heißen', '하이센', '~라고 불리다'), DeExample('Straße', '슈트라세', '거리')],
  ),

  // ───────── 이중모음 ─────────
  DeSoundUnit(
    id: 'ei', glyph: 'ei · ai', group: 'diph', ko: '아이', ipa: 'aɪ̯',
    how: '「아」에서 「이」 쪽으로 한 음절 안에서 미끄러진다. 앞의 「아」가 길고 뒤의 「이」는 짧고 약하다. ai(Kaiser)도 같은 소리.',
    korSim: '아이',
    korDiff: "ei 는 '에이'가 아니라 '아이'! '아-이' 두 음절로 끊지 말고 한 박자에.",
    vowel: DeVowelChartData(
      de: [VowelPoint(0.5, 1.0, 'a', 'a'), VowelPoint(0.15, 0.16, 'ɪ', 'i')],
      ko: [_kA, _kI],
      note: '「아」에서 출발해 「이」 쪽으로 가다 다 닿기 전에 멈춘다.',
      glide: true,
    ),
    ex: [DeExample('mein', '마인', '나의'), DeExample('Zeit', '차이트', '시간'), DeExample('Kaiser', '카이저', '황제')],
  ),
  DeSoundUnit(
    id: 'ie', glyph: 'ie', group: 'diph', ko: '이', ipa: 'iː',
    how: '이중모음이 아니라 긴 「이」 하나. e 는 「길게 읽어라」는 표시일 뿐 소리가 나지 않는다.',
    korSim: '이 (길게)',
    korDiff: "'이에'라고 읽지 않는다. sie = '지', Liebe = '리베'.",
    vowel: DeVowelChartData(
      de: [VowelPoint(0.0, 0.0, 'iː', 'ie')],
      ko: [_kI],
      note: 'ie 는 「이」와 같은 자리에서 길게.',
    ),
    ex: [DeExample('sie', '지', '그녀/그들'), DeExample('viel', '필', '많은'), DeExample('Liebe', '리베', '사랑')],
  ),
  DeSoundUnit(
    id: 'eu', glyph: 'eu · äu', group: 'diph', ko: '오이', ipa: 'ɔʏ̯',
    how: '입술을 둥글게 한 「오」에서 출발해 「위」(ü) 쪽으로 미끄러진다. äu(träumen)도 같은 소리.',
    korSim: '오이',
    korDiff: "글자대로 '에우'가 아니라 '오이'. 뒤쪽 '이'는 입술을 살짝 둥글게 한 짧은 소리.",
    vowel: DeVowelChartData(
      de: [VowelPoint(1.0, 0.66, 'ɔ', 'o'), VowelPoint(0.2, 0.16, 'ʏ', 'ü')],
      ko: [_kO, _kI],
      note: '「오」(조금 아래)에서 출발해 「이·위」 쪽으로 간다.',
      glide: true,
    ),
    ex: [DeExample('heute', '호이테', '오늘'), DeExample('Freund', '프로인트', '친구'), DeExample('träumen', '트로이멘', '꿈꾸다')],
  ),
  DeSoundUnit(
    id: 'au', glyph: 'au', group: 'diph', ko: '아우', ipa: 'aʊ̯',
    how: '「아」에서 입술을 오므리며 「우」 쪽으로 한 음절 안에서 미끄러진다.',
    korSim: '아우',
    korDiff: "한국어 '아우'와 거의 같다. 두 음절로 끊지 말고 '아'에 무게를 두어 한 박자에.",
    vowel: DeVowelChartData(
      de: [VowelPoint(0.5, 1.0, 'a', 'a'), VowelPoint(0.84, 0.16, 'ʊ', 'u')],
      ko: [_kA, _kU],
      note: '「아」에서 출발해 「우」 쪽으로 가다 다 닿기 전에 멈춘다.',
      glide: true,
    ),
    ex: [DeExample('Haus', '하우스', '집'), DeExample('Frau', '프라우', '여자'), DeExample('auch', '아우흐', '~도')],
  ),

  // ───────── 자음 ─────────
  DeSoundUnit(
    id: 'b', glyph: 'b', group: 'cons', ko: 'ㅂ', ipa: 'b', name: 'Be', nameKo: '베', speakName: 'B',
    how: '두 입술을 붙였다 떼며 성대를 울린다(유성 양순 파열음).',
    korSim: 'ㅂ',
    korDiff: "한국어 ㅂ은 첫소리에서 성대가 거의 울리지 않지만 독일어 b 는 목이 울린다(영어 b). 음절 끝에서는 [p] — ab = '압'.",
    place: 'bilabial',
    ex: [DeExample('bitte', '비테', '제발'), DeExample('bald', '발트', '곧'), DeExample('Bruder', '브루더', '형제')],
  ),
  DeSoundUnit(
    id: 'c', glyph: 'c', group: 'cons', ko: 'ㅋ', ipa: 'k · ts', name: 'Ce', nameKo: '체', speakName: 'C',
    how: 'c 혼자는 외래어에서만 나온다 — 대개 [k](Computer), e·i 앞에서는 [ts]. 프랑스어에서 온 Ch 는 [ʃ](Chef). 독일어 본래 말에서는 ch·ck·sch 묶음으로 쓴다.',
    korSim: 'ㅋ (가끔 ㅊ)',
    korDiff: "대부분 'ㅋ'. c 를 보면 먼저 ch·ck·sch 묶음인지 확인할 것 — 「자음 묶음」 참고.",
    place: 'velar',
    ex: [DeExample('Computer', '콤퓨터', '컴퓨터'), DeExample('Chef', '셰프', '상사')],
  ),
  DeSoundUnit(
    id: 'd', glyph: 'd', group: 'cons', ko: 'ㄷ', ipa: 'd', name: 'De', nameKo: '데', speakName: 'D',
    how: '혀끝을 윗잇몸에 붙였다 떼며 성대를 울린다(유성 치경 파열음).',
    korSim: 'ㄷ',
    korDiff: "목이 울리는 ㄷ(영어 d). 음절 끝에서는 [t] — und = '운트'.",
    place: 'alveolar',
    ex: [DeExample('danke', '당케', '고마워'), DeExample('du', '두', '너'), DeExample('Bruder', '브루더', '형제')],
  ),
  DeSoundUnit(
    id: 'f', glyph: 'f', group: 'cons', ko: 'ㅍ', ipa: 'f', name: 'Ef', nameKo: '에프', speakName: 'F',
    how: '아랫입술을 윗니에 살짝 대고 그 틈으로 바람을 낸다(무성 순치 마찰음).',
    korSim: 'ㅍ',
    korDiff: "한국어에는 없는 소리. 'ㅍ'로 적지만 두 입술을 붙여 터뜨리지 않는다 — 아랫입술과 윗니 사이로 '프-' 바람만.",
    place: 'labiodental',
    ex: [DeExample('für', '퓌어', '~를 위해'), DeExample('fragen', '프라겐', '묻다'), DeExample('Familie', '파밀리에', '가족')],
  ),
  DeSoundUnit(
    id: 'g', glyph: 'g', group: 'cons', ko: 'ㄱ', ipa: 'ɡ', name: 'Ge', nameKo: '게', speakName: 'G',
    how: '혀 뒤쪽을 여린입천장에 붙였다 떼며 성대를 울린다(유성 연구개 파열음).',
    korSim: 'ㄱ',
    korDiff: "목이 울리는 ㄱ(영어 g). 음절 끝에서는 [k] — Tag = '탁'. 끝 -ig 는 '이히'.",
    place: 'velar',
    ex: [DeExample('gut', '구트', '좋은'), DeExample('gehen', '게엔', '가다'), DeExample('Geld', '겔트', '돈')],
  ),
  DeSoundUnit(
    id: 'h', glyph: 'h', group: 'cons', ko: 'ㅎ', ipa: 'h', name: 'Ha', nameKo: '하', speakName: 'H',
    how: '목 안쪽(성대)에서 숨을 내쉬는 소리(무성 성문 마찰음). 모음 뒤의 h 는 소리가 나지 않고 앞 모음을 길게 한다.',
    korSim: 'ㅎ',
    korDiff: "첫소리 h 는 한국어 ㅎ과 같다. sehr·fahren 의 h 는 읽지 않는다 — 「음절 끝 규칙」 참고.",
    place: 'glottal',
    ex: [DeExample('haben', '하벤', '가지다'), DeExample('heute', '호이테', '오늘'), DeExample('Haus', '하우스', '집')],
  ),
  DeSoundUnit(
    id: 'j', glyph: 'j', group: 'cons', ko: '이', ipa: 'j', name: 'Jot', nameKo: '요트', speakName: 'J',
    how: '혀 가운데를 센입천장 가까이 올리며 미끄러지듯 시작한다(경구개 접근음).',
    korSim: "'야·예·유'의 첫소리",
    korDiff: "영어 j(ㅈ)가 아니다! 영어 yes 의 y. ja = '야', jetzt = '예츠트'.",
    place: 'palatal',
    ex: [DeExample('ja', '야', '네'), DeExample('jetzt', '예츠트', '지금'), DeExample('jung', '융', '젊은')],
  ),
  DeSoundUnit(
    id: 'k', glyph: 'k', group: 'cons', ko: 'ㅋ', ipa: 'k', name: 'Ka', nameKo: '카', speakName: 'K',
    how: '혀 뒤쪽을 여린입천장에 붙였다 떼며 숨과 함께 터뜨린다(무성 연구개 파열음).',
    korSim: 'ㅋ',
    korDiff: "한국어 ㅋ처럼 숨이 섞인다. 단어 첫머리 kl·kn 도 k 를 분명히 소리 낸다.",
    place: 'velar',
    ex: [DeExample('kommen', '코멘', '오다'), DeExample('Kind', '킨트', '아이'), DeExample('klein', '클라인', '작은')],
  ),
  DeSoundUnit(
    id: 'l', glyph: 'l', group: 'cons', ko: 'ㄹ', ipa: 'l', name: 'El', nameKo: '엘', speakName: 'L',
    how: '혀끝을 윗잇몸에 붙인 채 혀 옆으로 소리를 흘린다(치경 설측 접근음).',
    korSim: 'ㄹ (받침 ㄹ)',
    korDiff: "'달라'의 'ㄹㄹ'처럼 혀끝을 붙인 채 낸다. 첫소리에서도 혀를 튕기지 않는다. 영어 끝 l 처럼 어둡지도 않은 맑은 소리.",
    place: 'alveolar',
    ex: [DeExample('leben', '레벤', '살다'), DeExample('Liebe', '리베', '사랑'), DeExample('viel', '필', '많은')],
  ),
  DeSoundUnit(
    id: 'm', glyph: 'm', group: 'cons', ko: 'ㅁ', ipa: 'm', name: 'Em', nameKo: '엠', speakName: 'M',
    how: '두 입술을 붙이고 코로 소리를 내보낸다(양순 비음).',
    korSim: 'ㅁ',
    korDiff: "한국어 ㅁ과 같다.",
    place: 'bilabial',
    ex: [DeExample('machen', '마헨', '하다/만들다'), DeExample('Mann', '만', '남자'), DeExample('Mutter', '무터', '어머니')],
  ),
  DeSoundUnit(
    id: 'n', glyph: 'n', group: 'cons', ko: 'ㄴ', ipa: 'n', name: 'En', nameKo: '엔', speakName: 'N',
    how: '혀끝을 윗잇몸에 붙이고 코로 소리를 내보낸다(치경 비음).',
    korSim: 'ㄴ',
    korDiff: "한국어 ㄴ과 같다.",
    place: 'alveolar',
    ex: [DeExample('nein', '나인', '아니요'), DeExample('neu', '노이', '새로운'), DeExample('Nacht', '나흐트', '밤')],
  ),
  DeSoundUnit(
    id: 'p', glyph: 'p', group: 'cons', ko: 'ㅍ', ipa: 'p', name: 'Pe', nameKo: '페', speakName: 'P',
    how: '두 입술을 붙였다 떼며 숨과 함께 터뜨린다(무성 양순 파열음).',
    korSim: 'ㅍ',
    korDiff: "한국어 ㅍ과 비슷하게 숨이 섞인다. f(윗니+아랫입술)와 달리 두 입술로 터뜨린다.",
    place: 'bilabial',
    ex: [DeExample('Papa', '파파', '아빠'), DeExample('Problem', '프로블렘', '문제'), DeExample('Platz', '플라츠', '자리/광장')],
  ),
  DeSoundUnit(
    id: 'q', glyph: 'q', group: 'cons', ko: 'ㅋ', ipa: 'k(v)', name: 'Ku', nameKo: '쿠', speakName: 'Q',
    how: '언제나 qu 로 나오고 [kv] — k 다음 바로 아랫입술을 윗니에 대는 v.',
    korSim: "'크ㅂ'",
    korDiff: "'쿠'가 아니라 'ㅋ+v'. Quatsch = '크바치'. u 는 모음으로 읽지 않는다.",
    place: 'velar',
    ex: [DeExample('Quatsch', '크바치', '헛소리'), DeExample('quasi', '크바지', '사실상')],
  ),
  DeSoundUnit(
    id: 'r', glyph: 'r', group: 'cons', ko: 'ㄹ', ipa: 'ʁ', name: 'Er', nameKo: '에어', speakName: 'R',
    how: '혀끝은 아래에 두고, 혀뿌리를 목젖 쪽으로 올려 가볍게 긁는다(유성 구개수 마찰음 [ʁ]). 음절 끝에서는 약한 「어」[ɐ]로 바뀐다.',
    korSim: "ㄹ 로 적지만 소리는 목 안쪽 'ㅎ'에 가깝다",
    korDiff: "한국어 ㄹ(혀끝 튕김)과 전혀 다르다. 가글하듯 목 안쪽에서, 'ㅎ'에 목소리를 실어 약하게 긁는 느낌. 음절 끝(der, mehr)에서는 '어' — 「음절 끝 규칙」 참고.",
    place: 'uvular',
    ex: [DeExample('richtig', '리히티히', '옳은'), DeExample('rot', '로트', '빨간'), DeExample('Frau', '프라우', '여자')],
  ),
  DeSoundUnit(
    id: 's', glyph: 's', group: 'cons', ko: 'ㅈ · ㅅ', ipa: 'z · s', name: 'Es', nameKo: '에스', speakName: 'S',
    how: '혀끝을 윗잇몸 가까이 두고 바람을 낸다. 모음 앞에서는 성대를 울린 [z](sagen), 음절 끝·자음 앞에서는 [s](Haus). 첫머리 sp·st 는 [ʃ].',
    korSim: "모음 앞 'ㅈ', 끝 'ㅅ'",
    korDiff: "모음 앞 s[z]는 한국어에 없는 소리. 'ㅈ'로 적지만 혀를 붙이지 말고 'ㅅ'에 목소리를 얹어 '즈-' 하고 떨리게. 끝의 s 는 'ㅅ'.",
    place: 'alveolar',
    ex: [DeExample('sagen', '자겐', '말하다'), DeExample('so', '조', '그렇게'), DeExample('Haus', '하우스', '집')],
  ),
  DeSoundUnit(
    id: 't', glyph: 't', group: 'cons', ko: 'ㅌ', ipa: 't', name: 'Te', nameKo: '테', speakName: 'T',
    how: '혀끝을 윗잇몸에 붙였다 떼며 숨과 함께 터뜨린다(무성 치경 파열음).',
    korSim: 'ㅌ',
    korDiff: "한국어 ㅌ과 비슷하다. th 도 그냥 [t](영어 th 아님).",
    place: 'alveolar',
    ex: [DeExample('tun', '툰', '하다'), DeExample('Tag', '탁', '날'), DeExample('Telefon', '텔레폰', '전화')],
  ),
  DeSoundUnit(
    id: 'v', glyph: 'v', group: 'cons', ko: 'ㅍ', ipa: 'f (v)', name: 'Vau', nameKo: '파우', speakName: 'V',
    how: '독일어 본래 말에서는 f 와 같은 [f] — 아랫입술을 윗니에 대고 바람만. 외래어(Video 등)에서는 [v].',
    korSim: 'ㅍ',
    korDiff: "v 는 영어처럼 [v]가 아니라 대개 [f]! Vater = '파터'. 'ㅍ'로 적지만 두 입술을 붙이지 않는다.",
    place: 'labiodental',
    ex: [DeExample('Vater', '파터', '아버지'), DeExample('viel', '필', '많은'), DeExample('vor', '포어', '~앞에')],
  ),
  DeSoundUnit(
    id: 'w', glyph: 'w', group: 'cons', ko: 'ㅂ', ipa: 'v', name: 'We', nameKo: '베', speakName: 'W',
    how: '아랫입술을 윗니에 대고 성대를 울리며 바람을 낸다(유성 순치 마찰음 [v]).',
    korSim: 'ㅂ',
    korDiff: "영어 v 소리이고 한국어에는 없다. 'ㅂ'로 적지만 두 입술을 붙이지 말고 아랫입술을 윗니에 댄다. 영어 w('우')도 아니다.",
    place: 'labiodental',
    ex: [DeExample('was', '바스', '무엇'), DeExample('wir', '비어', '우리'), DeExample('wie', '비', '어떻게')],
  ),
  DeSoundUnit(
    id: 'x', glyph: 'x', group: 'cons', ko: 'ㅋㅅ', ipa: 'ks', name: 'Ix', nameKo: '익스', speakName: 'X',
    how: '[k]와 [s]를 이어서 낸다.',
    korSim: "'ㅋ+ㅅ' (받침 ㄱ + ㅅ)",
    korDiff: "Taxi = '탁시'. chs(wachsen)·ks 도 같은 소리.",
    place: 'velar',
    ex: [DeExample('Taxi', '탁시', '택시'), DeExample('extra', '엑스트라', '일부러'), DeExample('Text', '텍스트', '글')],
  ),
  DeSoundUnit(
    id: 'y', glyph: 'y', group: 'cons', ko: '위', ipa: 'ʏ · yː', name: 'Ypsilon', nameKo: '윕실론', speakName: 'Y',
    how: '대개 ü 와 같은 모음 [ʏ·yː](typisch, System). 영어에서 온 말은 [i](Handy).',
    korSim: '위 (영어 말은 이)',
    korDiff: "자음 이름표에 있지만 소리는 ü. 혀는 '이', 입술은 '우'.",
    vowel: _chartUe,
    ex: [DeExample('typisch', '튀피슈', '전형적인'), DeExample('System', '쥐스템', '시스템'), DeExample('Handy', '헨디', '휴대폰')],
  ),
  DeSoundUnit(
    id: 'z', glyph: 'z', group: 'cons', ko: 'ㅊ', ipa: 'ts', name: 'Zett', nameKo: '체트', speakName: 'Z',
    how: '혀끝을 윗잇몸에 붙였다 떼며 바로 [s] 바람을 낸다(무성 치경 파찰음 [ts]).',
    korSim: 'ㅊ',
    korDiff: "'ㅊ'와 비슷하지만 [t]+[s] — 'ㅊ'보다 혀가 앞(윗잇몸)이고 끝이 'ㅆ'처럼 샌다. 'ㅈ'나 영어 z(울림)가 아니다.",
    place: 'alveolar',
    ex: [DeExample('Zeit', '차이트', '시간'), DeExample('zu', '추', '~로'), DeExample('zwischen', '츠비셴', '~사이에')],
  ),

  // ───────── 자음 묶음 ─────────
  DeSoundUnit(
    id: 'ch_i', glyph: 'ch', group: 'cluster', ko: '히', ipa: 'ç',
    how: 'e·i·ä·ö·ü·ei·eu 뒤와 l·n·r 뒤, -chen 에서. 혀 가운데를 센입천장에 바짝 올리고 그 틈으로 숨만 내보낸다(무성 경구개 마찰음).',
    korSim: '히',
    korDiff: "'히'를 혀 앞쪽에서 바람만 — 한국어 'ㅎ'보다 좁고 날카롭다. '이크'나 '시'로 읽지 않는다. ich = '이히'.",
    place: 'palatal',
    ex: [DeExample('ich', '이히', '나'), DeExample('nicht', '니히트', '아니다'), DeExample('sprechen', '슈프레헨', '말하다')],
  ),
  DeSoundUnit(
    id: 'ch_a', glyph: 'ch', group: 'cluster', ko: '흐', ipa: 'x',
    how: 'a·o·u·au 뒤에서. 혀 뒤쪽을 여린입천장 가까이 올려 목 안쪽에서 긁는 마찰음(무성 연구개 마찰음).',
    korSim: '흐',
    korDiff: "한국어 'ㅎ'보다 훨씬 거칠게, 목 안쪽에서 '흐-' 긁는다. 'ㅋ'처럼 막지 않고 바람이 계속 나온다.",
    place: 'velar',
    ex: [DeExample('noch', '노흐', '아직'), DeExample('machen', '마헨', '하다/만들다'), DeExample('auch', '아우흐', '~도')],
  ),
  DeSoundUnit(
    id: 'sch', glyph: 'sch', group: 'cluster', ko: '슈', ipa: 'ʃ',
    how: '입술을 앞으로 둥글게 내밀고 혀를 잇몸 뒤에 가까이 해 「쉬-」 바람을 낸다(무성 후치경 마찰음).',
    korSim: '쉬 · 슈',
    korDiff: "한국어 '쉬'보다 입술을 더 내민다. 모음 앞은 '쇤·샤', 자음 앞·끝은 '슈'로 적는다.",
    place: 'postalveolar',
    ex: [DeExample('schön', '쇤', '아름다운'), DeExample('schnell', '슈넬', '빠른'), DeExample('Mensch', '멘슈', '사람')],
  ),
  DeSoundUnit(
    id: 'sp', glyph: 'sp', group: 'cluster', ko: '슈프', ipa: 'ʃp',
    how: '낱말(어간) 첫머리의 sp 는 [ʃp] — 「슈」 다음 바로 p.',
    korSim: '슈프',
    korDiff: "첫머리만 '슈프'. 낱말 가운데·끝의 sp 는 그냥 [sp] '스프'.",
    place: 'postalveolar',
    ex: [DeExample('sprechen', '슈프레헨', '말하다'), DeExample('Spaß', '슈파스', '재미'), DeExample('spät', '슈페트', '늦은')],
  ),
  DeSoundUnit(
    id: 'st', glyph: 'st', group: 'cluster', ko: '슈트', ipa: 'ʃt',
    how: '낱말(어간) 첫머리의 st 는 [ʃt] — 「슈」 다음 바로 t.',
    korSim: '슈트',
    korDiff: "첫머리만 '슈트'. 끝의 -st(ist, bist)는 [st] '스트'.",
    place: 'postalveolar',
    ex: [DeExample('Stadt', '슈타트', '도시'), DeExample('Stunde', '슈툰데', '시간'), DeExample('stehen', '슈테엔', '서다')],
  ),
  DeSoundUnit(
    id: 'pf', glyph: 'pf', group: 'cluster', ko: 'ㅍ', ipa: 'p͡f',
    how: '두 입술로 p 를 막은 채 아랫입술을 윗니로 옮겨 f 로 풀어 준다. 한 소리처럼 빠르게.',
    korSim: "'ㅍ' 두 번 (프ㅍ)",
    korDiff: "한국어에 없는 소리. 'ㅍ' 하나로 뭉개지 말고 입술 터뜨림 + 윗니 바람을 이어 붙인다. Kopf = '코프'.",
    place: 'labiodental',
    ex: [DeExample('Pferd', '프페어트', '말'), DeExample('Kopf', '코프', '머리'), DeExample('Apfelkuchen', '아펠쿠헨', '사과 케이크')],
  ),
  DeSoundUnit(
    id: 'qu', glyph: 'qu', group: 'cluster', ko: '크ㅂ', ipa: 'kv',
    how: 'k 다음 바로 v(아랫입술+윗니, 울림).',
    korSim: "'크바·크비'",
    korDiff: "영어 quick 의 '쿠'(w)가 아니라 [kv].",
    place: 'velar',
    ex: [DeExample('Quatsch', '크바치', '헛소리'), DeExample('quietschen', '크비첸', '삐걱거리다'), DeExample('quasi', '크바지', '사실상')],
  ),
  DeSoundUnit(
    id: 'ng', glyph: 'ng', group: 'cluster', ko: 'ㅇ', ipa: 'ŋ',
    how: '혀 뒤쪽을 여린입천장에 붙이고 코로 소리를 낸다(연구개 비음). g 는 따로 소리 내지 않는다.',
    korSim: "받침 'ㅇ'",
    korDiff: "받침 'ㅇ' 하나. lange = '랑에'(랑게 X), Junge = '융에'.",
    place: 'velar',
    ex: [DeExample('lange', '랑에', '오래'), DeExample('jung', '융', '젊은'), DeExample('Ding', '딩', '물건')],
  ),
  DeSoundUnit(
    id: 'tsch', glyph: 'tsch', group: 'cluster', ko: 'ㅊ', ipa: 't͡ʃ',
    how: '혀끝을 잇몸에 붙였다 떼며 sch 바람으로 푼다(무성 후치경 파찰음). 입술은 둥글게.',
    korSim: 'ㅊ (치)',
    korDiff: "한국어 'ㅊ'과 비슷하지만 입술을 둥글게 내밀어 '츄'에 가깝다. deutsch = '도이치'.",
    place: 'postalveolar',
    ex: [DeExample('deutsch', '도이치', '독일의'), DeExample('Quatsch', '크바치', '헛소리')],
  ),
  DeSoundUnit(
    id: 'ck', glyph: 'ck', group: 'cluster', ko: 'ㄱ · ㅋ', ipa: 'k',
    how: 'k 하나와 같은 소리. 앞 모음이 짧다는 표시다.',
    korSim: "받침 'ㄱ' / 'ㅋ'",
    korDiff: "k 를 두 번 읽지 않는다. 앞 모음을 짧게 끊는 것이 핵심 — Glück = '글뤽'.",
    place: 'velar',
    ex: [DeExample('zurück', '추뤽', '뒤로'), DeExample('Glück', '글뤽', '행운'), DeExample('Stück', '슈튁', '조각')],
  ),
  DeSoundUnit(
    id: 'chs', glyph: 'chs', group: 'cluster', ko: 'ㅋㅅ', ipa: 'ks',
    how: '낱말 안의 chs 는 대개 x 와 같은 [ks].',
    korSim: "'ㄱ받침+ㅅ'",
    korDiff: "ch 를 '흐'로 읽지 않는다. wachsen = '박센'.",
    place: 'velar',
    ex: [DeExample('wachsen', '박센', '자라다'), DeExample('wechseln', '벡셀른', '바꾸다')],
  ),

  // ───────── 음절 끝 규칙 ─────────
  DeSoundUnit(
    id: 'fin_er', glyph: '-er', group: 'final', ko: '어', ipa: 'ɐ',
    how: '강세 없는 끝 -er 는 r 을 굴리지 않고 입을 반쯤 벌린 약한 「어」[ɐ]가 된다.',
    korSim: '어',
    korDiff: "'ㄹ'을 붙이지 않는다. aber = '아버'(아베르 X), immer = '이머'.",
    vowel: _chartEr,
    ex: [DeExample('aber', '아버', '그러나'), DeExample('oder', '오더', '또는'), DeExample('immer', '이머', '항상')],
  ),
  DeSoundUnit(
    id: 'fin_r', glyph: '-r', group: 'final', ko: '어', ipa: 'ɐ̯',
    how: '모음 뒤 음절 끝의 r 은 목젖 소리 대신 짧은 「어」로 녹아 앞 모음에 붙는다.',
    korSim: '어',
    korDiff: "'ㄹ' 받침이 아니다. wir = '비어'(빌 X), hier = '히어', mehr = '메어'.",
    vowel: _chartEr,
    ex: [DeExample('wir', '비어', '우리'), DeExample('hier', '히어', '여기'), DeExample('mehr', '메어', '더')],
  ),
  DeSoundUnit(
    id: 'fin_b', glyph: '-b', group: 'final', ko: 'ㅍ', ipa: 'p',
    how: '낱말·음절 끝의 b·d·g 는 울림을 잃고 p·t·k 가 된다(끝소리 무성화).',
    korSim: "'프' / 받침 'ㅂ'",
    korDiff: "ab = '압', halb = '할프'. 울리는 'ㅂ'로 끝내지 않는다.",
    place: 'bilabial',
    ex: [DeExample('ab', '압', '~부터'), DeExample('halb', '할프', '절반의'), DeExample('lieb', '립', '사랑스러운')],
  ),
  DeSoundUnit(
    id: 'fin_d', glyph: '-d', group: 'final', ko: 'ㅌ', ipa: 't',
    how: '끝의 d 는 [t].',
    korSim: "'트' (ㅌ)",
    korDiff: "und = '운트', Kind = '킨트'. '운드'처럼 울리지 않는다.",
    place: 'alveolar',
    ex: [DeExample('und', '운트', '그리고'), DeExample('Kind', '킨트', '아이'), DeExample('Freund', '프로인트', '친구')],
  ),
  DeSoundUnit(
    id: 'fin_g', glyph: '-g', group: 'final', ko: 'ㅋ', ipa: 'k',
    how: '끝의 g 는 [k]. (단, -ig 는 따로 — 아래 칸.)',
    korSim: "'크' / 받침 'ㄱ'",
    korDiff: "Tag = '탁', genug = '게누크'.",
    place: 'velar',
    ex: [DeExample('Tag', '탁', '날'), DeExample('genug', '게누크', '충분한'), DeExample('weg', '베크', '떠나서')],
  ),
  DeSoundUnit(
    id: 'fin_ig', glyph: '-ig', group: 'final', ko: '이히', ipa: 'ɪç',
    how: '끝의 -ig 는 g 가 ich 의 ch[ç]로 바뀐다(표준 발음).',
    korSim: '이히',
    korDiff: "'이크'가 아니라 '이히'. richtig = '리히티히'. 남부·오스트리아에서는 [ɪk]도 쓴다.",
    place: 'palatal',
    ex: [DeExample('richtig', '리히티히', '옳은'), DeExample('wichtig', '비히티히', '중요한'), DeExample('König', '쾨니히', '왕')],
  ),
  DeSoundUnit(
    id: 'fin_s', glyph: 's+모음', group: 'final', ko: 'ㅈ', ipa: 'z',
    how: '모음 앞의 s 는 성대가 울리는 [z]. 낱말 첫머리든 모음 사이든 같다.',
    korSim: "'ㅈ' (울리는 ㅅ)",
    korDiff: "sehr = '제어', Musik = '무지크'. 혀를 붙이는 'ㅈ'가 아니라 'ㅅ'에 목소리를 얹은 '즈-'.",
    place: 'alveolar',
    ex: [DeExample('sehr', '제어', '매우'), DeExample('sagen', '자겐', '말하다'), DeExample('Musik', '무지크', '음악')],
  ),
  DeSoundUnit(
    id: 'fin_h', glyph: '모음+h', group: 'final', ko: '길게', ipa: 'ː',
    how: '모음 뒤의 h 는 소리가 없고, 앞 모음을 길게 하라는 표시다.',
    korSim: '앞 모음을 길게',
    korDiff: "fahren = '파렌', Sohn = '존'. 'ㅎ'를 넣지 않는다.",
    ex: [DeExample('fahren', '파렌', '(차를) 타다'), DeExample('Sohn', '존', '아들'), DeExample('sehr', '제어', '매우')],
  ),
];
