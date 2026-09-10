import '../model/matrix.dart';
import '../model/step.dart';

/// Configurable options for Gauss / Gauss-Jordan elimination
class EliminationOptions {
  final bool
  toRref; // true for Gauss-Jordan (RREF), false for Gaussian Elimination (REF)
  final bool normalizePivotToOne; // scale pivot row so pivot becomes 1
  final int? augmentedColIndex; // vertical divider line for augmented matrices
  final MatrixStructureType structure;

  const EliminationOptions({
    this.toRref = true,
    this.normalizePivotToOne = true,
    this.augmentedColIndex,
    this.structure = MatrixStructureType.standard,
  });
}

/// High-precision, step-by-step Gaussian and Gauss-Jordan Elimination engine.
class GaussJordanSolver {
  /// Solves and records every atomic matrix operation as a [MatrixStep]
  static StepSolution solve(
    Matrix inputMatrix, [
    EliminationOptions options = const EliminationOptions(),
  ]) {
    final steps = <MatrixStep>[];
    var currentMatrix = inputMatrix;
    var stepCounter = 0;

    int leadCol = 0;
    final rowCount = currentMatrix.rows;
    final colCount = currentMatrix.cols;
    final limitCols = options.augmentedColIndex ?? colCount;

    for (int r = 0; r < rowCount && leadCol < limitCols; leadCol++) {
      // 1. Find pivot in column leadCol at or below row r
      int pivotRow = -1;
      for (int i = r; i < rowCount; i++) {
        if (!currentMatrix.get(i, leadCol).isZero) {
          pivotRow = i;
          break;
        }
      }

      if (pivotRow == -1) {
        // All zeros in this column at/below r, continue to next column
        continue;
      }

      // 2. Row swap if necessary
      if (pivotRow != r) {
        final beforeSnap = MatrixSnapshot.fromMatrix(
          currentMatrix,
          structure: options.structure,
          augmentedColIndex: options.augmentedColIndex,
        );
        currentMatrix = currentMatrix.swapRows(r, pivotRow);
        final afterSnap = MatrixSnapshot.fromMatrix(
          currentMatrix,
          structure: options.structure,
          augmentedColIndex: options.augmentedColIndex,
        );

        final highlights = <CellHighlight>[
          for (int c = 0; c < colCount; c++) ...[
            CellHighlight(row: r, col: c, type: HighlightType.target),
            CellHighlight(row: pivotRow, col: c, type: HighlightType.source),
          ],
        ];

        steps.add(
          MatrixStep(
            stepIndex: ++stepCounter,
            titleKey: 'step_row_swap_title',
            titleParams: {'rowA': r + 1, 'rowB': pivotRow + 1},
            explanationKey: 'step_row_swap_desc',
            explanationParams: {
              'rowA': r + 1,
              'rowB': pivotRow + 1,
              'col': leadCol + 1,
              'pivot': currentMatrix.get(r, leadCol).toLatex(),
            },
            matrixBefore: beforeSnap,
            matrixAfter: afterSnap,
            transformation: RowSwapTransformation(r, pivotRow),
            highlights: highlights,
          ),
        );
      }

      // 3. Normalize pivot row so pivot element = 1 (if requested and not already 1)
      final pivotVal = currentMatrix.get(r, leadCol);
      if (options.normalizePivotToOne && !pivotVal.isOne) {
        final factor = pivotVal.inverse();
        final beforeSnap = MatrixSnapshot.fromMatrix(
          currentMatrix,
          structure: options.structure,
          augmentedColIndex: options.augmentedColIndex,
        );
        currentMatrix = currentMatrix.scaleRow(r, factor);
        final afterSnap = MatrixSnapshot.fromMatrix(
          currentMatrix,
          structure: options.structure,
          augmentedColIndex: options.augmentedColIndex,
        );

        final subCalcs = <SubCalculation>[];
        final highlights = <CellHighlight>[
          CellHighlight(
            row: r,
            col: leadCol,
            type: HighlightType.pivot,
            badgeText: '1',
          ),
        ];

        for (int c = 0; c < colCount; c++) {
          if (c != leadCol) {
            highlights.add(
              CellHighlight(row: r, col: c, type: HighlightType.target),
            );
          }
          final original = beforeSnap.get(r, c);
          final calculated = original * factor;
          subCalcs.add(
            SubCalculation(
              targetRow: r,
              targetCol: c,
              formulaLatex:
                  '${original.toLatex()} \\cdot ${factor.toLatex()} = ${calculated.toLatex()}',
              result: calculated,
            ),
          );
        }

        steps.add(
          MatrixStep(
            stepIndex: ++stepCounter,
            titleKey: 'step_row_scale_title',
            titleParams: {'row': r + 1},
            explanationKey: 'step_row_scale_desc',
            explanationParams: {
              'row': r + 1,
              'factor': factor.toLatex(),
              'pivot': pivotVal.toLatex(),
            },
            matrixBefore: beforeSnap,
            matrixAfter: afterSnap,
            transformation: RowScaleTransformation(r, factor),
            highlights: highlights,
            subCalculations: subCalcs,
          ),
        );
      }

      // 4. Eliminate elements in column leadCol
      // For RREF (options.toRref): eliminate all rows except r (both above and below)
      // For REF: only eliminate rows below r (i > r)
      final rowsToEliminate = <int>[];
      for (int i = 0; i < rowCount; i++) {
        if (i == r) continue;
        if (!options.toRref && i < r) continue;
        if (!currentMatrix.get(i, leadCol).isZero) {
          rowsToEliminate.add(i);
        }
      }

      final activePivot = currentMatrix.get(r, leadCol);

      for (final targetRow in rowsToEliminate) {
        final targetVal = currentMatrix.get(targetRow, leadCol);
        // We want targetVal - (multiplier * activePivot) = 0
        // multiplier = targetVal / activePivot
        final multiplier = targetVal / activePivot;
        final factor = -multiplier; // For targetRow + factor * pivotRow

        final beforeSnap = MatrixSnapshot.fromMatrix(
          currentMatrix,
          structure: options.structure,
          augmentedColIndex: options.augmentedColIndex,
        );

        currentMatrix = currentMatrix.addRowMultiple(targetRow, r, factor);

        final afterSnap = MatrixSnapshot.fromMatrix(
          currentMatrix,
          structure: options.structure,
          augmentedColIndex: options.augmentedColIndex,
        );

        final highlights = <CellHighlight>[
          CellHighlight(row: r, col: leadCol, type: HighlightType.pivot),
          CellHighlight(
            row: targetRow,
            col: leadCol,
            type: HighlightType.zeroed,
            badgeText: '0',
          ),
        ];

        final subCalcs = <SubCalculation>[];

        for (int c = 0; c < colCount; c++) {
          if (c != leadCol) {
            highlights.add(
              CellHighlight(row: targetRow, col: c, type: HighlightType.target),
            );
            highlights.add(
              CellHighlight(row: r, col: c, type: HighlightType.source),
            );
          }

          final origTarget = beforeSnap.get(targetRow, c);
          final sourceVal = beforeSnap.get(r, c);
          final resVal = afterSnap.get(targetRow, c);

          final signStr = multiplier.isNegative
              ? '+ ${(-multiplier).toLatex()}'
              : '- ${multiplier.toLatex()}';
          subCalcs.add(
            SubCalculation(
              targetRow: targetRow,
              targetCol: c,
              formulaLatex:
                  '${origTarget.toLatex()} $signStr \\cdot (${sourceVal.toLatex()}) = ${resVal.toLatex()}',
              result: resVal,
            ),
          );
        }

        steps.add(
          MatrixStep(
            stepIndex: ++stepCounter,
            titleKey: 'step_row_elimination_title',
            titleParams: {'target': targetRow + 1, 'source': r + 1},
            explanationKey: 'step_row_elimination_desc',
            explanationParams: {
              'target': targetRow + 1,
              'source': r + 1,
              'multiplier': multiplier.toLatex(),
              'col': leadCol + 1,
            },
            matrixBefore: beforeSnap,
            matrixAfter: afterSnap,
            transformation: RowEliminationTransformation(
              targetRow: targetRow,
              sourceRow: r,
              factor: factor,
            ),
            highlights: highlights,
            subCalculations: subCalcs,
          ),
        );
      }

      r++;
    }

    if (steps.isEmpty) {
      final snapshot = MatrixSnapshot.fromMatrix(
        currentMatrix,
        structure: options.structure,
        augmentedColIndex: options.augmentedColIndex,
      );
      steps.add(
        MatrixStep(
          stepIndex: 1,
          titleKey: 'stepAlreadyReducedTitle',
          explanationKey: 'stepAlreadyReducedDesc',
          matrixBefore: snapshot,
          matrixAfter: snapshot,
          transformation: InformationalStepTransformation(
            'No row operations needed',
          ),
          highlights: const [],
        ),
      );
    }

    return StepSolution(
      operationKey: options.toRref ? 'op_rref' : 'op_gauss',
      initialMatrix: inputMatrix,
      steps: steps,
      finalMatrix: currentMatrix,
      result: currentMatrix,
      resultLatex: currentMatrix.toLatex(),
      isSuccess: true,
    );
  }
}
