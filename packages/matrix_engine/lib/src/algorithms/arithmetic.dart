import '../model/matrix.dart';
import '../model/step.dart';
import '../rational/rational.dart';

class MatrixArithmeticSolver {
  /// A negative operand needs brackets so a reader never meets "3 + -15".
  static String _operand(Rational value) =>
      value.isNegative ? '(${value.toLatex()})' : value.toLatex();

  /// Matrix Addition: C = A + B
  static StepSolution add(Matrix a, Matrix b) {
    if (a.rows != b.rows || a.cols != b.cols) {
      return StepSolution(
        operationKey: 'op_add',
        initialMatrix: a,
        steps: const [],
        finalMatrix: a,
        isSuccess: false,
        errorMessageKey: 'error_dimension_mismatch_add',
      );
    }

    final steps = <MatrixStep>[];
    final resultData = List.generate(
      a.rows,
      (_) => List.generate(a.cols, (_) => Rational.zero),
    );

    var currentResultMatrix = Matrix(resultData);
    var stepCounter = 0;

    for (int r = 0; r < a.rows; r++) {
      for (int c = 0; c < a.cols; c++) {
        final valA = a.get(r, c);
        final valB = b.get(r, c);
        final sum = valA + valB;

        final beforeSnap = MatrixSnapshot.fromMatrix(currentResultMatrix);
        resultData[r][c] = sum;
        currentResultMatrix = Matrix(resultData);
        final afterSnap = MatrixSnapshot.fromMatrix(currentResultMatrix);

        final formula =
            '${_operand(valA)} + ${_operand(valB)} = ${sum.toLatex()}';

        steps.add(
          MatrixStep(
            stepIndex: ++stepCounter,
            titleKey: 'arithmetic_add_cell_title',
            titleParams: {'row': r + 1, 'col': c + 1},
            explanationKey: 'arithmetic_add_cell_desc',
            explanationParams: {'row': r + 1, 'col': c + 1, 'formula': formula},
            matrixBefore: beforeSnap,
            matrixAfter: afterSnap,
            transformation: MatrixElementAdditionTransformation(
              r,
              c,
              valA,
              valB,
            ),
            highlights: [
              CellHighlight(
                row: r,
                col: c,
                type: HighlightType.target,
                badgeText: sum.toLatex(),
              ),
            ],
            subCalculations: [
              SubCalculation(
                targetRow: r,
                targetCol: c,
                formulaLatex: formula,
                result: sum,
              ),
            ],
          ),
        );
      }
    }

    return StepSolution(
      operationKey: 'op_add',
      initialMatrix: a,
      steps: steps,
      finalMatrix: currentResultMatrix,
      result: currentResultMatrix,
      resultLatex: currentResultMatrix.toLatex(),
    );
  }

  /// Matrix Multiplication: C = A * B
  static StepSolution multiply(Matrix a, Matrix b) {
    if (a.cols != b.rows) {
      return StepSolution(
        operationKey: 'op_multiply',
        initialMatrix: a,
        steps: const [],
        finalMatrix: a,
        isSuccess: false,
        errorMessageKey: 'error_dimension_mismatch_multiply',
      );
    }

    final steps = <MatrixStep>[];
    final outRows = a.rows;
    final outCols = b.cols;
    final dotLength = a.cols;

    final resultData = List.generate(
      outRows,
      (_) => List.generate(outCols, (_) => Rational.zero),
    );

    var currentResult = Matrix(resultData);
    var stepCounter = 0;

    for (int r = 0; r < outRows; r++) {
      for (int c = 0; c < outCols; c++) {
        var cellSum = Rational.zero;
        final terms = <String>[];
        final rowElements = <Rational>[];
        final colElements = <Rational>[];

        for (int k = 0; k < dotLength; k++) {
          final elA = a.get(r, k);
          final elB = b.get(k, c);
          final prod = elA * elB;
          cellSum = cellSum + prod;
          rowElements.add(elA);
          colElements.add(elB);
          terms.add('(${_operand(elA)} \\cdot ${_operand(elB)})');
        }

        final beforeSnap = MatrixSnapshot.fromMatrix(currentResult);
        resultData[r][c] = cellSum;
        currentResult = Matrix(resultData);
        final afterSnap = MatrixSnapshot.fromMatrix(currentResult);

        final formula = '${terms.join(' + ')} = ${cellSum.toLatex()}';

        steps.add(
          MatrixStep(
            stepIndex: ++stepCounter,
            titleKey: 'arithmetic_mult_cell_title',
            titleParams: {'row': r + 1, 'col': c + 1},
            explanationKey: 'arithmetic_mult_cell_desc',
            explanationParams: {'row': r + 1, 'col': c + 1, 'formula': formula},
            matrixBefore: beforeSnap,
            matrixAfter: afterSnap,
            transformation: MatrixElementMultiplicationTransformation(
              targetRow: r,
              targetCol: c,
              rowElements: rowElements,
              colElements: colElements,
              result: cellSum,
            ),
            highlights: [
              CellHighlight(
                row: r,
                col: c,
                type: HighlightType.target,
                badgeText: cellSum.toLatex(),
              ),
            ],
            subCalculations: [
              SubCalculation(
                targetRow: r,
                targetCol: c,
                formulaLatex: formula,
                result: cellSum,
              ),
            ],
          ),
        );
      }
    }

    return StepSolution(
      operationKey: 'op_multiply',
      initialMatrix: a,
      steps: steps,
      finalMatrix: currentResult,
      result: currentResult,
      resultLatex: currentResult.toLatex(),
    );
  }
}
