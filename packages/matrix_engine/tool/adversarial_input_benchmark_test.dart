// Optional benchmark, not part of the default `dart test` run (files outside
// test/ are not picked up). Run from packages/matrix_engine with:
//   dart test tool/adversarial_input_benchmark_test.dart --reporter expanded
// Timings are machine-dependent and a VM run is not a browser or mobile
// measurement. Cases are deterministic; each cell is checked against the
// editor's 32-character bound and parsed with Rational.tryParse.

import 'package:matrix_engine/matrix_engine.dart';
import 'package:test/test.dart';

const _budgetMs = 5000;
const _maxCellLength = 32;

/// Deterministic 64-bit LCG so every run builds the same inputs.
class _Lcg {
  _Lcg(int seed) : _state = BigInt.from(seed);

  BigInt _state;

  static final BigInt _mask = (BigInt.one << 64) - BigInt.one;
  static final BigInt _mul = BigInt.parse('6364136223846793005');
  static final BigInt _add = BigInt.parse('1442695040888963407');

  int next(int bound) {
    _state = (_state * _mul + _add) & _mask;
    return ((_state >> 33) % BigInt.from(bound)).toInt();
  }

  /// A [count]-digit positive integer with a nonzero leading digit.
  BigInt digits(int count) {
    final buffer = StringBuffer()..write(1 + next(9));
    for (var i = 1; i < count; i++) {
      buffer.write(next(10));
    }
    return BigInt.parse(buffer.toString());
  }
}

/// Parses one cell the way the editor does and checks the length bound.
Rational _cell(String text) {
  expect(text.length, lessThanOrEqualTo(_maxCellLength), reason: text);
  final parsed = Rational.tryParse(text);
  if (parsed == null) fail('Rational.tryParse rejected "$text"');
  return parsed;
}

Matrix _matrix(List<List<String>> cells) => Matrix([
  for (final row in cells) [for (final text in row) _cell(text)],
]);

/// Runs [body], prints its wall time and asserts it is under the budget.
T _timed<T>(String name, T Function() body) {
  final watch = Stopwatch()..start();
  final result = body();
  watch.stop();
  final ms = watch.elapsedMilliseconds;
  print('$name: $ms ms');
  expect(ms, lessThan(_budgetMs), reason: '$name exceeded $_budgetMs ms');
  return result;
}

/// 15-digit numerator over 15-digit denominator, last digit odd and not 5,
/// with every numerator and denominator distinct across [count] fractions.
List<String> _distinctFractions(_Lcg g, int count) {
  final seen = <String>{};
  final out = <String>[];
  while (out.length < count) {
    final numerator = _oddEnding(g, 15);
    final denominator = _oddEnding(g, 15);
    if (!seen.add(numerator) || !seen.add(denominator)) continue;
    final sign = g.next(2) == 0 ? '-' : '';
    out.add('$sign$numerator/$denominator');
  }
  return out;
}

String _oddEnding(_Lcg g, int count) {
  final base = g.digits(count - 1).toString();
  return '$base${const ['1', '3', '7', '9'][g.next(4)]}';
}

List<String> _bigIntegers(_Lcg g, int count, int digitCount) {
  final seen = <String>{};
  final out = <String>[];
  while (out.length < count) {
    final text = g.digits(digitCount).toString();
    if (!seen.add(text)) continue;
    out.add(g.next(2) == 0 ? '-$text' : text);
  }
  return out;
}

List<List<String>> _grid(List<String> flat, int rows, int cols) => [
  for (var r = 0; r < rows; r++) flat.sublist(r * cols, (r + 1) * cols),
];

