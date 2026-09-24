import '../model/matrix.dart';
import '../model/step.dart';
import '../rational/rational.dart';
import 'determinant.dart';
import 'gauss_jordan.dart';

class InverseSolver {
  /// Solves for the inverse of [matrix] step-by-step.
  static StepSolution solve(Matrix matrix) {
    if (!matrix.isSquare) {
      return StepSolution(
        operationKey: 'op_inverse',
        initialMatrix: matrix,
        steps: const [],
        finalMatrix: matrix,
        isSuccess: false,
        errorMessageKey: 'error_inverse_not_square',
      );
    }

    // Check determinant
    final detSolution = DeterminantSolver.solve(matrix);
    final det = detSolution.result as Rational;
    if (det.isZero) {
      final snap = MatrixSnapshot.fromMatrix(matrix);
      final step = MatrixStep(
        stepIndex: 1,
        titleKey: 'inverse_singular_title',
        explanationKey: 'inverse_singular_desc',
        explanationParams: {'det': '0'},
        matrixBefore: snap,
        matrixAfter: snap,
        transformation: InformationalStepTransformation('Determinant is 0, matrix has no inverse'),
        highlights: [
          for (int r = 0; r < matrix.rows; r++)
            for (int c = 0; c < matrix.cols; c++)
              CellHighlight(row: r, col: c, type: HighlightType.inactive),
        ],
      );
      return StepSolution(
        operationKey: 'op_inverse',
        initialMatrix: matrix,
        steps: [step],
        finalMatrix: matrix,
        isSuccess: false,
        errorMessageKey: 'error_matrix_is_singular',
      );
    }

    if (matrix.rows == 2) {
      return _solve2x2(matrix, det);
    }

    return _solveGaussJordanBlock(matrix);
  }

  static StepSolution _solve2x2(Matrix matrix, Rational det) {
    final a = matrix.get(0, 0);
    final b = matrix.get(0, 1);
    final c = matrix.get(1, 0);
    final d = matrix.get(1, 1);

    final steps = <MatrixStep>[];
    final snap1 = MatrixSnapshot.fromMatrix(matrix);

    // Step 1: Show Determinant
    steps.add(MatrixStep(
      stepIndex: 1,
      titleKey: 'inverse_2x2_det_title',
      explanationKey: 'inverse_2x2_det_desc',
      explanationParams: {
        'det': det.toLatex(),
        'formula': '(${a.toLatex()} \\cdot ${d.toLatex()}) - (${b.toLatex()} \\cdot ${c.toLatex()})',
      },
      matrixBefore: snap1,
      matrixAfter: snap1,
      transformation: DeterminantCrossProductTransformation(
        mainDiagonalProduct: a * d,
        antiDiagonalProduct: b * c,
      ),
      highlights: const [],
    ));

    // Step 2: Swap diagonal elements and negate off-diagonal elements (Adjoint)
    // [ d  -b ]
    // [ -c  a ]
    final adjMatrix = Matrix([
      [d, -b],
      [-c, a],
    ]);
    final snap2 = MatrixSnapshot.fromMatrix(adjMatrix);

    steps.add(MatrixStep(
      stepIndex: 2,
      titleKey: 'inverse_2x2_adjoint_title',
      explanationKey: 'inverse_2x2_adjoint_desc',
      explanationParams: {
        'd': d.toLatex(),
        'minusB': (-b).toLatex(),
        'minusC': (-c).toLatex(),
        'a': a.toLatex(),
      },
      matrixBefore: snap1,
      matrixAfter: snap2,
      transformation: const AdjugateTransformation(),
      highlights: const [],
    ));

    // Step 3: Multiply adjoint by 1/det
    final invDet = det.inverse();
    final invData = [
      [d * invDet, (-b) * invDet],
      [(-c) * invDet, a * invDet],
    ];
    final invMatrix = Matrix(invData);
    final snap3 = MatrixSnapshot.fromMatrix(invMatrix);

    steps.add(MatrixStep(
      stepIndex: 3,
      titleKey: 'inverse_2x2_scale_title',
      explanationKey: 'inverse_2x2_scale_desc',
      explanationParams: {
        'factor': invDet.toLatex(),
      },
      matrixBefore: snap2,
      matrixAfter: snap3,
      transformation: MatrixScaleTransformation(invDet),
      highlights: const [],
      subCalculations: [
        SubCalculation(
          targetRow: 0,
          targetCol: 0,
          formulaLatex: '${d.toLatex()} \\cdot ${invDet.toLatex()} = ${invMatrix.get(0, 0).toLatex()}',
          result: invMatrix.get(0, 0),
        ),
        SubCalculation(
          targetRow: 0,
          targetCol: 1,
          formulaLatex: '${(-b).toLatex()} \\cdot ${invDet.toLatex()} = ${invMatrix.get(0, 1).toLatex()}',
          result: invMatrix.get(0, 1),
        ),
        SubCalculation(
          targetRow: 1,
          targetCol: 0,
          formulaLatex: '${(-c).toLatex()} \\cdot ${invDet.toLatex()} = ${invMatrix.get(1, 0).toLatex()}',
          result: invMatrix.get(1, 0),
        ),
        SubCalculation(
          targetRow: 1,
          targetCol: 1,
          formulaLatex: '${a.toLatex()} \\cdot ${invDet.toLatex()} = ${invMatrix.get(1, 1).toLatex()}',
          result: invMatrix.get(1, 1),
        ),
      ],
    ));

    return StepSolution(
      operationKey: 'op_inverse',
      initialMatrix: matrix,
      steps: steps,
      finalMatrix: invMatrix,
      result: invMatrix,
      resultLatex: invMatrix.toLatex(),
      isSuccess: true,
    );
  }

