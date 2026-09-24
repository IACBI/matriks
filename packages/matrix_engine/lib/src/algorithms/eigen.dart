import 'dart:math' as math;

import '../model/matrix.dart';
import '../model/step.dart';
import '../rational/rational.dart';
import 'determinant.dart';
import 'linear_systems.dart';

class Eigenpair {
  final Rational eigenvalue;
  final List<Rational> eigenvector;
  final int algebraicMultiplicity;

  const Eigenpair({
    required this.eigenvalue,
    required this.eigenvector,
    this.algebraicMultiplicity = 1,
  });

  String get vectorLatex => vectorLatexWith((e) => e.toLatex());

  /// [vectorLatex] with each entry written by [entry], e.g. as a decimal
  /// when the vector was rounded.
  String vectorLatexWith(String Function(Rational) entry) {
    final elements = eigenvector.map(entry).join(r' \\ ');
    return '\\mathbf{v} = \\begin{pmatrix}$elements\\end{pmatrix}';
  }
}

class EigenResult {
  final String characteristicPolynomialLatex;
  final List<Eigenpair> realEigenpairs;
  final bool hasComplexEigenvalues;

  const EigenResult({
    required this.characteristicPolynomialLatex,
    required this.realEigenpairs,
    this.hasComplexEigenvalues = false,
  });
}

class EigenSolver {
  /// Solves for eigenvalues and eigenvectors step-by-step
  static StepSolution solve(Matrix matrix) {
    if (!matrix.isSquare) {
      return StepSolution(
        operationKey: 'op_eigen',
        initialMatrix: matrix,
        steps: const [],
        finalMatrix: matrix,
        isSuccess: false,
        errorMessageKey: 'error_inverse_not_square',
      );
    }

    if (matrix.rows == 2) {
      return _solve2x2(matrix);
    }

    if (matrix.rows == 3) {
      return _solve3x3(matrix);
    }

    return StepSolution(
      operationKey: 'op_eigen',
      initialMatrix: matrix,
      finalMatrix: matrix,
      steps: const [],
      isSuccess: false,
      completeness: ResultCompleteness.unsupported,
    );
  }

