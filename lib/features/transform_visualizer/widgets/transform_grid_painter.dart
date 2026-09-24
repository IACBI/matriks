import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws the plane under the matrix [[a, b], [c, d]].
///
/// A faint copy of the untransformed grid stays behind the moving one so the
/// learner can compare before and after. [viewRadius] is how many units the
/// shorter side of the canvas spans from the centre; the screen derives it
/// from both endpoints of an animation, so the view does not zoom while the
/// grid moves.
class TransformGridPainter extends CustomPainter {
  final double a;
  final double b;
  final double c;
  final double d;
  final bool isDark;
  final double textScale;
  final double viewRadius;
  final Color iColor;
  final Color jColor;

  /// Unit directions of real eigenvectors of the target matrix, drawn as
  /// dashed lines through the origin.
  final List<Offset> eigenDirections;

  TransformGridPainter({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.isDark,
    this.textScale = 1,
    this.viewRadius = 3.5,
    this.iColor = const Color(0xFF3B82F6),
    this.jColor = const Color(0xFF10B981),
    this.eigenDirections = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final unitScale = math.min(size.width, size.height) / (2 * viewRadius);

    Offset toCanvas(double x, double y, {bool transformed = true}) {
      final tx = transformed ? a * x + b * y : x;
      final ty = transformed ? c * x + d * y : y;
      // Invert Y because canvas Y goes downwards.
      return Offset(center.dx + tx * unitScale, center.dy - ty * unitScale);
    }

    // Enough lines to reach the corners, thinned so neighbours stay at least
    // 8 px apart however far the view is zoomed out.
    final extent = math.max(size.width, size.height) / unitScale / 2;

    // 1. The untransformed plane, for comparison.
    final referencePaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: .07)
      ..strokeWidth = 1;
    _drawGrid(
      canvas,
      extent: extent,
      step: math.max(1, (8 / unitScale).ceil()),
      point: (x, y) => toCanvas(x, y, transformed: false),
      paint: (_) => referencePaint,
    );

    // 2. The transformed grid. A degenerate matrix collapses the plane onto a
    // line or a point; the same lines are drawn and overlap.
    final gridPaint = Paint()
      ..color = isDark
          ? const Color(0xFF334155).withValues(alpha: 0.7)
          : const Color(0xFFD5DCE6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final axisPaint = Paint()
      ..color = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    // The shortest image of a unit step decides how far the source grid must
    // reach and how sparse it must be to stay readable.
    final shortest = math.min(
      math.sqrt(a * a + c * c),
      math.sqrt(b * b + d * d),
    );
    final stretch = shortest < 1e-6 ? 1.0 : shortest;
    _drawGrid(
      canvas,
      extent: extent / stretch,
      step: math.max(1, (8 / (unitScale * stretch)).ceil()),
      point: toCanvas,
      paint: (i) => i == 0 ? axisPaint : gridPaint,
    );

    // 3. Directions that stay on their own line.
    final eigenPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: .45)
      ..strokeWidth = 1.5;
    final reach = math.max(size.width, size.height);
    for (final direction in eigenDirections) {
      _drawDashed(
        canvas,
        center - direction * reach,
        center + direction * reach,
        eigenPaint,
      );
    }

    // 4. Transformed unit square; orange when orientation is kept, red when
    // it is flipped (negative determinant).
    final flipped = a * d - b * c < 0;
    final areaColor = flipped ? const Color(0xFFE11D48) : const Color(0xFFF59E0B);
    final p00 = toCanvas(0, 0);
    final p10 = toCanvas(1, 0);
    final p11 = toCanvas(1, 1);
    final p01 = toCanvas(0, 1);
    final areaPath = Path()
      ..moveTo(p00.dx, p00.dy)
      ..lineTo(p10.dx, p10.dy)
      ..lineTo(p11.dx, p11.dy)
      ..lineTo(p01.dx, p01.dy)
      ..close();
    canvas
      ..drawPath(
        areaPath,
        Paint()
          ..color = areaColor.withValues(alpha: 0.22)
          ..style = PaintingStyle.fill,
      )
      ..drawPath(
        areaPath,
        Paint()
          ..color = areaColor.withValues(alpha: 0.7)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );

    // Coincident basis vectors share one label instead of obscuring each other.
    if ((p10 - p01).distance < .1) {
      _drawArrow(canvas, p00, p10, iColor, label: 'î = ĵ');
    } else {
      _drawArrow(canvas, p00, p10, iColor, label: 'î');
      _drawArrow(canvas, p00, p01, jColor, label: 'ĵ');
    }

    canvas.drawCircle(
      p00,
      3.5,
      Paint()
        ..color = isDark ? Colors.white : Colors.black
        ..style = PaintingStyle.fill,
    );
  }

  /// Lines x = k·step and y = k·step reaching [extent] in source units,
  /// capped so an extreme matrix cannot ask for thousands of lines.
  void _drawGrid(
    Canvas canvas, {
    required double extent,
    required int step,
    required Offset Function(double x, double y) point,
    required Paint Function(int index) paint,
  }) {
    final count = math.min((extent / step).ceil() + 1, 150);
    final reach = (count * step).toDouble();
    for (var k = -count; k <= count; k++) {
      final v = (k * step).toDouble();
      final linePaint = paint(k);
      canvas
        ..drawLine(point(v, -reach), point(v, reach), linePaint)
        ..drawLine(point(-reach, v), point(reach, v), linePaint);
    }
  }

  void _drawDashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    final delta = to - from;
    final length = delta.distance;
    if (length == 0) return;
    final unit = delta / length;
    const dash = 8.0;
    const gap = 6.0;
    for (var t = 0.0; t < length; t += dash + gap) {
      canvas.drawLine(
        from + unit * t,
        from + unit * math.min(t + dash, length),
        paint,
      );
    }
  }

  void _drawArrow(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color, {
    required String label,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final isZero = (end - start).distance < .1;
    if (!isZero) canvas.drawLine(start, end, paint);

    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    const arrowSize = 10.0;
    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowSize * math.cos(angle - math.pi / 6),
        end.dy - arrowSize * math.sin(angle - math.pi / 6),
      )
      ..lineTo(
        end.dx - arrowSize * math.cos(angle + math.pi / 6),
        end.dy - arrowSize * math.sin(angle + math.pi / 6),
      )
      ..close();
    if (!isZero) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: isZero ? '$label = 0' : label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 13 * textScale,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        end.dx + 20 * textScale * math.cos(angle),
        end.dy - 20 * textScale - (textPainter.height / 2),
      ),
    );
    textPainter.dispose();
  }

  @override
  bool shouldRepaint(covariant TransformGridPainter oldDelegate) =>
      oldDelegate.a != a ||
      oldDelegate.b != b ||
      oldDelegate.c != c ||
      oldDelegate.d != d ||
      oldDelegate.isDark != isDark ||
      oldDelegate.textScale != textScale ||
      oldDelegate.viewRadius != viewRadius ||
      oldDelegate.iColor != iColor ||
      oldDelegate.jColor != jColor ||
      !_sameDirections(oldDelegate.eigenDirections, eigenDirections);

  static bool _sameDirections(List<Offset> x, List<Offset> y) {
    if (x.length != y.length) return false;
    for (var i = 0; i < x.length; i++) {
      if (x[i] != y[i]) return false;
    }
    return true;
  }
}
