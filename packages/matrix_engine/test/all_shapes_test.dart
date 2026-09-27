/// Every solver on every matrix shape the editor allows, checked exactly
/// against references written here, together with the step record the
/// player animates: snapshots, highlights, sub-calculations and each row
/// operation replayed on its "before" frame.
///
/// Shapes (MatrixInputCubit.setDimensionsA/B): addition m×n + m×n and
/// multiplication m×k · k×n with m, k, n in 1..5; REF, RREF and rank on any
/// m×n; linear systems on an augmented m×c matrix with c in 2..5;
/// determinant, inverse and LU on n×n; eigen analysis on 2×2 and 3×3.
///
/// Every check of a shape is collected before the test fails, so a report
/// names all broken cases with the input that reproduces each.
library;

import 'dart:math';

import 'package:matrix_engine/matrix_engine.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------

/// Input kinds used for every shape. Integers and fractions repeat so each
/// shape sees several random matrices.
const _smallKinds = [
  'int',
  'int',
  'int',
  'frac',
  'frac',
  'sparse',
  'dupRow',
  'zeroRow',
  'dupCol',
  'zeroCol',
  'lowRank',
  'pivotZero',
  'zeros',
  'identity',
  'diagonal',
  'antidiagonal',
];

/// 15-digit/15-digit fractions, the longest cell the editor accepts. One per
/// shape keeps the sweep fast enough for a unit test.
const _bigKinds = ['big'];

List<String> _kinds(int rows, int cols) => [
  for (final kind in [..._smallKinds, ..._bigKinds])
    if (_applies(kind, rows, cols)) kind,
];

bool _applies(String kind, int rows, int cols) => switch (kind) {
  'dupRow' || 'bigDupRow' => rows >= 2,
  'dupCol' => cols >= 2,
  'pivotZero' => rows >= 2 && cols >= 2,
  _ => true,
};

/// Each kind paired with itself and with a kind five places on.
List<(String, String)> _pairs(List<String> a, List<String> b) => [
  for (var i = 0; i < a.length; i++) ...[
    (a[i], b[i % b.length]),
    (a[i], b[(i + 5) % b.length]),
  ],
];

/// A seed per operation and shape, so a single test reproduces on its own.
int _seed(String op, List<int> dims) {
  var h = 17;
  for (final unit in [...op.codeUnits, ...dims]) {
    h = (h * 31 + unit) % 2147483647;
  }
  return h;
}

final _multipliers = [
  Rational(1),
  Rational(-1),
  Rational(2),
  Rational(-3),
  Rational(1, 2),
];

class _Inputs {
  _Inputs(int seed) : _rng = Random(seed);

  final Random _rng;

  Rational _int({bool nonzero = false}) {
    while (true) {
      final v = _rng.nextInt(19) - 9;
      if (!nonzero || v != 0) return Rational(v);
    }
  }

  Rational _frac({bool nonzero = false}) =>
      Rational(_int(nonzero: nonzero).num, BigInt.from(_rng.nextInt(7) + 1));

  BigInt _digits(int count) {
    var v = BigInt.from(_rng.nextInt(9) + 1);
    for (var i = 1; i < count; i++) {
      v = v * BigInt.from(10) + BigInt.from(_rng.nextInt(10));
    }
    return v;
  }

  Rational _big() {
    final n = _digits(15);
    return Rational(_rng.nextBool() ? -n : n, _digits(15));
  }

  Rational _multiplier() => _multipliers[_rng.nextInt(_multipliers.length)];

  List<Rational> intVector(int length) => [
    for (var i = 0; i < length; i++) _int(),
  ];

  Matrix matrix(String kind, int rows, int cols) {
    List<List<Rational>> fill(Rational Function(int r, int c) entry) => [
      for (var r = 0; r < rows; r++)
        [for (var c = 0; c < cols; c++) entry(r, c)],
    ];

    List<List<Rational>> duplicateRow(List<List<Rational>> data) {
      final source = _rng.nextInt(rows);
      final target = (source + 1 + _rng.nextInt(rows - 1)) % rows;
      final k = _multiplier();
      data[target] = [for (final v in data[source]) v * k];
      return data;
    }

    switch (kind) {
      case 'int':
        return Matrix(fill((_, _) => _int()));
      case 'frac':
        return Matrix(fill((_, _) => _frac()));
      case 'sparse':
        return Matrix(
          fill(
            (_, _) =>
                _rng.nextInt(4) == 0 ? _int(nonzero: true) : Rational.zero,
          ),
        );
      case 'dupRow':
        return Matrix(duplicateRow(fill((_, _) => _int())));
      case 'zeroRow':
        final data = fill((_, _) => _int());
        data[_rng.nextInt(rows)] = List.filled(cols, Rational.zero);
        return Matrix(data);
      case 'dupCol':
        final data = fill((_, _) => _int());
        final source = _rng.nextInt(cols);
        final target = (source + 1 + _rng.nextInt(cols - 1)) % cols;
        final k = _multiplier();
        for (final row in data) {
          row[target] = row[source] * k;
        }
        return Matrix(data);
      case 'zeroCol':
        final data = fill((_, _) => _int());
        final col = _rng.nextInt(cols);
        for (final row in data) {
          row[col] = Rational.zero;
        }
        return Matrix(data);
      case 'lowRank':
        // A product through a narrower inner dimension: rank below min(m, n)
        // whenever both exceed one.
        final inner = max(1, min(rows, cols) - 1);
        final left = [for (var r = 0; r < rows; r++) intVector(inner)];
        final right = [for (var k = 0; k < inner; k++) intVector(cols)];
        return Matrix(
          fill((r, c) {
            var sum = Rational.zero;
            for (var k = 0; k < inner; k++) {
              sum += left[r][k] * right[k][c];
            }
            return sum;
          }),
        );
      case 'pivotZero':
        // Row 1 repeats row 0 except in the last column, so elimination
        // meets a zero pivot in column 1 and must swap or skip.
        final data = fill((_, _) => _int());
        data[0][0] = _int(nonzero: true);
        data[1] = [
          for (var c = 0; c < cols; c++)
            c == cols - 1 ? data[0][c] + _int(nonzero: true) : data[0][c],
        ];
        return Matrix(data);
      case 'zeros':
        return Matrix(fill((_, _) => Rational.zero));
      case 'identity':
        return Matrix(fill((r, c) => r == c ? Rational.one : Rational.zero));
      case 'diagonal':
        return Matrix(
          fill((r, c) => r == c ? _frac(nonzero: true) : Rational.zero),
        );
      case 'antidiagonal':
        return Matrix(
          fill(
            (r, c) => r + c == cols - 1 ? _int(nonzero: true) : Rational.zero,
          ),
        );
      case 'big':
        return Matrix(fill((_, _) => _big()));
      case 'bigDupRow':
        return Matrix(duplicateRow(fill((_, _) => _big())));
      case 'bigSparse':
        return Matrix(
          fill((_, _) => _rng.nextInt(3) == 0 ? _big() : Rational.zero),
        );
    }
    throw ArgumentError.value(kind, 'kind');
  }
}

// ---------------------------------------------------------------------------
// Independent references
// ---------------------------------------------------------------------------

Matrix _zero(int rows, int cols) =>
    Matrix([for (var r = 0; r < rows; r++) List.filled(cols, Rational.zero)]);

Matrix _identity(int n) => Matrix([
  for (var r = 0; r < n; r++)
    [for (var c = 0; c < n; c++) r == c ? Rational.one : Rational.zero],
]);

Matrix _product(Matrix a, Matrix b) => Matrix([
  for (var r = 0; r < a.rows; r++)
    [
      for (var c = 0; c < b.cols; c++)
        [for (var k = 0; k < a.cols; k++) a.get(r, k) * b.get(k, c)]
            .fold(Rational.zero, (sum, v) => sum + v),
    ],
]);

Matrix _sideBySide(Matrix a, Matrix b) => Matrix([
  for (var r = 0; r < a.rows; r++) [...a.getRow(r), ...b.getRow(r)],
]);

Matrix _columns(Matrix m, int from, int to) =>
    Matrix([for (var r = 0; r < m.rows; r++) m.getRow(r).sublist(from, to)]);

Matrix _shift(Matrix a, Rational lambda) => Matrix([
  for (var r = 0; r < a.rows; r++)
    [
      for (var c = 0; c < a.cols; c++)
        r == c ? a.get(r, c) - lambda : a.get(r, c),
    ],
]);

List<Rational> _apply(Matrix a, List<Rational> x) => [
  for (var r = 0; r < a.rows; r++)
    [for (var c = 0; c < a.cols; c++) a.get(r, c) * x[c]]
        .fold(Rational.zero, (sum, v) => sum + v),
];