  static StepSolution _solve2x2(Matrix matrix) {
    final a = matrix.get(0, 0);
    final b = matrix.get(0, 1);
    final c = matrix.get(1, 0);
    final d = matrix.get(1, 1);

    final trace = a + d;
    final det = (a * d) - (b * c);
    final snap = MatrixSnapshot.fromMatrix(matrix);

    final steps = <MatrixStep>[];
    var stepCounter = 0;

    // Step 1: Trace and Determinant
    final traceFormula = '${a.toLatex()} + ${d.toLatex()} = ${trace.toLatex()}';
    final detFormula =
        '(${a.toLatex()} \\cdot ${d.toLatex()}) - (${b.toLatex()} \\cdot ${c.toLatex()}) = ${det.toLatex()}';

    steps.add(
      MatrixStep(
        stepIndex: ++stepCounter,
        titleKey: 'eigen_char_poly_title',
        explanationKey: 'eigen_trace_det_desc',
        explanationParams: {'trace': trace.toLatex(), 'det': det.toLatex()},
        matrixBefore: snap,
        matrixAfter: snap,
        transformation: InformationalStepTransformation(
          'Trace and determinant computed for 2x2 matrix',
        ),
        highlights: [
          CellHighlight(row: 0, col: 0, type: HighlightType.selected),
          CellHighlight(row: 1, col: 1, type: HighlightType.selected),
        ],
        subCalculations: [
          SubCalculation(
            targetRow: 0,
            targetCol: 0,
            formulaLatex: traceFormula,
            result: trace,
          ),
          SubCalculation(
            targetRow: 1,
            targetCol: 1,
            formulaLatex: detFormula,
            result: det,
          ),
        ],
      ),
    );

    // Characteristic equation: λ² - tr(A)λ + det(A) = 0
    final trSign = trace.isNegative
        ? '+ ${(-trace).toLatex()}'
        : '- ${trace.toLatex()}';
    final detSign = det.isNegative
        ? '- ${(-det).toLatex()}'
        : '+ ${det.toLatex()}';
    final polyLatex = '\\lambda^2 $trSign \\lambda $detSign = 0';

    // Discriminant: Δ = trace² - 4*det
    final disc = (trace * trace) - (Rational.fromInt(4) * det);

    if (disc.isNegative) {
      // Complex eigenvalues
      final alpha = trace / Rational.fromInt(2);
      final betaDouble = math.sqrt(-disc.toDouble()) / 2;
      final betaStr = betaDouble.toStringAsFixed(2);
      final complexRoots = '${alpha.toLatex()} \\pm ${betaStr}i';

      steps.add(
        MatrixStep(
          stepIndex: ++stepCounter,
          titleKey: 'eigen_complex_title',
          explanationKey: 'eigen_complex_desc',
          explanationParams: {'poly': polyLatex, 'roots': complexRoots},
          matrixBefore: snap,
          matrixAfter: snap,
          transformation: EigenTransformation(
            polynomialLatex: polyLatex,
            realEigenvalues: const [],
          ),
          highlights: const [],
        ),
      );

      return StepSolution(
        operationKey: 'op_eigen',
        initialMatrix: matrix,
        steps: steps,
        finalMatrix: matrix,
        accuracy: ResultAccuracy.approximate,
        decimalPlaces: 2,
        completeness: ResultCompleteness.unsupported,
        result: EigenResult(
          characteristicPolynomialLatex: polyLatex,
          realEigenpairs: const [],
          hasComplexEigenvalues: true,
        ),
        resultLatex: '\\lambda \\approx $complexRoots',
      );
    }

    // Real roots
    final sqrtDisc = _trySqrtRational(disc);
    final eigenvalues = <Rational>[];

    if (sqrtDisc != null) {
      final l1 = (trace + sqrtDisc) / Rational.fromInt(2);
      final l2 = (trace - sqrtDisc) / Rational.fromInt(2);
      eigenvalues.add(l1);
      if (l1 != l2) eigenvalues.add(l2);
    } else {
      // Bound the irrational square root with exact rationals until rounding
      // both endpoints agrees. This avoids cancellation and exponent parsing.
      eigenvalues.addAll(_roundedQuadraticRoots(trace, disc));
    }

    // Step 2: Show Characteristic Polynomial and Roots
    // Rounded roots are written as the decimals they were rounded to;
    // 809/500 would hide that λ ≈ 1.618.
    final value = sqrtDisc == null ? _roundedLatex : _exactLatex;
    final rootsLatex = eigenvalues.map(value).join(', ');
    steps.add(
      MatrixStep(
        stepIndex: ++stepCounter,
        titleKey: 'eigen_roots_title',
        explanationKey: sqrtDisc == null
            ? 'eigen_roots_approx_desc'
            : 'eigen_roots_desc',
        explanationParams: {'poly': polyLatex, 'roots': rootsLatex},
        matrixBefore: snap,
        matrixAfter: snap,
        transformation: EigenTransformation(
          polynomialLatex: polyLatex,
          realEigenvalues: eigenvalues,
        ),
        highlights: [
          CellHighlight(row: 0, col: 0, type: HighlightType.selected),
          CellHighlight(row: 1, col: 1, type: HighlightType.selected),
        ],
      ),
    );

    // Step 3: For each eigenvalue, find eigenvector by solving (A - λI)v = 0
    final eigenpairs = <Eigenpair>[];

    for (int i = 0; i < eigenvalues.length; i++) {
      final lambda = eigenvalues[i];
      final shifted = Matrix([
        [a - lambda, b],
        [c, d - lambda],
      ]);
      final shiftedSnap = MatrixSnapshot.fromMatrix(shifted);

      // Eigenvector calculation:
      // (a - λ) v1 + b v2 = 0
      List<Rational> vector;
      if (!b.isZero) {
        // v2 = 1 => v1 = -b / (a - λ)
        // Or v = (-b, a - λ)
        vector = [-b, a - lambda];
      } else if (!c.isZero) {
        // v = (d - λ, -c)
        vector = [d - lambda, -c];
      } else if (!(a - lambda).isZero) {
        vector = [Rational.zero, Rational.one];
      } else {
        vector = [Rational.one, Rational.zero];
      }

      // Simplify vector by dividing by common factors
      vector = _simplifyVector(vector);

      final pair = Eigenpair(
        eigenvalue: lambda,
        eigenvector: vector,
        algebraicMultiplicity: disc.isZero ? 2 : 1,
      );
      eigenpairs.add(pair);

      steps.add(
        MatrixStep(
          stepIndex: ++stepCounter,
          titleKey: sqrtDisc == null
              ? 'eigen_vector_approx_title'
              : 'eigen_vector_title',
          titleParams: {'index': i + 1, 'lambda': value(lambda)},
          explanationKey: sqrtDisc == null
              ? 'eigen_vector_approx_desc'
              : 'eigen_vector_desc',
          explanationParams: {
            'lambda': value(lambda),
            'vector': pair.vectorLatexWith(value),
          },
          matrixBefore: shiftedSnap,
          matrixAfter: shiftedSnap,
          transformation: InformationalStepTransformation(
            'Solved null space of (A - λI)',
            sceneLatex: _shiftScene(lambda, pair.vectorLatexWith(value), value),
          ),
          highlights: [
            CellHighlight(row: 0, col: 0, type: HighlightType.selected),
            CellHighlight(row: 1, col: 1, type: HighlightType.selected),
          ],
        ),
      );
    }

    final summaryResultLatex = eigenpairs
        .map(
          (p) =>
              '\\lambda ${sqrtDisc == null ? r'\approx' : '='} ${value(p.eigenvalue)} \\implies ${p.vectorLatexWith(value)}',
        )
        .join(r' \quad ');

    return StepSolution(
      operationKey: 'op_eigen',
      initialMatrix: matrix,
      steps: steps,
      finalMatrix: matrix,
      result: EigenResult(
        characteristicPolynomialLatex: polyLatex,
        realEigenpairs: eigenpairs,
      ),
      resultLatex: summaryResultLatex,
      accuracy: sqrtDisc == null
          ? ResultAccuracy.approximate
          : ResultAccuracy.exact,
      decimalPlaces: sqrtDisc == null ? 3 : null,
      completeness: disc.isZero
          ? ResultCompleteness.partial
          : ResultCompleteness.complete,
    );
  }

