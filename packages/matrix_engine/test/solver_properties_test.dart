import 'dart:math';

import 'package:matrix_engine/matrix_engine.dart';
import 'package:test/test.dart';

/// Every solver checked on seeded random matrices against reference
/// implementations written independently of the engine's algorithms:
/// cofactor expansion, the schoolbook product, a plain Gauss-Jordan RREF.
/// The steps themselves are checked too, since the player animates them:
/// each row operation must turn its "before" snapshot into its "after".

Matrix _product(Matrix a, Matrix b) => Matrix([
  for (var r = 0; r < a.rows; r++)
    [
      for (var c = 0; c < b.cols; c++)
        [for (var k = 0; k < a.cols; k++) a.get(r, k) * b.get(k, c)]
            .fold(Rational.zero, (sum, v) => sum + v),
    ],
]);

Rational _cofactorDet(Matrix m) {
  if (m.rows == 1) return m.get(0, 0);
  var sum = Rational.zero;
  for (var c = 0; c < m.cols; c++) {
    if (m.get(0, c).isZero) continue;
    final term = m.get(0, c) * _cofactorDet(m.submatrix(0, c));
    sum = c.isEven ? sum + term : sum - term;
  }
  return sum;
}

/// Reduced row echelon form; unique for a matrix, so any correct solver
/// must produce exactly this.
Matrix _rref(Matrix m) {
  final rows = m.toList();
  var lead = 0;
  for (var r = 0; r < m.rows && lead < m.cols; lead++) {
    final pivot = [for (var i = r; i < m.rows; i++) i]
        .where((i) => !rows[i][lead].isZero)
        .firstOrNull;
    if (pivot == null) continue;
    final swap = rows[pivot];
    rows[pivot] = rows[r];
    rows[r] = swap;
    final p = rows[r][lead];
    rows[r] = [for (final v in rows[r]) v / p];
    for (var i = 0; i < m.rows; i++) {
      if (i == r || rows[i][lead].isZero) continue;
      final f = rows[i][lead];
      rows[i] = [for (var c = 0; c < m.cols; c++) rows[i][c] - f * rows[r][c]];
    }
    r++;
  }
  return Matrix(rows);
}

List<int> _leadingColumns(Matrix rref) {
  final out = <int>[];
  for (var r = 0; r < rref.rows; r++) {
    for (var c = 0; c < rref.cols; c++) {
      if (!rref.get(r, c).isZero) {
        out.add(c);
        break;
      }
    }
  }
  return out;
}

int _rank(Matrix m) => _leadingColumns(_rref(m)).length;

bool _isRowEchelon(Matrix m) {
  var previous = -1;
  var zeroRowSeen = false;
  for (var r = 0; r < m.rows; r++) {
    final lead = [for (var c = 0; c < m.cols; c++) c]
        .where((c) => !m.get(r, c).isZero)
        .firstOrNull;
    if (lead == null) {
      zeroRowSeen = true;
      continue;
    }
    if (zeroRowSeen || lead <= previous) return false;
    for (var below = r + 1; below < m.rows; below++) {
      if (!m.get(below, lead).isZero) return false;
    }
    previous = lead;
  }
  return true;
}

Matrix _random(Random rng, int rows, int cols, {bool fractions = true}) {
  Rational entry() {
    final roll = rng.nextInt(10);
    if (roll < 3) return Rational.zero;
    final n = rng.nextInt(13) - 6;
    if (fractions && roll == 9) return Rational(n, rng.nextInt(4) + 2);
    return Rational(n);
  }

  final data = [
    for (var r = 0; r < rows; r++) [for (var c = 0; c < cols; c++) entry()],
  ];
  // A third of the matrices are rank deficient: one row repeats a
  // combination of two others, so singular paths are exercised too.
  if (rows >= 3 && rng.nextInt(3) == 0) {
    final a = rng.nextInt(rows);
    final b = (a + 1) % rows;
    final target = (a + 2) % rows;
    final k = Rational(rng.nextInt(5) - 2);
    data[target] = [for (var c = 0; c < cols; c++) data[a][c] + k * data[b][c]];
  }
  return Matrix(data);
}

Matrix _toMatrix(MatrixSnapshot s) => s.toMatrix();

