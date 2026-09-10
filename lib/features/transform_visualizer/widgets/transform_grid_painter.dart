import 'dart:math' as math;

import 'package:flutter/material.dart';

class TransformGridPainter extends CustomPainter {
  final double a;
  final double b;
  final double c;
  final double d;
  final bool isDark;
  final double textScale;

  TransformGridPainter({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.isDark,
    this.textScale = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final unitScale = math.min(size.width, size.height) / 7.0; // 1 unit in grid

    // Helper: Map mathematical coordinate (x, y) to canvas (X, Y)
    Offset toCanvas(double x, double y) {
      final tx = a * x + b * y;
      final ty = c * x + d * y;
      // Invert Y because canvas Y goes downwards
      return Offset(center.dx + tx * unitScale, center.dy - ty * unitScale);
    }

    final gridPaint = Paint()
      ..color = isDark
          ? const Color(0xFF334155).withValues(alpha: 0.5)
          : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    // 1. Draw Transformed Grid Lines
    const gridRange = 3;
    for (int i = -gridRange; i <= gridRange; i++) {
      final p1 = toCanvas(i.toDouble(), -gridRange.toDouble());
      final p2 = toCanvas(i.toDouble(), gridRange.toDouble());
      canvas.drawLine(p1, p2, i == 0 ? axisPaint : gridPaint);

      final q1 = toCanvas(-gridRange.toDouble(), i.toDouble());
      final q2 = toCanvas(gridRange.toDouble(), i.toDouble());
      canvas.drawLine(q1, q2, i == 0 ? axisPaint : gridPaint);
    }

    // 2. Draw Transformed Unit Square (Parallelogram)
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

    final areaPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, areaPaint);

    final areaBorderPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(areaPath, areaBorderPaint);

    // Coincident basis vectors share one label instead of obscuring each other.
    if ((p10 - p01).distance < .1) {
      _drawArrow(canvas, p00, p10, const Color(0xFF3B82F6), label: 'î = ĵ');
    } else {
      _drawArrow(canvas, p00, p10, const Color(0xFF3B82F6), label: 'î');
      _drawArrow(canvas, p00, p01, const Color(0xFF10B981), label: 'ĵ');
    }

    // 5. Origin indicator dot
    final originPaint = Paint()
      ..color = isDark ? Colors.white : Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(p00, 3.5, originPaint);
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

    // Arrowhead
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final angle = math.atan2(dy, dx);
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

    final arrowHeadPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    if (!isZero) canvas.drawPath(path, arrowHeadPaint);

    // Vector Label (î or ĵ)
    final labelText = isZero ? '$label = 0' : label;
    final textSpan = TextSpan(
      text: labelText,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w900,
        fontSize: 13 * textScale,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final labelOffset = Offset(
      end.dx + 20 * textScale * math.cos(angle),
      end.dy - 20 * textScale - (textPainter.height / 2),
    );
    textPainter.paint(canvas, labelOffset);
    textPainter.dispose();
  }

  @override
  bool shouldRepaint(covariant TransformGridPainter oldDelegate) {
    return oldDelegate.a != a ||
        oldDelegate.b != b ||
        oldDelegate.c != c ||
        oldDelegate.d != d ||
        oldDelegate.isDark != isDark ||
        oldDelegate.textScale != textScale;
  }
}