  static StepSolution _solve3x3(Matrix matrix) {
    // 3x3 Eigenvalues:
    // p(λ) = -λ³ + c2 λ² - c1 λ + c0 = 0
    final c2 = matrix.get(0, 0) + matrix.get(1, 1) + matrix.get(2, 2); // Trace
    // Principal minors
    final m1 =
        (matrix.get(1, 1) * matrix.get(2, 2)) -
        (matrix.get(1, 2) * matrix.get(2, 1));
    final m2 =
        (matrix.get(0, 0) * matrix.get(2, 2)) -
        (matrix.get(0, 2) * matrix.get(2, 0));
    final m3 =
        (matrix.get(0, 0) * matrix.get(1, 1)) -
        (matrix.get(0, 1) * matrix.get(1, 0));
    final c1 = m1 + m2 + m3;
    final detSol = DeterminantSolver.solve(matrix);
    final c0 = detSol.result as Rational;

    final polyLatex =
        '-\\lambda^3 + (${c2.toLatex()})\\lambda^2 - (${c1.toLatex()})\\lambda + (${c0.toLatex()}) = 0';
    final snap = MatrixSnapshot.fromMatrix(matrix);
    final steps = <MatrixStep>[];
    var stepCounter = 0;

    steps.add(
      MatrixStep(
        stepIndex: ++stepCounter,
        titleKey: 'eigen_char_poly_title',
        explanationKey: 'eigen_3x3_poly_desc',
        explanationParams: {
          'poly': polyLatex,
          'trace': c2.toLatex(),
          'det': c0.toLatex(),
        },
        matrixBefore: snap,
        matrixAfter: snap,
        transformation: InformationalStepTransformation(
          'Computed 3x3 characteristic equation',
        ),
        highlights: [
          for (int i = 0; i < 3; i++)
            CellHighlight(row: i, col: i, type: HighlightType.selected),
        ],
      ),
    );

    final spectrum = _cubicSpectrum(c2, c1, c0);
    final complexLatex = spectrum.complexLatex;
    final eigenpairs = <Eigenpair>[];

    if (spectrum.exact.isEmpty && spectrum.approximate.isEmpty) {
      steps.add(
        MatrixStep(
          stepIndex: ++stepCounter,
          titleKey: 'eigen_roots_title',
          explanationKey: 'eigen_irrational_desc',
          explanationParams: {'poly': polyLatex},
          matrixBefore: snap,
          matrixAfter: snap,
          transformation: InformationalStepTransformation(
            'Cubic roots could not be isolated',
          ),
          highlights: const [],
        ),
      );

      return StepSolution(
        operationKey: 'op_eigen',
        initialMatrix: matrix,
        steps: steps,
        finalMatrix: matrix,
        result: EigenResult(
          characteristicPolynomialLatex: polyLatex,
          realEigenpairs: const [],
        ),
        resultLatex: polyLatex,
        completeness: ResultCompleteness.unsupported,
      );
    }

    final eigenvalues = [
      for (final root in spectrum.exact) (value: root, exact: true),
      for (final root in spectrum.approximate) (value: root, exact: false),
    ]..sort((a, b) => a.value.compareTo(b.value));
    final approximate = spectrum.approximate.isNotEmpty;
    final rootsLatex = eigenvalues
        .map((e) => e.exact ? _exactLatex(e.value) : _roundedLatex(e.value))
        .join(', ');
    steps.add(
      MatrixStep(
        stepIndex: ++stepCounter,
        titleKey: 'eigen_roots_title',
        explanationKey: complexLatex != null
            ? 'eigen_cubic_complex_desc'
            : approximate
            ? 'eigen_roots_approx_desc'
            : 'eigen_roots_desc',
        explanationParams: {
          'poly': polyLatex,
          'roots': rootsLatex,
          'complex': ?complexLatex,
        },
        matrixBefore: snap,
        matrixAfter: snap,
        transformation: EigenTransformation(
          polynomialLatex: polyLatex,
          realEigenvalues: [for (final e in eigenvalues) e.value],
        ),
        highlights: [
          for (int i = 0; i < 3; i++)
            CellHighlight(row: i, col: i, type: HighlightType.selected),
        ],
      ),
    );

    var repeated = false;
    for (int i = 0; i < eigenvalues.length; i++) {
      final lambda = eigenvalues[i].value;
      final exact = eigenvalues[i].exact;
      final shifted = Matrix(
        List.generate(
          3,
          (r) => List.generate(
            3,
            (c) => r == c ? matrix.get(r, c) - lambda : matrix.get(r, c),
          ),
        ),
      );
      final multiplicity = exact ? _multiplicity(lambda, c2, c1) : 1;
      final value = exact ? _exactLatex : _roundedLatex;
      if (multiplicity > 1) repeated = true;

      final pair = Eigenpair(
        eigenvalue: lambda,
        eigenvector: exact
            ? _nullVector(shifted)
            : _approximateNullVector(shifted),
        algebraicMultiplicity: multiplicity,
      );
      eigenpairs.add(pair);

      steps.add(
        MatrixStep(
          stepIndex: ++stepCounter,
          titleKey: exact ? 'eigen_vector_title' : 'eigen_vector_approx_title',
          titleParams: {'index': i + 1, 'lambda': value(lambda)},
          explanationKey: exact
              ? 'eigen_vector_desc'
              : 'eigen_vector_approx_desc',
          explanationParams: {
            'lambda': value(lambda),
            'vector': pair.vectorLatexWith(value),
          },
          matrixBefore: MatrixSnapshot.fromMatrix(shifted),
          matrixAfter: MatrixSnapshot.fromMatrix(shifted),
          transformation: InformationalStepTransformation(
            'Eigenvector found for 3x3 matrix',
            sceneLatex: _shiftScene(lambda, pair.vectorLatexWith(value), value),
          ),
          highlights: [
            for (int r = 0; r < 3; r++)
              CellHighlight(row: r, col: r, type: HighlightType.selected),
          ],
        ),
      );
    }

    final resultLatex = [
      for (var i = 0; i < eigenpairs.length; i++)
        if (eigenvalues[i].exact)
          '\\lambda = ${_exactLatex(eigenpairs[i].eigenvalue)} \\implies '
              '${eigenpairs[i].vectorLatex}'
        else
          '\\lambda \\approx ${_roundedLatex(eigenpairs[i].eigenvalue)} '
              '\\implies ${eigenpairs[i].vectorLatexWith(_roundedLatex)}',
      if (complexLatex != null)
        '\\lambda \\approx $complexLatex',
    ].join(r' \quad ');

    return StepSolution(
      operationKey: 'op_eigen',
      initialMatrix: matrix,
      steps: steps,
      finalMatrix: matrix,
      result: EigenResult(
        characteristicPolynomialLatex: polyLatex,
        realEigenpairs: eigenpairs,
        hasComplexEigenvalues: complexLatex != null,
      ),
      resultLatex: resultLatex,
      accuracy: approximate || complexLatex != null
          ? ResultAccuracy.approximate
          : ResultAccuracy.exact,
      decimalPlaces: approximate
          ? 3
          : complexLatex != null
          ? 2
          : null,
      completeness:
          spectrum.missing || repeated || complexLatex != null
          ? ResultCompleteness.partial
          : ResultCompleteness.complete,
    );
  }

