import '../model/matrix.dart';
import '../model/step.dart';
import '../rational/rational.dart';

enum DeterminantMethod {
  auto, // 2x2: formula, 3x3: Sarrus/Cofactor, NxN: Triangularization / Row reduction
  cofactor, // Laplace cofactor expansion
  sarrus, // Sarrus rule (for 3x3)
  triangular, // Gaussian elimination to upper triangular
}

class DeterminantSolver {
  /// A negative operand needs brackets so a reader never meets "-12 + -10".
  static String _operand(Rational value) =>
      value.isNegative ? '(${value.toLatex()})' : value.toLatex();

  static StepSolution solve(
    Matrix matrix, {
    DeterminantMethod method = DeterminantMethod.auto,
  }) {
    if (!matrix.isSquare) {
      throw ArgumentError(
        'Determinant can only be calculated for square matrices.',
      );
    }

    if (matrix.rows == 1) {
      final val = matrix.get(0, 0);
      final snap = MatrixSnapshot.fromMatrix(matrix);
      final step = MatrixStep(
        stepIndex: 1,
        titleKey: 'det_1x1_title',
        explanationKey: 'det_1x1_desc',
        explanationParams: {'val': val.toLatex()},
        matrixBefore: snap,
        matrixAfter: snap,
        transformation: InformationalStepTransformation(
          '1x1 determinant is the element itself',
        ),
        highlights: [CellHighlight(row: 0, col: 0, type: HighlightType.selected)],
      );
      return StepSolution(
        operationKey: 'op_determinant',
        initialMatrix: matrix,
        steps: [step],
        finalMatrix: matrix,
        result: val,
        resultLatex: val.toLatex(),
      );
    }

    if (matrix.rows == 2 &&
        (method == DeterminantMethod.auto ||
            method == DeterminantMethod.sarrus)) {
      return _solve2x2(matrix);
    }

    if (matrix.rows == 3 &&
        (method == DeterminantMethod.auto ||
            method == DeterminantMethod.sarrus)) {
      return _solve3x3Sarrus(matrix);
    }

    // General case: Triangularization (Row reduction)
    return _solveTriangular(matrix);
  }

  static StepSolution _solve2x2(Matrix matrix) {
    final a = matrix.get(0, 0);
    final b = matrix.get(0, 1);
    final c = matrix.get(1, 0);
    final d = matrix.get(1, 1);

    final mainDiag = a * d;
    final antiDiag = b * c;
    final det = mainDiag - antiDiag;

    final snap = MatrixSnapshot.fromMatrix(matrix);

    final step1 = MatrixStep(
      stepIndex: 1,
      titleKey: 'det_2x2_main_diagonal_title',
      explanationKey: 'det_2x2_main_diagonal_desc',
      explanationParams: {
        'a': a.toLatex(),
        'd': d.toLatex(),
        'product': mainDiag.toLatex(),
      },
      matrixBefore: snap,
      matrixAfter: snap,
      transformation: DeterminantCrossProductTransformation(
        mainDiagonalProduct: mainDiag,
        antiDiagonalProduct: antiDiag,
        phase: 1,
      ),
      highlights: const [],
    );

    final step2 = MatrixStep(
      stepIndex: 2,
      titleKey: 'det_2x2_anti_diagonal_title',
      explanationKey: 'det_2x2_anti_diagonal_desc',
      explanationParams: {
        'b': b.toLatex(),
        'c': c.toLatex(),
        'product': antiDiag.toLatex(),
      },
      matrixBefore: snap,
      matrixAfter: snap,
      transformation: DeterminantCrossProductTransformation(
        mainDiagonalProduct: mainDiag,
        antiDiagonalProduct: antiDiag,
        phase: 2,
      ),
      highlights: const [],
    );

    final step3 = MatrixStep(
      stepIndex: 3,
      titleKey: 'det_2x2_final_title',
      explanationKey: 'det_2x2_final_desc',
      explanationParams: {
        'main': mainDiag.toLatex(),
        'anti': antiDiag.toLatex(),
        'det': det.toLatex(),
      },
      matrixBefore: snap,
      matrixAfter: snap,
      transformation: DeterminantCrossProductTransformation(
        mainDiagonalProduct: mainDiag,
        antiDiagonalProduct: antiDiag,
        phase: 3,
        recap: true,
      ),
      highlights: const [],
    );

    return StepSolution(
      operationKey: 'op_determinant',
      initialMatrix: matrix,
      steps: [step1, step2, step3],
      finalMatrix: matrix,
      result: det,
      resultLatex: det.toLatex(),
    );
  }

