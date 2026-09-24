import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Curved connector with arrowheads linking the two rows of a swap.
///
/// The connector is static; the rows themselves carry the motion, so it only
/// repaints when the geometry changes.
class RowSwapBracketsPainter extends CustomPainter {
  final int rowA;
  final int rowB;
  final double cellHeight;

  const RowSwapBracketsPainter({
    required this.rowA,
    required this.rowB,
    required this.cellHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final topRow = math.min(rowA, rowB);
    final bottomRow = math.max(rowA, rowB);

    final start = Offset(size.width - 4, topRow * cellHeight + cellHeight / 2);
    final end = Offset(size.width - 4, bottomRow * cellHeight + cellHeight / 2);
    final control = Offset(start.dx - 18, (start.dy + end.dy) / 2);

    final color = AppTheme.accentAmber.withValues(alpha: 0.8);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // A quadratic Bézier leaves each end along the line to its control point,
    // so the arrowheads point along the curve at any row distance.
    _drawArrowHead(canvas, start, start - control, color);
    _drawArrowHead(canvas, end, end - control, color);
  }

  void _drawArrowHead(Canvas canvas, Offset tip, Offset direction, Color color) {
    final angle = math.atan2(direction.dy, direction.dx);
    const size = 7.0;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - size * math.cos(angle - math.pi / 7),
        tip.dy - size * math.sin(angle - math.pi / 7),
      )
      ..lineTo(
        tip.dx - size * math.cos(angle + math.pi / 7),
        tip.dy - size * math.sin(angle + math.pi / 7),
      )
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant RowSwapBracketsPainter oldDelegate) =>
      oldDelegate.cellHeight != cellHeight ||
      oldDelegate.rowA != rowA ||
      oldDelegate.rowB != rowB;
}
