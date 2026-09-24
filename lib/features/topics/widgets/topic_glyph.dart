import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/topic_item.dart';

/// A small drawing of what an operation does to a matrix: the staircase of
/// an echelon form, the identity of RREF, the crossing diagonals of a
/// determinant. It stands next to the topic's name, which carries the
/// meaning for screen readers.
class TopicGlyph extends StatelessWidget {
  final TopicType type;
  final double size;

  const TopicGlyph({super.key, required this.type, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(size / 4),
        ),
        child: CustomPaint(
          painter: _GlyphPainter(
            type: type,
            strong: scheme.primary,
            weak: scheme.onSurfaceVariant.withValues(alpha: 0.28),
          ),
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  final TopicType type;
  final Color strong;
  final Color weak;

  const _GlyphPainter({
    required this.type,
    required this.strong,
    required this.weak,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final inset = size.width * 0.22;
    final area = size.width - 2 * inset;
    final cell = area / 3;
    final fill = Paint();
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, size.width / 22)
      ..strokeCap = StrokeCap.round;

    Rect rect(int r, int c) => Rect.fromLTWH(
      inset + c * cell + 1,
      inset + r * cell + 1,
      cell - 2,
      cell - 2,
    );
    void cellAt(int r, int c, Color color) => canvas.drawRRect(
      RRect.fromRectAndRadius(rect(r, c), const Radius.circular(1.5)),
      fill..color = color,
    );
    void grid(Color Function(int r, int c) color) {
      for (var r = 0; r < 3; r++) {
        for (var c = 0; c < 3; c++) {
          cellAt(r, c, color(r, c));
        }
      }
    }

    Offset at(double x, double y) =>
        Offset(inset + x * area, inset + y * area);
    void line(Offset a, Offset b, Color color) =>
        canvas.drawLine(a, b, stroke..color = color);
    void arrow(Offset from, Offset to, Color color) {
      line(from, to, color);
      final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
      final head = area * 0.18;
      for (final turn in [-2.6, 2.6]) {
        line(
          to,
          to + Offset(math.cos(angle + turn), math.sin(angle + turn)) * head,
          color,
        );
      }
    }

    void label(String text, Offset center, double fontSize) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: strong,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        center - Offset(painter.width / 2, painter.height / 2),
      );
    }

    switch (type) {
      case TopicType.gauss:
        // Zeros below the pivots: a staircase.
        grid((r, c) => c >= r ? strong : weak);
      case TopicType.rref:
        grid((r, c) => r == c ? strong : weak);
      case TopicType.linearSystems:
        grid((r, c) => c == 2 ? strong : weak);
        line(at(2 / 3, -0.05), at(2 / 3, 1.05), strong);
      case TopicType.determinant:
        grid((r, c) => weak);
        line(at(0.05, 0.05), at(0.95, 0.95), strong);
        line(at(0.95, 0.05), at(0.05, 0.95), strong.withValues(alpha: 0.5));
      case TopicType.inverse:
        grid((r, c) => r == c ? strong : weak);
        label('−1', at(1.05, -0.12), size.width * 0.24);
      case TopicType.rankNullity:
        // Two independent rows and a row that reduces to zeros.
        grid((r, c) => r < 2 ? strong : Colors.transparent);
        for (var c = 0; c < 3; c++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect(2, c), const Radius.circular(1.5)),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = weak,
          );
        }
      case TopicType.eigen:
        // A direction the matrix only stretches.
        arrow(at(0.05, 0.95), at(0.45, 0.55), weak);
        arrow(at(0.05, 0.95), at(0.95, 0.05), strong);
      case TopicType.lu:
        grid(
          (r, c) => r > c
              ? strong.withValues(alpha: 0.55)
              : r == c
              ? strong
              : weak,
        );
      case TopicType.transform2d:
        final square = Path()
          ..moveTo(at(0, 1).dx, at(0, 1).dy)
          ..lineTo(at(0.6, 1).dx, at(0.6, 1).dy)
          ..lineTo(at(0.6, 0.4).dx, at(0.6, 0.4).dy)
          ..lineTo(at(0, 0.4).dx, at(0, 0.4).dy)
          ..close();
        final sheared = Path()
          ..moveTo(at(0, 1).dx, at(0, 1).dy)
          ..lineTo(at(0.6, 1).dx, at(0.6, 1).dy)
          ..lineTo(at(1, 0.2).dx, at(1, 0.2).dy)
          ..lineTo(at(0.4, 0.2).dx, at(0.4, 0.2).dy)
          ..close();
        canvas.drawPath(square, stroke..color = weak);
        canvas.drawPath(sheared, stroke..color = strong);
      case TopicType.practice:
        label('?', at(0.5, 0.5), size.width * 0.5);
      case TopicType.add:
        grid((r, c) => weak);
        line(at(0.5, 0.2), at(0.5, 0.8), strong);
        line(at(0.2, 0.5), at(0.8, 0.5), strong);
      case TopicType.multiply:
        // A row of A meets a column of B in one entry.
        grid((r, c) => r == 1 || c == 1 ? strong : weak);
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.strong != strong ||
      oldDelegate.weak != weak;
}