  static StepSolution _solve3x3Sarrus(Matrix matrix) {
    // Sarrus rule: positive diagonals - negative diagonals
    final m = matrix;
    final p1 = m.get(0, 0) * m.get(1, 1) * m.get(2, 2);
    final p2 = m.get(0, 1) * m.get(1, 2) * m.get(2, 0);
    final p3 = m.get(0, 2) * m.get(1, 0) * m.get(2, 1);
    final posTotal = p1 + p2 + p3;

    final n1 = m.get(0, 2) * m.get(1, 1) * m.get(2, 0);
    final n2 = m.get(0, 0) * m.get(1, 2) * m.get(2, 1);
    final n3 = m.get(0, 1) * m.get(1, 0) * m.get(2, 2);
    final negTotal = n1 + n2 + n3;

    final det = posTotal - negTotal;
    final snap = MatrixSnapshot.fromMatrix(matrix);
    final steps = <MatrixStep>[];

    steps.add(
      MatrixStep(
        stepIndex: 1,
        titleKey: 'det_sarrus_pos_title',
        explanationKey: 'det_sarrus_pos_desc',
        explanationParams: {
          'p1': _operand(p1),
          'p2': _operand(p2),
          'p3': _operand(p3),
          'total': posTotal.toLatex(),
        },
        matrixBefore: snap,
        matrixAfter: snap,
        transformation: DeterminantSarrusTransformation(
          positiveProducts: [p1, p2, p3],
          negativeProducts: [n1, n2, n3],
          phase: 1,
        ),
        highlights: const [],
      ),
    );

    steps.add(
      MatrixStep(
        stepIndex: 2,
        titleKey: 'det_sarrus_neg_title',
        explanationKey: 'det_sarrus_neg_desc',
        explanationParams: {
          'n1': _operand(n1),
          'n2': _operand(n2),
          'n3': _operand(n3),
          'total': negTotal.toLatex(),
        },
        matrixBefore: snap,
        matrixAfter: snap,
        transformation: DeterminantSarrusTransformation(
          positiveProducts: [p1, p2, p3],
          negativeProducts: [n1, n2, n3],
          phase: 2,
        ),
        highlights: const [],
      ),
    );

    steps.add(
      MatrixStep(
        stepIndex: 3,
        titleKey: 'det_sarrus_final_title',
        explanationKey: 'det_sarrus_final_desc',
        explanationParams: {
          'pos': posTotal.toLatex(),
          'neg': negTotal.toLatex(),
          'det': det.toLatex(),
        },
        matrixBefore: snap,
        matrixAfter: snap,
        transformation: DeterminantSarrusTransformation(
          positiveProducts: [p1, p2, p3],
          negativeProducts: [n1, n2, n3],
          phase: 3,
          recap: true,
        ),
        highlights: const [],
      ),
    );

    return StepSolution(
      operationKey: 'op_determinant',
      initialMatrix: matrix,
      steps: steps,
      finalMatrix: matrix,
      result: det,
      resultLatex: det.toLatex(),
    );
  }

