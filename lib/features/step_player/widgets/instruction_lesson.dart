import 'package:flutter/material.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/theme/app_theme.dart';
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

  /// No step-specific teaching text exists; the step's own description is
  /// shown instead of three placeholder phases.
  final bool generic;

  /// The phases and calculations already say everything the solver's step
  /// description says, so the description is not repeated beside them.
  final bool coversDescription;

  /// Leading calculations that recap earlier steps and are visible from the
  /// start; only the rest are revealed during the operation.
  final int revealedAtStart;

  const InstructionLesson(
    this.source,
    this.operation,
    this.result, [
    this.calculations = const [],
    this.markers = const [],
    this.rationale,
  ]) : generic = false,
       coversDescription = false,
       revealedAtStart = 0;

  const InstructionLesson._({
    required this.source,
    required this.operation,
    required this.result,
    this.calculations = const [],
    this.markers = const [],
    this.rationale,
    this.generic = false,
    this.coversDescription = true,
    this.revealedAtStart = 0,
  });

  static const _generic = InstructionLesson._(
    source: '',
    operation: '',
    result: '',
    generic: true,
    coversDescription: false,
  );

  /// Calculations revealed one at a time during the operation phase.
  int get progressiveCount => calculations.length - revealedAtStart;

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
      return InstructionLesson._(
        source: l10n?.guideAddSource ?? 'Match the same position in A and B.',
        operation: l10n?.guideAddApply ?? 'Add this pair of entries.',
        result:
            l10n?.guideAddResult ??
            'Their sum belongs in the same position in C.',
        calculations: [
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
      String? rationale;
      if (ratio != null) {
        rationale = trans is LUEliminationTransformation
            ? l10n?.guideLuReason(
                    entry.toString(),
                    pivot.toString(),
                    ratio.toString(),
                    '${trans.lowerRow + 1}',
                    '${trans.lowerCol + 1}',
                  ) ??
                  'Target $entry ÷ pivot $pivot = $ratio. The same number is written into L.'
            : l10n?.guideEliminateReason(
                    entry.toString(),
                    pivot.toString(),
                    ratio.toString(),
                  ) ??
                  'Target $entry ÷ pivot $pivot = $ratio. Subtract this multiple of the source row to cancel the target entry.';
      }
      final sign = trans.factor.isNegative ? '-' : '+';
      return InstructionLesson._(
        source:
            l10n?.guideEliminateSource(source, target, col) ??
            'Use row $source to change row $target. Focus on column $col.',
        operation: trans.factor.isNegative
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
        result:
            l10n?.guideEliminateResult(col, value.toString()) ??
            'The entry in column $col is now $value.',
        calculations: [
          for (final c in changingColumns(trans, original, after.cols))
            '${math(original.get(trans.targetRow, c))} $sign ${math(trans.factor.abs())} \\cdot ${math(original.get(trans.sourceRow, c))} = ${after.get(trans.targetRow, c).toLatex()}',
        ],
        rationale: rationale,
      );
    }
    if (trans is RowScaleTransformation) {
      final row = '${trans.row + 1}';
      return InstructionLesson._(
        source:
            l10n?.guideScaleSource(row, trans.scalar.toString()) ??
            'Scale row $row by ${trans.scalar}.',
        operation:
            l10n?.guideScaleApply ?? 'Apply the factor to the whole row.',
        result:
            l10n?.guideScaleResult ??
            'Compare the scaled row with the original.',
        calculations: [
          for (final c in changingColumns(trans, original, after.cols))
            '${math(trans.scalar)} \\cdot ${math(original.get(trans.row, c))} = ${after.get(trans.row, c).toLatex()}',
        ],
        // The solver's description says why the row is scaled.
        coversDescription: false,
      );
    }
    if (trans is RowSwapTransformation) {
      return InstructionLesson._(
        source:
            l10n?.guideSwapSource('${trans.rowA + 1}', '${trans.rowB + 1}') ??
            'Exchange rows ${trans.rowA + 1} and ${trans.rowB + 1}.',
        operation:
            l10n?.guideSwapApply ??
            'Move the whole rows; values do not change.',
        result:
            l10n?.guideSwapResult ?? 'The rows are in their new positions.',
        // The solver's description says why the rows are exchanged.
        coversDescription: false,
      );
    }
    if (trans is MatrixElementMultiplicationTransformation) {
      final terms = List.generate(
        trans.rowElements.length,
        (i) =>
            '${math(trans.rowElements[i])} \\cdot ${math(trans.colElements[i])}',
      );
      return InstructionLesson._(
        source:
            l10n?.guideDotSource(
              '${trans.targetRow + 1}',
              '${trans.targetCol + 1}',
            ) ??
            'Pair the source row and column.',
        operation:
            l10n?.guideDotApply ?? 'Multiply matching entries, then add.',
        result:
            l10n?.guideDotResult(
              '${trans.targetRow + 1}',
              '${trans.targetCol + 1}',
            ) ??
            'The sum is the output entry.',
        calculations: [
          ...terms,
          '${terms.join(' + ')} = ${trans.result.toLatex()}',
        ],
        rationale:
            l10n?.guideDotReason ??
            'One output entry uses a whole row of A and a whole column of B. Multiply entries in matching positions, then add their contributions.',
      );
    }
    if (trans is AdjugateTransformation && original.rows == 2) {
      final a = original.get(0, 0);
      final b = original.get(0, 1);
      final c = original.get(1, 0);
      final d = original.get(1, 1);
      return InstructionLesson._(
        source:
            l10n?.guideAdjSource ??
            'Look at the diagonal a, d and the other two entries b, c.',
        operation:
            l10n?.guideAdjApply ??
            'a and d trade places; b and c change sign.',
        result:
            l10n?.guideAdjResult ??
            'This is adj(A). Dividing it by det(A) gives the inverse.',
        calculations: [
          '\\begin{pmatrix} ${a.toLatex()} & ${b.toLatex()} \\\\ ${c.toLatex()} & ${d.toLatex()} \\end{pmatrix} \\rightarrow \\begin{pmatrix} ${d.toLatex()} & ${(-b).toLatex()} \\\\ ${(-c).toLatex()} & ${a.toLatex()} \\end{pmatrix}',
        ],
        rationale:
            l10n?.guideAdjReason ??
            'For a 2×2 matrix, A · adj(A) = det(A) · I. So A⁻¹ = adj(A) ÷ det(A) whenever det(A) ≠ 0.',
      );
    }
    if (trans is MatrixScaleTransformation) {
      return InstructionLesson._(
        source:
            l10n?.guideScaleAllSource(trans.scalar.toString()) ??
            'Every entry is multiplied by the same number, ${trans.scalar}.',
        operation:
            l10n?.guideScaleAllApply ??
            'Multiply each entry by the factor, one at a time.',
        result: l10n?.guideScaleAllResult ?? 'The scaled matrix is A⁻¹.',
        calculations: [
          for (var r = 0; r < after.rows; r++)
            for (var c = 0; c < after.cols; c++)
              '${math(original.get(r, c))} \\cdot ${math(trans.scalar)} = ${after.get(r, c).toLatex()}',
        ],
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
      return InstructionLesson._(
        source:
            l10n?.guideDiagSource ??
            'In a triangular matrix the determinant is the product of the diagonal.',
        operation:
            l10n?.guideDiagApply ??
            'Multiply the diagonal entries one by one. Each row swap earlier contributed a factor of −1.',
        result:
            l10n?.guideDiagResult ??
            'The last product is the determinant of the original matrix.',
        calculations: lines,
      );
    }
    if (trans is DeterminantCrossProductTransformation ||
        trans is DeterminantSarrusTransformation) {
      final lines = <String>[];
      final markers = <String>[];
      var recap = false;
      if (trans is DeterminantCrossProductTransformation) {
        recap = trans.recap;
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
        recap = trans.recap;
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
      if (recap) {
        // Earlier steps drew each product; here they stay listed for
        // reference and only the final subtraction is new.
        return InstructionLesson._(
          source:
              l10n?.guideDetRecapSource ??
              'All products are known from the previous steps.',
          operation:
              l10n?.guideDetRecapApply ??
              'Subtract the − total from the + total.',
          result:
              l10n?.guideDetRecapResult ??
              'The difference is the determinant.',
          calculations: lines,
          markers: markers,
          revealedAtStart: lines.length - 1,
          rationale:
              l10n?.guideDetReason ??
              'The determinant measures signed area or volume scaling. Add the products marked + and subtract those marked −; a zero determinant means the transformation loses a dimension.',
        );
      }
      return InstructionLesson._(
        source:
            l10n?.guideDetSource ??
            'Follow the factors and signs of each product.',
        operation:
            l10n?.guideDetApply ??
            'Follow one product at a time below the matrix.',
        result:
            l10n?.guideDetResult ??
            'Their sum is this group\'s contribution to the determinant.',
        calculations: lines,
        markers: markers,
        rationale:
            l10n?.guideDetReason ??
            'The determinant measures signed area or volume scaling. Add the products marked + and subtract those marked −; a zero determinant means the transformation loses a dimension.',
      );
    }
    return _generic;
  }
}

class InstructionExplanation extends StatelessWidget {
  final InstructionLesson lesson;
  final InstructionPhase phase;
  final int activeCalculation;
  final bool showAllPhases;

  /// Whether a screen reader announces phase changes. Off while the lesson
  /// plays, when phases change every few seconds.
  final bool announce;

  const InstructionExplanation({
    super.key,
    required this.lesson,
    required this.phase,
    this.activeCalculation = -1,
    this.showAllPhases = false,
    this.announce = true,
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
    // Recap lines are listed from the start; the rest appear one by one.
    final start = lesson.revealedAtStart;
    final visibleCalculations =
        showAllPhases || phase == InstructionPhase.result
        ? lesson.calculations.length
        : phase == InstructionPhase.source
        ? start
        : (start + activeCalculation + 1).clamp(
            start,
            lesson.calculations.length,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // With every phase shown at once there is no phase to name. The
        // dots show where the step is; screen readers hear the phase name.
        if (!showAllPhases) ...[
          Semantics(
            liveRegion: announce,
            label: '${phase.index + 1} / 3 · $title',
            child: ExcludeSemantics(
              child: _PhaseDots(
                key: const ValueKey('phase-dots'),
                phase: phase,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        // One sentence at a time, like a subtitle under the matrix.
        AnimatedSwitcher(
          duration: AppTheme.motion(context, AppTheme.stateMs),
          child: Text(
            showAllPhases
                ? '${lesson.source}\n\n${lesson.operation}\n\n${lesson.result}'
                : description,
            key: ValueKey(showAllPhases ? -1 : phase.index),
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (visibleCalculations > 0) ...[
          const SizedBox(height: 12),
          ...List.generate(visibleCalculations, (index) {
            final selected =
                phase == InstructionPhase.operation &&
                index == start + activeCalculation;
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

class _PhaseDots extends StatelessWidget {
  final InstructionPhase phase;

  const _PhaseDots({super.key, required this.phase});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (final p in InstructionPhase.values) ...[
          AnimatedContainer(
            duration: AppTheme.motion(context, AppTheme.stateMs),
            width: p == phase ? 22 : 10,
            height: 4,
            decoration: BoxDecoration(
              color: p.index <= phase.index
                  ? scheme.primary
                  : scheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ],
    );
  }
}