/// Every solver that applies to a square matrix, with the exactness checks
/// that are cheap to state.
void _squareSuite(String label, Matrix a, {required bool invertible}) {
  final n = a.rows;
  final det = _timed('$label: determinant', () => DeterminantSolver.solve(a));
  expect(det.isSuccess, isTrue);
  final determinant = det.result as Rational;

  if (invertible) {
    expect(determinant.isZero, isFalse, reason: '$label should be invertible');
  } else {
    expect(determinant.isZero, isTrue, reason: '$label should be singular');
  }

  final inverse = _timed('$label: inverse', () => InverseSolver.solve(a));
  if (invertible) {
    expect(inverse.isSuccess, isTrue);
    final inv = inverse.result as Matrix;
    final product = _timed(
      '$label: multiply A x inverse(A)',
      () => MatrixArithmeticSolver.multiply(a, inv).result as Matrix,
    );
    expect(product, equals(Matrix.identity(n)), reason: label);
  } else {
    expect(inverse.isSuccess, isFalse);
  }

  final rref = _timed(
    '$label: RREF (Gauss-Jordan)',
    () => GaussJordanSolver.solve(a),
  );
  if (invertible) {
    expect(rref.finalMatrix, equals(Matrix.identity(n)), reason: label);
  }

  final lu = _timed('$label: LU', () => LUDecompositionSolver.solve(a));
  if (invertible && lu.isSuccess) {
    final result = lu.result as LUResult;
    final left = result.pMatrix == null
        ? a
        : MatrixArithmeticSolver.multiply(result.pMatrix!, a).result as Matrix;
    final right =
        MatrixArithmeticSolver.multiply(result.lMatrix, result.uMatrix).result
            as Matrix;
    expect(right, equals(left), reason: '$label: LU reconstruction');
  }

  final rank = _timed('$label: rank/nullity', () => RankNullitySolver.solve(a));
  final rankResult = rank.result as RankNullityResult;
  expect(rankResult.rank + rankResult.nullity, equals(n));
  if (invertible) {
    expect(rankResult.rank, equals(n));
  } else {
    expect(rankResult.rank, lessThan(n));
  }

  final augmented = a.augment(
    Matrix([
      for (var r = 0; r < n; r++) [Rational.fromInt(r + 1)],
    ]),
  );
  final system = _timed(
    '$label: linear system [A | b]',
    () => LinearSystemsSolver.solve(augmented),
  );
  if (invertible) {
    final x = (system.result as LinearSystemResult).uniqueSolution;
    expect(x, isNotNull, reason: label);
    final solved = [for (var r = 0; r < n; r++) Rational.fromInt(r + 1)];
    final ax = [
      for (var r = 0; r < n; r++)
        [for (var c = 0; c < n; c++) a.get(r, c) * x![c]]
            .fold<Rational>(Rational.zero, (sum, term) => sum + term),
    ];
    for (var r = 0; r < n; r++) {
      expect(ax[r], equals(solved[r]), reason: '$label: A x = b, row $r');
    }
  }
}