/// Reduced row echelon form, pivoting on the largest entry (the engine takes
/// the first nonzero one); the RREF is unique, so both must agree.
Matrix _rref(Matrix m) {
  final rows = m.toList();
  var r = 0;
  for (var c = 0; c < m.cols && r < m.rows; c++) {
    var best = -1;
    for (var i = r; i < m.rows; i++) {
      if (rows[i][c].isZero) continue;
      if (best < 0 || rows[i][c].abs() > rows[best][c].abs()) best = i;
    }
    if (best < 0) continue;
    final swap = rows[best];
    rows[best] = rows[r];
    rows[r] = swap;
    final pivot = rows[r][c];
    rows[r] = [for (final v in rows[r]) v / pivot];
    for (var i = 0; i < m.rows; i++) {
      final f = rows[i][c];
      if (i == r || f.isZero) continue;
      rows[i] = [for (var k = 0; k < m.cols; k++) rows[i][k] - f * rows[r][k]];
    }
    r++;
  }
  return Matrix(rows);
}

/// The leading column of each nonzero row.
List<int> _leading(Matrix m) => [
  for (var r = 0; r < m.rows; r++)
    for (var c = 0; c < m.cols; c++)
      if (!m.get(r, c).isZero && m.getRow(r).take(c).every((v) => v.isZero)) c,
];

int _rank(Matrix m) => _leading(_rref(m)).length;

bool _isRowEchelon(Matrix m, {required bool leadingOnes}) {
  var previous = -1;
  var zeroRowSeen = false;
  for (var r = 0; r < m.rows; r++) {
    final lead = m.getRow(r).indexWhere((v) => !v.isZero);
    if (lead < 0) {
      zeroRowSeen = true;
      continue;
    }
    if (zeroRowSeen || lead <= previous) return false;
    if (leadingOnes && !m.get(r, lead).isOne) return false;
    previous = lead;
  }
  return true;
}

bool _isReducedRowEchelon(Matrix m) {
  if (!_isRowEchelon(m, leadingOnes: true)) return false;
  for (var r = 0; r < m.rows; r++) {
    final lead = m.getRow(r).indexWhere((v) => !v.isZero);
    if (lead < 0) continue;
    for (var i = 0; i < m.rows; i++) {
      if (i != r && !m.get(i, lead).isZero) return false;
    }
  }
  return true;
}

bool _isUpperTriangular(Matrix m) {
  for (var r = 0; r < m.rows; r++) {
    for (var c = 0; c < r && c < m.cols; c++) {
      if (!m.get(r, c).isZero) return false;
    }
  }
  return true;
}

bool _isUnitLowerTriangular(Matrix m) {
  if (!m.isSquare) return false;
  for (var r = 0; r < m.rows; r++) {
    if (!m.get(r, r).isOne) return false;
    for (var c = r + 1; c < m.cols; c++) {
      if (!m.get(r, c).isZero) return false;
    }
  }
  return true;
}

bool _isPermutation(Matrix m) {
  if (!m.isSquare) return false;
  for (var r = 0; r < m.rows; r++) {
    final row = m.getRow(r);
    if (row.where((v) => v.isOne).length != 1) return false;
    if (row.any((v) => !v.isOne && !v.isZero)) return false;
  }
  for (var c = 0; c < m.cols; c++) {
    if (m.getCol(c).where((v) => v.isOne).length != 1) return false;
  }
  return true;
}

/// Fraction-free Bareiss elimination; every division is exact.
Rational _bareiss(Matrix m) {
  final n = m.rows;
  final a = m.toList();
  var sign = Rational.one;
  var previous = Rational.one;
  for (var k = 0; k < n - 1; k++) {
    if (a[k][k].isZero) {
      var swap = -1;
      for (var i = k + 1; i < n; i++) {
        if (!a[i][k].isZero) {
          swap = i;
          break;
        }
      }
      if (swap < 0) return Rational.zero;
      final t = a[k];
      a[k] = a[swap];
      a[swap] = t;
      sign = -sign;
    }
    for (var i = k + 1; i < n; i++) {
      for (var j = k + 1; j < n; j++) {
        a[i][j] = (a[i][j] * a[k][k] - a[i][k] * a[k][j]) / previous;
      }
    }
    previous = a[k][k];
  }
  return sign * a[n - 1][n - 1];
}

Rational _cofactor(Matrix m) {
  if (m.rows == 1) return m.get(0, 0);
  var sum = Rational.zero;
  for (var c = 0; c < m.cols; c++) {
    if (m.get(0, c).isZero) continue;
    final minor = Matrix([
      for (var r = 1; r < m.rows; r++)
        [
          for (var k = 0; k < m.cols; k++)
            if (k != c) m.get(r, k),
        ],
    ]);
    final term = m.get(0, c) * _cofactor(minor);
    sum = c.isEven ? sum + term : sum - term;
  }
  return sum;
}

/// det(xI - A) by cofactor expansion over polynomials.
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

// ---------------------------------------------------------------------------
// Reporting
// ---------------------------------------------------------------------------

class _Stats {
  var cases = 0;
  var checks = 0;
  var steps = 0;
  var slowest = 0;
  var slowestLabel = '';
  var slowestLargestBig = 0;
  var slowestLargestBigLabel = '';
  final counters = <String, int>{};
}

final _allStats = <String, _Stats>{};

_Stats _stats(String op) => _allStats.putIfAbsent(op, _Stats.new);

String _show(Matrix m) =>
    '[${[for (var r = 0; r < m.rows; r++) '[${m.getRow(r).join(', ')}]'].join(', ')}]';

String _showSnapshot(MatrixSnapshot s) => _show(s.toMatrix());

/// Collects the failed checks of one shape, each with its reproducing input.
class _Report {
  _Report(this.op, this.shape, {this.largest = false});

  final String op;
  final String shape;

  /// Whether this is the operation's largest shape, where the slowest solve
  /// of 15-digit fractions is recorded.
  final bool largest;

  final _failures = <String>[];
  var _failed = 0;
  var _case = '';
  String Function() _input = () => '';

  _Stats get stats => _stats(op);

  void begin(String kind, String Function() input) {
    _case = kind;
    _input = input;
    stats.cases++;
  }

  void count(String counter) =>
      stats.counters[counter] = (stats.counters[counter] ?? 0) + 1;

  void that(bool ok, String Function() message) {
    stats.checks++;
    if (ok) return;
    _failed++;
    if (_failures.length < 12) {
      _failures.add('$op $shape [$_case] ${message()}\n    input: ${_input()}');
    }
  }

  StepSolution? solve(StepSolution Function() run) {
    final watch = Stopwatch()..start();
    try {
      final solution = run();
      watch.stop();
      final micros = watch.elapsedMicroseconds;
      if (micros > stats.slowest) {
        stats.slowest = micros;
        stats.slowestLabel = '$shape $_case';
      }
      if (largest &&
          _case.contains('big') &&
          micros > stats.slowestLargestBig) {
        stats.slowestLargestBig = micros;
        stats.slowestLargestBigLabel = '$shape $_case';
      }
      return solution;
    } catch (error, trace) {
      that(false, () => 'solver threw $error\n${_top(trace)}');
      return null;
    }
  }

  void run(void Function() checks) {
    try {
      checks();
    } catch (error, trace) {
      that(false, () => 'check threw $error\n${_top(trace)}');
    }
  }

  void done() {
    if (_failed == 0) return;
    fail(
      '$_failed failed checks; the first ${_failures.length}:\n'
      '${_failures.join('\n')}',
    );
  }
}

String _top(StackTrace trace) =>
    trace.toString().split('\n').take(4).join('\n');

void _printSummary() {
  String ms(int micros) => '${(micros / 1000).toStringAsFixed(1)} ms';
  final lines = ['all shapes summary:'];
  for (final MapEntry(key: op, value: s) in _allStats.entries) {
    lines.add(
      '  $op: ${s.cases} cases, ${s.steps} steps, ${s.checks} checks; '
      'slowest ${ms(s.slowest)} (${s.slowestLabel})'
      '${s.slowestLargestBigLabel.isEmpty ? '' : '; slowest largest-shape big ${ms(s.slowestLargestBig)} (${s.slowestLargestBigLabel})'}'
      '${s.counters.isEmpty ? '' : '; ${s.counters}'}',
    );
  }
  print(lines.join('\n'));
}

// ---------------------------------------------------------------------------
// LaTeX
// ---------------------------------------------------------------------------

final _exponent = RegExp(r'[0-9][eE][+-]?[0-9]');
final _environment = RegExp(r'\\(begin|end)\{([a-zA-Z*]+)\}');

