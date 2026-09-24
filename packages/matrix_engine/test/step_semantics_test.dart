import 'package:matrix_engine/matrix_engine.dart';
import 'package:test/test.dart';

/// Roles that the app's legend names: pivot, source, target, zero result.
const _eliminationRoles = {
  HighlightType.pivot,
  HighlightType.source,
  HighlightType.target,
  HighlightType.zeroed,
};

Iterable<HighlightType> _roles(MatrixStep step) =>
    step.highlights.map((h) => h.type).where(_eliminationRoles.contains);

void main() {
  test('Determinant formula steps claim no elimination roles', () {
    for (final matrix in [
      Matrix.fromInts([
        [2, 3],
        [1, 4],
      ]),
      Matrix.fromInts([
        [1, 2, 3],
        [0, 1, 4],
        [5, 6, 0],
      ]),
    ]) {
      final solution = DeterminantSolver.solve(matrix);
      for (final step in solution.steps) {
        expect(_roles(step), isEmpty);
        // The explanation lists these products; no single cell owns them.
        expect(step.subCalculations, isEmpty);
      }
      final last = solution.steps.last.transformation;
      expect(
        last is DeterminantCrossProductTransformation
            ? last.recap
            : (last as DeterminantSarrusTransformation).recap,
        isTrue,
      );
    }
  });

  test('Eigen, rank and LU summary steps mark only real pivots', () {
    final eigen = EigenSolver.solve(
      Matrix.fromInts([
        [4, 1],
        [2, 3],
      ]),
    );
    for (final step in eigen.steps) {
      expect(_roles(step), isEmpty);
    }
    final rank = RankNullitySolver.solve(
      Matrix.fromInts([
        [1, 2, 3],
        [2, 4, 6],
        [1, 0, 1],
      ]),
    );
    final summary = rank.steps.last;
    final result = rank.result as RankNullityResult;
    expect(summary.highlights.length, result.rank);
    for (final h in summary.highlights) {
      expect(h.type, HighlightType.pivot);
      expect(rank.finalMatrix.get(h.row, h.col), Rational.one);
    }
    final lu = LUDecompositionSolver.solve(
      Matrix.fromInts([
        [2, 1, 1],
        [4, 3, 3],
        [8, 7, 9],
      ]),
    );
    expect(lu.steps.first.highlights, isEmpty);
    expect(lu.steps.last.highlights, isEmpty);
  });

  test('Eigenvector steps say the matrix shown is A - lambda I', () {
    final solution = EigenSolver.solve(
      Matrix.fromInts([
        [2, 0, 0],
        [0, 3, 0],
        [0, 0, -4],
      ]),
    );
    final scenes = solution.steps
        .where((s) => s.explanationKey == 'eigen_vector_desc')
        .map((s) => s.explanationParams['scene'] as String)
        .toList();
    expect(scenes, hasLength(3));
    expect(scenes, contains(startsWith('A + 4I')));
    expect(scenes, contains(startsWith('A - 2I')));
  });

  test('LU steps carry L as it is filled and the result names L and U', () {
    final solution = LUDecompositionSolver.solve(
      Matrix.fromInts([
        [2, 1, 1],
        [4, 3, 3],
        [8, 7, 9],
      ]),
    );
    final eliminations = solution.steps
        .map((s) => s.transformation)
        .whereType<LUEliminationTransformation>()
        .toList();
    expect(eliminations, isNotEmpty);
    for (final t in eliminations) {
      expect(t.lower.get(t.lowerRow, t.lowerCol), -t.factor);
      expect(t.lowerRow, t.targetRow);
      expect(t.lowerCol, t.sourceRow);
    }
    final lu = solution.result as LUResult;
    expect(eliminations.last.lower.toMatrix(), lu.lMatrix);
    expect(solution.resultLatex, contains('L = '));
    expect(solution.resultLatex, contains('U = '));
  });

  test('2x2 inverse animates the adjugate and the 1/det scaling', () {
    final solution = InverseSolver.solve(
      Matrix.fromInts([
        [4, 7],
        [2, 6],
      ]),
    );
    final adjugate = solution.steps[1];
    expect(adjugate.transformation, isA<AdjugateTransformation>());
    expect(
      adjugate.matrixAfter.toMatrix(),
      Matrix.fromInts([
        [6, -7],
        [-2, 4],
      ]),
    );
    final scale = solution.steps[2];
    expect(scale.transformation, isA<MatrixScaleTransformation>());
    expect(
      (scale.transformation as MatrixScaleTransformation).scalar,
      Rational(1, 10),
    );
    expect(scale.matrixAfter.toMatrix(), solution.result);
  });

  test('Block inverse extraction keeps [I | A^-1] and marks the right block', () {
    final solution = InverseSolver.solve(
      Matrix.fromInts([
        [1, 2, 0],
        [0, 1, 0],
        [2, 0, 1],
      ]),
    );
    final extract = solution.steps.last;
    expect(extract.transformation, isA<IdentitySeparationTransformation>());
    expect(extract.matrixBefore.cols, 6);
    expect(extract.matrixAfter.cols, 6);
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        expect(extract.matrixAfter.get(r, c), r == c ? Rational.one : Rational.zero);
        expect(
          extract.matrixAfter.get(r, c + 3),
          (solution.result as Matrix).get(r, c),
        );
      }
    }
    expect(extract.highlights.every((h) => h.col >= 3), isTrue);
  });
}
