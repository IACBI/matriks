import 'package:flutter/material.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/widgets/math_text.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'instruction_timeline.dart';

/// Presentation-only reasoning. Solver snapshots remain the source of truth.
class InstructionLesson {
  final String source;
  final String operation;
  final String result;
  final List<String> calculations;
  final List<String> markers;
  final String? rationale;

  const InstructionLesson(
    this.source,
    this.operation,
    this.result, [
    this.calculations = const [],
    this.markers = const [],
    this.rationale,
  ]);

  factory InstructionLesson.forStep({
    required StepTransformation? transformation,
    required MatrixSnapshot after,
    MatrixSnapshot? before,
    AppLocalizations? l10n,
  }) {
    final original = before ?? after;
    final trans = transformation;
    String math(Rational value) => '(${value.toLatex()})';
    if (trans is MatrixElementAdditionTransformation) {
      return InstructionLesson(
        l10n?.guideAddSource ?? 'Match the same position in A and B.',
        l10n?.guideAddApply ?? 'Add this pair of entries.',
        l10n?.guideAddResult ?? 'Their sum belongs in the same position in C.',
        [
          '${math(trans.left)} + ${math(trans.right)} = ${(trans.left + trans.right).toLatex()}',
        ],
      );
    }
    if (trans is RowEliminationTransformation) {
      var column = 0;
      for (var c = 0; c < after.cols; c++) {
        if (after.get(trans.targetRow, c) == Rational.zero &&
            original.get(trans.targetRow, c) != Rational.zero) {
          column = c;
          break;
        }
      }
      final source = '${trans.sourceRow + 1}';
      final target = '${trans.targetRow + 1}';
      final col = '${column + 1}';
      final value = after.get(trans.targetRow, column);
      final pivot = original.get(trans.sourceRow, column);
      final entry = original.get(trans.targetRow, column);
      final ratio = pivot == Rational.zero ? null : entry / pivot;
      final rationale = ratio == null
          ? null
          : l10n?.guideEliminateReason(
                  entry.toString(),
                  pivot.toString(),
                  ratio.toString(),
                ) ??
                'Target $entry ÷ pivot $pivot = $ratio. Subtract this multiple of the source row to cancel the target entry.';
      final sign = trans.factor.isNegative ? '-' : '+';
      return InstructionLesson(
        l10n?.guideEliminateSource(source, target, col) ??
            'Use row $source to change row $target. Focus on column $col.',
        trans.factor.isNegative
            ? l10n?.guideEliminateSubtract(
                    trans.factor.abs().toString(),
                    source,
                    target,
                  ) ??
                  'Subtract ${trans.factor.abs()} times row $source from row $target.'
            : l10n?.guideEliminateApply(
                    trans.factor.toString(),
                    source,
                    target,
                  ) ??
                  'Add ${trans.factor} times row $source to row $target.',
        l10n?.guideEliminateResult(col, value.toString()) ??
            'The entry in column $col is now $value.',
        [
          for (var c = 0; c < after.cols; c++)
            '${math(original.get(trans.targetRow, c))} $sign ${math(trans.factor.abs())} \\cdot ${math(original.get(trans.sourceRow, c))} = ${after.get(trans.targetRow, c).toLatex()}',
        ],
        const [],
        rationale,
      );
    }
    if (trans is RowScaleTransformation) {
      final row = '${trans.row + 1}';
      return InstructionLesson(
        l10n?.guideScaleSource(row, trans.scalar.toString()) ??
            'Scale row $row by ${trans.scalar}.',
        l10n?.guideScaleApply ?? 'Apply the factor to the whole row.',
        l10n?.guideScaleResult ?? 'Compare the scaled row with the original.',
        [
          for (var c = 0; c < after.cols; c++)
            '${math(trans.scalar)} \\cdot ${math(original.get(trans.row, c))} = ${after.get(trans.row, c).toLatex()}',
        ],
      );
    }
    if (trans is RowSwapTransformation) {
      return InstructionLesson(
        l10n?.guideSwapSource('${trans.rowA + 1}', '${trans.rowB + 1}') ??
            'Exchange rows ${trans.rowA + 1} and ${trans.rowB + 1}.',
        l10n?.guideSwapApply ?? 'Move the whole rows; values do not change.',
        l10n?.guideSwapResult ?? 'The rows are in their new positions.',
      );
    }
    if (trans is MatrixElementMultiplicationTransformation) {
      final terms = List.generate(
        trans.rowElements.length,
        (i) =>
            '${math(trans.rowElements[i])} \\cdot ${math(trans.colElements[i])}',
      );
      return InstructionLesson(
        l10n?.guideDotSource(
              '${trans.targetRow + 1}',
              '${trans.targetCol + 1}',
            ) ??
            'Pair the source row and column.',
        l10n?.guideDotApply ?? 'Multiply matching entries, then add.',
        l10n?.guideDotResult(
              '${trans.targetRow + 1}',
              '${trans.targetCol + 1}',
            ) ??
            'The sum is the output entry.',
        [...terms, '${terms.join(' + ')} = ${trans.result.toLatex()}'],
        const [],
        l10n?.guideDotReason ?? 'One output entry uses a whole row of A and a whole column of B. Multiply entries in matching positions, then add their contributions.',
      );
    }
    if (trans is DeterminantDiagonalProductTransformation) {
      var product = trans.sign;
      final factors = <String>[math(trans.sign)];
      final lines = <String>[];
      for (final value in trans.diagonalElements) {
        product *= value;
        factors.add(math(value));
        lines.add('${factors.join(r' \cdot ')} = ${product.toLatex()}');
      }
      return InstructionLesson(
        l10n?.guideDetSource ?? 'Follow the factors and signs of each product.',
        l10n?.guideDetApply ?? 'Follow one product at a time below the matrix.',
        l10n?.guideDetResult ?? 'Check the products at your own pace.',
        lines,
      );
    }
    if (trans is DeterminantCrossProductTransformation ||
        trans is DeterminantSarrusTransformation) {
      final lines = <String>[];
      final markers = <String>[];
      if (trans is DeterminantCrossProductTransformation) {
        if (trans.phase != 2) {
          final factors = original.rows == 2 && original.cols == 2
              ? '${math(original.get(0, 0))} \\cdot ${math(original.get(1, 1))} = '
              : '';
          lines.add('$factors${trans.mainDiagonalProduct.toLatex()}');
          markers.add('+');
        }
        if (trans.phase != 1) {
          final factors = original.rows == 2 && original.cols == 2
              ? '${math(original.get(0, 1))} \\cdot ${math(original.get(1, 0))} = '
              : '';
          lines.add('$factors${trans.antiDiagonalProduct.toLatex()}');
          markers.add('−');
        }
        if (trans.phase == 3) {
          lines.add(
            '${math(trans.mainDiagonalProduct)} - ${math(trans.antiDiagonalProduct)} = ${(trans.mainDiagonalProduct - trans.antiDiagonalProduct).toLatex()}',
          );
        }
      } else if (trans is DeterminantSarrusTransformation) {
        const positive = [
          [0, 1, 2],
          [1, 2, 0],
          [2, 0, 1],
        ];
        const negative = [
          [2, 1, 0],
          [0, 2, 1],
          [1, 0, 2],
        ];
        for (final group in [
          (positive, trans.positiveProducts, trans.phase != 2),
          (negative, trans.negativeProducts, trans.phase != 1),
        ]) {
          if (!group.$3) continue;
          for (var i = 0; i < group.$2.length; i++) {
            final factors = List.generate(
              3,
              (r) => math(original.get(r, group.$1[i][r])),
            );
            lines.add('${factors.join(r' \cdot ')} = ${group.$2[i].toLatex()}');
            markers.add(identical(group.$1, positive) ? '+' : '−');
          }
        }
        if (trans.phase == 3) {
          final pos = trans.positiveProducts.fold(
            Rational.zero,
            (sum, v) => sum + v,
          );
          final neg = trans.negativeProducts.fold(
            Rational.zero,
            (sum, v) => sum + v,
          );
          lines.add('${math(pos)} - ${math(neg)} = ${(pos - neg).toLatex()}');
        }
      }
      return InstructionLesson(
        l10n?.guideDetSource ?? 'Follow the factors and signs of each product.',
        l10n?.guideDetApply ?? 'Follow one product at a time below the matrix.',
        l10n?.guideDetResult ?? 'Check the products at your own pace.',
        lines,
        markers,
        l10n?.guideDetReason ?? 'The determinant measures signed area or volume scaling. Add the products marked + and subtract those marked −; a zero determinant means the transformation loses a dimension.',
      );
    }
    return InstructionLesson(
      l10n?.guideGenericSource ?? 'Read the matrix and the goal of this step.',
      l10n?.guideGenericApply ??
          'Follow the highlighted entries and the explanation.',
      l10n?.guideGenericResult ??
          'Check the result. Continue when you are ready.',
    );
  }
}