/// Why [latex] is malformed or inexact, or null when it is neither.
String? _latexProblem(String latex) {
  var depth = 0;
  var escaped = 0;
  for (var i = 0; i < latex.length; i++) {
    final ch = latex[i];
    if (ch == '\\') {
      if (i + 1 < latex.length) {
        final next = latex[i + 1];
        if (next == '{') escaped++;
        if (next == '}') escaped--;
        if (next == '{' || next == '}' || next == '\\') i++;
      }
      continue;
    }
    if (ch == '{') depth++;
    if (ch == '}' && --depth < 0) return 'an unmatched }';
  }
  if (depth != 0) return 'an unclosed {';
  if (escaped != 0) return r'unbalanced \{ \}';
  final open = <String>[];
  for (final m in _environment.allMatches(latex)) {
    if (m[1] == 'begin') {
      open.add(m[2]!);
    } else if (open.isEmpty || open.removeLast() != m[2]) {
      return 'an unmatched \\end{${m[2]}}';
    }
  }
  if (open.isNotEmpty) return 'an unclosed \\begin{${open.last}}';
  for (final bad in ['NaN', 'Infinity', 'approx', 'e+', 'e-']) {
    if (latex.contains(bad)) return '"$bad"';
  }
  if (_exponent.hasMatch(latex)) return 'exponent notation';
  return null;
}

void _checkLatex(_Report rep, String where, String latex) {
  final problem = _latexProblem(latex);
  rep.that(problem == null, () => '$where has $problem: $latex');
}

final _fraction = RegExp(r'^(-?)\\frac\{([0-9]+)\}\{([0-9]+)\}$');
final _integer = RegExp(r'^-?[0-9]+$');

/// A value written by Rational.toLatex.
Rational? _parseLatexRational(String text) {
  final s = text.trim();
  final f = _fraction.firstMatch(s);
  if (f != null) {
    final v = Rational(BigInt.parse(f[2]!), BigInt.parse(f[3]!));
    return f[1] == '-' ? -v : v;
  }
  return _integer.hasMatch(s) ? Rational(BigInt.parse(s)) : null;
}

final _term = RegExp(
  r'^(?:([a-z](?:_\{[0-9]+\})?) )?\\begin\{pmatrix\}(.*)\\end\{pmatrix\}$',
);

/// `\mathbf{x} = (…) + t (…) + …` as (parameter, column) terms.
List<(String?, List<Rational>)>? _parseSolution(String latex) {
  const prefix = r'\mathbf{x} = ';
  if (!latex.startsWith(prefix)) return null;
  final terms = <(String?, List<Rational>)>[];
  for (final text in latex.substring(prefix.length).split(' + ')) {
    final m = _term.firstMatch(text);
    if (m == null) return null;
    final entries = [
      for (final e in m[2]!.split(r' \\ ')) _parseLatexRational(e),
    ];
    if (entries.any((e) => e == null)) return null;
    terms.add((m[1], [for (final e in entries) e!]));
  }
  return terms;
}

// ---------------------------------------------------------------------------
// Step record
// ---------------------------------------------------------------------------

bool _holds(MatrixSnapshot s, Matrix m) =>
    s.rows == m.rows && s.cols == m.cols && s.toMatrix() == m;

bool _sameSnapshot(MatrixSnapshot a, MatrixSnapshot b) =>
    a.rows == b.rows &&
    a.cols == b.cols &&
    a.structure == b.structure &&
    a.augmentedColIndex == b.augmentedColIndex &&
    a.toMatrix() == b.toMatrix();

bool _wellFormed(MatrixSnapshot s) {
  if (s.rows < 1 || s.cols < 1 || s.values.length != s.rows) return false;
  if (s.values.any((row) => row.length != s.cols)) return false;
  final divider = s.augmentedColIndex;
  return divider == null || (divider > 0 && divider < s.cols);
}

bool _inside(MatrixSnapshot s, int row, int col) =>
    row >= 0 && row < s.rows && col >= 0 && col < s.cols;

List<List<Rational>> _values(MatrixSnapshot s) => [
  for (final row in s.values) [...row],
];

/// Row, column and value checks shared by every solver.
void _checkRecord(
  _Report rep,
  StepSolution s, {
  Matrix? first,
  Matrix? last,
  bool continuous = true,
  bool cellCalculations = true,
  MatrixStructureType structure = MatrixStructureType.standard,
  int? divider,
}) {
  rep.that(
    s.accuracy == ResultAccuracy.exact &&
        s.completeness == ResultCompleteness.complete &&
        s.decimalPlaces == null,
    () =>
        'accuracy ${s.accuracy}, completeness ${s.completeness}, '
        'decimalPlaces ${s.decimalPlaces}',
  );
  final resultLatex = s.resultLatex;
  if (resultLatex != null) _checkLatex(rep, 'resultLatex', resultLatex);
  final steps = s.steps;
  rep.stats.steps += steps.length;
  rep.that(steps.isNotEmpty, () => 'the lesson has no steps');
  if (steps.isEmpty) return;
  if (first != null) {
    rep.that(
      _holds(steps.first.matrixBefore, first),
      () =>
          'first matrixBefore ${_showSnapshot(steps.first.matrixBefore)} '
          'is not ${_show(first)}',
    );
  }
  if (last != null) {
    rep.that(
      _holds(steps.last.matrixAfter, last),
      () =>
          'last matrixAfter ${_showSnapshot(steps.last.matrixAfter)} '
          'is not ${_show(last)}',
    );
  }
  for (final (i, step) in steps.indexed) {
    final where = 'step ${i + 1}/${steps.length} ${step.titleKey}';
    rep.that(
      step.stepIndex == i + 1,
      () => '$where has stepIndex ${step.stepIndex}',
    );
    for (final (name, snap) in [
      ('before', step.matrixBefore),
      ('after', step.matrixAfter),
    ]) {
      rep.that(_wellFormed(snap), () => '$where: malformed $name snapshot');
      rep.that(
        snap.structure == structure && snap.augmentedColIndex == divider,
        () =>
            '$where: $name snapshot is ${snap.structure}/'
            '${snap.augmentedColIndex}, expected $structure/$divider',
      );
    }
    if (continuous && i > 0) {
      rep.that(
        _sameSnapshot(steps[i - 1].matrixAfter, step.matrixBefore),
        () =>
            '$where: matrixBefore ${_showSnapshot(step.matrixBefore)} is not '
            'the previous matrixAfter ${_showSnapshot(steps[i - 1].matrixAfter)}',
      );
    }
    _checkHighlights(rep, where, step);
    _checkSubCalculations(rep, where, step, cells: cellCalculations);
    _checkTransformation(rep, where, step);
    _checkStepText(rep, where, step);
  }
}

void _checkHighlights(_Report rep, String where, MatrixStep step) {
  final seen = <(int, int)>{};
  for (final h in step.highlights) {
    final inside =
        _inside(step.matrixBefore, h.row, h.col) &&
        _inside(step.matrixAfter, h.row, h.col);
    rep.that(inside, () => '$where: highlight (${h.row}, ${h.col}) outside');
    if (!inside) continue;
    rep.that(
      seen.add((h.row, h.col)),
      () => '$where: cell (${h.row}, ${h.col}) has two highlights',
    );
    final value = step.matrixAfter.get(h.row, h.col);
    if (h.type == HighlightType.zeroed || h.badgeText == '0') {
      rep.that(
        value.isZero,
        () => '$where: (${h.row}, ${h.col}) marked zero holds $value',
      );
    }
    if (h.type == HighlightType.pivot) {
      rep.that(
        !value.isZero,
        () => '$where: pivot (${h.row}, ${h.col}) is zero',
      );
    }
    if (h.badgeText == '1') {
      rep.that(
        value.isOne,
        () => '$where: (${h.row}, ${h.col}) badged 1 holds $value',
      );
    }
    final badge = h.badgeText;
    if (badge != null) _checkLatex(rep, '$where badge', badge);
  }
}

void _checkSubCalculations(
  _Report rep,
  String where,
  MatrixStep step, {
  required bool cells,
}) {
  for (final sc in step.subCalculations) {
    final inside = _inside(step.matrixAfter, sc.targetRow, sc.targetCol);
    rep.that(
      inside,
      () =>
          '$where: sub-calculation (${sc.targetRow}, ${sc.targetCol}) outside',
    );
    _checkLatex(rep, '$where formula', sc.formulaLatex);
    final result = sc.result.toLatex();
    rep.that(
      sc.formulaLatex.endsWith(' = $result') ||
          // The contradiction row states 0 ≠ c, with no English word.
          (step.titleKey == 'system_inconsistent_title' &&
              sc.formulaLatex == '0 \\neq $result'),
      () => '$where: formula "${sc.formulaLatex}" does not give $result',
    );
    if (cells && inside) {
      final entry = step.matrixAfter.get(sc.targetRow, sc.targetCol);
      rep.that(
        entry == sc.result,
        () =>
            '$where: sub-calculation (${sc.targetRow}, ${sc.targetCol}) = '
            '${sc.result} but matrixAfter holds $entry',
      );
    }
  }
}