  static StepSolution _solveTriangular(Matrix matrix) {
    // Converts to upper triangular using row operations.
    // Det = signFactor * product(diagonal elements)
    final steps = <MatrixStep>[];
    var current = matrix;
    var signMultiplier =
        Rational.one; // Swapping rows multiplies determinant by -1
    final n = matrix.rows;
    var stepCounter = 0;

    for (int col = 0; col < n; col++) {
      // Find pivot
      int pivotRow = -1;
      for (int r = col; r < n; r++) {
        if (!current.get(r, col).isZero) {
          pivotRow = r;
          break;
        }
      }

      if (pivotRow == -1) {
        // Zero column found below diagonal -> determinant is 0!
        final snap = MatrixSnapshot.fromMatrix(current);
        steps.add(
          MatrixStep(
            stepIndex: ++stepCounter,
            titleKey: 'det_singular_column_title',
            titleParams: {'col': col + 1},
            explanationKey: 'det_singular_column_desc',
            explanationParams: {'col': col + 1},
            matrixBefore: snap,
            matrixAfter: snap,
            transformation: InformationalStepTransformation(
              'Zero column encountered; determinant is 0',
            ),
            highlights: [
              for (int r = col; r < n; r++)
                CellHighlight(row: r, col: col, type: HighlightType.zeroed),
            ],
          ),
        );

        return StepSolution(
          operationKey: 'op_determinant',
          initialMatrix: matrix,
          steps: steps,
          finalMatrix: current,
          result: Rational.zero,
          resultLatex: '0',
        );
      }

      // Row swap if needed
      if (pivotRow != col) {
        final beforeSnap = MatrixSnapshot.fromMatrix(current);
        current = current.swapRows(col, pivotRow);
        signMultiplier = -signMultiplier;
        final afterSnap = MatrixSnapshot.fromMatrix(current);

        steps.add(
          MatrixStep(
            stepIndex: ++stepCounter,
            titleKey: 'det_row_swap_title',
            titleParams: {'rowA': col + 1, 'rowB': pivotRow + 1},
            explanationKey: 'det_row_swap_desc',
            explanationParams: {
              'rowA': col + 1,
              'rowB': pivotRow + 1,
              'sign': signMultiplier.toLatex(),
            },
            matrixBefore: beforeSnap,
            matrixAfter: afterSnap,
            transformation: RowSwapTransformation(col, pivotRow),
            highlights: [
              for (int c = 0; c < n; c++) ...[
                CellHighlight(row: col, col: c, type: HighlightType.target),
                CellHighlight(
                  row: pivotRow,
                  col: c,
                  type: HighlightType.source,
                ),
              ],
            ],
          ),
        );
      }

      // Eliminate rows below pivot
      final pivotVal = current.get(col, col);
      for (int r = col + 1; r < n; r++) {
        final val = current.get(r, col);
        if (val.isZero) continue;

        final multiplier = val / pivotVal;
        final factor = -multiplier;

        final beforeSnap = MatrixSnapshot.fromMatrix(current);
        current = current.addRowMultiple(r, col, factor);
        final afterSnap = MatrixSnapshot.fromMatrix(current);

        final highlights = <CellHighlight>[
          CellHighlight(row: col, col: col, type: HighlightType.pivot),
          CellHighlight(
            row: r,
            col: col,
            type: HighlightType.zeroed,
            badgeText: '0',
          ),
        ];
        final subCalcs = <SubCalculation>[];

        for (int c = 0; c < n; c++) {
          if (c != col) {
            highlights.add(
              CellHighlight(row: r, col: c, type: HighlightType.target),
            );
            highlights.add(
              CellHighlight(row: col, col: c, type: HighlightType.source),
            );
          }
          final origTarget = beforeSnap.get(r, c);
          final sourceVal = beforeSnap.get(col, c);
          final resVal = afterSnap.get(r, c);
          subCalcs.add(
            SubCalculation(
              targetRow: r,
              targetCol: c,
              formulaLatex:
                  '${origTarget.toLatex()} - (${multiplier.toLatex()}) \\cdot (${sourceVal.toLatex()}) = ${resVal.toLatex()}',
              result: resVal,
            ),
          );
        }

        steps.add(
          MatrixStep(
            stepIndex: ++stepCounter,
            titleKey: 'step_row_elimination_title',
            titleParams: {'target': r + 1, 'source': col + 1},
            explanationKey: 'step_row_elimination_desc',
            explanationParams: {
              'target': r + 1,
              'source': col + 1,
              'multiplier': multiplier.toLatex(),
              'col': col + 1,
            },
            matrixBefore: beforeSnap,
            matrixAfter: afterSnap,
            transformation: RowEliminationTransformation(
              targetRow: r,
              sourceRow: col,
              factor: factor,
            ),
            highlights: highlights,
            subCalculations: subCalcs,
          ),
        );
      }
    }

    // Now current is upper triangular: det = signMultiplier * product of diagonals
    var diagProduct = Rational.one;
    final diagElements = <Rational>[];
    final diagHighlights = <CellHighlight>[];

    for (int i = 0; i < n; i++) {
      final d = current.get(i, i);
      diagElements.add(d);
      diagProduct = diagProduct * d;
      diagHighlights.add(
        CellHighlight(row: i, col: i, type: HighlightType.selected),
      );
    }

    final finalDet = signMultiplier * diagProduct;
    final finalSnap = MatrixSnapshot.fromMatrix(current);

    steps.add(
      MatrixStep(
        stepIndex: ++stepCounter,
        titleKey: 'det_diagonal_product_title',
        explanationKey: 'det_diagonal_product_desc',
        explanationParams: {
          'diagonals': diagElements.map((e) => e.toLatex()).join(' \\cdot '),
          'sign': signMultiplier == Rational.one ? '' : '(-1) \\cdot ',
          'det': finalDet.toLatex(),
        },
        matrixBefore: finalSnap,
        matrixAfter: finalSnap,
        transformation: DeterminantDiagonalProductTransformation(
          diagonalElements: diagElements,
          sign: signMultiplier,
        ),
        highlights: diagHighlights,
      ),
    );

    return StepSolution(
      operationKey: 'op_determinant',
      initialMatrix: matrix,
      steps: steps,
      finalMatrix: current,
      result: finalDet,
      resultLatex: finalDet.toLatex(),
    );
  }
}
