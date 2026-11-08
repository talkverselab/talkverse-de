import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../services/de_phonetics.dart';

/// IPA 모음 사다리꼴 1장 위에 독일어 모음(진한 ●)과 한국어 모음(파랑 ●)을 함께 찍는다.
/// 일본어앱 vowel_compare_chart.dart 를 독일어 vs 한국어로 옮긴 것. 이중모음은 화살표.
class DeVowelChart extends StatelessWidget {
  final DeVowelChartData data;
  const DeVowelChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.45,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.washi,
              border: Border.all(color: AppColors.kinDeep.withValues(alpha: 0.6)),
            ),
            padding: const EdgeInsets.fromLTRB(30, 22, 12, 12),
            child: CustomPaint(
              painter: _TrapezoidPainter(data, tr('전설'), tr('중설'), tr('후설'), tr('고'), tr('중'), tr('저')),
              size: Size.infinite,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          children: [
            _legendDot(AppColors.beni, tr('독일어')),
            _legendDot(AppColors.ai, tr('한국어')),
          ],
        ),
        const SizedBox(height: 4),
        Text(data.note, style: const TextStyle(fontSize: 11.5, color: AppColors.sumi, height: 1.45)),
      ],
    );
  }

  Widget _legendDot(Color c, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c)),
      ],
    );
  }
}

class _TrapezoidPainter extends CustomPainter {
  final DeVowelChartData data;
  final String front, central, back, high, mid, low;
  _TrapezoidPainter(this.data, this.front, this.central, this.back, this.high, this.mid, this.low);

  // IPA 사다리꼴: 위 변은 전체 폭, 아래로 갈수록 전설 경계가 오른쪽으로.
  Offset _map(double x, double y, Size s) {
    final left = 0.38 * s.width * y;
    return Offset(left + (s.width - left) * x, y * s.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.sumiLight.withValues(alpha: 0.45)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(_map(0, 0, size).dx, _map(0, 0, size).dy)
      ..lineTo(_map(1, 0, size).dx, _map(1, 0, size).dy)
      ..lineTo(_map(1, 1, size).dx, _map(1, 1, size).dy)
      ..lineTo(_map(0, 1, size).dx, _map(0, 1, size).dy)
      ..close();
    canvas.drawPath(path, grid);
    for (final y in [1 / 3, 2 / 3]) {
      canvas.drawLine(_map(0, y, size), _map(1, y, size), grid);
    }
    canvas.drawLine(_map(0.5, 0, size), _map(0.5, 1, size), grid);

    _text(canvas, front, Offset(_map(0, 0, size).dx - 2, -18), 9);
    _text(canvas, central, Offset(_map(0.5, 0, size).dx - 10, -18), 9);
    _text(canvas, back, Offset(size.width - 22, -18), 9);
    _text(canvas, high, Offset(-24, _map(0, 0, size).dy - 5), 9);
    _text(canvas, mid, Offset(-24, _map(0, 0.5, size).dy - 5), 9);
    _text(canvas, low, Offset(-24, size.height - 10), 9);

    final base = _map(data.de.first.x, data.de.first.y, size);
    // 독일어 기준점 ↔ 한국어 점선
    for (final k in data.ko) {
      _dashedLine(canvas, base, _map(k.x, k.y, size),
          Paint()
            ..color = AppColors.sumiLight.withValues(alpha: 0.6)
            ..strokeWidth = 1);
    }
    // 이중모음 화살표
    if (data.glide && data.de.length > 1) {
      final to = _map(data.de[1].x, data.de[1].y, size);
      final arrow = Paint()
        ..color = AppColors.beni
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(base, to, arrow);
      final dir = (to - base) / (to - base).distance;
      final n = Offset(-dir.dy, dir.dx);
      final tip = to - dir * 8;
      canvas.drawPath(
          Path()
            ..moveTo(to.dx, to.dy)
            ..lineTo((tip + n * 5).dx, (tip + n * 5).dy)
            ..lineTo((tip - n * 5).dx, (tip - n * 5).dy)
            ..close(),
          Paint()..color = AppColors.beni);
    }

    for (final k in data.ko) {
      final p = _map(k.x, k.y, size);
      canvas.drawCircle(p, 5, Paint()..color = AppColors.ai);
      _pointLabel(canvas, size, p, '${k.ipa} ${k.label}', AppColors.ai, left: true);
    }
    for (var i = 0; i < data.de.length; i++) {
      final d = data.de[i];
      final p = _map(d.x, d.y, size);
      final r = i == 0 ? 7.0 : 5.5;
      canvas.drawCircle(p, r, Paint()..color = AppColors.beni);
      canvas.drawCircle(
          p,
          r,
          Paint()
            ..color = AppColors.washi
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
      _pointLabel(canvas, size, p, '${d.ipa} ${d.label}', AppColors.beni, bold: true);
    }
  }

  void _pointLabel(Canvas canvas, Size size, Offset p, String s, Color c, {bool bold = false, bool left = false}) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(fontSize: bold ? 12 : 10.5, fontWeight: bold ? FontWeight.w900 : FontWeight.w700, color: c)),
      textDirection: TextDirection.ltr,
    )..layout();
    // 독일어는 점 오른쪽, 한국어는 왼쪽(겹침 줄이기). 넘치면 반대쪽.
    var dx = left ? p.dx - tp.width - 9 : p.dx + 9;
    if (dx < 0) dx = p.dx + 9;
    if (dx + tp.width > size.width) dx = p.dx - tp.width - 9;
    var dy = p.dy - tp.height / 2 + (left ? 8 : 0);
    if (dy < 0) dy = 0;
    if (dy + tp.height > size.height) dy = size.height - tp.height;
    tp.paint(canvas, Offset(dx, dy));
  }

  void _text(Canvas canvas, String s, Offset o, double fs) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(fontSize: fs, color: AppColors.sumiLight, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, o);
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 4.0, gap = 3.0;
    final d = (b - a).distance;
    if (d == 0) return;
    final dir = (b - a) / d;
    var t = 0.0;
    while (t < d) {
      final end = (t + dash).clamp(0.0, d);
      canvas.drawLine(a + dir * t, a + dir * end, paint);
      t += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _TrapezoidPainter old) => old.data != data;
}