class InstructionExplanation extends StatelessWidget {
  final InstructionLesson lesson;
  final InstructionPhase phase;
  final int activeCalculation;
  final bool showAllPhases;

  const InstructionExplanation({
    super.key,
    required this.lesson,
    required this.phase,
    this.activeCalculation = -1,
    this.showAllPhases = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final title = switch (phase) {
      InstructionPhase.source => l10n?.focusSource ?? 'Understand the goal',
      InstructionPhase.operation =>
        l10n?.focusOperation ?? 'Follow the calculation',
      InstructionPhase.result => l10n?.focusResult ?? 'Check what changed',
    };
    final description = switch (phase) {
      InstructionPhase.source => lesson.source,
      InstructionPhase.operation => lesson.operation,
      InstructionPhase.result => lesson.result,
    };
    final visibleCalculations =
        showAllPhases || phase == InstructionPhase.result
        ? lesson.calculations.length
        : phase == InstructionPhase.source
        ? 0
        : (activeCalculation + 1).clamp(0, lesson.calculations.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            showAllPhases
                ? (l10n?.stepExplanation ?? 'Why this works')
                : '${phase.index + 1} / 3 · $title',
            style: theme.textTheme.labelLarge,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          showAllPhases
              ? '${lesson.source}\n\n${lesson.operation}\n\n${lesson.result}'
              : description,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (visibleCalculations > 0) ...[
          const SizedBox(height: 12),
          ...List.generate(visibleCalculations, (index) {
            final selected =
                phase == InstructionPhase.operation &&
                index == activeCalculation;
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? theme.colorScheme.primary.withValues(alpha: .08)
                    : theme.colorScheme.surface,
                border: Border(
                  left: BorderSide(
                    width: 2,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (index < lesson.markers.length) ...[
                    Text(
                      lesson.markers[index],
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: MathText(
                      lesson.calculations[index],
                      fontSize: 17,
                      wrapLines: true,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
