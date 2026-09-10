import 'package:flutter/material.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/math_text.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Show the actual operands, never source beams on the output matrix.
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
    Widget vector(
      String label,
      List<Rational> values,
      bool vertical,
      Color color,
    ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: color, width: 2)),
            ),
            child: MathText(
              r'\begin{bmatrix}' +
                  List.generate(values.length, (i) {
                    final value = values[i].toLatex();
                    return i == activeTerm ? '\\boxed{$value}' : value;
                  }).join(vertical ? r' \\ ' : ' & ') +
                  r'\end{bmatrix}',
              fontSize: 20,
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
              AppTheme.accentPurple,
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
