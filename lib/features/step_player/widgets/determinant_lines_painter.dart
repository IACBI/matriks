import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/theme/app_theme.dart';

/// Only draws factor relationships. Scalable, accessible formulas live in widgets.
class DeterminantLinesPainter extends CustomPainter {
  final int rows;
  final int cols;
  final double cellWidth;
  final double cellHeight;
  final StepTransformation transformation;
  final double progress;
  final bool isDark;

  const DeterminantLinesPainter({
    required this.rows,
    required this.cols,
    required this.cellWidth,
    required this.cellHeight,
    required this.transformation,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final paths = <(List<(int, int)>, Color)>[];
    final trans = transformation;
    if (trans is DeterminantCrossProductTransformation &&
        rows == 2 &&
        cols == 2) {
      if (trans.phase != 2) paths.add(([(0, 0), (1, 1)], AppTheme.accentCyan));
      if (trans.phase != 1) paths.add(([(0, 1), (1, 0)], AppTheme.accentRed));
    } else if (trans is DeterminantSarrusTransformation &&
        rows >= 3 &&
        cols >= 3) {
      if (trans.phase != 2) {
        for (final columns in [
          [0, 1, 2],
          [1, 2, 0],
          [2, 0, 1],
        ]) {
          paths.add((
            List.generate(3, (r) => (r, columns[r])),
            AppTheme.accentGreen,
          ));
        }
      }
      if (trans.phase != 1) {
        for (final columns in [
          [2, 1, 0],
          [0, 2, 1],
          [1, 0, 2],
        ]) {
          paths.add((
            List.generate(3, (r) => (r, columns[r])),
            AppTheme.accentRed,
          ));
        }
      }
    }
    if (paths.isEmpty) return;
    final scaled = progress * paths.length;
    final index = scaled.floor().clamp(0, paths.length - 1);
    final local = (scaled - index).clamp(0.0, 1.0);
    final (cells, color) = paths[index];
    final points = cells
        .map(
          (cell) =>
              Offset((cell.$2 + .5) * cellWidth, (cell.$1 + .5) * cellHeight),
        )
        .toList();
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final radius = math.min(cellWidth, cellHeight) * .34;
    for (var i = 0; i < points.length; i++) {
      if (local >= i / points.length) {
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
      final segmentProgress = (local * (points.length - 1) - i).clamp(0.0, 1.0);
      canvas.drawLine(start, Offset.lerp(start, end, segmentProgress)!, paint);
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
      old.isDark != isDark;
}
