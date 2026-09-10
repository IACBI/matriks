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

  String get vectorLatex {
    final elements = eigenvector.map((e) => e.toLatex()).join(r' \\ ');
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
          CellHighlight(row: 0, col: 0, type: HighlightType.pivot),
          CellHighlight(row: 1, col: 1, type: HighlightType.pivot),
          CellHighlight(row: 0, col: 1, type: HighlightType.target),
          CellHighlight(row: 1, col: 0, type: HighlightType.target),
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
          eigenvalues.add(plusLow);
          eigenvalues.add(minusLow);
          break;
        }
        scale *= BigInt.from(1000);
      }
    }

    // Step 2: Show Characteristic Polynomial and Roots
    final rootsLatex = eigenvalues.map((e) => e.toLatex()).join(', ');
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
          CellHighlight(row: 0, col: 0, type: HighlightType.pivot),
          CellHighlight(row: 1, col: 1, type: HighlightType.pivot),
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
          titleParams: {'index': i + 1, 'lambda': lambda.toLatex()},
          explanationKey: sqrtDisc == null
              ? 'eigen_vector_approx_desc'
              : 'eigen_vector_desc',
          explanationParams: {
            'lambda': lambda.toLatex(),
            'vector': pair.vectorLatex,
          },
          matrixBefore: shiftedSnap,
          matrixAfter: shiftedSnap,
          transformation: InformationalStepTransformation(
            'Solved null space of (A - λI)',
          ),
          highlights: [
            CellHighlight(row: 0, col: 0, type: HighlightType.pivot),
            CellHighlight(row: 1, col: 1, type: HighlightType.pivot),
          ],
        ),
      );
    }

    final summaryResultLatex = eigenpairs
        .map(
          (p) =>
              '\\lambda ${sqrtDisc == null ? r'\approx' : '='} ${p.eigenvalue.toLatex()} \\implies ${p.vectorLatex}',
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
            CellHighlight(row: i, col: i, type: HighlightType.pivot),
        ],
      ),
    );

    // Find rational roots for the cubic equation: -λ³ + c2 λ² - c1 λ + c0 = 0
    final rationalRoots = _findCubicRationalRoots(c2, c1, c0);
    final eigenpairs = <Eigenpair>[];

    if (rationalRoots.isEmpty) {
      steps.add(
        MatrixStep(
          stepIndex: ++stepCounter,
          titleKey: 'eigen_roots_title',
          explanationKey: 'eigen_irrational_desc',
          explanationParams: {'poly': polyLatex},
          matrixBefore: snap,
          matrixAfter: snap,
          transformation: InformationalStepTransformation(
            'Cubic equation has no integer/rational roots',
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

    final uniqueRoots = rationalRoots.toSet().toList();
    for (int i = 0; i < uniqueRoots.length; i++) {
      final lambda = uniqueRoots[i];
      // Solve (A - λI)v = 0 using LinearSystemsSolver with augmented zero column
      final shifted = Matrix(
        List.generate(
          3,
          (r) => List.generate(
            3,
            (c) => r == c ? matrix.get(r, c) - lambda : matrix.get(r, c),
          ),
        ),
      );
      final augmentedZero = shifted.augment(Matrix.zero(3, 1));
      final nullSol = LinearSystemsSolver.solve(augmentedZero);
      final lResult = nullSol.result as LinearSystemResult;

      List<Rational> vector = [Rational.one, Rational.zero, Rational.zero];
      if (lResult.freeVariables.isNotEmpty) {
        // Extract eigenvector from parametric solution
        final f = lResult.freeVariables.first;
        vector = List.generate(3, (idx) {
          if (idx == f) return Rational.one;
          final pivotRow = lResult.basicVariables.indexOf(idx);
          if (pivotRow < 0) return Rational.zero;
          return -nullSol.finalMatrix.get(pivotRow, f);
        });
      }

      final pair = Eigenpair(
        eigenvalue: lambda,
        eigenvector: _simplifyVector(vector),
        algebraicMultiplicity: _multiplicity(lambda, c2, c1),
      );
      eigenpairs.add(pair);

      steps.add(
        MatrixStep(
          stepIndex: ++stepCounter,
          titleKey: 'eigen_vector_title',
          titleParams: {'index': i + 1, 'lambda': lambda.toLatex()},
          explanationKey: 'eigen_vector_desc',
          explanationParams: {
            'lambda': lambda.toLatex(),
            'vector': pair.vectorLatex,
          },
          matrixBefore: MatrixSnapshot.fromMatrix(shifted),
          matrixAfter: MatrixSnapshot.fromMatrix(shifted),
          transformation: InformationalStepTransformation(
            'Eigenvector found for 3x3 matrix',
          ),
          highlights: [
            for (int r = 0; r < 3; r++)
              CellHighlight(row: r, col: r, type: HighlightType.pivot),
          ],
        ),
      );
    }

    final resultLatex = eigenpairs
        .map(
          (p) =>
              '\\lambda = ${p.eigenvalue.toLatex()} \\implies ${p.vectorLatex}',
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
      resultLatex: resultLatex,
      completeness: uniqueRoots.length == 3
          ? ResultCompleteness.complete
          : ResultCompleteness.partial,
    );
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

  static List<Rational> _findCubicRationalRoots(
    Rational c2,
    Rational c1,
    Rational c0,
  ) {
    // Tests integer candidates between -20 and 20
    final roots = <Rational>[];
    for (int x = -20; x <= 20; x++) {
      final r = Rational.fromInt(x);
      // -r³ + c2*r² - c1*r + c0 == 0
      final val = -(r.pow(3)) + (c2 * r.pow(2)) - (c1 * r) + c0;
      if (val.isZero) {
        roots.add(r);
      }
    }
    return roots;
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