  /// Roots of p(λ) = λ³ - c2 λ² + c1 λ - c0, the characteristic polynomial.
  ///
  /// Rational roots are exact: floating-point estimates only propose
  /// candidates, and a candidate is kept only when the polynomial vanishes at
  /// it in rational arithmetic. Once one rational root is known the remaining
  /// quadratic is solved directly. An irreducible cubic is bracketed with
  /// rational endpoints until both round to the same three decimals, like the
  /// 2×2 irrational case. Coefficients too large for a floating-point estimate
  /// fall back to an integer search and report the spectrum as incomplete.
  static ({
    List<Rational> exact,
    List<Rational> approximate,
    String? complexLatex,
    bool missing,
  })
  _cubicSpectrum(Rational c2, Rational c1, Rational c0) {
    final exact = <Rational>{};
    for (int x = -20; x <= 20; x++) {
      final r = Rational.fromInt(x);
      if (_evalCubic(r, c2, c1, c0).isZero) exact.add(r);
    }

    final values = [c2.toDouble(), c1.toDouble(), c0.toDouble()];
    final estimable = values.every((v) => v.isFinite && v.abs() <= 1e12);
    final crossings = <double>[];
    if (estimable) {
      final (roots, critical) = _realRootEstimates(
        values[0],
        values[1],
        values[2],
      );
      crossings.addAll(roots);
      final lcm = [c2.den, c1.den, c0.den].reduce((a, b) => a * b ~/ a.gcd(b));
      final denominators = _divisors(lcm);
      for (final estimate in [...roots, ...critical]) {
        for (final q in denominators) {
          final scaled = estimate * q.toDouble();
          if (!scaled.isFinite || scaled.abs() > 1e15) continue;
          final nearest = BigInt.from(scaled.roundToDouble());
          for (final delta in [BigInt.zero, BigInt.one, -BigInt.one]) {
            final candidate = Rational(nearest + delta, q);
            if (_evalCubic(candidate, c2, c1, c0).isZero) exact.add(candidate);
          }
        }
      }
    }

    var counted = 0;
    for (final root in exact) {
      counted += _multiplicity(root, c2, c1);
    }
    final approximate = <Rational>[];
    String? complexLatex;

    if (counted == 1) {
      // λ³ - c2λ² + c1λ - c0 = (λ - r)(λ² + pλ + s).
      final r = exact.single;
      final p = r - c2;
      final s = c1 + p * r;
      final trace = -p;
      final disc = p * p - Rational.fromInt(4) * s;
      if (disc.isNegative) {
        final alpha = trace / Rational.fromInt(2);
        final beta = math.sqrt(-disc.toDouble()) / 2;
        complexLatex = '${alpha.toLatex()} \\pm ${beta.toStringAsFixed(2)}i';
      } else {
        final root = _trySqrtRational(disc);
        if (root != null) {
          exact
            ..add((trace + root) / Rational.fromInt(2))
            ..add((trace - root) / Rational.fromInt(2));
        } else {
          approximate.addAll(_roundedQuadraticRoots(trace, disc));
        }
      }
    } else if (counted == 0 && crossings.isNotEmpty) {
      for (final estimate in crossings) {
        final rounded = _refineRoot(estimate, c2, c1, c0);
        if (rounded == null) {
          approximate.clear();
          break;
        }
        approximate.add(rounded);
      }
      if (approximate.length == 1) {
        // One real root: the other two are a conjugate pair of the deflated
        // quadratic λ² + pλ + s.
        final r = crossings.single;
        final p = r - values[0];
        final s = values[1] + p * r;
        final disc = p * p - 4 * s;
        if (disc < 0) {
          final alpha = (-p / 2).toStringAsFixed(2);
          final beta = (math.sqrt(-disc) / 2).toStringAsFixed(2);
          complexLatex = '$alpha \\pm ${beta}i';
        } else {
          approximate.clear();
        }
      } else if (approximate.length != 3) {
        approximate.clear();
      }
    }

    var total = approximate.length + (complexLatex == null ? 0 : 2);
    for (final root in exact) {
      total += _multiplicity(root, c2, c1);
    }
    final ordered = exact.toList()..sort((a, b) => a.compareTo(b));
    return (
      exact: ordered,
      approximate: approximate,
      complexLatex: complexLatex,
      missing: total < 3,
    );
  }