void _checkStepText(_Report rep, String where, MatrixStep step) {
  const rowKeys = {'row', 'rowA', 'rowB', 'target', 'source'};
  final rows = step.matrixAfter.rows;
  final cols = step.matrixAfter.cols;
  for (final params in [step.titleParams, step.explanationParams]) {
    for (final MapEntry(:key, :value) in params.entries) {
      if (value is String) {
        _checkLatex(rep, '$where $key', value);
      } else if (value is int) {
        final limit = rowKeys.contains(key)
            ? rows
            : key == 'col'
            ? cols
            : max(rows, cols);
        final low = rowKeys.contains(key) || key == 'col' ? 1 : 0;
        rep.that(
          value >= low && value <= limit,
          () => '$where: $key = $value outside $low..$limit',
        );
      } else {
        rep.that(false, () => '$where: $key is a ${value.runtimeType}');
      }
    }
  }
  switch (step.transformation) {
    case InformationalStepTransformation(:final note, :final sceneLatex):
      _checkLatex(rep, '$where note', note);
      if (sceneLatex != null) _checkLatex(rep, '$where scene', sceneLatex);
    case LinearSystemTransformation(:final summaryLatex):
      _checkLatex(rep, '$where summary', summaryLatex);
    case EigenTransformation(:final polynomialLatex):
      _checkLatex(rep, '$where polynomial', polynomialLatex);
    default:
      break;
  }
}

/// Replays each operation on its "before" frame; frames that only explain
/// must not change the matrix.
void _checkTransformation(_Report rep, String where, MatrixStep step) {
  final before = step.matrixBefore;
  final after = step.matrixAfter;
  final params = step.explanationParams;
  bool row(int r) => r >= 0 && r < before.rows;
  void unchanged() => rep.that(
    _sameSnapshot(before, after),
    () =>
        '$where: ${step.transformation.runtimeType} changed the matrix '
        '${_showSnapshot(before)} -> ${_showSnapshot(after)}',
  );
  void becomes(List<List<Rational>> expected, String what) => rep.that(
    after.rows == before.rows &&
        after.cols == before.cols &&
        after.structure == before.structure &&
        after.augmentedColIndex == before.augmentedColIndex &&
        after.toMatrix() == Matrix(expected),
    () =>
        '$where: $what of ${_showSnapshot(before)} gives '
        '${_show(Matrix(expected))}, the step shows ${_showSnapshot(after)}',
  );

  void elimination(RowEliminationTransformation t) {
    if (!row(t.targetRow) || !row(t.sourceRow)) {
      rep.that(false, () => '$where: rows ${t.targetRow}, ${t.sourceRow}');
      return;
    }
    rep.that(t.targetRow != t.sourceRow, () => '$where: row onto itself');
    rep.that(!t.factor.isZero, () => '$where: zero factor');
    // targetRow ← targetRow + factor · sourceRow.
    final v = _values(before);
    v[t.targetRow] = [
      for (var c = 0; c < before.cols; c++)
        v[t.targetRow][c] + t.factor * v[t.sourceRow][c],
    ];
    becomes(v, 'R${t.targetRow + 1} + (${t.factor})·R${t.sourceRow + 1}');
    final multiplier = params['multiplier'];
    if (multiplier != null) {
      rep.that(
        multiplier == (-t.factor).toLatex(),
        () => '$where: multiplier $multiplier, factor ${t.factor}',
      );
    }
  }

  switch (step.transformation) {
    case LUEliminationTransformation t:
      elimination(t);
      final lower = t.lower.toMatrix();
      rep.that(
        t.lowerRow == t.targetRow && t.lowerCol == t.sourceRow,
        () => '$where: L entry (${t.lowerRow}, ${t.lowerCol})',
      );
      rep.that(
        _isUnitLowerTriangular(lower) && lower.rows == before.rows,
        () => '$where: L is not unit lower triangular: ${_show(lower)}',
      );
      if (_inside(t.lower, t.lowerRow, t.lowerCol)) {
        rep.that(
          lower.get(t.lowerRow, t.lowerCol) == -t.factor,
          () =>
              '$where: L holds ${lower.get(t.lowerRow, t.lowerCol)}, '
              'factor ${t.factor}',
        );
      }
    case RowEliminationTransformation t:
      elimination(t);
    case RowSwapTransformation t:
      if (!row(t.rowA) || !row(t.rowB)) {
        rep.that(false, () => '$where: rows ${t.rowA}, ${t.rowB}');
        return;
      }
      rep.that(t.rowA != t.rowB, () => '$where: swaps a row with itself');
      final v = _values(before);
      final swap = v[t.rowA];
      v[t.rowA] = v[t.rowB];
      v[t.rowB] = swap;
      becomes(v, 'R${t.rowA + 1} <-> R${t.rowB + 1}');
      final col = params['col'];
      final pivot = params['pivot'];
      if (col is int && pivot != null && _inside(after, t.rowA, col - 1)) {
        rep.that(
          after.get(t.rowA, col - 1).toLatex() == pivot,
          () =>
              '$where: pivot $pivot, matrix holds '
              '${after.get(t.rowA, col - 1)}',
        );
      }
    case RowScaleTransformation t:
      if (!row(t.row)) {
        rep.that(false, () => '$where: row ${t.row}');
        return;
      }
      rep.that(
        !t.scalar.isZero && !t.scalar.isOne,
        () => '$where: scales by ${t.scalar}',
      );
      final v = _values(before);
      v[t.row] = [for (final e in v[t.row]) e * t.scalar];
      becomes(v, '(${t.scalar})·R${t.row + 1}');
      final pivot = params['pivot'];
      if (pivot != null && !t.scalar.isZero) {
        rep.that(
          pivot == t.scalar.inverse().toLatex(),
          () => '$where: pivot $pivot, scalar ${t.scalar}',
        );
      }
    case MatrixElementAdditionTransformation t:
      if (!_inside(before, t.row, t.col)) {
        rep.that(false, () => '$where: cell (${t.row}, ${t.col})');
        return;
      }
      final v = _values(before);
      v[t.row][t.col] = t.left + t.right;
      becomes(v, 'setting (${t.row}, ${t.col}) to ${t.left} + ${t.right}');
    case MatrixElementMultiplicationTransformation t:
      if (!_inside(before, t.targetRow, t.targetCol)) {
        rep.that(false, () => '$where: cell (${t.targetRow}, ${t.targetCol})');
        return;
      }
      rep.that(
        t.rowElements.length == t.colElements.length &&
            t.rowElements.isNotEmpty,
        () => '$where: ${t.rowElements.length}·${t.colElements.length} terms',
      );
      var dot = Rational.zero;
      for (
        var k = 0;
        k < min(t.rowElements.length, t.colElements.length);
        k++
      ) {
        dot += t.rowElements[k] * t.colElements[k];
      }
      rep.that(dot == t.result, () => '$where: dot $dot, result ${t.result}');
      final v = _values(before);
      v[t.targetRow][t.targetCol] = t.result;
      becomes(v, 'setting (${t.targetRow}, ${t.targetCol}) to ${t.result}');
    case AdjugateTransformation():
      if (before.rows != 2 || before.cols != 2) {
        rep.that(false, () => '$where: adjugate of a non-2x2 frame');
        return;
      }
      final [[a, b], [c, d]] = before.values;
      becomes([
        [d, -b],
        [-c, a],
      ], 'the adjugate');
    case MatrixScaleTransformation t:
      becomes([
        for (final r in before.values) [for (final e in r) e * t.scalar],
      ], 'scaling by ${t.scalar}');
    case DeterminantCrossProductTransformation t:
      unchanged();
      if (before.rows == 2 && before.cols == 2) {
        rep.that(
          t.mainDiagonalProduct == before.get(0, 0) * before.get(1, 1) &&
              t.antiDiagonalProduct == before.get(0, 1) * before.get(1, 0),
          () =>
              '$where: diagonal products ${t.mainDiagonalProduct}, '
              '${t.antiDiagonalProduct}',
        );
      } else {
        rep.that(false, () => '$where: 2x2 products on a larger frame');
      }
      rep.that(t.phase >= 1 && t.phase <= 3, () => '$where: phase ${t.phase}');
    case DeterminantSarrusTransformation t:
      unchanged();
      if (before.rows == 3 && before.cols == 3) {
        Rational p(List<(int, int)> cells) => cells
            .map((rc) => before.get(rc.$1, rc.$2))
            .fold(Rational.one, (x, y) => x * y);
        final positive = [
          p([(0, 0), (1, 1), (2, 2)]),
          p([(0, 1), (1, 2), (2, 0)]),
          p([(0, 2), (1, 0), (2, 1)]),
        ];
        final negative = [
          p([(0, 2), (1, 1), (2, 0)]),
          p([(0, 0), (1, 2), (2, 1)]),
          p([(0, 1), (1, 0), (2, 2)]),
        ];
        rep.that(
          _sameList(t.positiveProducts, positive) &&
              _sameList(t.negativeProducts, negative),
          () =>
              '$where: Sarrus products ${t.positiveProducts} / '
              '${t.negativeProducts}, expected $positive / $negative',
        );
      } else {
        rep.that(false, () => '$where: Sarrus on a non-3x3 frame');
      }
      rep.that(t.phase >= 1 && t.phase <= 3, () => '$where: phase ${t.phase}');
    case DeterminantDiagonalProductTransformation t:
      unchanged();
      rep.that(
        _sameList(t.diagonalElements, [
          for (var i = 0; i < min(before.rows, before.cols); i++)
            before.get(i, i),
        ]),
        () => '$where: diagonal ${t.diagonalElements}',
      );
      rep.that(
        t.sign == Rational.one || t.sign == Rational.minusOne,
        () => '$where: sign ${t.sign}',
      );
    case IdentitySeparationTransformation t:
      unchanged();
      rep.that(
        t.splitCol == before.augmentedColIndex &&
            t.splitCol * 2 == before.cols &&
            _columns(before.toMatrix(), 0, t.splitCol) ==
                _identity(before.rows),
        () => '$where: split at ${t.splitCol} of ${_showSnapshot(before)}',
      );
    case RankNullityTransformation t:
      unchanged();
      rep.that(
        t.rank + t.nullity == t.totalCols && t.totalCols == before.cols,
        () => '$where: rank ${t.rank} + nullity ${t.nullity} vs ${t.totalCols}',
      );
    case LUDecompositionTransformation t:
      unchanged();
      rep.that(
        _holds(t.uSnapshot, after.toMatrix()) &&
            _isUnitLowerTriangular(t.lSnapshot.toMatrix()),
        () =>
            '$where: L ${_showSnapshot(t.lSnapshot)}, '
            'U ${_showSnapshot(t.uSnapshot)}',
      );
    case InformationalStepTransformation():
    case LinearSystemTransformation():
    case EigenTransformation():
      unchanged();
  }
}

