import 'package:flutter/material.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/math_text.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Show the actual operands, never source beams on the output matrix.
///
/// Every entry keeps a frame of the same width whether it is active or not,
/// so moving to the next term changes a colour and never reflows the vector.
class MultiplicationSources extends StatelessWidget {
  final MatrixElementMultiplicationTransformation transformation;
  final int activeTerm;
  const MultiplicationSources({
    super.key,
    required this.transformation,
    this.activeTerm = -1,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scaler = MediaQuery.textScalerOf(context);

    Widget entry(Rational value, bool active, Color color) => AnimatedContainer(
      duration: AppTheme.motion(context),
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      constraints: BoxConstraints(minWidth: scaler.scale(36)),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: .12) : Colors.transparent,
        border: Border.all(
          color: active ? color : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      alignment: Alignment.center,
      child: MathText(value.toLatex(), fontSize: 20),
    );

    Widget vector(
      String label,
      List<Rational> values,
      bool vertical,
      Color color,
    ) {
      final entries = [
        for (var i = 0; i < values.length; i++)
          entry(values[i], i == activeTerm, color),
      ];
      final body = vertical
          ? Column(mainAxisSize: MainAxisSize.min, children: entries)
          : Row(mainAxisSize: MainAxisSize.min, children: entries);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: color, width: 2)),
            ),
            child: CustomPaint(
              painter: _BracketsPainter(
                theme.brightness == Brightness.dark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF475569),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: body,
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            vector(
              l10n.multiplicationSourceRow('${transformation.targetRow + 1}'),
              transformation.rowElements,
              false,
              AppTheme.accentAmber,
            ),
            const SizedBox(width: 24),
            vector(
              l10n.multiplicationSourceColumn(
                '${transformation.targetCol + 1}',
              ),
              transformation.colElements,
              true,
              AppTheme.accentAmber,
            ),
          ],
        ),
      ),
    );
  }
}

/// Square brackets on both sides of whatever the child's size turns out to be.
class _BracketsPainter extends CustomPainter {
  final Color color;
  const _BracketsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const tick = 6.0;
    final h = size.height;
    final w = size.width;
    canvas
      ..drawPath(
        Path()
          ..moveTo(tick, 1)
          ..lineTo(1, 1)
          ..lineTo(1, h - 1)
          ..lineTo(tick, h - 1),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(w - tick, 1)
          ..lineTo(w - 1, 1)
          ..lineTo(w - 1, h - 1)
          ..lineTo(w - tick, h - 1),
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant _BracketsPainter oldDelegate) =>
      oldDelegate.color != color;
}
