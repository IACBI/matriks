import '../algebra/number_field.dart';
import '../algebra/polynomial.dart';
import '../model/matrix.dart';
import '../model/step.dart';
import '../rational/rational.dart';
import 'operand.dart';
import 'determinant.dart';
import 'exact_spectrum.dart';

/// A rational eigenvalue with one eigenvector, kept for callers that work
/// with rational vectors. [EigenResult.eigenpairs] holds every eigenvalue,
/// including irrational and complex ones, with a full eigenspace basis.
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

  /// [vectorLatex] with each entry written by [entry].
  String vectorLatexWith(String Function(Rational) entry) {
    final elements = eigenvector.map(entry).join(r' \\ ');
    return '\\mathbf{v} = \\begin{pmatrix}$elements\\end{pmatrix}';
  }
}

class EigenResult {
  final String characteristicPolynomialLatex;

  /// Eigenpairs whose eigenvalue is rational, one representative vector
  /// each. Irrational and complex eigenvalues are in [eigenpairs].
  final List<Eigenpair> realEigenpairs;
  final bool hasComplexEigenvalues;

  /// Every distinct eigenvalue, exactly, in lesson order: rational,
  /// irrational and complex, each with a basis of its eigenspace.
  final List<ExactEigenpair> eigenpairs;

  /// The monic characteristic polynomial det(λI - A).
  final RationalPolynomial? characteristicPolynomial;

  const EigenResult({
    required this.characteristicPolynomialLatex,
    required this.realEigenpairs,
    this.hasComplexEigenvalues = false,
    this.eigenpairs = const [],
    this.characteristicPolynomial,
  });

  /// Whether every eigenspace is as large as its eigenvalue's multiplicity,
  /// so that A = PDP⁻¹ over the complex numbers.
  bool get isDiagonalizable =>
      eigenpairs.isNotEmpty && eigenpairs.every((p) => !p.isDefective);
}

class EigenSolver {
  /// Eigenvalues and eigenvectors of a 2×2 or 3×3 matrix, step by step and
  /// exactly: rational eigenvalues as fractions, the others in closed form,
  /// eigenvectors by exact elimination in Q(λ).
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

    if (matrix.rows == 2 || matrix.rows == 3) {
      return _solve(matrix);
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

  static StepSolution _solve(Matrix matrix) {
    final n = matrix.rows;
    final snap = MatrixSnapshot.fromMatrix(matrix);
    final steps = <MatrixStep>[];
    var stepCounter = 0;
    final diagonal = [
      for (int i = 0; i < n; i++)
        CellHighlight(row: i, col: i, type: HighlightType.selected),
    ];

    final String polyLatex;
    final RationalPolynomial characteristic;
    if (n == 2) {
      final a = matrix.get(0, 0);
      final b = matrix.get(0, 1);
      final c = matrix.get(1, 0);
      final d = matrix.get(1, 1);
      final trace = a + d;
      final det = (a * d) - (b * c);
      final traceFormula =
          '${operandLatex(a)} + ${operandLatex(d)} = ${trace.toLatex()}';
      final detFormula =
          '(${operandLatex(a)} \\cdot ${operandLatex(d)}) - (${operandLatex(b)} \\cdot ${operandLatex(c)}) = ${det.toLatex()}';
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
          highlights: diagonal,
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
      polyLatex = '\\lambda^2 $trSign \\lambda $detSign = 0';
      characteristic = RationalPolynomial([det, -trace, Rational.one]);
    } else {
      // det(A - λI) = -λ³ + c2 λ² - c1 λ + c0.
      final c2 = matrix.get(0, 0) + matrix.get(1, 1) + matrix.get(2, 2);
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
      final c0 = DeterminantSolver.solve(matrix).result as Rational;
      polyLatex =
          '-\\lambda^3 + (${c2.toLatex()})\\lambda^2 - (${c1.toLatex()})\\lambda + (${c0.toLatex()}) = 0';
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
          highlights: diagonal,
        ),
      );
      characteristic = RationalPolynomial([-c0, c1, -c2, Rational.one]);
    }

    final spectrum = exactSpectrum(characteristic);
    final values = [...spectrum.roots]..sort((x, y) => _order(n, x, y));