bool _sameList(List<Rational> a, List<Rational> b) =>
    a.length == b.length &&
    [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((e) => e);

// ---------------------------------------------------------------------------
// Operation checks
// ---------------------------------------------------------------------------

void _checkAddition(_Report rep, Matrix a, Matrix b, StepSolution s) {
  final expected = Matrix([
    for (var r = 0; r < a.rows; r++)
      [for (var c = 0; c < a.cols; c++) a.get(r, c) + b.get(r, c)],
  ]);
  rep.that(s.isSuccess && s.errorMessageKey == null, () => 'not a success');
  rep.that(
    s.result is Matrix && s.result == expected && s.finalMatrix == expected,
    () => 'A + B gave ${_show(s.finalMatrix)}, expected ${_show(expected)}',
  );
  rep.that(
    s.steps.length == a.rows * a.cols,
    () => '${s.steps.length} steps for ${a.rows * a.cols} cells',
  );
  for (final (i, step) in s.steps.indexed) {
    final t = step.transformation;
    final r = i ~/ a.cols;
    final c = i % a.cols;
    rep.that(
      t is MatrixElementAdditionTransformation &&
          t.row == r &&
          t.col == c &&
          t.left == a.get(r, c) &&
          t.right == b.get(r, c),
      () => 'step ${i + 1} does not add A($r,$c) and B($r,$c)',
    );
  }
  _checkRecord(rep, s, first: _zero(a.rows, a.cols), last: expected);
}

void _checkMultiplication(_Report rep, Matrix a, Matrix b, StepSolution s) {
  final expected = _product(a, b);
  rep.that(s.isSuccess && s.errorMessageKey == null, () => 'not a success');
  rep.that(
    s.result is Matrix && s.result == expected && s.finalMatrix == expected,
    () => 'AB gave ${_show(s.finalMatrix)}, expected ${_show(expected)}',
  );
  rep.that(
    s.steps.length == a.rows * b.cols,
    () => '${s.steps.length} steps for ${a.rows * b.cols} cells',
  );
  for (final (i, step) in s.steps.indexed) {
    final t = step.transformation;
    final r = i ~/ b.cols;
    final c = i % b.cols;
    rep.that(
      t is MatrixElementMultiplicationTransformation &&
          t.targetRow == r &&
          t.targetCol == c &&
          _sameList(t.rowElements, a.getRow(r)) &&
          _sameList(t.colElements, b.getCol(c)) &&
          t.result == expected.get(r, c),
      () => 'step ${i + 1} is not row $r of A times column $c of B',
    );
  }
  _checkRecord(rep, s, first: _zero(a.rows, b.cols), last: expected);
}

void _checkElimination(
  _Report rep,
  Matrix a,
  StepSolution s, {
  required bool reduced,
}) {
  final rref = _rref(a);
  final f = s.finalMatrix;
  rep.that(s.isSuccess, () => 'not a success');
  rep.that(
    s.result is Matrix && s.result == f && s.initialMatrix == a,
    () => 'result or initialMatrix differs from the matrices it names',
  );
  if (reduced) {
    rep.that(
      _isReducedRowEchelon(f) && f == rref,
      () => 'RREF ${_show(f)}, expected ${_show(rref)}',
    );
  } else {
    rep.that(
      _isRowEchelon(f, leadingOnes: true),
      () => '${_show(f)} is not in row echelon form with leading ones',
    );
    rep.that(
      _rref(f) == rref,
      () => 'REF ${_show(f)} is not row-equivalent to A (RREF ${_show(rref)})',
    );
  }
  _checkRecord(rep, s, first: a, last: f);
}

void _checkRank(_Report rep, Matrix a, StepSolution s) {
  final rref = _rref(a);
  final pivots = _leading(rref);
  final free = [
    for (var c = 0; c < a.cols; c++)
      if (!pivots.contains(c)) c,
  ];
  final result = s.result;
  rep.that(s.isSuccess, () => 'not a success');
  if (result is! RankNullityResult) {
    rep.that(false, () => 'result is ${result.runtimeType}');
    return;
  }
  rep.count('rank ${result.rank}');
  rep.that(
    result.rank == pivots.length &&
        result.nullity == a.cols - pivots.length &&
        result.totalCols == a.cols,
    () =>
        'rank ${result.rank}, nullity ${result.nullity}, cols '
        '${result.totalCols}; expected ${pivots.length}, '
        '${a.cols - pivots.length}, ${a.cols}',
  );
  rep.that(
    _sameInts(result.pivotColumnIndices, pivots) &&
        _sameInts(result.freeColumnIndices, free),
    () =>
        'pivots ${result.pivotColumnIndices}, free '
        '${result.freeColumnIndices}; expected $pivots, $free',
  );
  rep.that(s.finalMatrix == rref, () => 'final ${_show(s.finalMatrix)}');
  final summary = s.steps.lastOrNull?.transformation;
  rep.that(
    summary is RankNullityTransformation &&
        summary.rank == result.rank &&
        summary.nullity == result.nullity &&
        summary.totalCols == a.cols,
    () => 'the summary step disagrees with the result',
  );
  _checkRecord(rep, s, first: a, last: rref);
}

bool _sameInts(List<int> a, List<int> b) =>
    a.length == b.length &&
    [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((e) => e);

void _checkLinearSystem(_Report rep, Matrix augmented, StepSolution s) {
  final unknowns = augmented.cols - 1;
  final coefficients = _columns(augmented, 0, unknowns);
  final b = augmented.getCol(unknowns);
  final rankA = _rank(coefficients);
  final rankAb = _rank(augmented);
  final expectedType = rankA < rankAb
      ? LinearSystemType.inconsistent
      : rankA == unknowns
      ? LinearSystemType.unique
      : LinearSystemType.infinite;
  final result = s.result;
  rep.that(s.isSuccess, () => 'not a success');
  if (result is! LinearSystemResult) {
    rep.that(false, () => 'result is ${result.runtimeType}');
    return;
  }
  rep.count(result.type.name);
  rep.that(
    result.type == expectedType,
    () =>
        '${result.type}, but rank A = $rankA, rank [A|b] = $rankAb, '
        '$unknowns unknowns',
  );
  final f = s.finalMatrix;
  final coefficientRref = _rref(coefficients);
  rep.that(
    _columns(f, 0, unknowns) == coefficientRref && _rref(f) == _rref(augmented),
    () => 'final ${_show(f)} is not [RREF(A) | b\'] row-equivalent to [A|b]',
  );
  _checkLatex(rep, 'solutionLatex', result.solutionLatex);
  final summary = s.steps.lastOrNull?.transformation;
  rep.that(
    summary is LinearSystemTransformation && summary.type == result.type,
    () => 'the last step is not the ${result.type} summary',
  );
  final pivots = _leading(coefficientRref);
  final free = [
    for (var c = 0; c < unknowns; c++)
      if (!pivots.contains(c)) c,
  ];
  switch (result.type) {
    case LinearSystemType.unique:
      final x = result.uniqueSolution;
      if (x == null || x.length != unknowns) {
        rep.that(false, () => 'unique solution $x');
        break;
      }
      rep.that(
        _sameList(_apply(coefficients, x), b),
        () => 'Ax = ${_apply(coefficients, x)} for x = $x, b = $b',
      );
      rep.that(
        _sameInts(result.basicVariables, pivots) &&
            result.freeVariables.isEmpty,
        () => 'basic ${result.basicVariables}, free ${result.freeVariables}',
      );
      final parsed = _parseSolution(result.solutionLatex);
      rep.that(
        parsed != null &&
            parsed.length == 1 &&
            parsed.single.$1 == null &&
            _sameList(parsed.single.$2, x),
        () => 'solutionLatex ${result.solutionLatex} does not state x = $x',
      );
      rep.that(
        summary is LinearSystemTransformation &&
            summary.summaryLatex == result.solutionLatex &&
            s.resultLatex == result.solutionLatex,
        () => 'summary and resultLatex differ from solutionLatex',
      );
      final prose = [
        for (final (i, v) in x.indexed) 'x_{${i + 1}} = ${v.toLatex()}',
      ].join(', ');
      rep.that(
        s.steps.last.explanationParams['solution'] == prose,
        () => 'prose ${s.steps.last.explanationParams['solution']} vs $prose',
      );
    case LinearSystemType.infinite:
      rep.that(
        result.uniqueSolution == null &&
            _sameInts(result.basicVariables, pivots) &&
            _sameInts(result.freeVariables, free) &&
            free.isNotEmpty,
        () =>
            'basic ${result.basicVariables}, free ${result.freeVariables}; '
            'expected $pivots, $free',
      );
      final parsed = _parseSolution(result.solutionLatex);
      if (parsed == null || parsed.length != free.length + 1) {
        rep.that(
          false,
          () =>
              'cannot read ${free.length} parameters from '
              '${result.solutionLatex}',
        );
        break;
      }
      final (name0, particular) = parsed.first;
      rep.that(
        name0 == null &&
            particular.length == unknowns &&
            _sameList(_apply(coefficients, particular), b) &&
            free.every((c) => particular[c].isZero),
        () => 'particular solution $particular does not solve Ax = b',
      );
      final names = <String>{};
      for (final (i, (name, direction)) in parsed.skip(1).indexed) {
        rep.that(
          name != null &&
              names.add(name) &&
              direction.length == unknowns &&
              _sameList(
                _apply(coefficients, direction),
                List.filled(augmented.rows, Rational.zero),
              ) &&
              [
                for (final c in free)
                  direction[c] == (c == free[i] ? Rational.one : Rational.zero),
              ].every((e) => e),
          () =>
              'direction $name = $direction is not the null-space vector '
              'of x_${free[i] + 1}',
        );
      }
      rep.that(
        summary is LinearSystemTransformation &&
            summary.summaryLatex == result.solutionLatex &&
            s.resultLatex == result.solutionLatex,
        () => 'summary and resultLatex differ from solutionLatex',
      );
      rep.that(
        s.steps.last.titleParams['count'] == free.length &&
            s.steps.last.explanationParams['freeVars'] ==
                [for (final c in free) 'x_{${c + 1}}'].join(', '),
        () => 'free-variable prose ${s.steps.last.explanationParams}',
      );
    case LinearSystemType.inconsistent:
      rep.that(
        result.uniqueSolution == null &&
            result.basicVariables.isEmpty &&
            result.freeVariables.isEmpty,
        () => 'an inconsistent system reports variables',
      );
      final row = s.steps.last.titleParams['row'];
      rep.that(
        row is int &&
            row >= 1 &&
            row <= f.rows &&
            f.getRow(row - 1).take(unknowns).every((v) => v.isZero) &&
            !f.get(row - 1, unknowns).isZero,
        () => 'row $row of ${_show(f)} is not 0 = c with c ≠ 0',
      );
  }
  _checkRecord(
    rep,
    s,
    first: augmented,
    last: f,
    structure: MatrixStructureType.augmented,
    divider: unknowns,
  );
}

void _checkDeterminant(_Report rep, Matrix a, StepSolution s) {
  final n = a.rows;
  final det = _bareiss(a);
  if (n <= 4) {
    rep.that(det == _cofactor(a), () => 'reference determinants disagree');
  }
  if (det.isZero) rep.count('det 0');
  rep.that(s.isSuccess, () => 'not a success');
  rep.that(
    s.result is Rational && s.result == det && s.resultLatex == det.toLatex(),
    () => 'det ${s.result}, expected $det',
  );
  final steps = s.steps;
  if (n <= 3) {
    rep.that(steps.length == (n == 1 ? 1 : 3), () => '${steps.length} steps');
    for (final step in steps) {
      rep.that(
        _holds(step.matrixBefore, a) && _holds(step.matrixAfter, a),
        () => '${step.titleKey} does not show A',
      );
    }
    final last = steps.lastOrNull?.transformation;
    if (n == 2) {
      rep.that(
        last is DeterminantCrossProductTransformation &&
            last.phase == 3 &&
            last.mainDiagonalProduct - last.antiDiagonalProduct == det,
        () => 'the 2x2 formula does not give $det',
      );
    } else if (n == 3) {
      rep.that(
        last is DeterminantSarrusTransformation &&
            last.phase == 3 &&
            last.positiveProducts.fold(Rational.zero, (x, y) => x + y) -
                    last.negativeProducts.fold(
                      Rational.zero,
                      (x, y) => x + y,
                    ) ==
                det,
        () => 'the Sarrus products do not give $det',
      );
    }
    _checkRecord(rep, s, first: a, last: a);
    return;
  }
  final swaps = steps
      .where((step) => step.transformation is RowSwapTransformation)
      .length;
  final last = steps.lastOrNull;
  final f = s.finalMatrix;
  if (last?.titleKey == 'det_singular_column_title') {
    rep.count('det zero column');
    rep.that(det.isZero, () => 'a zero column was reported for det $det');
  } else {
    final t = last?.transformation;
    rep.that(
      t is DeterminantDiagonalProductTransformation &&
          t.sign == (swaps.isEven ? Rational.one : Rational.minusOne) &&
          t.diagonalElements.fold(t.sign, (x, y) => x * y) == det &&
          _isUpperTriangular(f),
      () =>
          'the triangular form ${_show(f)} with $swaps swaps does not give '
          '$det',
    );
  }
  _checkRecord(rep, s, first: a, last: f);
}

void _checkInverse(_Report rep, Matrix a, StepSolution s) {
  final n = a.rows;
  final det = _bareiss(a);
  if (det.isZero) {
    rep.count('singular');
    rep.that(
      !s.isSuccess &&
          s.errorMessageKey == 'error_matrix_is_singular' &&
          s.result == null &&
          s.steps.length == 1,
      () =>
          'singular: isSuccess ${s.isSuccess}, error ${s.errorMessageKey}, '
          'result ${s.result}, ${s.steps.length} steps',
    );
    _checkRecord(rep, s, first: a, last: a);
    return;
  }
  final inverse = s.result;
  rep.that(
    s.isSuccess && s.errorMessageKey == null,
    () =>
        'invertible (det $det) but isSuccess ${s.isSuccess}, '
        'error ${s.errorMessageKey}',
  );
  if (inverse is! Matrix) {
    rep.that(false, () => 'result is ${inverse.runtimeType}');
    return;
  }
  rep.that(
    inverse == s.finalMatrix &&
        _product(a, inverse) == _identity(n) &&
        _product(inverse, a) == _identity(n),
    () => 'A·A⁻¹ ≠ I for A⁻¹ = ${_show(inverse)}',
  );
  if (n == 2) {
    _checkRecord(rep, s, first: a, last: inverse);
    return;
  }
  // [A | I] is set up in the first step and [I | A⁻¹] is the last frame; the
  // result is its right block.
  rep.that(
    s.steps.last.transformation is IdentitySeparationTransformation,
    () => 'the last step does not separate A⁻¹',
  );
  _checkRecord(
    rep,
    s,
    first: _sideBySide(a, _identity(n)),
    last: _sideBySide(_identity(n), inverse),
    structure: MatrixStructureType.block,
    divider: n,
  );
}

void _checkLu(_Report rep, Matrix a, StepSolution s) {
  final n = a.rows;
  final result = s.result;
  rep.that(s.isSuccess, () => 'not a success');
  if (result is! LUResult) {
    rep.that(false, () => 'result is ${result.runtimeType}');
    return;
  }
  final l = result.lMatrix;
  final u = result.uMatrix;
  final p = result.pMatrix ?? _identity(n);
  if (_bareiss(a).isZero) rep.count('singular');
  if (result.isPermuted) rep.count('permuted');
  rep.that(
    (result.pMatrix == null) == !result.isPermuted,
    () => 'pMatrix ${result.pMatrix} with isPermuted ${result.isPermuted}',
  );
  rep.that(
    _isUnitLowerTriangular(l) &&
        _isUpperTriangular(u) &&
        _isPermutation(p) &&
        l.rows == n &&
        u.rows == n &&
        u.cols == n &&
        p.rows == n,
    () => 'L ${_show(l)}, U ${_show(u)}, P ${_show(p)} have the wrong form',
  );
  rep.that(
    _product(p, a) == _product(l, u),
    () => 'PA ≠ LU: L ${_show(l)}, U ${_show(u)}, P ${_show(p)}',
  );
  rep.that(s.finalMatrix == u, () => 'finalMatrix is not U');
  // PA = LU holds after every elimination, with the L the step carries and
  // P accumulated from the swaps before it.
  var perm = _identity(n).toList();
  for (final (i, step) in s.steps.indexed) {
    final t = step.transformation;
    final where = 'step ${i + 1} ${step.titleKey}';
    switch (t) {
      case RowSwapTransformation(:final rowA, :final rowB)
          when rowA >= 0 && rowA < n && rowB >= 0 && rowB < n:
        final swap = perm[rowA];
        perm[rowA] = perm[rowB];
        perm[rowB] = swap;
      case LUEliminationTransformation(:final lower):
        rep.that(
          _product(lower.toMatrix(), step.matrixAfter.toMatrix()) ==
              _product(Matrix(perm), a),
          () => '$where: P·A ≠ L·U with L ${_showSnapshot(lower)}',
        );
      case RowEliminationTransformation():
        rep.that(false, () => '$where: an elimination without its L entry');
      case LUDecompositionTransformation(:final lSnapshot, :final uSnapshot):
        final (lExpected, uExpected) = i == 0 ? (_identity(n), a) : (l, u);
        rep.that(
          _holds(lSnapshot, lExpected) && _holds(uSnapshot, uExpected),
          () =>
              '$where: L ${_showSnapshot(lSnapshot)}, '
              'U ${_showSnapshot(uSnapshot)}',
        );
      default:
        rep.that(false, () => '$where: unexpected ${t.runtimeType}');
    }
  }
  rep.that(Matrix(perm) == p, () => 'swaps give ${_show(Matrix(perm))}');
  rep.that(
    s.steps.first.transformation is LUDecompositionTransformation &&
        s.steps.last.transformation is LUDecompositionTransformation,
    () => 'the lesson does not open and close with L and U',
  );
  _checkRecord(rep, s, first: a, last: u);
}

void _checkEigen(_Report rep, Matrix a, StepSolution s) {
  final n = a.rows;
  final result = s.result;
  rep.that(s.isSuccess, () => 'not a success');
  if (result is! EigenResult) {
    rep.that(false, () => 'result is ${result.runtimeType}');
    return;
  }
  final characteristic = _characteristic(a);
  rep.that(
    result.characteristicPolynomial == characteristic,
    () =>
        'characteristic polynomial ${result.characteristicPolynomial}, '
        'expected $characteristic',
  );
  _checkLatex(rep, 'polynomial', result.characteristicPolynomialLatex);
  final pairs = result.eigenpairs;
  rep.that(
    pairs.fold(0, (sum, p) => sum + p.algebraicMultiplicity) == n,
    () => 'multiplicities ${[for (final p in pairs) p.algebraicMultiplicity]}',
  );
  final factors = <RationalPolynomial, int>{};
  for (final pair in pairs) {
    factors[pair.eigenvalue.minimalPolynomial] = pair.algebraicMultiplicity;
  }
  var product = RationalPolynomial.one;
  for (final MapEntry(key: m, value: k) in factors.entries) {
    for (var i = 0; i < k; i++) {
      product = product * m;
    }
  }
  rep.that(
    product == characteristic,
    () => 'factors multiply to $product, not $characteristic',
  );
  for (final pair in pairs) {
    final value = pair.eigenvalue;
    rep.count(
      value.isRational
          ? (pair.isDefective ? 'rational defective' : 'rational')
          : !value.isReal
          ? 'complex'
          : 'irrational degree ${value.degree}',
    );
    _checkLatex(rep, 'eigenvalue', value.latex);
    _checkLatex(rep, 'eigenvalue text', value.text);
    final field = value.field;
    final lambda = field.generator;
    rep.that(
      pair.eigenspaceBasis.isNotEmpty &&
          pair.geometricMultiplicity <= pair.algebraicMultiplicity,
      () =>
          '${value.text}: geometric ${pair.geometricMultiplicity}, '
          'algebraic ${pair.algebraicMultiplicity}',
    );
    for (final v in pair.eigenspaceBasis) {
      _checkLatex(rep, 'eigenvector', pair.vectorLatex(v));
      var zero = v.length == n && v.any((e) => !e.isZero);
      for (var r = 0; r < n && zero; r++) {
        var sum = field.zero;
        for (var c = 0; c < n; c++) {
          final entry = field.rational(a.get(r, c));
          sum += (r == c ? entry - lambda : entry) * v[c];
        }
        zero = sum.isZero;
      }
      rep.that(zero, () => '(A - λI)v ≠ 0 for λ = ${value.text}, v = $v');
    }
    final rational = value.rationalValue;
    if (rational != null) {
      final nullity = n - _rank(_shift(a, rational));
      final basis = Matrix([
        for (final v in pair.eigenspaceBasis) [for (final e in v) e[0]],
      ]);
      rep.that(
        pair.geometricMultiplicity == nullity &&
            _rank(basis) == pair.geometricMultiplicity,
        () =>
            'λ = $rational: basis of ${pair.geometricMultiplicity} for an '
            'eigenspace of dimension $nullity',
      );
    } else {
      rep.that(
        pair.algebraicMultiplicity == 1 && pair.geometricMultiplicity == 1,
        () => '${value.text} is irrational but repeated',
      );
    }
  }
  final rationalValues = [
    for (final p in pairs)
      if (p.eigenvalue.isRational) p.eigenvalue.rationalValue!,
  ];
  rep.that(
    _sameList([
      for (final p in result.realEigenpairs) p.eigenvalue,
    ], rationalValues),
    () =>
        'realEigenpairs ${[for (final p in result.realEigenpairs) p.eigenvalue]}',
  );
  for (final p in result.realEigenpairs) {
    rep.that(
      p.eigenvector.any((e) => !e.isZero) &&
          _sameList(_apply(a, p.eigenvector), [
            for (final e in p.eigenvector) e * p.eigenvalue,
          ]),
      () => 'Av ≠ λv for λ = ${p.eigenvalue}, v = ${p.eigenvector}',
    );
    _checkLatex(rep, 'vectorLatex', p.vectorLatex);
  }
  rep.that(
    result.hasComplexEigenvalues == pairs.any((p) => !p.eigenvalue.isReal),
    () => 'hasComplexEigenvalues ${result.hasComplexEigenvalues}',
  );
  // Eigen steps are explanations: each shows A, or A - λI for the rational λ
  // whose eigenvector it finds.
  final frames = [a, for (final r in rationalValues) _shift(a, r)];
  for (final (i, step) in s.steps.indexed) {
    rep.that(
      frames.any((m) => _holds(step.matrixAfter, m)),
      () =>
          'step ${i + 1} ${step.titleKey} shows '
          '${_showSnapshot(step.matrixAfter)}, neither A nor A - λI',
    );
    final t = step.transformation;
    if (t is EigenTransformation) {
      rep.that(
        _sameList(t.realEigenvalues, rationalValues),
        () => 'roots step lists ${t.realEigenvalues}, expected $rationalValues',
      );
    }
  }
  if (n == 2 && s.steps.isNotEmpty) {
    final calcs = s.steps.first.subCalculations;
    rep.that(
      calcs.length == 2 &&
          calcs[0].result == a.get(0, 0) + a.get(1, 1) &&
          calcs[1].result ==
              a.get(0, 0) * a.get(1, 1) - a.get(0, 1) * a.get(1, 0),
      () => 'trace and determinant sub-calculations',
    );
  }
  // The 2x2 trace and determinant sub-calculations are anchored on diagonal
  // cells but hold tr(A) and det(A), not those entries.
  _checkRecord(rep, s, continuous: false, cellCalculations: false);
}

// ---------------------------------------------------------------------------
// Fixed eigen cases: every kind of spectrum.
// ---------------------------------------------------------------------------

final _eigenCases = <int, List<List<List<int>>>>{
  2: [
    [
      [0, -1],
      [1, 0],
    ], // ±i
    [
      [1, 1],
      [0, 1],
    ], // defective
    [
      [1, 2],
      [3, 4],
    ], // surds
    [
      [3, 0],
      [0, 3],
    ], // scalar
    [
      [0, 0],
      [0, 0],
    ],
  ],
  3: [
    [
      [0, 0, 1],
      [1, 0, 3],
      [0, 1, 0],
    ], // x³ - 3x - 1: three real cubic roots
    [
      [0, 0, 2],
      [1, 0, 0],
      [0, 1, 0],
    ], // x³ - 2: Cardano
    [
      [2, 1, 0],
      [0, 2, 1],
      [0, 0, 2],
    ], // defective triple root
    [
      [1, 0, 0],
      [0, 0, -1],
      [0, 1, 0],
    ], // 1, ±i
    [
      [1, 0, 0],
      [0, 0, 2],
      [0, 1, 0],
    ], // 1, ±√2
    [
      [2, 0, 0],
      [0, 1, 1],
      [0, 1, 1],
    ], // 0 and a double 2 with a full eigenspace
  ],
};

// ---------------------------------------------------------------------------

void main() {
  tearDownAll(_printSummary);

  group('addition', () {
    for (var m = 1; m <= 5; m++) {
      for (var n = 1; n <= 5; n++) {
        test('${m}x$n + ${m}x$n', () {
          final rep = _Report('addition', '${m}x$n', largest: m == 5 && n == 5);
          final inputs = _Inputs(_seed('add', [m, n]));
          final kinds = _kinds(m, n);
          for (final (ka, kb) in _pairs(kinds, kinds)) {
            final a = inputs.matrix(ka, m, n);
            final b = inputs.matrix(kb, m, n);
            rep.begin('$ka+$kb', () => 'A = ${_show(a)}, B = ${_show(b)}');
            final s = rep.solve(() => MatrixArithmeticSolver.add(a, b));
            if (s != null) rep.run(() => _checkAddition(rep, a, b, s));
          }
          rep.done();
        });
      }
    }
  });

  group('multiplication', () {
    for (var m = 1; m <= 5; m++) {
      for (var k = 1; k <= 5; k++) {
        for (var n = 1; n <= 5; n++) {
          test('${m}x$k * ${k}x$n', () {
            final rep = _Report(
              'multiplication',
              '${m}x$k*${k}x$n',
              largest: m == 5 && k == 5 && n == 5,
            );
            final inputs = _Inputs(_seed('mul', [m, k, n]));
            for (final (ka, kb) in _pairs(_kinds(m, k), _kinds(k, n))) {
              final a = inputs.matrix(ka, m, k);
              final b = inputs.matrix(kb, k, n);
              rep.begin('$ka*$kb', () => 'A = ${_show(a)}, B = ${_show(b)}');
              final s = rep.solve(() => MatrixArithmeticSolver.multiply(a, b));
              if (s != null) rep.run(() => _checkMultiplication(rep, a, b, s));
            }
            rep.done();
          });
        }
      }
    }
  });

  for (final (op, reduced) in [('gauss', false), ('rref', true)]) {
    group(reduced ? 'Gauss-Jordan RREF' : 'Gaussian elimination REF', () {
      for (var m = 1; m <= 5; m++) {
        for (var n = 1; n <= 5; n++) {
          test('${m}x$n', () {
            final rep = _Report(op, '${m}x$n', largest: m == 5 && n == 5);
            final inputs = _Inputs(_seed(op, [m, n]));
            for (final kind in _kinds(m, n)) {
              final a = inputs.matrix(kind, m, n);
              rep.begin(kind, () => _show(a));
              final s = rep.solve(
                () => GaussJordanSolver.solve(
                  a,
                  EliminationOptions(toRref: reduced),
                ),
              );
              if (s != null) {
                rep.run(() => _checkElimination(rep, a, s, reduced: reduced));
              }
            }
            rep.done();
          });
        }
      }
    });
  }

  group('rank and nullity', () {
    for (var m = 1; m <= 5; m++) {
      for (var n = 1; n <= 5; n++) {
        test('${m}x$n', () {
          final rep = _Report('rank', '${m}x$n', largest: m == 5 && n == 5);
          final inputs = _Inputs(_seed('rank', [m, n]));
          for (final kind in _kinds(m, n)) {
            final a = inputs.matrix(kind, m, n);
            rep.begin(kind, () => _show(a));
            final s = rep.solve(() => RankNullitySolver.solve(a));
            if (s != null) rep.run(() => _checkRank(rep, a, s));
          }
          rep.done();
        });
      }
    }
  });

  group('linear systems', () {
    for (var m = 1; m <= 5; m++) {
      for (var c = 2; c <= 5; c++) {
        test('${m}x$c augmented (${c - 1} unknowns)', () {
          final rep = _Report('linear', '${m}x$c', largest: m == 5 && c == 5);
          final inputs = _Inputs(_seed('linear', [m, c]));
          final unknowns = c - 1;
          void solve(String kind, Matrix augmented) {
            rep.begin(kind, () => _show(augmented));
            final s = rep.solve(() => LinearSystemsSolver.solve(augmented));
            if (s != null) rep.run(() => _checkLinearSystem(rep, augmented, s));
          }

          for (final kind in _kinds(m, c)) {
            // The whole [A | b] of this kind, usually inconsistent when A is
            // rank deficient.
            solve(kind, inputs.matrix(kind, m, c));
            if (!_applies(kind, m, unknowns)) continue;
            // A of this kind with b = A·x₀, always consistent.
            final a = inputs.matrix(kind, m, unknowns);
            final b = _apply(a, inputs.intVector(unknowns));
            solve(
              '$kind, b = Ax0',
              _sideBySide(
                a,
                Matrix([
                  for (final v in b) [v],
                ]),
              ),
            );
            // The homogeneous system.
            solve('$kind, b = 0', _sideBySide(a, _zero(m, 1)));
          }
          rep.done();
        });
      }
    }
  });

  for (final op in ['determinant', 'inverse', 'lu']) {
    group(op, () {
      for (var n = 1; n <= 5; n++) {
        test('${n}x$n', () {
          final rep = _Report(op, '${n}x$n', largest: n == 5);
          final inputs = _Inputs(_seed(op, [n]));
          final kinds = [
            ..._kinds(n, n),
            // More random matrices, a third of them singular by a repeated
            // row, for the swap and singular paths of each solver.
            for (var i = 0; i < 6; i++) ...['int', 'sparse'],
            if (n >= 2) ...['dupRow', 'dupRow'],
          ];
          for (final kind in kinds) {
            final a = inputs.matrix(kind, n, n);
            rep.begin(kind, () => _show(a));
            final s = rep.solve(
              () => switch (op) {
                'determinant' => DeterminantSolver.solve(a),
                'inverse' => InverseSolver.solve(a),
                _ => LUDecompositionSolver.solve(a),
              },
            );
            if (s == null) continue;
            rep.run(() {
              switch (op) {
                case 'determinant':
                  _checkDeterminant(rep, a, s);
                case 'inverse':
                  _checkInverse(rep, a, s);
                default:
                  _checkLu(rep, a, s);
              }
            });
          }
          rep.done();
        });
      }
    });
  }

  group('eigen', () {
    for (final n in [2, 3]) {
      test('${n}x$n', () {
        final rep = _Report('eigen', '${n}x$n', largest: n == 3);
        final inputs = _Inputs(_seed('eigen', [n]));
        final matrices = [
          for (final kind in _kinds(n, n)) (kind, inputs.matrix(kind, n, n)),
          for (final data in _eigenCases[n]!) ('fixed', Matrix.fromInts(data)),
        ];
        for (final (kind, a) in matrices) {
          rep.begin(kind, () => _show(a));
          final s = rep.solve(() => EigenSolver.solve(a));
          if (s != null) rep.run(() => _checkEigen(rep, a, s));
        }
        rep.done();
      });
    }

    test('other sizes are reported unsupported, as documented', () {
      for (final n in [1, 4, 5]) {
        final s = EigenSolver.solve(_identity(n));
        expect(s.isSuccess, isFalse);
        expect(s.completeness, ResultCompleteness.unsupported);
        expect(s.steps, isEmpty);
      }
    });
  });
}
