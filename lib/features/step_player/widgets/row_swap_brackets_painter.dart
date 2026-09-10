import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Custom painter for animated curved swap brackets that visually link
/// the two swapping rows with directional arrows and clear curved paths.
class RowSwapBracketsPainter extends CustomPainter {
  final int rowA;
  final int rowB;
  final double cellHeight;
  final double progress; // 0.0 to 1.0
  final bool isDark;

  const RowSwapBracketsPainter({
    required this.rowA,
    required this.rowB,
    required this.cellHeight,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final topRow = math.min(rowA, rowB);
    final bottomRow = math.max(rowA, rowB);

    final yStart = topRow * cellHeight + cellHeight / 2;
    final yEnd = bottomRow * cellHeight + cellHeight / 2;
    final xBase = size.width - 4;
    final curveBulge = 18.0;

    final path = Path()..moveTo(xBase, yStart);
    final controlX = xBase - curveBulge;
    final controlY = (yStart + yEnd) / 2;
    path.quadraticBezierTo(controlX, controlY, xBase, yEnd);

    final color = AppTheme.accentPurple.withValues(alpha: 0.8);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Arrow heads on both ends
    _drawArrowHead(
      canvas,
      Offset(xBase, yStart),
      angle: -math.pi / 4,
      color: color,
    );
    _drawArrowHead(
      canvas,
      Offset(xBase, yEnd),
      angle: math.pi / 4,
      color: color,
    );
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset tip, {
    required double angle,
    required Color color,
  }) {
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final arrowSize = 6.0;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - arrowSize, tip.dy - arrowSize * 0.7)
      ..lineTo(tip.dx - arrowSize, tip.dy + arrowSize * 0.7)
      ..close();

    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(angle);
    canvas.translate(-tip.dx, -tip.dy);
    canvas.drawPath(path, arrowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RowSwapBracketsPainter oldDelegate) {
    return oldDelegate.cellHeight != cellHeight ||
        oldDelegate.progress != progress ||
        oldDelegate.rowA != rowA ||
        oldDelegate.rowB != rowB ||
        oldDelegate.isDark != isDark;
  }
}