    // Roots step.
    final allRational = values.every((v) => v.isRational);
    final cubic = spectrum.factors.any((f) => f.factor.degree == 3);
    final String rootsKey;
    final Map<String, dynamic> rootsParams = {'poly': polyLatex};
    if (allRational) {
      rootsKey = 'eigen_roots_desc';
      rootsParams['roots'] = values
          .map((v) => v.rationalValue!.toLatex())
          .join(', ');
    } else if (cubic) {
      rootsKey = values.every((v) => v.isReal)
          ? 'eigen_roots_trig_desc'
          : 'eigen_roots_cardano_desc';
    } else {
      rootsParams['roots'] = _rootList(values);
      if (n == 3) {
        rootsKey = 'eigen_roots_factored_desc';
        rootsParams['factors'] = [
          for (final f in spectrum.factors)
            for (var i = 0; i < f.multiplicity; i++) '(${f.factor.toLatex()})',
        ].join();
      } else if (values.first.isReal) {
        rootsKey = 'eigen_roots_surd_desc';
        final trace = matrix.get(0, 0) + matrix.get(1, 1);
        final det = characteristic[0];
        rootsParams['disc'] = (trace * trace - Rational(4) * det).toLatex();
      } else {
        rootsKey = 'eigen_complex_desc';
      }
    }
    final rootsScene = allRational
        ? polyLatex
        : '$polyLatex \\;\\Rightarrow\\; ${[for (final (i, v) in values.indexed) '\\lambda_{${i + 1}} = ${v.latex}'].join(r',\quad ')}';
    steps.add(
      MatrixStep(
        stepIndex: ++stepCounter,
        titleKey: !allRational && n == 2 && !values.first.isReal
            ? 'eigen_complex_title'
            : 'eigen_roots_title',
        explanationKey: rootsKey,
        explanationParams: rootsParams,
        matrixBefore: snap,
        matrixAfter: snap,
        transformation: EigenTransformation(
          polynomialLatex: rootsScene,
          realEigenvalues: [
            for (final v in values)
              if (v.isRational) v.rationalValue!,
          ],
        ),
        highlights: diagonal,
      ),
    );