  static Rational _evalCubic(
    Rational x,
    Rational c2,
    Rational c1,
    Rational c0,
  ) => ((x - c2) * x + c1) * x - c0;

  /// Sign-change roots by bisection between the critical points, plus the
  /// critical points themselves, which are the only places a repeated root can
  /// touch the axis without crossing it.
  static (List<double>, List<double>) _realRootEstimates(
    double c2,
    double c1,
    double c0,
  ) {
    double f(double x) => ((x - c2) * x + c1) * x - c0;
    final bound = 1 + [c2.abs(), c1.abs(), c0.abs()].reduce(math.max);
    final critical = <double>[];
    final d = c2 * c2 - 3 * c1;
    if (d > 0) {
      final root = math.sqrt(d);
      critical
        ..add((c2 - root) / 3)
        ..add((c2 + root) / 3);
    }
    final points = [-bound, ...critical, bound];
    final roots = <double>[];
    for (var i = 0; i + 1 < points.length; i++) {
      var a = points[i];
      var b = points[i + 1];
      var fa = f(a);
      final fb = f(b);
      if (fa == 0 || fb == 0 || (fa < 0) == (fb < 0)) continue;
      for (var k = 0; k < 200; k++) {
        final mid = (a + b) / 2;
        if (mid == a || mid == b) break;
        final fm = f(mid);
        if (fm == 0) {
          a = b = mid;
          break;
        }
        if ((fm < 0) == (fa < 0)) {
          a = mid;
          fa = fm;
        } else {
          b = mid;
        }
      }
      roots.add((a + b) / 2);
    }
    return (roots, critical);
  }

