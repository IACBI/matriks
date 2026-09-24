import '../model/matrix.dart';
import '../model/step.dart';

class LUResult {
  final Matrix lMatrix;
  final Matrix uMatrix;
  final Matrix? pMatrix; // Permutation matrix if row swaps were needed
  final bool isPermuted;

  const LUResult({
    required this.lMatrix,
    required this.uMatrix,
    this.pMatrix,
    this.isPermuted = false,
  });
}

class LUDecompositionSolver {
  /// Solves A = LU (or PA = LU if row swaps needed) with step-by-step educational explanations
  static StepSolution solve(Matrix matrix) {
    if (!matrix.isSquare) {
      return StepSolution(
        operationKey: 'op_lu',
        initialMatrix: matrix,
        steps: const [],
        finalMatrix: matrix,
        isSuccess: false,
        errorMessageKey: 'error_inverse_not_square',
      );
    }

    final n = matrix.rows;
    var u = matrix;
    var l = Matrix.identity(n);
    var p = Matrix.identity(n);

    final steps = <MatrixStep>[];
    var stepCounter = 0;
    bool neededPermutation = false;

    // Initial step: Introduce L = I and U = A
    steps.add(
      MatrixStep(
        stepIndex: ++stepCounter,
        titleKey: 'lu_init_title',
        explanationKey: 'lu_init_desc',
        matrixBefore: MatrixSnapshot.fromMatrix(u),
        matrixAfter: MatrixSnapshot.fromMatrix(u),
        transformation: LUDecompositionTransformation(
          lSnapshot: MatrixSnapshot.fromMatrix(l),
          uSnapshot: MatrixSnapshot.fromMatrix(u),
        ),
        highlights: const [],
      ),
    );

    // Gaussian elimination to form U, storing multipliers in L
    for (int col = 0; col < n - 1; col++) {
      // Check pivot
      if (u.get(col, col).isZero) {
        // Find swap candidate below
        int swapRow = -1;
        for (int r = col + 1; r < n; r++) {
          if (!u.get(r, col).isZero) {
            swapRow = r;
            break;
          }
        }

        if (swapRow != -1) {
          neededPermutation = true;
          final beforeSwap = MatrixSnapshot.fromMatrix(u);
          u = u.swapRows(col, swapRow);
          p = p.swapRows(col, swapRow);
          // Swap already computed entries in L (columns before 'col')
          final lData = l.toList();
          for (int c = 0; c < col; c++) {
            final tmp = lData[col][c];
            lData[col][c] = lData[swapRow][c];
            lData[swapRow][c] = tmp;
          }
          l = Matrix(lData);

          steps.add(
            MatrixStep(
              stepIndex: ++stepCounter,
              titleKey: 'step_row_swap_title',
              titleParams: {'rowA': col + 1, 'rowB': swapRow + 1},
              explanationKey: 'lu_swap_desc',
              explanationParams: {'rowA': col + 1, 'rowB': swapRow + 1},
              matrixBefore: beforeSwap,
              matrixAfter: MatrixSnapshot.fromMatrix(u),
              transformation: RowSwapTransformation(col, swapRow),
              highlights: [
                for (int c = 0; c < n; c++) ...[
                  CellHighlight(row: col, col: c, type: HighlightType.target),
                  CellHighlight(
                    row: swapRow,
                    col: c,
                    type: HighlightType.source,
                  ),
                ],
              ],
            ),
          );
        }
      }

      final pivot = u.get(col, col);
      if (pivot.isZero) continue;

      for (int row = col + 1; row < n; row++) {
        final targetVal = u.get(row, col);
        if (targetVal.isZero) continue;

        final multiplier = targetVal / pivot;

        // Update L: store multiplier at L[row][col]
        l = l.setEntry(row, col, multiplier);

        // Update U: row = row - multiplier * col
        final beforeSnap = MatrixSnapshot.fromMatrix(u);
        u = u.addRowMultiple(row, col, -multiplier);
        final afterSnap = MatrixSnapshot.fromMatrix(u);

        final subCalcs = <SubCalculation>[];
        for (int c = col; c < n; c++) {
          final orig = beforeSnap.get(row, c);
          final src = beforeSnap.get(col, c);
          final res = u.get(row, c);
          subCalcs.add(
            SubCalculation(
              targetRow: row,
              targetCol: c,
              formulaLatex:
                  '${orig.toLatex()} - (${multiplier.toLatex()}) \\cdot (${src.toLatex()}) = ${res.toLatex()}',
              result: res,
            ),
          );
        }

        steps.add(
          MatrixStep(
            stepIndex: ++stepCounter,
            titleKey: 'lu_elim_title',
            titleParams: {'target': row + 1, 'source': col + 1},
            explanationKey: 'lu_elim_desc',
            explanationParams: {
              'target': row + 1,
              'source': col + 1,
              'multiplier': multiplier.toLatex(),
            },
            matrixBefore: beforeSnap,
            matrixAfter: afterSnap,
            transformation: LUEliminationTransformation(
              targetRow: row,
              sourceRow: col,
              factor: -multiplier,
              lower: MatrixSnapshot.fromMatrix(l),
              lowerRow: row,
              lowerCol: col,
            ),
            // Same roles as Gauss elimination, so the legend reads alike.
            highlights: [
              CellHighlight(row: col, col: col, type: HighlightType.pivot),
              CellHighlight(
                row: row,
                col: col,
                type: HighlightType.zeroed,
                badgeText: '0',
              ),
              for (int c = col + 1; c < n; c++) ...[
                CellHighlight(row: row, col: c, type: HighlightType.target),
                CellHighlight(row: col, col: c, type: HighlightType.source),
              ],
            ],
            subCalculations: subCalcs,
          ),
        );
      }
    }

    final lLatex = l.toLatex();
    final uLatex = u.toLatex();
    // The result names the factors themselves, not just the identity they
    // satisfy; with a row exchange P is part of the answer.
    final summaryLatex = [
      if (neededPermutation) 'P = ${p.toLatex()}',
      'L = $lLatex',
      'U = $uLatex',
    ].join(r' \quad ');

    steps.add(
      MatrixStep(
        stepIndex: ++stepCounter,
        titleKey: 'lu_final_title',
        explanationKey: 'lu_final_desc',
        explanationParams: {'l': lLatex, 'u': uLatex},
        matrixBefore: MatrixSnapshot.fromMatrix(u),
        matrixAfter: MatrixSnapshot.fromMatrix(u),
        transformation: LUDecompositionTransformation(
          lSnapshot: MatrixSnapshot.fromMatrix(l),
          uSnapshot: MatrixSnapshot.fromMatrix(u),
        ),
        highlights: const [],
      ),
    );

    return StepSolution(
      operationKey: 'op_lu',
      initialMatrix: matrix,
      steps: steps,
      finalMatrix: u,
      result: LUResult(
        lMatrix: l,
        uMatrix: u,
        pMatrix: neededPermutation ? p : null,
        isPermuted: neededPermutation,
      ),
      resultLatex: summaryLatex,
    );
  }
}
