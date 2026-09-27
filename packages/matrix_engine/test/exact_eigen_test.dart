import 'dart:math';

import 'package:matrix_engine/matrix_engine.dart';
import 'package:test/test.dart';

/// Exact eigen analysis: every eigenvalue in closed form, every eigenvector
/// verified in its own number field Q(λ).

/// det(xI - A) by cofactor expansion over polynomials, independent of the
/// solver's trace and minor formulas.
RationalPolynomial _characteristic(Matrix a) {
  RationalPolynomial det(List<List<RationalPolynomial>> m) {
    if (m.length == 1) return m[0][0];
    var sum = RationalPolynomial.zero;
    for (var c = 0; c < m.length; c++) {
      final minor = [
        for (var r = 1; r < m.length; r++)
          [
            for (var k = 0; k < m.length; k++)
              if (k != c) m[r][k],
          ],
      ];
      final term = m[0][c] * det(minor);
      sum = c.isEven ? sum + term : sum - term;
    }
    return sum;
  }

  return det([
    for (var r = 0; r < a.rows; r++)
      [
        for (var c = 0; c < a.cols; c++)
          RationalPolynomial([-a.get(r, c), if (r == c) Rational.one]),
      ],
  ]);
}

/// (a) (A - λI)v = 0 in Q(λ) for every basis vector; returns the pairs.
List<ExactEigenpair> _expectExact(Matrix a, StepSolution solution) {
  expect(solution.isSuccess, isTrue);
  expect(solution.accuracy, ResultAccuracy.exact);
  expect(solution.decimalPlaces, isNull);
  expect(solution.completeness, ResultCompleteness.complete);
  final result = solution.result as EigenResult;
  for (final pair in result.eigenpairs) {
    final field = pair.eigenvalue.field;
    final lambda = field.generator;
    expect(pair.eigenspaceBasis, isNotEmpty);
    for (final v in pair.eigenspaceBasis) {
      expect(v, hasLength(a.rows));
      expect(v.any((e) => !e.isZero), isTrue, reason: 'zero vector for\n$a');
      for (var r = 0; r < a.rows; r++) {
        var sum = field.zero;
        for (var c = 0; c < a.cols; c++) {
          final entry = field.rational(a.get(r, c));
          sum += (r == c ? entry - lambda : entry) * v[c];
        }
        expect(
          sum.isZero,
          isTrue,
          reason: '(A - λI)v ≠ 0 for λ = ${pair.eigenvalue.text} on\n$a',
        );
      }
    }
  }
  return result.eigenpairs;
}

/// (b) the irreducible factors with multiplicity multiply to the
/// characteristic polynomial; (c) the multiplicities sum to n.
void _expectFactorization(Matrix a, List<ExactEigenpair> pairs) {
  final byFactor = <RationalPolynomial, int>{};
  for (final pair in pairs) {
    final m = pair.eigenvalue.minimalPolynomial;
    expect(m.isMonic, isTrue);
    final previous = byFactor[m];
    if (previous != null) {
      expect(pair.algebraicMultiplicity, previous, reason: 'conjugates');
    }
    byFactor[m] = pair.algebraicMultiplicity;
  }
  var product = RationalPolynomial.one;
  for (final MapEntry(key: m, value: k) in byFactor.entries) {
    for (var i = 0; i < k; i++) {
      product *= m;
    }
  }
  expect(product, _characteristic(a), reason: 'factorization of\n$a');
  // Each distinct root appears once: deg m pairs per irreducible factor.
  for (final m in byFactor.keys) {
    expect(
      pairs.where((p) => p.eigenvalue.minimalPolynomial == m).length,
      m.degree,
    );
  }
  expect(
    pairs.fold(0, (sum, p) => sum + p.algebraicMultiplicity),
    a.rows,
    reason: 'multiplicities of\n$a',
  );
}