  /// Possible denominators of a rational root: divisors of the common
  /// denominator of the coefficients. Very large values are not factored.
  static List<BigInt> _divisors(BigInt n) {
    if (n > BigInt.from(1000000000000)) return [BigInt.one, n];
    final value = n.toInt();
    final found = <int>{};
    for (var i = 1; i * i <= value; i++) {
      if (value % i == 0) {
        found
          ..add(i)
          ..add(value ~/ i);
      }
    }
    return (found.toList()..sort()).map(BigInt.from).toList();
  }

  static Rational? _dyadic(double value) {
    if (!value.isFinite || value.abs() > 1e12) return null;
    const scale = 1 << 30;
    return Rational(
      BigInt.from((value * scale).roundToDouble()),
      BigInt.from(scale),
    );
  }

  /// Brackets a simple irrational root with rational endpoints until both
  /// round to the same three decimals. Returns null when the estimate does not
  /// bracket a sign change, so an unreliable estimate is never reported.
  static Rational? _refineRoot(
    double estimate,
    Rational c2,
    Rational c1,
    Rational c0,
  ) {
    final width = 1e-6 * math.max(1.0, estimate.abs());
    final start = _dyadic(estimate - width);
    final end = _dyadic(estimate + width);
    if (start == null || end == null) return null;
    var lo = start;
    var hi = end;
    var fLo = _evalCubic(lo, c2, c1, c0);
    final fHi = _evalCubic(hi, c2, c1, c0);
    if (fLo.isZero || fHi.isZero || fLo.isNegative == fHi.isNegative) {
      return null;
    }
    for (var i = 0; i < 200; i++) {
      final low = _roundThreePlaces(lo);
      if (low == _roundThreePlaces(hi)) return low;
      final mid = (lo + hi) / Rational.fromInt(2);
      final fMid = _evalCubic(mid, c2, c1, c0);
      if (fMid.isZero) return _roundThreePlaces(mid);
      if (fMid.isNegative == fLo.isNegative) {
        lo = mid;
        fLo = fMid;
      } else {
        hi = mid;
      }
    }
    return null;
  }