  static StepSolution _solveGaussJordanBlock(Matrix matrix) {
    final n = matrix.rows;
    final identity = Matrix.identity(n);
    final augmented = matrix.augment(identity);

    // Initial setup step: [A | I]
    final snapInit = MatrixSnapshot.fromMatrix(
      augmented,
      structure: MatrixStructureType.block,
      augmentedColIndex: n,
    );

    final initialStep = MatrixStep(
      stepIndex: 1,
      titleKey: 'inverse_block_init_title',
      explanationKey: 'inverse_block_init_desc',
      explanationParams: {'n': n},
      matrixBefore: snapInit,
      matrixAfter: snapInit,
      transformation: InformationalStepTransformation('Augment A with identity matrix I_n'),
      highlights: [
        for (int r = 0; r < n; r++)
          for (int c = n; c < 2 * n; c++)
            CellHighlight(row: r, col: c, type: HighlightType.selected),
      ],
    );

    // Solve via Gauss-Jordan with block structure
    final gjSolution = GaussJordanSolver.solve(
      augmented,
      EliminationOptions(
        toRref: true,
        normalizePivotToOne: true,
        augmentedColIndex: n,
        structure: MatrixStructureType.block,
      ),
    );

    final renumberedSteps = <MatrixStep>[initialStep];
    var counter = 1;
    for (final s in gjSolution.steps) {
      renumberedSteps.add(MatrixStep(
        stepIndex: ++counter,
        titleKey: s.titleKey,
        titleParams: s.titleParams,
        explanationKey: s.explanationKey,
        explanationParams: s.explanationParams,
        matrixBefore: s.matrixBefore,
        matrixAfter: s.matrixAfter,
        transformation: s.transformation,
        highlights: s.highlights,
        subCalculations: s.subCalculations,
      ));
    }

    // Split final augmented matrix [I | A^-1]
    final (_, rightBlock) = gjSolution.finalMatrix.split(n);

    // The extraction step keeps [I | A⁻¹] on screen and marks the right
    // block. Showing only A⁻¹ with the left block as its "before" values made
    // the identity appear in the inverse's place until the step ended.
    final blockSnap = MatrixSnapshot.fromMatrix(
      gjSolution.finalMatrix,
      structure: MatrixStructureType.block,
      augmentedColIndex: n,
    );
    renumberedSteps.add(MatrixStep(
      stepIndex: ++counter,
      titleKey: 'inverse_block_extract_title',
      explanationKey: 'inverse_block_extract_desc',
      explanationParams: const {},
      matrixBefore: blockSnap,
      matrixAfter: blockSnap,
      transformation: IdentitySeparationTransformation(n),
      highlights: [
        for (int r = 0; r < n; r++)
          for (int c = n; c < 2 * n; c++)
            CellHighlight(row: r, col: c, type: HighlightType.selected),
      ],
    ));

    return StepSolution(
      operationKey: 'op_inverse',
      initialMatrix: matrix,
      steps: renumberedSteps,
      finalMatrix: rightBlock,
      result: rightBlock,
      resultLatex: rightBlock.toLatex(),
      isSuccess: true,
    );
  }
}