/// (d) the floating-point value of each closed form is a root: |p(z)| is
/// tiny against the size of the terms, and distinct roots stay apart.
void _expectApproximations(Matrix a, List<ExactEigenpair> pairs) {
  final p = _characteristic(a);
  final coefficients = [
    for (final c in p.coefficients) c.num.toDouble() / c.den.toDouble(),
  ];
  for (final pair in pairs) {
    final value = pair.eigenvalue;
    final re = value.approximate;
    final im = value.approximateImaginary;
    expect(re.isFinite && im.isFinite, isTrue);
    expect(value.isReal, im == 0);
    // Horner in complex arithmetic, and Σ|a_i||z|^i for scale.
    var accRe = 0.0;
    var accIm = 0.0;
    var scale = 0.0;
    final modulus = sqrt(re * re + im * im);
    for (var i = coefficients.length - 1; i >= 0; i--) {
      final nextRe = accRe * re - accIm * im + coefficients[i];
      final nextIm = accRe * im + accIm * re;
      accRe = nextRe;
      accIm = nextIm;
      scale += coefficients[i].abs() * pow(modulus, i);
    }
    final residual = sqrt(accRe * accRe + accIm * accIm);
    expect(
      residual <= 1e-8 * scale,
      isTrue,
      reason:
          'p(${value.text}) ≈ $residual for scale $scale ($re + ${im}i) on\n$a',
    );
  }
  for (var i = 0; i < pairs.length; i++) {
    for (var j = i + 1; j < pairs.length; j++) {
      final x = pairs[i].eigenvalue;
      final y = pairs[j].eigenvalue;
      expect(
        x.approximate != y.approximate ||
            x.approximateImaginary != y.approximateImaginary,
        isTrue,
        reason: '${x.text} and ${y.text} coincide on\n$a',
      );
    }
  }
}

void _expectAll(Matrix a) {
  final solution = EigenSolver.solve(a);
  final pairs = _expectExact(a, solution);
  _expectFactorization(a, pairs);
  _expectApproximations(a, pairs);
  final result = solution.result as EigenResult;
  expect(result.characteristicPolynomial!.monic(), _characteristic(a));
  expect(
    result.realEigenpairs.map((p) => p.eigenvalue),
    pairs
        .where((p) => p.eigenvalue.isRational)
        .map((p) => p.eigenvalue.rationalValue),
  );
  expect(result.hasComplexEigenvalues, pairs.any((p) => !p.eigenvalue.isReal));
  // The result lists one exact part per eigenvalue.
  expect(solution.resultLatex!.split(r' \quad '), hasLength(pairs.length));
  expect(solution.resultLatex, isNot(contains(r'\approx')));
}

BigInt _digits(Random rng, int digits) {
  var value = BigInt.zero;
  for (var i = 0; i < digits; i++) {
    value = value * BigInt.from(10) + BigInt.from(rng.nextInt(10));
  }
  return value;
}

Matrix _random(Random rng, int n, Rational Function() entry) => Matrix([
  for (var r = 0; r < n; r++) [for (var c = 0; c < n; c++) entry()],
]);

Matrix _ints(List<List<int>> rows) => Matrix.fromInts(rows);