  /// Roots of λ² - trace·λ + det with irrational square root of [disc],
  /// rounded to three decimals from exact rational bounds.
  static List<Rational> _roundedQuadraticRoots(Rational trace, Rational disc) {
    var scale = BigInt.from(1000);
    while (true) {
      final floor = _integerSqrt(disc.num * scale * scale ~/ disc.den);
      final lower = Rational(floor, scale);
      final upper = Rational(floor + BigInt.one, scale);
      final plusLow = _roundThreePlaces((trace + lower) / Rational(2));
      final plusHigh = _roundThreePlaces((trace + upper) / Rational(2));
      final minusLow = _roundThreePlaces((trace - upper) / Rational(2));
      final minusHigh = _roundThreePlaces((trace - lower) / Rational(2));
      if (plusLow == plusHigh && minusLow == minusHigh) {
        return [plusLow, minusLow];
      }
      scale *= BigInt.from(1000);
    }
  }

  /// A basis vector of the null space of a singular 3×3 matrix.
  static List<Rational> _nullVector(Matrix shifted) {
    final augmentedZero = shifted.augment(Matrix.zero(3, 1));
    final nullSol = LinearSystemsSolver.solve(augmentedZero);
    final lResult = nullSol.result as LinearSystemResult;
    var vector = [Rational.one, Rational.zero, Rational.zero];
    if (lResult.freeVariables.isNotEmpty) {
      final f = lResult.freeVariables.first;
      vector = List.generate(3, (idx) {
        if (idx == f) return Rational.one;
        final pivotRow = lResult.basicVariables.indexOf(idx);
        if (pivotRow < 0) return Rational.zero;
        return -nullSol.finalMatrix.get(pivotRow, f);
      });
    }
    return _simplifyVector(vector);
  }

