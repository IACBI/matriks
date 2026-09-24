import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/theme/app_theme.dart';

/// Only draws factor relationships. Scalable, accessible formulas live in widgets.
///
/// Products marked + are green and products marked − are red, matching the
/// explanation below the matrix. Products already covered stay visible,
/// faded, so the learner can see which diagonals have been counted.
class DeterminantLinesPainter extends CustomPainter {
  final int rows;
  final int cols;
  final double cellWidth;
  final double cellHeight;
  final StepTransformation transformation;
  final double progress;

  /// When the first two columns are drawn again to the right of a 3×3
  /// matrix, the distance between the last real column and the first copy.
  /// Every Sarrus diagonal is then a straight line, as it is usually taught.
  /// Without copies the wrapped diagonals bend back inside the matrix.
  final double? copiedColumnsGap;

  /// Draw every product of the step at once, without motion: reduced motion
  /// and static steps still need to see which entries are multiplied.
  final bool showAll;

  const DeterminantLinesPainter({
    required this.rows,
    required this.cols,
    required this.cellWidth,
    required this.cellHeight,
    required this.transformation,
    required this.progress,
    this.copiedColumnsGap,
    this.showAll = false,
  });

  List<(List<(int, int)>, Color)> _paths() {
    final paths = <(List<(int, int)>, Color)>[];
    final trans = transformation;
    if (trans is DeterminantCrossProductTransformation &&
        rows == 2 &&
        cols == 2) {
      if (trans.phase != 2) paths.add(([(0, 0), (1, 1)], AppTheme.accentGreen));
      if (trans.phase != 1) paths.add(([(0, 1), (1, 0)], AppTheme.accentRed));
    } else if (trans is DeterminantSarrusTransformation &&
        rows >= 3 &&
        cols >= 3) {
      final wrap = copiedColumnsGap == null;
      if (trans.phase != 2) {
        for (var i = 0; i < 3; i++) {
          paths.add((
            List.generate(3, (r) => (r, wrap ? (i + r) % 3 : i + r)),
            AppTheme.accentGreen,
          ));
        }
      }
      if (trans.phase != 1) {
        for (var i = 0; i < 3; i++) {
          paths.add((
            List.generate(3, (r) => (r, wrap ? (2 + i - r) % 3 : 2 + i - r)),
            AppTheme.accentRed,
          ));
        }
      }
    }
    return paths;
  }

  double _x(int column) {
    final gap = copiedColumnsGap;
    if (gap == null || column < cols) return (column + .5) * cellWidth;
    return cols * cellWidth + gap + (column - cols + .5) * cellWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paths = _paths();
    if (paths.isEmpty) return;
    final radius = math.min(cellWidth, cellHeight) * .34;
    Offset centre((int, int) cell) =>
        Offset(_x(cell.$2), (cell.$1 + .5) * cellHeight);
    if (showAll) {
      for (final (cells, color) in paths) {
        _drawPath(canvas, [for (final cell in cells) centre(cell)], color, 1, radius);
      }
      return;
    }
    if (progress <= 0 || progress >= 1) return;
    final scaled = progress * paths.length;
    final index = scaled.floor().clamp(0, paths.length - 1);
    final local = (scaled - index).clamp(0.0, 1.0);
    for (var p = 0; p <= index; p++) {
      final (cells, color) = paths[p];
      _drawPath(
        canvas,
        [for (final cell in cells) centre(cell)],
        p == index ? color : color.withValues(alpha: .3),
        p == index ? local : 1,
        radius,
      );
    }
  }

  void _drawPath(
    Canvas canvas,
    List<Offset> points,
    Color color,
    double reveal,
    double radius,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < points.length; i++) {
      if (reveal >= i / points.length) {
        canvas.drawCircle(points[i], radius, paint);
      }
    }
    // Leave a gap around each value so the line cannot obscure the number.
    for (var i = 0; i < points.length - 1; i++) {
      final delta = points[i + 1] - points[i];
      final length = delta.distance;
      if (length <= radius * 2) continue;
      final start = points[i] + delta / length * radius;
      final end = points[i + 1] - delta / length * radius;
      final segment = (reveal * (points.length - 1) - i).clamp(0.0, 1.0);
      canvas.drawLine(start, Offset.lerp(start, end, segment)!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DeterminantLinesPainter old) =>
      old.rows != rows ||
      old.cols != cols ||
      old.cellWidth != cellWidth ||
      old.cellHeight != cellHeight ||
      old.transformation != transformation ||
      old.progress != progress ||
      old.copiedColumnsGap != copiedColumnsGap ||
      old.showAll != showAll;
}
