import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/core/theme/app_theme.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/features/matrix_input/matrix_input_cubit.dart';
import 'package:matriks/features/matrix_input/views/matrix_input_screen.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/settings/cubit/settings_state.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/step_player/result_check.dart';
import 'package:matriks/features/step_player/step_text.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/step_player/widgets/matrix_cell_widget.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/features/topics/models/topic_item.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

/// Matrix shapes the editor allows, rendered in the player and the editor.
/// This file runs a representative subset ([suiteRuns]: every topic, the
/// extreme shapes 1×1, 1×5, 5×1 and 5×5 and a mixed one, every step);
/// tool/all_shapes_sweep_test.dart imports the same checks and runs every
/// shape.

final l10nEn = lookupAppLocalizations(const Locale('en'));

/// Loads flutter_math's KaTeX fonts, so formulas are measured as the app
/// draws them. Without them every glyph is the test font's 1 em square,
/// which makes a formula about twice as wide as on screen. Prose still uses
/// the test font.
Future<void> loadMathFonts() async {
  final manifest = jsonDecode(await rootBundle.loadString('FontManifest.json'));
  for (final entry in (manifest as List).cast<Map<String, dynamic>>()) {
    final family = entry['family'] as String;
    if (!family.startsWith('packages/flutter_math_fork/')) continue;
    final loader = FontLoader(family);
    for (final font in (entry['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

/// Topics that open the matrix editor; the other two have their own screens.
const editorTopics = [
  TopicType.add,
  TopicType.multiply,
  TopicType.gauss,
  TopicType.rref,
  TopicType.linearSystems,
  TopicType.determinant,
  TopicType.inverse,
  TopicType.rankNullity,
  TopicType.lu,
  TopicType.eigen,
];

// Integers and fractions, including the repeating decimals 1/3, 1/6, 1/7,
// 2/3 and -2/7, and a zero that forces pivot searches.
final _palette = [
  for (final (n, d) in const [
    (2, 1),
    (-1, 1),
    (1, 3),
    (4, 1),
    (-2, 7),
    (3, 1),
    (0, 1),
    (5, 2),
    (-3, 1),
    (1, 7),
    (1, 1),
    (-3, 4),
    (6, 1),
    (2, 3),
    (-5, 1),
    (1, 6),
  ])
    Rational(BigInt.from(n), BigInt.from(d)),
];

/// A deterministic mix of integers and fractions; [seed] gives a different
/// matrix of the same shape.
Matrix sampleMatrix(int rows, int cols, {int seed = 0}) => Matrix([
  for (var r = 0; r < rows; r++)
    [
      for (var c = 0; c < cols; c++)
        _palette[(r * 7 + c * 3 + r * c + seed * 5) % _palette.length],
    ],
]);

Rational _det(Matrix m) => DeterminantSolver.solve(m).result as Rational;

/// [sampleMatrix] with its diagonal raised until it is invertible.
Matrix invertibleMatrix(int n, {int seed = 0}) {
  var rows = sampleMatrix(n, n, seed: seed).toList();
  for (var bump = 0; _det(Matrix(rows)).isZero; bump++) {
    rows = [
      for (var r = 0; r < n; r++)
        [
          for (var c = 0; c < n; c++)
            r == c ? rows[r][c] + Rational.one : rows[r][c],
        ],
    ];
  }
  return Matrix(rows);
}

/// A singular n×n matrix with fractions: 1×1 is [0], 2×2 has a second row
/// 2/3 of the first, larger ones a last row equal to the sum of the first
/// two.
Matrix singularMatrix(int n) {
  if (n == 1) {
    return Matrix.fromInts([
      [0],
    ]);
  }
  final rows = sampleMatrix(n, n, seed: 2).toList();
  final last = n == 2
      ? [for (final v in rows[0]) v * Rational(BigInt.two, BigInt.from(3))]
      : [for (var c = 0; c < n; c++) rows[0][c] + rows[1][c]];
  rows[n - 1] = last;
  final matrix = Matrix(rows);
  assert(_det(matrix).isZero);
  return matrix;
}

/// [m]×[cols] augmented system whose last row reads 0 = 1/3.
Matrix inconsistentSystem(int m, int cols) {
  final rows = sampleMatrix(m, cols, seed: 3).toList();
  rows[m - 1] = [
    for (var c = 0; c < cols; c++)
      c == cols - 1 ? Rational(BigInt.one, BigInt.from(3)) : Rational.zero,
  ];
  return Matrix(rows);
}

/// The solution the editor's Solve button computes for [topic].
StepSolution solveFor(TopicType topic, Matrix a, [Matrix? b]) =>
    switch (topic) {
      TopicType.gauss => GaussJordanSolver.solve(
        a,
        const EliminationOptions(toRref: false),
      ),
      TopicType.rref => GaussJordanSolver.solve(
        a,
        const EliminationOptions(toRref: true),
      ),
      TopicType.linearSystems => LinearSystemsSolver.solve(a),
      TopicType.determinant => DeterminantSolver.solve(a),
      TopicType.inverse => InverseSolver.solve(a),
      TopicType.rankNullity => RankNullitySolver.solve(a),
      TopicType.eigen => EigenSolver.solve(a),
      TopicType.lu => LUDecompositionSolver.solve(a),
      TopicType.add => MatrixArithmeticSolver.add(a, b!),
      TopicType.multiply => MatrixArithmeticSolver.multiply(a, b!),
      TopicType.transform2d ||
      TopicType.practice => throw ArgumentError('$topic has no matrix solver'),
    };

/// One lesson: a topic and the input the learner typed.
class ShapeCase {
  final TopicType topic;
  final String name;
  final Matrix a;
  final Matrix? b;

  /// The largest shape of its topic, also rendered at 320×568 and 200% text.
  final bool largest;

  ShapeCase(this.topic, this.name, this.a, {this.b, this.largest = false});

  late final StepSolution solution = solveFor(topic, a, b);

  @override
  String toString() => name;
}

String _shape(Matrix m) => '${m.rows}x${m.cols}';

/// Eigen inputs: the shape alone would test one path, so each size also
/// gets integer, irrational, complex, repeated and cubic spectra.
List<ShapeCase> eigenCases() {
  ShapeCase eigen(String what, List<List<int>> rows, {bool largest = false}) {
    final m = Matrix.fromInts(rows);
    return ShapeCase(
      TopicType.eigen,
      'eigen ${_shape(m)} $what',
      m,
      largest: largest,
    );
  }

  return [
    ShapeCase(TopicType.eigen, 'eigen 2x2 sample', sampleMatrix(2, 2)),
    eigen('integer', [
      [4, 1],
      [2, 3],
    ]),
    eigen('golden (sqrt 5)', [
      [1, 1],
      [1, 0],
    ]),
    eigen('complex', [
      [0, -1],
      [1, 0],
    ]),
    eigen('defective', [
      [1, 1],
      [0, 1],
    ]),
    ShapeCase(
      TopicType.eigen,
      'eigen 2x2 fractions',
      Matrix([
        [Rational(BigInt.one, BigInt.from(3)), Rational(BigInt.from(2))],
        [Rational(BigInt.one, BigInt.from(7)), Rational(BigInt.from(-1))],
      ]),
    ),
    ShapeCase(
      TopicType.eigen,
      'eigen 3x3 sample',
      sampleMatrix(3, 3),
      largest: true,
    ),
    eigen('integer', [
      [2, 0, 0],
      [0, 3, 4],
      [0, 4, 9],
    ]),
    eigen('three real cubic roots', [
      [0, 1, 0],
      [0, 0, 1],
      [1, 3, 0],
    ], largest: true),
    eigen('cube root and complex pair', [
      [0, 1, 0],
      [0, 0, 1],
      [2, 0, 0],
    ], largest: true),
    eigen('repeated', [
      [2, 1, 0],
      [0, 2, 0],
      [0, 0, 3],
    ]),
  ];
}

/// Every shape the editor allows, for every topic.
List<ShapeCase> allShapeCases() {
  final cases = <ShapeCase>[];
  for (var m = 1; m <= 5; m++) {
    for (var n = 1; n <= 5; n++) {
      final largest = m == 5 && n == 5;
      cases.add(
        ShapeCase(
          TopicType.add,
          'add ${m}x$n',
          sampleMatrix(m, n),
          b: sampleMatrix(m, n, seed: 1),
          largest: largest,
        ),
      );
      for (var k = 1; k <= 5; k++) {
        cases.add(
          ShapeCase(
            TopicType.multiply,
            'multiply ${m}x$k*${k}x$n',
            sampleMatrix(m, k),
            b: sampleMatrix(k, n, seed: 1),
            largest: largest && k == 5,
          ),
        );
      }
      for (final topic in [
        TopicType.gauss,
        TopicType.rref,
        TopicType.rankNullity,
      ]) {
        cases.add(
          ShapeCase(
            topic,
            '${topic.name} ${m}x$n',
            sampleMatrix(m, n),
            largest: largest,
          ),
        );
      }
      if (n >= 2) {
        cases.add(
          ShapeCase(
            TopicType.linearSystems,
            'linearSystems ${m}x$n',
            sampleMatrix(m, n),
            largest: largest,
          ),
        );
        cases.add(
          ShapeCase(
            TopicType.linearSystems,
            'linearSystems ${m}x$n inconsistent',
            inconsistentSystem(m, n),
            largest: largest,
          ),
        );
      }
    }
    cases.addAll(squareCases(m));
  }
  cases.addAll(eigenCases());
  return cases;
}

/// Signed 8-digit fractions, well within the editor's 32 characters a cell.
Matrix longEntryMatrix(int rows, int cols, {int seed = 0}) => Matrix([
  for (var r = 0; r < rows; r++)
    [
      for (var c = 0; c < cols; c++)
        Rational(
          BigInt.from(
            ((r + c + seed).isEven ? -1 : 1) *
                (12345678 + 1111 * (r * cols + c) + 7 * seed),
          ),
          BigInt.from(87654321 - 999 * (r + 7 * c + seed)),
        ),
    ],
]);

/// The largest shape of every topic with [longEntryMatrix] input, for the
/// sweep: the widest cells and formulas the editor can produce.
List<ShapeCase> longEntryCases() {
  ShapeCase long(TopicType topic, int rows, int cols, {int? colsB}) =>
      ShapeCase(
        topic,
        '${topic.name} ${rows}x$cols${colsB == null ? '' : '*${cols}x$colsB'} '
        'long entries',
        longEntryMatrix(rows, cols),
        b: colsB == null ? null : longEntryMatrix(cols, colsB, seed: 1),
        largest: true,
      );
  return [
    ShapeCase(
      TopicType.add,
      'add 5x5 long entries',
      longEntryMatrix(5, 5),
      b: longEntryMatrix(5, 5, seed: 1),
      largest: true,
    ),
    long(TopicType.multiply, 5, 5, colsB: 5),
    for (final topic in [
      TopicType.gauss,
      TopicType.rref,
      TopicType.rankNullity,
      TopicType.linearSystems,
      TopicType.determinant,
      TopicType.inverse,
      TopicType.lu,
    ])
      long(topic, 5, 5),
    // 2×2 and 3×3 determinants draw formula scenes (Sarrus copies).
    long(TopicType.determinant, 2, 2),
    long(TopicType.determinant, 3, 3),
    long(TopicType.inverse, 2, 2),
    long(TopicType.eigen, 2, 2),
    long(TopicType.eigen, 3, 3),
    for (final topic in [TopicType.determinant, TopicType.inverse])
      ShapeCase(
        topic,
        '${topic.name} 3x3 long decimals',
        longDecimalMatrix(3),
        largest: true,
      ),
  ];
}

/// Terminating decimals with eight digits after the point, such as
/// -1234.56789012, whose decimal view is long but exact.
Matrix longDecimalMatrix(int n) => Matrix([
  for (var r = 0; r < n; r++)
    [
      for (var c = 0; c < n; c++)
        Rational(
          BigInt.from(
            ((r + c).isEven ? 1 : -1) *
                // The diagonal term keeps the matrix invertible.
                (123456789012 +
                    1000003 * (r * n + c) +
                    (r == c ? 7000000000 * (r + 1) : 0)),
          ),
          BigInt.from(100000000),
        ),
    ],
]);

/// Determinant, inverse and LU of one size, with a singular input as well.
List<ShapeCase> squareCases(int n) => [
  for (final topic in [
    TopicType.determinant,
    TopicType.inverse,
    TopicType.lu,
  ]) ...[
    ShapeCase(
      topic,
      '${topic.name} ${n}x$n',
      invertibleMatrix(n),
      largest: n == 5,
    ),
    ShapeCase(
      topic,
      '${topic.name} ${n}x$n singular',
      singularMatrix(n),
      largest: n == 5,
    ),
  ],
];

typedef Viewport = ({String name, Size size, double scale, bool detailed});

/// Phone and desktop at 100% text. The desktop run opens the details drawer
/// (detailed explanations) so its formulas are rendered too.
const Viewport phone = (
  name: '390x844',
  size: Size(390, 844),
  scale: 1,
  detailed: false,
);
const Viewport desktop = (
  name: '1280x800',
  size: Size(1280, 800),
  scale: 1,
  detailed: true,
);
const Viewport smallLargeText = (
  name: '320x568@2x',
  size: Size(320, 568),
  scale: 2,
  detailed: false,
);

/// One player run: a lesson at one viewport in the given number views.
typedef PlayerRun = ({ShapeCase shape, Viewport viewport, List<bool> decimals});

const _both = [false, true];
const _fractions = [false];
const _decimals = [true];

/// The subset the normal suite renders: every topic at 1×1, 1×5, 5×1, a
/// mixed shape and 5×5 (square topics: 1, 2, 3 and 5, and a singular 5×5;
/// eigen: every spectrum), each with every step and the result. Each input
/// is rendered once, and the runs of a topic together cover both number
/// views and all three viewports; the largest shape takes 320×568 at 200%
/// text. tool/all_shapes_sweep_test.dart renders every input everywhere.
List<PlayerRun> suiteRuns() {
  final byName = {for (final c in allShapeCases()) c.name: c};
  PlayerRun run(String name, Viewport viewport, List<bool> decimals) =>
      (shape: byName[name]!, viewport: viewport, decimals: decimals);
  List<PlayerRun> rectangular(String topic, String mixed) => [
    run('$topic 1x1', phone, _both),
    run('$topic 1x5', desktop, _decimals),
    run('$topic 5x1', phone, _decimals),
    run('$topic $mixed', desktop, _both),
    run('$topic 5x5', smallLargeText, _fractions),
  ];
  List<PlayerRun> square(String topic) => [
    run('$topic 1x1', phone, _both),
    run('$topic 2x2', desktop, _decimals),
    run('$topic 3x3', phone, _decimals),
    run('$topic 2x2 singular', desktop, _both),
    run('$topic 5x5', smallLargeText, _fractions),
    run('$topic 5x5 singular', phone, _fractions),
  ];
  return [
    ...rectangular('add', '2x3'),
    run('multiply 1x1*1x1', phone, _both),
    run('multiply 1x5*5x1', desktop, _decimals),
    run('multiply 5x1*1x5', phone, _decimals),
    run('multiply 2x3*3x4', desktop, _both),
    run('multiply 5x5*5x5', smallLargeText, _fractions),
    ...rectangular('gauss', '2x3'),
    ...rectangular('rref', '2x3'),
    ...rectangular('rankNullity', '4x3'),
    run('linearSystems 1x2', phone, _both),
    run('linearSystems 1x5', desktop, _decimals),
    run('linearSystems 5x2', phone, _decimals),
    run('linearSystems 3x4', desktop, _both),
    run('linearSystems 3x4 inconsistent', phone, _fractions),
    run('linearSystems 5x5', smallLargeText, _fractions),
    ...square('determinant'),
    ...square('inverse'),
    ...square('lu'),
    for (final shape in eigenCases())
      (
        shape: shape,
        viewport: shape.a.rows == 2 ? phone : desktop,
        decimals: _both,
      ),
    run('eigen 3x3 three real cubic roots', smallLargeText, _fractions),
  ];
}

Widget shapesHost(
  Widget home,
  SettingsCubit settings, {
  double scale = 1,
  String language = 'en',
}) => BlocProvider.value(
  value: settings,
  child: MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: Locale(language),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: home,
  ),
);

/// The cubit of the player on screen.
PlayerCubit playerOf(WidgetTester tester) =>
    BlocProvider.of<PlayerCubit>(tester.element(find.byType(Scaffold).first));

/// Collects problems by message, remembering where each was first seen.
class Findings {
  final Map<String, List<String>> _where = {};
  int frames = 0;

  void add(String where, Iterable<String> problems) {
    for (final problem in problems) {
      (_where[problem] ??= []).add(where);
    }
  }

  bool get isEmpty => _where.isEmpty;

  void addAll(Findings other) {
    frames += other.frames;
    other._where.forEach((problem, where) {
      (_where[problem] ??= []).addAll(where);
    });
  }

  @override
  String toString() => [
    for (final MapEntry(key: problem, value: where) in _where.entries)
      '- $problem\n    at ${where.take(4).join('; ')}'
          '${where.length > 4 ? ' (+${where.length - 4} more)' : ''}',
  ].join('\n');
}

/// App widgets named in an error's creator chain, nearest first, so a
/// report says where in the screen a formula or row overflowed.
const _appWidgets = [
  'MatrixCellWidget',
  'MultiplicationSources',
  'InstructionExplanation',
  'StepDetails',
  'StepCard',
  'RoleLegend',
  'ResultChecks',
  'SolutionStatus',
  'SolutionSummary',
  'CellCalculationSheet',
  'PlayerControlBar',
  'MatrixDisplayGrid',
  'StepPlayerScreen',
  'MatrixInputScreen',
];

/// The first line of a reported error, without object hashes, and the app
/// widgets around the render object it names. Called when the error is
/// reported: afterwards the element may be gone, and describing it then
/// reports an error of its own.
String describeError(FlutterErrorDetails details) {
  final first = details
      .exceptionAsString()
      .split('\n')
      .first
      .trim()
      .replaceAll(RegExp(r'#[0-9a-f]{5}'), '');
  final names = <String>[];
  for (final node
      in details.informationCollector?.call() ?? const <DiagnosticsNode>[]) {
    final creator = switch (node.value) {
      RenderObject(:final DebugCreator debugCreator) => debugCreator,
      _ => null,
    };
    if (creator == null) continue;
    creator.element.visitAncestorElements((element) {
      final name = element.widget.runtimeType.toString();
      if (_appWidgets.contains(name) && !names.contains(name)) names.add(name);
      return names.length < 3;
    });
    break;
  }
  final where = names.isEmpty ? '' : ' in ${names.join(' < ')}';
  return 'error: $first$where';
}

// A backslash command, an index or exponent group, a brace, or an alignment
// '&' between entries; "Eigenvalues & Eigenvectors" is prose.
final _rawTex = RegExp(r'\\|_\{|\^\{|[{}]|[\d)}\]]\s*&\s*[-\d(\\{]');
const _forbiddenText = ['≈', 'NaN', 'Infinity', 'e+'];

/// Errors reported since the last frame, text that should never be shown,
/// and TeX left in semantics.
List<String> screenProblems(WidgetTester tester, List<String> errors) {
  final out = [...errors];
  errors.clear();
  final pending = tester.takeException();
  if (pending != null) out.add('exception: ${'$pending'.split('\n').first}');

  for (final element in find.byType(RichText).evaluate()) {
    final text = (element.widget as RichText).text.toPlainText();
    for (final bad in _forbiddenText) {
      if (text.contains(bad)) out.add('text shows "$bad": "$text"');
    }
    if (text.contains(r'\')) out.add('TeX drawn as plain text: "$text"');
  }
  for (final element in find.byType(MathText).evaluate()) {
    final latex = (element.widget as MathText).latex;
    for (final bad in [r'\approx', ..._forbiddenText]) {
      if (latex.contains(bad)) out.add('formula shows "$bad": "$latex"');
    }
  }
  for (final node in find.semantics.byPredicate((_) => true).evaluate()) {
    for (final (kind, text) in [
      ('label', node.label),
      ('value', node.value),
      ('hint', node.hint),
      ('tooltip', node.tooltip),
    ]) {
      if (_rawTex.hasMatch(text)) out.add('TeX in semantics $kind: "$text"');
      for (final bad in _forbiddenText) {
        if (text.contains(bad)) out.add('semantics $kind has "$bad": "$text"');
      }
    }
  }
  return out;
}

bool _isDivider(Widget w) =>
    w is Container &&
    w.constraints == const BoxConstraints.tightFor(width: 2, height: 42);

/// The player's matrix shows exactly [snapshot]: rows×cols cells with its
/// values, in the chosen number view, and the augmented divider after the
/// coefficient columns. With a null [snapshot] no matrix may be drawn.
List<String> gridProblems(
  WidgetTester tester,
  MatrixSnapshot? snapshot, {
  required bool decimal,
}) {
  final out = <String>[];
  final grids = find.byType(MatrixDisplayGrid);
  final count = grids.evaluate().length;
  if (snapshot == null) {
    if (count != 0) out.add('a matrix is drawn where none belongs');
    return out;
  }
  if (count != 1) return ['expected one matrix grid, found $count'];
  final rows = snapshot.rows;
  final cols = snapshot.cols;
  final cellFinder = find.descendant(
    of: grids,
    matching: find.byType(MatrixCellWidget),
  );
  final cells = [
    for (final e in cellFinder.evaluate()) e.widget as MatrixCellWidget,
  ];
  if (cells.length != rows * cols) {
    return ['grid shows ${cells.length} cells for a ${rows}x$cols snapshot'];
  }
  for (var i = 0; i < cells.length; i++) {
    final expected = snapshot.get(i ~/ cols, i % cols);
    if (cells[i].value != expected) {
      out.add(
        'cell (${i ~/ cols + 1}, ${i % cols + 1}) shows ${cells[i].value}, '
        'snapshot has $expected',
      );
    }
    if (cells[i].isDecimalView != decimal) {
      out.add('cell ${i + 1} ignores the number view');
    }
  }
  final aug = snapshot.augmentedColIndex;
  final dividers = find.descendant(
    of: grids,
    matching: find.byWidgetPredicate(_isDivider),
  );
  final dividerCount = dividers.evaluate().length;
  if (aug != null && (aug < 1 || aug >= cols)) {
    out.add('augmented divider index $aug outside 1..${cols - 1}');
  }
  final expectedDividers = aug != null && aug >= 1 && aug < cols ? rows : 0;
  if (dividerCount != expectedDividers) {
    out.add('expected $expectedDividers divider(s), found $dividerCount');
  } else if (expectedDividers > 0) {
    final line = tester.getRect(dividers.first);
    final left = tester.getRect(cellFinder.at(aug! - 1));
    final right = tester.getRect(cellFinder.at(aug));
    if (line.left < left.right - .5 || line.right > right.left + .5) {
      out.add('divider is not between columns $aug and ${aug + 1}');
    }
  }
  return out;
}

/// Result view: every independent check holds and an error is stated.
List<String> resultProblems(
  WidgetTester tester,
  StepSolution solution, {
  required bool decimal,
}) {
  final l = l10nEn;
  final out = <String>[];
  final checks = resultChecks(solution, l);
  for (final check in checks) {
    if (!check.holds) out.add('check fails: ${check.latex}');
  }
  final fails = find.text(l.checkFails).evaluate().length;
  if (fails > 0) out.add('"${l.checkFails}" shown $fails time(s)');
  final holds = find.text(l.checkHolds).evaluate().length;
  if (holds != checks.length) {
    out.add('expected ${checks.length} "${l.checkHolds}", found $holds');
  }
  if (!solution.isSuccess) {
    final message = localizedSolverError(l, solution.errorMessageKey);
    if (find.text(message).evaluate().isEmpty) {
      out.add('error message "$message" not shown');
    }
  } else if (solution.result case LinearSystemResult(
    type: LinearSystemType.inconsistent,
  )) {
    // Stated in the learner's language, not as the engine's English TeX.
    if (find.text(l.systemNoSolution).evaluate().isEmpty) {
      out.add('"${l.systemNoSolution}" not shown');
    }
  } else if (solution.resultLatex != null && solution.result is! Matrix) {
    if (find.byType(MathText).evaluate().isEmpty) out.add('no result shown');
  }
  out.addAll(
    gridProblems(
      tester,
      solution.isSuccess && solution.result is Matrix
          ? MatrixSnapshot.fromMatrix(solution.finalMatrix)
          : null,
      decimal: decimal,
    ),
  );
  return out;
}

/// A step's title and text come from translations, not raw solver keys.
List<String> stepTextProblems(MatrixStep step) {
  final l = l10nEn;
  return [
    if (localizedStepText(l, step.titleKey, step.titleParams) == step.titleKey)
      'untranslated step title key "${step.titleKey}"',
    if (localizedStepText(l, step.explanationKey, step.explanationParams) ==
        step.explanationKey)
      'untranslated step text key "${step.explanationKey}"',
  ];
}

/// Runs [body] with every framework error it causes kept in a list rather
/// than failing the test at the first, so one frame with several overflows
/// is reported in full. The test's handler is back before the caller checks
/// the result, so a failing expect is reported as usual.
Future<T> collectingErrors<T>(
  Future<T> Function(List<String> errors) body,
) async {
  final errors = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) => errors.add(describeError(details));
  try {
    return await body(errors);
  } finally {
    FlutterError.onError = previous;
  }
}

/// Renders [shape] in static steps and visits every step and then the
/// result, once per number view in [decimals] (fractions, then decimals).
Future<Findings> verifyPlayer(
  WidgetTester tester,
  ShapeCase shape,
  Viewport viewport,
  List<String> errors, {
  List<bool> decimals = const [false, true],
}) async {
  final findings = Findings();
  final solution = shape.solution;
  final checks = resultChecks(solution, l10nEn);
  tester.view.physicalSize = viewport.size;
  tester.view.devicePixelRatio = 1;
  final settings = SettingsCubit(
    initial: SettingsState(
      solutionMode: SolutionMode.steps,
      explanationLevel: viewport.detailed
          ? ExplanationLevel.detailed
          : ExplanationLevel.short,
    ),
  );
  await tester.pumpWidget(
    shapesHost(
      StepPlayerScreen(
        solution: solution,
        topicTitle: TopicItem.of(shape.topic).title(l10nEn),
      ),
      settings,
      scale: viewport.scale,
    ),
  );
  await tester.pump(Duration.zero);
  final player = playerOf(tester);
  final total = solution.steps.length;
  if (total == 0) findings.add('$shape', ['solution has no steps']);
  for (final decimal in decimals) {
    if (settings.state.isDecimalView != decimal) settings.toggleDecimalView();
    final view = decimal ? 'decimal' : 'fraction';
    for (var i = 0; i < total; i++) {
      player.jumpToStep(i);
      // A cubit delivers its state in a microtask. A bare pump() draws a
      // frame only if one is already scheduled and flushes microtasks after
      // it, so it can show the previous state; Duration.zero flushes first.
      // Every pump in this file does the same.
      await tester.pump(Duration.zero);
      final step = solution.steps[i];
      final holds = find.text(l10nEn.checkHolds).evaluate().length;
      findings.frames++;
      findings.add('$shape @${viewport.name} $view step ${i + 1}/$total', [
        if (player.state.currentStepIndex != i ||
            player.state.mode != SolutionMode.steps)
          'player is not on static step ${i + 1}',
        ...screenProblems(tester, errors),
        ...gridProblems(tester, step.matrixAfter, decimal: decimal),
        ...stepTextProblems(step),
        if (find.text(l10nEn.checkFails).evaluate().isNotEmpty)
          'the lesson shows "${l10nEn.checkFails}"',
        // The finished lesson repeats the result's checks.
        if (i == total - 1 && holds != checks.length)
          'last step shows $holds "${l10nEn.checkHolds}" for '
              '${checks.length} checks',
      ]);
    }
    player.showResult();
    await tester.pump(Duration.zero);
    findings.frames++;
    findings.add('$shape @${viewport.name} $view result', [
      ...screenProblems(tester, errors),
      ...resultProblems(tester, solution, decimal: decimal),
    ]);
  }
  // Unmount before the settings close.
  await tester.pumpWidget(const SizedBox.shrink());
  await settings.close();
  return findings;
}

/// The viewports [shape] is rendered at: [phone] and [desktop], and
/// [smallLargeText] for the largest shape of a topic.
List<Viewport> viewportsFor(ShapeCase shape) => [
  phone,
  desktop,
  if (shape.largest) smallLargeText,
];

/// Runs [verifyPlayer] for [cases] at [viewportsFor] each, in both number
/// views, and returns every problem found.
Future<Findings> playerFindings(WidgetTester tester, List<ShapeCase> cases) =>
    runFindings(tester, [
      for (final shape in cases)
        for (final viewport in viewportsFor(shape))
          (shape: shape, viewport: viewport, decimals: _both),
    ]);

/// Runs [verifyPlayer] for each of [runs] and returns every problem found.
Future<Findings> runFindings(WidgetTester tester, List<PlayerRun> runs) {
  addTearDown(tester.view.reset);
  return collectingErrors((errors) async {
    final all = Findings();
    for (final run in runs) {
      all.addAll(
        await verifyPlayer(
          tester,
          run.shape,
          run.viewport,
          errors,
          decimals: run.decimals,
        ),
      );
    }
    return all;
  });
}

/// Editor dimensions: A, and B for the two-matrix topics.
typedef EditorShape = ({int rowsA, int colsA, int? rowsB, int? colsB});

/// Every shape the editor accepts for [topic].
List<EditorShape> editorShapes(TopicType topic) => switch (topic) {
  TopicType.add => [
    for (var m = 1; m <= 5; m++)
      for (var n = 1; n <= 5; n++) (rowsA: m, colsA: n, rowsB: m, colsB: n),
  ],
  TopicType.multiply => [
    for (var m = 1; m <= 5; m++)
      for (var k = 1; k <= 5; k++)
        for (var n = 1; n <= 5; n++) (rowsA: m, colsA: k, rowsB: k, colsB: n),
  ],
  TopicType.linearSystems => [
    for (var m = 1; m <= 5; m++)
      for (var c = 2; c <= 5; c++)
        (rowsA: m, colsA: c, rowsB: null, colsB: null),
  ],
  TopicType.determinant || TopicType.inverse || TopicType.lu => [
    for (var n = 1; n <= 5; n++) (rowsA: n, colsA: n, rowsB: null, colsB: null),
  ],
  TopicType.eigen => [
    for (var n = 2; n <= 3; n++) (rowsA: n, colsA: n, rowsB: null, colsB: null),
  ],
  _ => [
    for (var m = 1; m <= 5; m++)
      for (var n = 1; n <= 5; n++)
        (rowsA: m, colsA: n, rowsB: null, colsB: null),
  ],
};

const editorSizes = [Size(390, 844), Size(844, 390), Size(1280, 800)];

final _solveButton = find.widgetWithText(ElevatedButton, l10nEn.calculate);

int _editorCells(String matrix) => find
    .byWidgetPredicate(
      (w) =>
          w is Semantics &&
          (w.properties.label?.startsWith('Matrix $matrix, row ') ?? false),
    )
    .evaluate()
    .length;

/// The editor after [MatrixInputCubit.setDimensionsA]/B: the cell count of
/// A (and B), the augmented divider, no overflow, and a Solve button that
/// can be scrolled into view and hit.
Future<List<String>> editorShapeProblems(
  WidgetTester tester,
  TopicType topic,
  EditorShape shape,
  Size size,
  List<String> errors,
) async {
  final out = <String>[];
  final cubit = BlocProvider.of<MatrixInputCubit>(tester.element(_solveButton));
  if (cubit.state.activeMatrix != 0) cubit.selectMatrix(0);
  cubit.setDimensionsA(shape.rowsA, shape.colsA);
  if (topic == TopicType.multiply) {
    cubit.setDimensionsB(shape.rowsB!, shape.colsB!);
  }
  await tester.pump(Duration.zero);
  final state = cubit.state;
  if ((state.rowsA, state.colsA) != (shape.rowsA, shape.colsA)) {
    out.add(
      'A is ${state.rowsA}x${state.colsA}, not '
      '${shape.rowsA}x${shape.colsA}',
    );
  }
  final cellsA = _editorCells('A');
  if (cellsA != shape.rowsA * shape.colsA) {
    out.add('editor shows $cellsA cells for A ${shape.rowsA}x${shape.colsA}');
  }
  if (topic == TopicType.linearSystems) {
    final dividers = find.byWidgetPredicate(_isDivider).evaluate().length;
    if (dividers != shape.rowsA) {
      out.add('expected ${shape.rowsA} augmented dividers, found $dividers');
    }
  }
  out.addAll(screenProblems(tester, errors));
  if (shape.rowsB != null) {
    if ((state.rowsB, state.colsB) != (shape.rowsB, shape.colsB)) {
      out.add(
        'B is ${state.rowsB}x${state.colsB}, not '
        '${shape.rowsB}x${shape.colsB}',
      );
    }
    cubit.selectMatrix(1);
    await tester.pump(Duration.zero);
    final cellsB = _editorCells('B');
    if (cellsB != shape.rowsB! * shape.colsB!) {
      out.add('editor shows $cellsB cells for B ${shape.rowsB}x${shape.colsB}');
    }
    out.addAll(screenProblems(tester, errors));
    cubit.selectMatrix(0);
    await tester.pump(Duration.zero);
  }
  await tester.ensureVisible(_solveButton);
  await tester.pump(Duration.zero);
  final rect = tester.getRect(_solveButton);
  if (_solveButton.hitTestable().evaluate().length != 1 ||
      rect.top < 0 ||
      rect.bottom > size.height ||
      rect.left < 0 ||
      rect.right > size.width) {
    out.add('Solve cannot be brought on screen ($rect)');
  }
  out.addAll(screenProblems(tester, errors));
  return out;
}

/// Opens the editor for [topic] at [size] with static steps as the player
/// mode, so a solve opens a still lesson.
Future<SettingsCubit> openEditor(
  WidgetTester tester,
  TopicType topic,
  Size size,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  final settings = SettingsCubit(
    initial: const SettingsState(solutionMode: SolutionMode.steps),
  );
  await tester.pumpWidget(
    shapesHost(MatrixInputScreen(topic: TopicItem.of(topic)), settings),
  );
  await tester.pump(Duration.zero);
  return settings;
}

/// Presses Solve and waits for the background solve to open the player.
/// Returns the solution the player shows, or null if none opened.
Future<StepSolution?> solveThroughEditor(WidgetTester tester) async {
  await tester.ensureVisible(_solveButton);
  await tester.pump(Duration.zero);
  await tester.tap(_solveButton);
  for (var i = 0; i < 200; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(Duration.zero);
    if (find.byType(StepPlayerScreen).evaluate().isNotEmpty) break;
  }
  if (find.byType(StepPlayerScreen).evaluate().isEmpty) return null;
  // The page transition.
  await tester.pump(const Duration(milliseconds: 500));
  return BlocProvider.of<PlayerCubit>(
    tester.element(find.byType(MatrixDisplayGrid)),
  ).state.solution;
}

/// Checks the player a solve opened, then returns to the editor.
Future<List<String>> solvedPlayerProblems(
  WidgetTester tester,
  TopicType topic,
  EditorShape shape,
  List<String> errors,
) async {
  final solution = await solveThroughEditor(tester);
  if (solution == null) return ['Solve did not open the player'];
  final out = <String>[];
  final a = solution.initialMatrix;
  if ((a.rows, a.cols) != (shape.rowsA, shape.colsA)) {
    out.add(
      'player opened for ${a.rows}x${a.cols}, not '
      '${shape.rowsA}x${shape.colsA}',
    );
  }
  final operation = switch (topic) {
    TopicType.gauss => 'op_gauss',
    TopicType.rref => 'op_rref',
    TopicType.linearSystems => 'op_linear_systems',
    TopicType.determinant => 'op_determinant',
    TopicType.inverse => 'op_inverse',
    TopicType.rankNullity => 'op_rank_nullity',
    TopicType.eigen => 'op_eigen',
    TopicType.lu => 'op_lu',
    TopicType.add => 'op_add',
    TopicType.multiply => 'op_multiply',
    TopicType.transform2d || TopicType.practice => '',
  };
  if (solution.operationKey != operation) {
    out.add('player opened ${solution.operationKey}, not $operation');
  }
  if (solution.steps.isEmpty) {
    out.add('player opened with no steps');
  } else {
    out.addAll(
      gridProblems(tester, solution.steps.first.matrixAfter, decimal: false),
    );
  }
  out.addAll(screenProblems(tester, errors));
  Navigator.of(tester.element(find.byType(MatrixDisplayGrid))).pop();
  await tester.pump(Duration.zero);
  await tester.pump(const Duration(milliseconds: 500));
  return out;
}

/// The row and column buttons of the editor, pressed to both limits.
Future<List<String>> dimensionButtonProblems(
  WidgetTester tester,
  TopicType topic,
  List<String> errors,
) async {
  final l = l10nEn;
  final out = <String>[];
  final cubit = BlocProvider.of<MatrixInputCubit>(tester.element(_solveButton));
  final item = TopicItem.of(topic);
  final minRows = topic == TopicType.eigen ? 2 : 1;
  final maxRows = topic == TopicType.eigen ? 3 : 5;
  final minCols = item.isAugmentedSystem ? 2 : minRows;
  final maxCols = topic == TopicType.eigen ? 3 : 5;

  Finder button(String tooltip) =>
      find.byWidgetPredicate((w) => w is IconButton && w.tooltip == tooltip);
  bool enabled(String tooltip) =>
      (tester.widget<IconButton>(button(tooltip))).onPressed != null;

  List<String> invariants(String after) {
    final s = cubit.state;
    return [
      if (s.rowsA < minRows || s.rowsA > maxRows)
        '$after: A has ${s.rowsA} rows',
      if (s.colsA < minCols || s.colsA > maxCols)
        '$after: A has ${s.colsA} columns',
      if (item.requiresSquare && s.rowsA != s.colsA)
        '$after: square topic shows ${s.rowsA}x${s.colsA}',
      if (topic == TopicType.multiply && s.rowsB != s.colsA)
        '$after: B has ${s.rowsB} rows for ${s.colsA} columns of A',
      if (topic == TopicType.add && (s.rowsB != s.rowsA || s.colsB != s.colsA))
        '$after: B is ${s.rowsB}x${s.colsB}, A ${s.rowsA}x${s.colsA}',
      if (s.rowsB < 1 || s.rowsB > 5 || s.colsB < 1 || s.colsB > 5)
        '$after: B is ${s.rowsB}x${s.colsB}',
      if (_editorCells(s.activeMatrix == 0 ? 'A' : 'B') !=
          (s.activeMatrix == 0 ? s.rowsA * s.colsA : s.rowsB * s.colsB))
        '$after: cell count does not match the size',
    ];
  }

  /// Presses [tooltip] until it disables; returns the number of presses.
  Future<int> pressUntilDisabled(String tooltip) async {
    var presses = 0;
    while (enabled(tooltip) && presses < 10) {
      await tester.tap(button(tooltip));
      await tester.pump(Duration.zero);
      presses++;
      out.addAll(invariants('${topic.name} "$tooltip" x$presses'));
      out.addAll(screenProblems(tester, errors));
    }
    if (presses == 10) out.add('"$tooltip" never disables');
    return presses;
  }

  int rows() =>
      cubit.state.activeMatrix == 0 ? cubit.state.rowsA : cubit.state.rowsB;
  int cols() =>
      cubit.state.activeMatrix == 0 ? cubit.state.colsA : cubit.state.colsB;

  // A.
  await pressUntilDisabled(l.addRow);
  if (rows() != maxRows) out.add('${topic.name}: rows stop at ${rows()}');
  await pressUntilDisabled(l.removeRow);
  if (rows() != minRows) out.add('${topic.name}: rows stop at ${rows()}');
  if (item.requiresSquare) {
    if (enabled(l.addColumn) || enabled(l.removeColumn)) {
      out.add('${topic.name}: column buttons enabled on a square topic');
    }
  } else {
    await pressUntilDisabled(l.addColumn);
    if (cols() != maxCols) out.add('${topic.name}: cols stop at ${cols()}');
    await pressUntilDisabled(l.removeColumn);
    if (cols() != minCols) out.add('${topic.name}: cols stop at ${cols()}');
  }

  if (item.isDualMatrix) {
    await tester.tap(find.text(l.matrixB));
    await tester.pump(Duration.zero);
    if (cubit.state.activeMatrix != 1) out.add('${topic.name}: B not active');
    if (topic == TopicType.multiply) {
      if (enabled(l.addRow) || enabled(l.removeRow)) {
        out.add('multiply: B row buttons enabled although locked to A');
      }
      await pressUntilDisabled(l.addColumn);
      if (cols() != 5) out.add('multiply: B cols stop at ${cols()}');
      await pressUntilDisabled(l.removeColumn);
      if (cols() != 1) out.add('multiply: B cols stop at ${cols()}');
    } else {
      await pressUntilDisabled(l.addRow);
      await pressUntilDisabled(l.addColumn);
      if ((cubit.state.rowsA, cubit.state.colsA) != (5, 5)) {
        out.add('add: A did not follow B to 5x5');
      }
      await pressUntilDisabled(l.removeRow);
      await pressUntilDisabled(l.removeColumn);
      if ((cubit.state.rowsA, cubit.state.colsA) != (1, 1)) {
        out.add('add: A did not follow B to 1x1');
      }
    }
    await tester.tap(find.text(l.matrixA));
    await tester.pump(Duration.zero);
    if (topic == TopicType.multiply) {
      // B's rows follow A's columns both ways.
      await pressUntilDisabled(l.addColumn);
      await pressUntilDisabled(l.removeColumn);
    }
  }

  // The cubit clamps sizes the buttons never request.
  final clamps = <((int, int), (int, int))>[
    ((0, 0), (minRows, item.requiresSquare ? minRows : minCols)),
    ((9, 9), (maxRows, maxCols)),
    if (item.requiresSquare) ((2, 4), (2, 2)),
    if (item.isAugmentedSystem) ((3, 1), (3, 2)),
  ];
  for (final ((rowsIn, colsIn), expected) in clamps) {
    cubit.setDimensionsA(rowsIn, colsIn);
    await tester.pump(Duration.zero);
    final got = (cubit.state.rowsA, cubit.state.colsA);
    if (got != expected) {
      out.add(
        '${topic.name}: setDimensionsA($rowsIn, $colsIn) gave $got, '
        'expected $expected',
      );
    }
    out.addAll(invariants('${topic.name} setDimensionsA($rowsIn, $colsIn)'));
  }
  if (topic == TopicType.multiply) {
    cubit.setDimensionsA(2, 3);
    cubit.setDimensionsB(4, 9);
    if ((cubit.state.rowsB, cubit.state.colsB) != (3, 5)) {
      out.add(
        'multiply: setDimensionsB(4, 9) with A 2x3 gave '
        '${cubit.state.rowsB}x${cubit.state.colsB}, expected 3x5',
      );
    }
  }
  if (topic == TopicType.add) {
    cubit.setDimensionsB(4, 2);
    if ((cubit.state.rowsA, cubit.state.colsA) != (4, 2)) {
      out.add('add: setDimensionsB(4, 2) left A unchanged');
    }
  }
  await tester.pump(Duration.zero);
  out.addAll(screenProblems(tester, errors));
  return out;
}

/// The extreme and a few mixed editor shapes of [topic]; every size for the
/// square topics.
List<EditorShape> representativeEditorShapes(TopicType topic) {
  const extremes = [(1, 1), (1, 5), (5, 1), (5, 5), (2, 3), (4, 3)];
  return [
    for (final shape in editorShapes(topic))
      if (switch (topic) {
        TopicType.multiply => [
          (1, 1, 1),
          (1, 5, 1),
          (5, 1, 5),
          (5, 5, 5),
          (2, 3, 4),
        ].contains((shape.rowsA, shape.colsA, shape.colsB)),
        TopicType.linearSystems => [
          (1, 2),
          (1, 5),
          (5, 2),
          (5, 5),
          (3, 4),
        ].contains((shape.rowsA, shape.colsA)),
        TopicType.determinant ||
        TopicType.inverse ||
        TopicType.lu ||
        TopicType.eigen => true,
        _ => extremes.contains((shape.rowsA, shape.colsA)),
      })
        shape,
  ];
}

String _sizeName(Size size) => '${size.width.toInt()}x${size.height.toInt()}';

/// [editorShapeProblems] for [shapes] of [topic] at every size in
/// [editorSizes].
Future<Findings> editorFindings(
  WidgetTester tester,
  TopicType topic,
  List<EditorShape> shapes,
) async {
  addTearDown(tester.view.reset);
  return collectingErrors((errors) async {
    final findings = Findings();
    for (final size in editorSizes) {
      final settings = await openEditor(tester, topic, size);
      for (final shape in shapes) {
        findings.frames++;
        findings.add(
          '${topic.name} $shape @${_sizeName(size)}',
          await editorShapeProblems(tester, topic, shape, size, errors),
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await settings.close();
    }
    return findings;
  });
}

/// Sets each of [shapes] in the editor at [sizes], presses Solve and checks
/// the player that opens.
Future<Findings> solveFindings(
  WidgetTester tester,
  TopicType topic,
  List<EditorShape> shapes,
  List<Size> sizes,
) async {
  addTearDown(tester.view.reset);
  return collectingErrors((errors) async {
    final findings = Findings();
    for (final size in sizes) {
      final settings = await openEditor(tester, topic, size);
      for (final shape in shapes) {
        final where = '${topic.name} $shape @${_sizeName(size)}';
        findings.frames++;
        findings.add(
          where,
          await editorShapeProblems(tester, topic, shape, size, errors),
        );
        findings.add(
          where,
          await solvedPlayerProblems(tester, topic, shape, errors),
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await settings.close();
    }
    return findings;
  });
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadMathFonts();
  });
  final runs = suiteRuns();

  group('Player, every topic at the extreme and mixed shapes', () {
    for (final topic in editorTopics) {
      final topicRuns = runs.where((r) => r.shape.topic == topic).toList();
      testWidgets('${topic.name}: ${topicRuns.length} inputs, every step and '
          'the result', (tester) async {
        final findings = await runFindings(tester, topicRuns);
        expect(findings.frames, greaterThan(0));
        expect(findings.isEmpty, isTrue, reason: '$findings');
      });
    }
  });

  testWidgets('The player menu switches to decimals and shows the result', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.physicalSize = phone.size;
    tester.view.devicePixelRatio = 1;
    final settings = SettingsCubit(
      initial: const SettingsState(solutionMode: SolutionMode.steps),
    );
    addTearDown(settings.close);
    final solution = InverseSolver.solve(invertibleMatrix(3));
    final problems = await collectingErrors((errors) async {
      await tester.pumpWidget(
        shapesHost(
          StepPlayerScreen(solution: solution, topicTitle: 'Inverse'),
          settings,
        ),
      );
      await tester.pump(Duration.zero);
      Future<void> choose(String item) async {
        await tester.tap(find.byKey(const ValueKey('player-menu')));
        await tester.pumpAndSettle();
        // The entry, not its label: a checked entry's text is not itself
        // hit-testable.
        await tester.tap(
          find.ancestor(
            of: find.text(item),
            matching: find.byWidgetPredicate((w) => w is PopupMenuItem),
          ),
        );
        await tester.pumpAndSettle();
      }

      await choose(l10nEn.decimalView);
      final repeating = find.byWidgetPredicate(
        (w) => w is MathText && w.latex.contains(r'\overline{'),
      );
      final inDecimals = [
        if (!settings.state.isDecimalView) 'the menu did not switch views',
        if (repeating.evaluate().isEmpty) 'no repeating decimal on screen',
        ...gridProblems(
          tester,
          solution.steps.first.matrixAfter,
          decimal: true,
        ),
        ...screenProblems(tester, errors),
      ];
      await choose(l10nEn.showResult);
      return [
        ...inDecimals,
        if (playerOf(tester).state.mode != SolutionMode.result)
          'the menu did not show the result',
        ...resultProblems(tester, solution, decimal: true),
        ...screenProblems(tester, errors),
      ];
    });
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  group('Editor at 390x844, 844x390 and 1280x800', () {
    for (final topic in editorTopics) {
      final shapes = representativeEditorShapes(topic);
      testWidgets('${topic.name}: ${shapes.length} shapes', (tester) async {
        final findings = await editorFindings(tester, topic, shapes);
        expect(findings.isEmpty, isTrue, reason: '$findings');
      });
    }
  });

  group('Solve opens the player for the shape', () {
    for (final topic in editorTopics) {
      testWidgets('${topic.name}: smallest and largest shape', (tester) async {
        final shapes = editorShapes(topic);
        final findings = await solveFindings(tester, topic, [
          shapes.first,
          shapes.last,
        ], editorSizes);
        expect(findings.isEmpty, isTrue, reason: '$findings');
      });
    }
  });

  group('Row and column buttons respect the limits', () {
    for (final topic in editorTopics) {
      testWidgets(topic.name, (tester) async {
        addTearDown(tester.view.reset);
        final settings = await openEditor(tester, topic, const Size(390, 844));
        addTearDown(settings.close);
        final problems = await collectingErrors(
          (errors) => dimensionButtonProblems(tester, topic, errors),
        );
        expect(problems, isEmpty, reason: problems.join('\n'));
      });
    }
  });
}