    // One step per distinct eigenvalue.
    final pairs = <ExactEigenpair>[];
    final rationalPairs = <Eigenpair>[];
    final resultParts = <String>[];
    final candidates = <RationalPolynomial, List<List<NumberFieldElement>>>{};
    for (final (i, value) in values.indexed) {
      final index = i + 1;
      final rational = value.rationalValue;
      if (rational != null) {
        final shifted = Matrix([
          for (var r = 0; r < n; r++)
            [
              for (var c = 0; c < n; c++)
                r == c ? matrix.get(r, c) - rational : matrix.get(r, c),
            ],
        ]);
        final basis = _rationalEigenspace(shifted);
        final field = value.field;
        final pair = ExactEigenpair(
          eigenvalue: value,
          eigenspaceBasis: [
            for (final v in basis) [for (final e in v) field.rational(e)],
          ],
        );
        pairs.add(pair);
        rationalPairs.add(
          Eigenpair(
            eigenvalue: rational,
            eigenvector: basis.first,
            algebraicMultiplicity: value.algebraicMultiplicity,
          ),
        );
        final vectors = _rationalVectorsLatex(basis);
        final shiftedSnap = MatrixSnapshot.fromMatrix(shifted);
        final String key;
        final Map<String, dynamic> params = {'lambda': rational.toLatex()};
        if (value.algebraicMultiplicity == 1) {
          key = 'eigen_vector_desc';
          params['vector'] = vectors;
        } else if (!pair.isDefective) {
          key = 'eigen_eigenspace_desc';
          params['vectors'] = vectors;
          params['multiplicity'] = value.algebraicMultiplicity;
        } else {
          key = 'eigen_defective_desc';
          params['vectors'] = vectors;
          params['algebraic'] = value.algebraicMultiplicity;
          params['geometric'] = pair.geometricMultiplicity;
        }
        steps.add(
          MatrixStep(
            stepIndex: ++stepCounter,
            titleKey: 'eigen_vector_title',
            titleParams: {'index': index, 'lambda': rational.toLatex()},
            explanationKey: key,
            explanationParams: params,
            matrixBefore: shiftedSnap,
            matrixAfter: shiftedSnap,
            transformation: InformationalStepTransformation(
              'Solved null space of (A - λI)',
              sceneLatex: _shiftScene(rational, vectors),
            ),
            highlights: diagonal,
          ),
        );
        resultParts.add(
          '\\lambda = ${rational.toLatex()} \\implies '
          '${basis.length == 1 ? vectors : '\\mathbf{v} = ${[for (final v in basis) _column(v)].join(', ')}'}',
        );
        continue;
      }

      final vector = _irrationalEigenvector(matrix, value, candidates);
      final pair = ExactEigenpair(eigenvalue: value, eigenspaceBasis: [vector]);
      pairs.add(pair);
      final field = value.field;
      final lambda = field.generator;
      final symbol = value.degree == 3 ? '\\lambda_{$index}' : r'\lambda';
      final shiftLatex = [
        for (var r = 0; r < n; r++)
          [
            for (var c = 0; c < n; c++)
              r != c
                  ? matrix.get(r, c).toLatex()
                  : value.degree == 3
                  ? _minusLambda(matrix.get(r, c))
                  : value.elementLatex(
                      field.rational(matrix.get(r, c)) - lambda,
                    ),
          ].join(' & '),
      ].join(r' \\ ');
      final vectorScene = pair.vectorLatex(vector);
      final scene =
          '${value.degree == 3 ? '\\lambda_{$index} = ${value.latex},\\quad ' : ''}'
          'A - \\lambda I = \\begin{pmatrix}$shiftLatex\\end{pmatrix} '
          '\\;\\Rightarrow\\; \\mathbf{v} = $vectorScene';
      final vectorText = 'v = ${pair.vectorText(vector)}';
      final String titleKey;
      final Map<String, dynamic> titleParams;
      final String key;
      final Map<String, dynamic> params;
      if (value.degree == 3) {
        titleKey = 'eigen_vector_cubic_title';
        titleParams = {'index': index};
        key = 'eigen_vector_cubic_desc';
        params = {
          'index': index,
          'poly': value.minimalPolynomial.toLatex(),
          'vector': vectorText,
        };
      } else {
        titleKey = 'eigen_vector_title';
        titleParams = {'index': index, 'lambda': value.text};
        key = value.isReal
            ? 'eigen_vector_surd_desc'
            : 'eigen_vector_complex_desc';
        params = {'lambda': value.text, 'vector': vectorText};
      }
      steps.add(
        MatrixStep(
          stepIndex: ++stepCounter,
          titleKey: titleKey,
          titleParams: titleParams,
          explanationKey: key,
          explanationParams: params,
          // A - λI has irrational entries, which a snapshot cannot hold: the
          // grid shows A and the scene writes A - λI exactly.
          matrixBefore: snap,
          matrixAfter: snap,
          transformation: InformationalStepTransformation(
            'Solved null space of (A - λI) in Q(λ)',
            sceneLatex: scene,
          ),
          highlights: diagonal,
        ),
      );
      resultParts.add(
        value.degree == 3
            ? '$symbol = ${value.latex} \\implies \\mathbf{v} = '
                  '${pair.vectorLatex(vector, symbol: symbol)}'
            : '\\lambda = ${value.latex} \\implies \\mathbf{v} = $vectorScene',
      );
    }