  /// For a rounded eigenvalue A - λI is not singular, so there is no exact
  /// null space. The cross product of its two most independent rows is the
  /// direction orthogonal to both, which is the eigenvector in the limit.
  /// Scaled so its largest entry is 1 and rounded to three decimals.
  static List<Rational> _approximateNullVector(Matrix shifted) {
    List<Rational> cross(List<Rational> u, List<Rational> v) => [
      u[1] * v[2] - u[2] * v[1],
      u[2] * v[0] - u[0] * v[2],
      u[0] * v[1] - u[1] * v[0],
    ];
    double norm(List<Rational> v) =>
        v.fold(0.0, (sum, e) => sum + e.toDouble() * e.toDouble());
    final rows = [for (var r = 0; r < 3; r++) shifted.getRow(r)];
    var best = cross(rows[0], rows[1]);
    for (final candidate in [
      cross(rows[0], rows[2]),
      cross(rows[1], rows[2]),
    ]) {
      if (norm(candidate) > norm(best)) best = candidate;
    }
    var largest = best.first;
    for (final e in best) {
      if (e.abs() > largest.abs()) largest = e;
    }
    if (largest.isZero) return [Rational.one, Rational.zero, Rational.zero];
    return _simplifyVector([
      for (final e in best) _roundThreePlaces(e / largest),
    ]);
  }

  /// Caption above the matrix of an eigenvector step: the grid shows
  /// A - λI, not A, and its null space gives the vector.
  static String _shiftScene(
    Rational lambda,
    String vectorLatex,
    String Function(Rational) value,
  ) {
    final size = lambda.abs();
    final coefficient = size == Rational.one ? '' : value(size);
    final shift = lambda.isZero
        ? 'A'
        : '${lambda.isNegative ? 'A +' : 'A -'} ${coefficient}I';
    return '$shift \\;\\Rightarrow\\; $vectorLatex';
  }

  static String _exactLatex(Rational value) => value.toLatex();

  /// A value already rounded to three decimals, written as that decimal
  /// without trailing zeros: 1.618, 0.5, -2.
  static String _roundedLatex(Rational value) {
    final text = value.toDecimalString(3);
    return text.contains('.')
        ? text.replaceFirst(RegExp(r'\.?0+$'), '')
        : text;
  }

  static int _multiplicity(Rational root, Rational c2, Rational c1) {
    final derivative =
        -Rational.fromInt(3) * root.pow(2) +
        Rational.fromInt(2) * c2 * root -
        c1;
    if (!derivative.isZero) return 1;
    return (-Rational.fromInt(6) * root + Rational.fromInt(2) * c2).isZero
        ? 3
        : 2;
  }

  static Rational? _trySqrtRational(Rational r) {
    if (r.isNegative) return null;
    final numSqrt = _isPerfectSquare(r.num);
    final denSqrt = _isPerfectSquare(r.den);
    if (numSqrt != null && denSqrt != null) {
      return Rational(numSqrt, denSqrt);
    }
    return null;
  }

  static BigInt? _isPerfectSquare(BigInt n) {
    if (n < BigInt.zero) return null;
    if (n == BigInt.zero) return BigInt.zero;
    if (n == BigInt.one) return BigInt.one;

    final root = _integerSqrt(n);
    return root * root == n ? root : null;
  }

  static Rational _roundThreePlaces(Rational value) {
    final scaled = value.num.abs() * BigInt.from(1000);
    var rounded = scaled ~/ value.den;
    if ((scaled % value.den) * BigInt.two >= value.den) {
      rounded += BigInt.one;
    }
    return Rational(value.isNegative ? -rounded : rounded, 1000);
  }

  static BigInt _integerSqrt(BigInt n) {
    var low = BigInt.zero;
    var high = BigInt.one << ((n.bitLength + 1) ~/ 2);
    while (low <= high) {
      final mid = (low + high) ~/ BigInt.two;
      if (mid * mid <= n) {
        low = mid + BigInt.one;
      } else {
        high = mid - BigInt.one;
      }
    }
    return high;
  }

  static List<Rational> _simplifyVector(List<Rational> v) {
    // Make first non-zero element positive
    int firstNonZero = -1;
    for (int i = 0; i < v.length; i++) {
      if (!v[i].isZero) {
        firstNonZero = i;
        break;
      }
    }
    if (firstNonZero == -1) return v;

    var normalized = v;
    if (v[firstNonZero].isNegative) {
      normalized = v.map((e) => -e).toList();
    }
    return normalized;
  }
}