void main() {
  group('RationalPolynomial', () {
    final x = RationalPolynomial.x;
    final one = RationalPolynomial.one;
    test('arithmetic, division and gcd', () {
      final p = (x - one) * (x - one) * (x + one); // x³ - x² - x + 1
      expect(p, RationalPolynomial.fromInts([1, -1, -1, 1]));
      final (:quotient, :remainder) = p.divMod(x * x + one);
      expect(quotient * (x * x + one) + remainder, p);
      expect(remainder.degree, lessThan(2));
      expect(p.gcd(p.derivative()), x - one);
      expect(p.evaluate(Rational(1, 2)), Rational(3, 8));
      expect(p.toLatex(), r'\lambda^{3} - \lambda^{2} - \lambda + 1');
      expect(RationalPolynomial.zero.degree, -1);
      expect(
        RationalPolynomial([Rational.one, Rational.zero, Rational.zero]),
        one,
      );
    });
  });

  group('NumberField', () {
    test('Q(√2): arithmetic and inverses are exact', () {
      final field = NumberField(RationalPolynomial.fromInts([-2, 0, 1]));
      final root2 = field.generator;
      expect(root2 * root2, field.rational(Rational(2)));
      final a = field.one + root2; // 1 + √2
      expect(a * a.inverse(), field.one);
      expect(a.inverse(), root2 - field.one); // 1/(1 + √2) = √2 - 1
      expect((a - a).isZero, isTrue);
      expect(
        () => field.zero.inverse(),
        throwsA(isA<DivisionByZeroException>()),
      );
    });
    test('a cubic field reduces powers of the generator', () {
      final field = NumberField(RationalPolynomial.fromInts([-2, 0, 0, 1]));
      final t = field.generator;
      expect(t * t * t, field.rational(Rational(2)));
      final e = t * t + t + field.one;
      expect(e * e.inverse(), field.one);
    });
    test('elements of different fields do not mix', () {
      final a = NumberField(RationalPolynomial.fromInts([-2, 0, 1]));
      final b = NumberField(RationalPolynomial.fromInts([-3, 0, 1]));
      expect(() => a.one + b.one, throwsArgumentError);
    });
  });

  group('Known spectra', () {
    List<String> latex(Matrix a) => [
      for (final p in (EigenSolver.solve(a).result as EigenResult).eigenpairs)
        p.eigenvalue.latex,
    ];

    test('[[0,2],[1,0]] has ±√2', () {
      final a = _ints([
        [0, 2],
        [1, 0],
      ]);
      expect(latex(a), [r'\sqrt{2}', r'-\sqrt{2}']);
      _expectAll(a);
    });
    test('[[1,1],[1,0]] has (1 ± √5)/2 with integer vectors', () {
      final a = _ints([
        [1, 1],
        [1, 0],
      ]);
      final solution = EigenSolver.solve(a);
      final pairs = (solution.result as EigenResult).eigenpairs;
      expect(pairs.map((p) => p.eigenvalue.latex), [
        r'\frac{1}{2} + \frac{\sqrt{5}}{2}',
        r'\frac{1}{2} - \frac{\sqrt{5}}{2}',
      ]);
      expect(pairs.map((p) => p.eigenvalue.text), ['1/2 + √5/2', '1/2 - √5/2']);
      expect(pairs.map((p) => p.vectorLatex(p.eigenspaceBasis.single)), [
        r'\begin{pmatrix}2 \\ -1 + \sqrt{5}\end{pmatrix}',
        r'\begin{pmatrix}2 \\ -1 - \sqrt{5}\end{pmatrix}',
      ]);
      expect(solution.resultLatex, contains(r'\frac{\sqrt{5}}{2} \implies'));
      _expectAll(a);
    });
    test('[[0,-1],[1,0]] has ±i with complex vectors', () {
      final a = _ints([
        [0, -1],
        [1, 0],
      ]);
      final pairs = (EigenSolver.solve(a).result as EigenResult).eigenpairs;
      expect(pairs.map((p) => p.eigenvalue.latex), ['i', '-i']);
      expect(pairs.map((p) => p.vectorText(p.eigenspaceBasis.single)), [
        '(1, -i)',
        '(1, i)',
      ]);
      _expectAll(a);
    });
    test('[[1,-2],[1,3]] has 2 ± i', () {
      final a = _ints([
        [1, -2],
        [1, 3],
      ]);
      expect(latex(a), ['2 + i', '2 - i']);
      _expectAll(a);
    });
    test('the companion matrix of x³ - 2 has ∛2 and a complex pair', () {
      final a = _ints([
        [0, 1, 0],
        [0, 0, 1],
        [2, 0, 0],
      ]);
      final solution = EigenSolver.solve(a);
      final pairs = (solution.result as EigenResult).eigenpairs;
      expect(pairs.map((p) => p.eigenvalue.latex), [
        r'\sqrt[3]{2}',
        r'-\frac{\sqrt[3]{2}}{2} + \frac{\sqrt{3}\,\sqrt[3]{2}}{2}i',
        r'-\frac{\sqrt[3]{2}}{2} - \frac{\sqrt{3}\,\sqrt[3]{2}}{2}i',
      ]);
      expect(pairs.first.eigenvalue.approximate, closeTo(pow(2, 1 / 3), 1e-12));
      // One vector formula in λ serves all three roots of the cubic.
      expect(
        pairs.map((p) => p.vectorLatex(p.eigenspaceBasis.single)).toSet(),
        hasLength(1),
      );
      expect(solution.steps[1].explanationKey, 'eigen_roots_cardano_desc');
      _expectAll(a);
    });
    test('the companion matrix of x³ - 3x + 1 has three real roots', () {
      final a = _ints([
        [0, 1, 0],
        [0, 0, 1],
        [-1, 3, 0],
      ]);
      final solution = EigenSolver.solve(a);
      final pairs = (solution.result as EigenResult).eigenpairs;
      // Angles are written in [0, π]: 8π/9 rather than the equal 10π/9.
      expect(pairs.map((p) => p.eigenvalue.latex), [
        r'2\cos\left(\frac{8\pi}{9}\right)',
        r'2\cos\left(\frac{4\pi}{9}\right)',
        r'2\cos\left(\frac{2\pi}{9}\right)',
      ]);
      expect(pairs.every((p) => p.eigenvalue.isReal), isTrue);
      expect(
        pairs.first.vectorLatex(pairs.first.eigenspaceBasis.single),
        r'\begin{pmatrix}1 \\ \lambda \\ \lambda^{2}\end{pmatrix}',
      );
      expect(solution.steps[1].explanationKey, 'eigen_roots_trig_desc');
      _expectAll(a);
    });
    test('a cubic whose arccos is not a rational angle keeps arccos', () {
      // λ³ - 7λ + 7: three real roots, arccos(-3√21/14 · …) is no table value.
      final a = _ints([
        [0, 1, 0],
        [0, 0, 1],
        [-7, 7, 0],
      ]);
      final pairs = (EigenSolver.solve(a).result as EigenResult).eigenpairs;
      expect(pairs.first.eigenvalue.latex, contains(r'\arccos'));
      _expectAll(a);
    });
    test('diag(1, 30, 40), once reported as missing, is exact', () {
      final a = _ints([
        [1, 0, 0],
        [0, 30, 0],
        [0, 0, 40],
      ]);
      expect(latex(a), ['1', '30', '40']);
      _expectAll(a);
    });
    test('diag(a, a, b) with 1000003 denominators is exact', () {
      Rational r(int n) => Rational(BigInt.from(n), BigInt.from(1000003));
      final a = r(999983);
      final b = r(-500018);
      final matrix = Matrix([
        [a, Rational.zero, Rational.zero],
        [Rational.zero, a, Rational.zero],
        [Rational.zero, Rational.zero, b],
      ]);
      final pairs =
          (EigenSolver.solve(matrix).result as EigenResult).eigenpairs;
      expect(
        {
          for (final p in pairs)
            p.eigenvalue.rationalValue: (
              p.algebraicMultiplicity,
              p.geometricMultiplicity,
            ),
        },
        {b: (1, 1), a: (2, 2)},
      );
      _expectAll(matrix);
    });
  });

  test('a large-denominator rational root beside an irrational pair', () {
    // Every prime has a root here, so the rational root is found by the
    // Sturm isolation and bisection, and the irrational pair is rejected
    // there too.
    final r = Rational(BigInt.from(999983), BigInt.from(1000003));
    final block = Matrix([
      [r, Rational.zero, Rational.zero],
      [Rational.zero, Rational.zero, Rational(2)],
      [Rational.zero, Rational.one, Rational.zero],
    ]);
    final p = _ints([
      [1, 2, 0],
      [0, 1, 3],
      [1, 0, 1],
    ]);
    final a = _mul(_mul(p, block), InverseSolver.solve(p).result as Matrix);
    final pairs = (EigenSolver.solve(a).result as EigenResult).eigenpairs;
    expect(pairs.map((pair) => pair.eigenvalue.latex), [
      r'-\sqrt{2}',
      r.toLatex(),
      r'\sqrt{2}',
    ]);
    _expectAll(a);
  });

  group('(e) Geometric multiplicity', () {
    ({int algebraic, int geometric, bool defective}) only(Matrix a) {
      final pairs = _expectExact(a, EigenSolver.solve(a));
      final p = pairs.single;
      return (
        algebraic: p.algebraicMultiplicity,
        geometric: p.geometricMultiplicity,
        defective: p.isDefective,
      );
    }

    test('[[2,1],[0,2]] is defective', () {
      final a = _ints([
        [2, 1],
        [0, 2],
      ]);
      expect(only(a), (algebraic: 2, geometric: 1, defective: true));
      final solution = EigenSolver.solve(a);
      expect((solution.result as EigenResult).isDiagonalizable, isFalse);
      expect(solution.steps.last.explanationKey, 'eigen_defective_desc');
      expect(solution.steps.last.explanationParams['geometric'], 1);
    });
    test('a 3x3 Jordan block has one eigenvector', () {
      expect(
        only(
          _ints([
            [3, 1, 0],
            [0, 3, 1],
            [0, 0, 3],
          ]),
        ),
        (algebraic: 3, geometric: 1, defective: true),
      );
    });
    test('a 3x3 block of sizes 2 and 1 has two eigenvectors', () {
      expect(
        only(
          _ints([
            [2, 1, 0],
            [0, 2, 0],
            [0, 0, 2],
          ]),
        ),
        (algebraic: 3, geometric: 2, defective: true),
      );
    });
    test('a repeated eigenvalue with a full eigenspace is not defective', () {
      final a = _ints([
        [2, 0, 1],
        [0, 2, 0],
        [0, 0, 5],
      ]);
      final solution = EigenSolver.solve(a);
      final pairs = _expectExact(a, solution);
      final two = pairs.firstWhere(
        (p) => p.eigenvalue.rationalValue == Rational(2),
      );
      expect(two.algebraicMultiplicity, 2);
      expect(two.geometricMultiplicity, 2);
      expect((solution.result as EigenResult).isDiagonalizable, isTrue);
      expect(
        solution.steps.map((s) => s.explanationKey),
        contains('eigen_eigenspace_desc'),
      );
    });
  });

  group('Random matrices', () {
    final rng = Random(20260926);
    test('300 small-integer 2x2 and 300 3x3 matrices', () {
      for (var i = 0; i < 600; i++) {
        _expectAll(
          _random(rng, 2 + i % 2, () => Rational(rng.nextInt(11) - 5)),
        );
      }
    });
    test('100 fractional 2x2 and 100 3x3 matrices', () {
      for (var i = 0; i < 200; i++) {
        _expectAll(
          _random(
            rng,
            2 + i % 2,
            () => Rational(rng.nextInt(19) - 9, rng.nextInt(6) + 1),
          ),
        );
      }
    });
    test('repeated and rational spectra from similarity transforms', () {
      // P·D·P⁻¹ with repeated diagonal entries, so repeated roots and
      // rational eigenvalues with larger eigenspaces are exercised too.
      for (var i = 0; i < 60; i++) {
        final n = 2 + i % 2;
        final d = [for (var k = 0; k < n; k++) rng.nextInt(3) - 1];
        Matrix p;
        do {
          p = _random(rng, n, () => Rational(rng.nextInt(5) - 2));
        } while ((DeterminantSolver.solve(p).result as Rational).isZero);
        final inverse = InverseSolver.solve(p).result as Matrix;
        final diagonal = Matrix([
          for (var r = 0; r < n; r++)
            [for (var c = 0; c < n; c++) Rational(r == c ? d[r] : 0)],
        ]);
        final a = _mul(_mul(p, diagonal), inverse);
        _expectAll(a);
        final pairs = (EigenSolver.solve(a).result as EigenResult).eigenpairs;
        expect(pairs.every((pair) => !pair.isDefective), isTrue);
      }
    });
    test('40 matrices of 15-digit fractions', () {
      for (var i = 0; i < 40; i++) {
        _expectAll(
          _random(
            rng,
            2 + i % 2,
            () => Rational(
              _digits(rng, 15) * (rng.nextBool() ? BigInt.one : -BigInt.one),
              _digits(rng, 15) + BigInt.one,
            ),
          ),
        );
      }
    });
  });

  test('a 3x3 matrix of 15-digit fractions solves well under a second', () {
    final rng = Random(7);
    final a = _random(
      rng,
      3,
      () => Rational(
        _digits(rng, 15) * (rng.nextBool() ? BigInt.one : -BigInt.one),
        _digits(rng, 15) + BigInt.one,
      ),
    );
    final watch = Stopwatch()..start();
    final solution = EigenSolver.solve(a);
    watch.stop();
    _expectExact(a, solution);
    // Generous bound so a loaded machine does not fail it; typical timings
    // are reported in the change notes.
    expect(watch.elapsedMilliseconds, lessThan(1000));
  });
}

Matrix _mul(Matrix a, Matrix b) => Matrix([
  for (var r = 0; r < a.rows; r++)
    [
      for (var c = 0; c < b.cols; c++)
        [for (var k = 0; k < a.cols; k++) a.get(r, k) * b.get(k, c)]
            .fold(Rational.zero, (sum, v) => sum + v),
    ],
]);