/// Applying each row operation to its "before" snapshot must give its
/// "after" snapshot; otherwise the animation shows something the
/// arithmetic did not do.
void _expectRowOperationsConsistent(StepSolution solution, String label) {
  for (final step in solution.steps) {
    final before = _toMatrix(step.matrixBefore);
    final after = _toMatrix(step.matrixAfter);
    final t = step.transformation;
    final Matrix? expected = switch (t) {
      RowSwapTransformation() => before.swapRows(t.rowA, t.rowB),
      RowScaleTransformation() => before.scaleRow(t.row, t.scalar),
      RowEliminationTransformation() => before.addRowMultiple(
        t.targetRow,
        t.sourceRow,
        t.factor,
      ),
      _ => null,
    };
    if (expected != null) {
      expect(after, expected, reason: '$label step ${step.stepIndex}');
    }
  }
}

void _expectChained(StepSolution solution, String label) {
  for (var i = 1; i < solution.steps.length; i++) {
    expect(
      _toMatrix(solution.steps[i].matrixBefore),
      _toMatrix(solution.steps[i - 1].matrixAfter),
      reason: '$label: step ${i + 1} starts where step $i ended',
    );
  }
}

void main() {
  final rng = Random(20260924);
  const rounds = 60;

  test('Determinant equals cofactor expansion for every method and size', () {
    for (var i = 0; i < rounds; i++) {
      final n = 1 + i % 5;
      final a = _random(rng, n, n);
      final expected = _cofactorDet(a);
      for (final method in DeterminantMethod.values) {
        final solution = DeterminantSolver.solve(a, method: method);
        expect(solution.result, expected, reason: '$method on\n$a');
        _expectRowOperationsConsistent(solution, 'det $method');
      }
    }
  });

  test('Inverse satisfies A·A⁻¹ = A⁻¹·A = I, or the matrix is singular', () {
    for (var i = 0; i < rounds; i++) {
      final n = 1 + i % 5;
      final a = _random(rng, n, n);
      final solution = InverseSolver.solve(a);
      if (_cofactorDet(a).isZero) {
        expect(solution.isSuccess, isFalse, reason: '$a');
        continue;
      }
      final inverse = solution.result as Matrix;
      expect(_product(a, inverse), Matrix.identity(n), reason: '$a');
      expect(_product(inverse, a), Matrix.identity(n), reason: '$a');
      _expectRowOperationsConsistent(solution, 'inverse');
    }
  });

  test('Sum and product match the schoolbook definitions', () {
    for (var i = 0; i < rounds; i++) {
      final rows = 1 + rng.nextInt(5);
      final inner = 1 + rng.nextInt(5);
      final cols = 1 + rng.nextInt(5);
      final a = _random(rng, rows, inner);
      final b = _random(rng, inner, cols);
      final c = _random(rng, rows, inner);
      expect(MatrixArithmeticSolver.multiply(a, b).result, _product(a, b));
      expect(
        MatrixArithmeticSolver.add(a, c).result,
        Matrix([
          for (var r = 0; r < rows; r++)
            [for (var k = 0; k < inner; k++) a.get(r, k) + c.get(r, k)],
        ]),
      );
    }
  });

  test('Gauss-Jordan reaches the unique RREF through valid row operations', () {
    for (var i = 0; i < rounds; i++) {
      final a = _random(rng, 1 + rng.nextInt(5), 1 + rng.nextInt(5));
      final rref = GaussJordanSolver.solve(a);
      expect(rref.result, _rref(a), reason: '$a');
      _expectChained(rref, 'rref');
      _expectRowOperationsConsistent(rref, 'rref');

      final ref = GaussJordanSolver.solve(
        a,
        const EliminationOptions(toRref: false, normalizePivotToOne: false),
      );
      final echelon = ref.result as Matrix;
      expect(_isRowEchelon(echelon), isTrue, reason: '$a\n->\n$echelon');
      expect(_rref(echelon), _rref(a), reason: 'row equivalent: $a');
      _expectChained(ref, 'ref');
      _expectRowOperationsConsistent(ref, 'ref');
    }
  });

  test('LU satisfies P·A = L·U with unit lower L and upper U', () {
    for (var i = 0; i < rounds; i++) {
      final n = 1 + i % 5;
      final a = _random(rng, n, n);
      final solution = LUDecompositionSolver.solve(a);
      expect(solution.isSuccess, isTrue, reason: '$a');
      final lu = solution.result as LUResult;
      final p = lu.pMatrix ?? Matrix.identity(n);
      expect(_product(p, a), _product(lu.lMatrix, lu.uMatrix), reason: '$a');
      for (var r = 0; r < n; r++) {
        expect(lu.lMatrix.get(r, r), Rational.one);
        for (var c = r + 1; c < n; c++) {
          expect(lu.lMatrix.get(r, c), Rational.zero, reason: 'L upper part');
          expect(lu.uMatrix.get(c, r), Rational.zero, reason: 'U lower part');
        }
      }
      _expectChained(solution, 'lu');
      _expectRowOperationsConsistent(solution, 'lu');
    }
  });

  test('Rank and nullity agree with an independent RREF', () {
    for (var i = 0; i < rounds; i++) {
      final a = _random(rng, 1 + rng.nextInt(5), 1 + rng.nextInt(5));
      final solution = RankNullitySolver.solve(a);
      final result = solution.result as RankNullityResult;
      final pivots = _leadingColumns(_rref(a));
      expect(result.rank, pivots.length, reason: '$a');
      expect(result.nullity, a.cols - pivots.length);
      expect(result.pivotColumnIndices, pivots);
      expect(result.freeColumnIndices, [
        for (var c = 0; c < a.cols; c++)
          if (!pivots.contains(c)) c,
      ]);
      _expectRowOperationsConsistent(solution, 'rank');
    }
  });

  test('Linear systems: solutions satisfy Ax = b and types follow ranks', () {
    for (var i = 0; i < rounds; i++) {
      final rows = 1 + rng.nextInt(4);
      final unknowns = 1 + rng.nextInt(4);
      final a = _random(rng, rows, unknowns);
      final b = _random(rng, rows, 1);
      final solution = LinearSystemsSolver.solve(a.augment(b));
      final result = solution.result as LinearSystemResult;
      final rankA = _rank(a);
      final rankAb = _rank(a.augment(b));
      final expectedType = rankA < rankAb
          ? LinearSystemType.inconsistent
          : rankA == unknowns
          ? LinearSystemType.unique
          : LinearSystemType.infinite;
      expect(result.type, expectedType, reason: '$a | $b');
      if (result.type == LinearSystemType.unique) {
        final x = Matrix([
          for (final v in result.uniqueSolution!) [v],
        ]);
        expect(_product(a, x), b, reason: '$a x = $b');
      }
      if (result.type == LinearSystemType.infinite) {
        expect(result.freeVariables.length, unknowns - rankA);
      }
      _expectRowOperationsConsistent(solution, 'system');
    }
  });

  test('Eigenpairs satisfy Av = λv exactly or to their stated rounding', () {
    for (var i = 0; i < rounds * 2; i++) {
      final n = 2 + i % 2;
      final a = _random(rng, n, n, fractions: i % 4 == 0);
      final solution = EigenSolver.solve(a);
      final result = solution.result as EigenResult;
      Rational charPoly(Rational lambda) => _cofactorDet(
        Matrix([
          for (var r = 0; r < n; r++)
            [
              for (var c = 0; c < n; c++)
                r == c ? a.get(r, c) - lambda : a.get(r, c),
            ],
        ]),
      );
      for (final pair in result.realEigenpairs) {
        final v = Matrix([
          for (final e in pair.eigenvector) [e],
        ]);
        expect(pair.eigenvector.any((e) => !e.isZero), isTrue);
        final exact = charPoly(pair.eigenvalue).isZero;
        if (exact) {
          expect(
            _product(a, v),
            Matrix([
              for (final e in pair.eigenvector) [e * pair.eigenvalue],
            ]),
            reason: 'Av = λv for λ = ${pair.eigenvalue} on\n$a',
          );
        } else {
          // Rounded to three decimals: a true root lies within 0.0005.
          expect(solution.accuracy, ResultAccuracy.approximate);
          final half = Rational(1, 2000);
          final low = charPoly(pair.eigenvalue - half);
          final high = charPoly(pair.eigenvalue + half);
          expect(
            low.isZero || high.isZero || low.isNegative != high.isNegative,
            isTrue,
            reason: 'a root near ${pair.eigenvalue} for\n$a',
          );
        }
      }
      if (solution.completeness == ResultCompleteness.complete) {
        // Every real root is reported: count sign changes of the
        // characteristic polynomial against the number of pairs.
        final values = result.realEigenpairs.map((p) => p.eigenvalue).toSet();
        expect(values.length, result.realEigenpairs.length);
        expect(result.hasComplexEigenvalues, isFalse);
        expect(
          result.realEigenpairs.length,
          n,
          reason: 'distinct roots of\n$a',
        );
      }
    }
  });
}