void main() {
  group('input bounds', () {
    test('every generated cell fits the editor and parses', () {
      final g = _Lcg(7);
      for (final text in [
        ..._distinctFractions(g, 10),
        ..._bigIntegers(g, 10, 31),
      ]) {
        _cell(text);
      }
    });
  });

  group('5x5 solvers', () {
    test('fractions with 15-digit numerators and denominators', () {
      final cells = _distinctFractions(_Lcg(101), 25);
      _squareSuite(
        '5x5 fractions',
        _matrix(_grid(cells, 5, 5)),
        invertible: true,
      );
    });

    test('31-digit integers', () {
      final cells = _bigIntegers(_Lcg(202), 25, 31);
      _squareSuite(
        '5x5 31-digit integers',
        _matrix(_grid(cells, 5, 5)),
        invertible: true,
      );
    });

    test('singular 5x5 with 20-digit entries, row dependency', () {
      final g = _Lcg(303);
      final rows = [
        for (var r = 0; r < 4; r++)
          [
            for (var c = 0; c < 5; c++)
              g.digits(20) * (g.next(2) == 0 ? BigInt.one : BigInt.from(-1)),
          ],
      ];
      final dependent = [
        for (var c = 0; c < 5; c++)
          rows[0][c] + rows[1][c] * BigInt.two - rows[3][c],
      ];
      final all = [...rows, dependent];
      final text = [
        for (final row in all) [for (final v in row) v.toString()],
      ];
      _squareSuite('5x5 singular', _matrix(text), invertible: false);
    });

    test('nearly singular 5x5: one-unit perturbation of a singular matrix', () {
      final g = _Lcg(404);
      final rows = [
        for (var r = 0; r < 4; r++) [for (var c = 0; c < 5; c++) g.digits(20)],
      ];
      final dependent = [
        for (var c = 0; c < 5; c++)
          rows[0][c] + rows[1][c] * BigInt.two - rows[3][c],
      ];
      final all = [...rows, dependent];
      all[4][4] = all[4][4] + BigInt.one;
      final a = _matrix([
        for (final row in all) [for (final v in row) v.toString()],
      ]);
      // Expanding along the perturbed entry: det equals the leading 4x4 minor.
      final minor = _matrix([
        for (var r = 0; r < 4; r++)
          [for (var c = 0; c < 4; c++) rows[r][c].toString()],
      ]);
      final minorDet = DeterminantSolver.solve(minor).result as Rational;
      final det = DeterminantSolver.solve(a).result as Rational;
      expect(det, equals(minorDet));
      _squareSuite('5x5 nearly singular', a, invertible: !det.isZero);
    });

    test('Cauchy (Hilbert-like) with 15-digit denominators', () {
      final cells = <String>[];
      for (var i = 0; i < 5; i++) {
        for (var j = 0; j < 5; j++) {
          final sum =
              BigInt.parse('100000000000000') +
              BigInt.from(7919 * i) +
              BigInt.parse('10000000000000') +
              BigInt.from(104729 * j);
          cells.add('1/$sum');
        }
      }
      _squareSuite('5x5 Cauchy', _matrix(_grid(cells, 5, 5)), invertible: true);
    });

    test('editor stops at 5x5 and eigen analysis is unsupported', () {
      final a = _matrix(_grid(_distinctFractions(_Lcg(505), 25), 5, 5));
      final solution = EigenSolver.solve(a);
      expect(solution.completeness, ResultCompleteness.unsupported);
    });
  });

  group('eigen analysis', () {
    test('3x3 generic large coprime fractions', () {
      final a = _matrix(_grid(_distinctFractions(_Lcg(606), 9), 3, 3));
      final solution = _timed(
        '3x3 fractions: eigen',
        () => EigenSolver.solve(a),
      );
      expect(solution.isSuccess, isTrue);
      final result = solution.result as EigenResult;
      expect(
        result.eigenpairs.fold<int>(0, (s, p) => s + p.algebraicMultiplicity),
        equals(3),
      );
    });

    test('3x3 repeated eigenvalue with large entries, full eigenspace', () {
      // A = cI + u vᵀ: eigenvalue c has multiplicity 2 and nullity 2.
      const c = 12345678901234;
      final u = [123457, 234567, 345679];
      final v = [-987653, 876543, 765431];
      final s = u[0] * v[0] + u[1] * v[1] + u[2] * v[2];
      expect(s, isNot(0));
      final cells = [
        for (var r = 0; r < 3; r++)
          [for (var q = 0; q < 3; q++) '${(r == q ? c : 0) + u[r] * v[q]}'],
      ];
      final a = _matrix(cells);
      final solution = _timed(
        '3x3 repeated: eigen',
        () => EigenSolver.solve(a),
      );
      final result = solution.result as EigenResult;
      expect(result.isDiagonalizable, isTrue);
      final repeated = result.eigenpairs.singleWhere(
        (p) => p.algebraicMultiplicity == 2,
      );
      expect(repeated.eigenspaceBasis, hasLength(2));
    });

    test('3x3 defective Jordan block with large entries', () {
      final a = _matrix([
        ['12345678901234567', '98765432109876', '0'],
        ['0', '12345678901234567', '55555555555557'],
        ['0', '0', '12345678901234567'],
      ]);
      final solution = _timed(
        '3x3 defective: eigen',
        () => EigenSolver.solve(a),
      );
      final result = solution.result as EigenResult;
      expect(result.isDiagonalizable, isFalse);
      final triple = result.eigenpairs.singleWhere(
        (p) => p.algebraicMultiplicity == 3,
      );
      expect(triple.eigenspaceBasis, hasLength(1));
    });

    test('2x2 with irrational eigenvalues +-sqrt(D) for a 15-digit D', () {
      final a = _matrix([
        ['0', '999999999999989'],
        ['1', '0'],
      ]);
      final solution = _timed('2x2 sqrt(D): eigen', () => EigenSolver.solve(a));
      final result = solution.result as EigenResult;
      expect(result.realEigenpairs, isEmpty);
      expect(result.eigenpairs, hasLength(2));
    });

    test('2x2 large fractions', () {
      final a = _matrix(_grid(_distinctFractions(_Lcg(707), 4), 2, 2));
      final solution = _timed(
        '2x2 fractions: eigen',
        () => EigenSolver.solve(a),
      );
      expect(solution.isSuccess, isTrue);
    });
  });
}