    return StepSolution(
      operationKey: 'op_eigen',
      initialMatrix: matrix,
      steps: steps,
      finalMatrix: matrix,
      result: EigenResult(
        characteristicPolynomialLatex: polyLatex,
        realEigenpairs: rationalPairs,
        hasComplexEigenvalues: values.any((v) => !v.isReal),
        eigenpairs: pairs,
        characteristicPolynomial: characteristic,
      ),
      resultLatex: resultParts.join(r' \quad '),
    );
  }

  /// Lesson order: real eigenvalues first (largest first for 2×2 as the
  /// quadratic formula gives them, ascending for 3×3), then each complex
  /// pair with the positive imaginary part first.
  static int _order(int n, ExactEigenvalue a, ExactEigenvalue b) {
    if (a.isReal != b.isReal) return a.isReal ? -1 : 1;
    if (a.isReal) {
      final order = compareRealEigenvalues(a, b);
      return n == 2 ? -order : order;
    }
    return compareConjugates(a, b);
  }

  /// Eigenvalues for prose: rational ones as fractions, a conjugate pair
  /// once as a ± formula.
  static String _rootList(List<ExactEigenvalue> values) {
    final parts = <String>[];
    final seen = <RationalPolynomial>{};
    for (final v in values) {
      if (v.isRational) {
        parts.add(v.rationalValue!.toLatex());
      } else if (seen.add(v.minimalPolynomial)) {
        parts.add(conjugatePair(v)?.text ?? v.text);
      }
    }
    return parts.join(', ');
  }

  /// A basis of the null space of the singular rational matrix [shifted].
  ///
  /// A 2×2 matrix of rank 1 keeps the vector read off its first nonzero row,
  /// (-b, a - λ) or (d - λ, -c); otherwise each free variable of the reduced
  /// row echelon form gives one vector. Each is signed so that its first
  /// nonzero entry is positive.
  static List<List<Rational>> _rationalEigenspace(Matrix shifted) {
    final n = shifted.rows;
    if (n == 2 && !_isZero(shifted)) {
      final a = shifted.get(0, 0);
      final b = shifted.get(0, 1);
      final c = shifted.get(1, 0);
      final d = shifted.get(1, 1);
      final List<Rational> vector;
      if (!b.isZero) {
        vector = [-b, a];
      } else if (!c.isZero) {
        vector = [d, -c];
      } else if (!a.isZero) {
        vector = [Rational.zero, Rational.one];
      } else {
        vector = [Rational.one, Rational.zero];
      }
      return [_simplifyVector(vector)];
    }
    final field = NumberField.rational(Rational.zero);
    final basis = _nullSpace([
      for (var r = 0; r < n; r++)
        [for (var c = 0; c < n; c++) field.rational(shifted.get(r, c))],
    ]);
    return [
      for (final v in basis) _simplifyVector([for (final e in v) e[0]]),
    ];
  }

  static bool _isZero(Matrix m) {
    for (var r = 0; r < m.rows; r++) {
      for (var c = 0; c < m.cols; c++) {
        if (!m.get(r, c).isZero) return false;
      }
    }
    return true;
  }

  /// The eigenvector of a simple irrational or complex eigenvalue, computed
  /// in Q(λ) = Q[x]/(m) with λ the class of x.
  ///
  /// The eigenspace is one-dimensional: repeated roots of a characteristic
  /// polynomial of degree 2 or 3 are rational. Gaussian elimination over
  /// Q(λ) gives one basis vector; for a 3×3 matrix each nonzero cross
  /// product of two rows of A - λI is a multiple of it, and the vector that
  /// is shortest to write after [normalizeEigenvector] is kept. A 2×2 matrix
  /// uses (-b, a - λ) or (d - λ, -c), as for a rational eigenvalue.
  ///
  /// The candidates depend only on the field, so conjugate eigenvalues share
  /// them through [cache]; each conjugate normalizes them for its own sign.
  static List<NumberFieldElement> _irrationalEigenvector(
    Matrix matrix,
    ExactEigenvalue value,
    Map<RationalPolynomial, List<List<NumberFieldElement>>> cache,
  ) {
    final candidates = cache.putIfAbsent(
      value.minimalPolynomial,
      () => _eigenvectorCandidates(matrix, value.field),
    );
    List<NumberFieldElement>? best;
    int? bestSize;
    for (final candidate in candidates) {
      final normalized = normalizeEigenvector(value, candidate);
      final size = writtenSize(value, normalized);
      if (bestSize == null || size < bestSize) {
        best = normalized;
        bestSize = size;
      }
    }
    return best!;
  }

  static List<List<NumberFieldElement>> _eigenvectorCandidates(
    Matrix matrix,
    NumberField field,
  ) {
    final n = matrix.rows;
    final lambda = field.generator;
    final shifted = [
      for (var r = 0; r < n; r++)
        [
          for (var c = 0; c < n; c++)
            r == c
                ? field.rational(matrix.get(r, c)) - lambda
                : field.rational(matrix.get(r, c)),
        ],
    ];
    final candidates = <List<NumberFieldElement>>[];
    if (n == 2) {
      final [[a, b], [c, d]] = shifted;
      candidates.add(!b.isZero ? [-b, a] : [d, -c]);
    } else {
      final basis = _nullSpace(shifted);
      if (basis.length != 1) {
        throw StateError(
          'A simple eigenvalue has a one-dimensional eigenspace',
        );
      }
      candidates.add(basis.single);
      for (final (i, j) in [(0, 1), (0, 2), (1, 2)]) {
        final u = shifted[i];
        final w = shifted[j];
        final cross = [
          u[1] * w[2] - u[2] * w[1],
          u[2] * w[0] - u[0] * w[2],
          u[0] * w[1] - u[1] * w[0],
        ];
        if (cross.any((e) => !e.isZero)) candidates.add(cross);
      }
    }
    return candidates;
  }

  /// Null-space basis of [m] by Gauss–Jordan elimination over its field:
  /// one vector per free column, 1 there and 0 in the other free columns.
  static List<List<NumberFieldElement>> _nullSpace(
    List<List<NumberFieldElement>> m,
  ) {
    final rows = [
      for (final row in m) [...row],
    ];
    final cols = rows.first.length;
    final pivots = <int>[];
    var r = 0;
    for (var c = 0; c < cols && r < rows.length; c++) {
      final p = [for (var i = r; i < rows.length; i++) i]
          .firstWhere((i) => !rows[i][c].isZero, orElse: () => -1);
      if (p < 0) continue;
      final pivotRow = rows[p];
      rows[p] = rows[r];
      final inverse = pivotRow[c].inverse();
      rows[r] = [for (final e in pivotRow) e * inverse];
      for (var i = 0; i < rows.length; i++) {
        if (i == r || rows[i][c].isZero) continue;
        final factor = rows[i][c];
        rows[i] = [
          for (var k = 0; k < cols; k++) rows[i][k] - factor * rows[r][k],
        ];
      }
      pivots.add(c);
      r++;
    }
    final field = m.first.first.field;
    return [
      for (var free = 0; free < cols; free++)
        if (!pivots.contains(free))
          [
            for (var k = 0; k < cols; k++)
              k == free
                  ? field.one
                  : pivots.contains(k)
                  ? -rows[pivots.indexOf(k)][free]
                  : field.zero,
          ],
    ];
  }

  static String _column(List<Rational> v) =>
      '\\begin{pmatrix}${v.map((e) => e.toLatex()).join(r' \\ ')}\\end{pmatrix}';

  /// `\mathbf{v} = (…)`, or `\mathbf{v}_{1} = (…), \mathbf{v}_{2} = (…)`
  /// for an eigenspace of dimension 2 or more.
  static String _rationalVectorsLatex(List<List<Rational>> basis) {
    if (basis.length == 1) return '\\mathbf{v} = ${_column(basis.single)}';
    return [
      for (final (i, v) in basis.indexed)
        '\\mathbf{v}_{${i + 1}} = ${_column(v)}',
    ].join(', ');
  }

  /// A diagonal entry of A - λI for a cubic λ: `2 - \lambda`, `-\lambda`.
  static String _minusLambda(Rational entry) =>
      entry.isZero ? r'-\lambda' : '${entry.toLatex()} - \\lambda';

  /// Caption above the matrix of an eigenvector step: the grid shows
  /// A - λI, not A, and its null space gives the vector.
  static String _shiftScene(Rational lambda, String vectorLatex) {
    final size = lambda.abs();
    final coefficient = size == Rational.one ? '' : size.toLatex();
    final shift = lambda.isZero
        ? 'A'
        : '${lambda.isNegative ? 'A +' : 'A -'} ${coefficient}I';
    return '$shift \\;\\Rightarrow\\; $vectorLatex';
  }

  static List<Rational> _simplifyVector(List<Rational> v) {
    // Make first non-zero element positive
    final firstNonZero = v.indexWhere((e) => !e.isZero);
    if (firstNonZero == -1 || !v[firstNonZero].isNegative) return v;
    return v.map((e) => -e).toList();
  }
}
