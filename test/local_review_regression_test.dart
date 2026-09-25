import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/app.dart';
import 'package:matriks/core/theme/app_theme.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/features/matrix_input/views/matrix_input_screen.dart';
import 'package:matriks/features/practice/views/practice_screen.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/settings/views/settings_screen.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/step_player/result_check.dart';
import 'package:matriks/features/step_player/step_text.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/step_player/widgets/matrix_cell_widget.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/features/step_player/widgets/solution_summary.dart';
import 'package:matriks/features/topics/models/topic_item.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';
import 'package:matrix_engine/matrix_engine.dart';

/// Defects found by driving the release web build and the Windows build on a
/// local machine (2026-09-25).

Widget _app(Widget home, {String locale = 'en'}) => BlocProvider(
  create: (_) => SettingsCubit(),
  child: MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: Locale(locale),
    home: home,
  ),
);

/// One lesson per topic, plus the branches the defaults do not reach.
Map<String, StepSolution> _lessons() => {
  'add': MatrixArithmeticSolver.add(
    Matrix.fromInts([
      [1, -2],
      [3, 0],
    ]),
    Matrix.fromInts([
      [4, 1],
      [-1, 2],
    ]),
  ),
  'multiply': MatrixArithmeticSolver.multiply(
    Matrix.fromInts([
      [1, 2],
      [3, 4],
    ]),
    Matrix.fromInts([
      [2, 0],
      [1, -1],
    ]),
  ),
  'ref': GaussJordanSolver.solve(
    Matrix.fromInts([
      [1, 2, 1],
      [2, 5, 4],
      [1, 3, 3],
    ]),
    const EliminationOptions(toRref: false),
  ),
  'system': LinearSystemsSolver.solve(
    Matrix.fromInts([
      [1, 1, 1, 6],
      [0, 2, 5, -4],
      [2, 5, -1, 27],
    ]),
  ),
  'system infinite': LinearSystemsSolver.solve(
    Matrix.fromInts([
      [1, 2, 3],
      [2, 4, 6],
    ]),
  ),
  'determinant 3x3': DeterminantSolver.solve(
    Matrix.fromInts([
      [2, -1, 3],
      [1, 4, 0],
      [5, 2, 1],
    ]),
  ),
  'determinant 4x4': DeterminantSolver.solve(
    Matrix.fromInts([
      [0, 1, 2, 1],
      [1, 0, 1, 2],
      [2, 1, 0, 1],
      [1, 2, 1, 1],
    ]),
  ),
  'inverse 2x2': InverseSolver.solve(
    Matrix.fromInts([
      [4, 7],
      [2, 6],
    ]),
  ),
  'inverse 3x3': InverseSolver.solve(
    Matrix.fromInts([
      [1, 2, 3],
      [0, 1, 4],
      [5, 6, 0],
    ]),
  ),
  'rank': RankNullitySolver.solve(
    Matrix.fromInts([
      [1, 2, 3],
      [2, 4, 6],
      [1, 0, 1],
    ]),
  ),
  'lu swap': LUDecompositionSolver.solve(
    Matrix.fromInts([
      [0, 1, 1],
      [1, 2, 1],
      [2, 7, 9],
    ]),
  ),
  'eigen 2x2': EigenSolver.solve(
    Matrix.fromInts([
      [4, 1],
      [2, 3],
    ]),
  ),
  'eigen 3x3': EigenSolver.solve(
    Matrix.fromInts([
      [2, 1, 0],
      [1, 2, 0],
      [0, 0, 5],
    ]),
  ),
};

/// TeX a screen reader would spell out instead of reading.
final _texResidue = RegExp(r'\\[a-zA-Z]|[{}&^_]');

List<String> _formulas(WidgetTester tester) => [
  for (final math in tester.widgetList<MathText>(find.byType(MathText)))
    math.latex,
];

void main() {
  testWidgets('Every rendered formula has a readable screen reader label', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final seen = <String>{};
    for (final MapEntry(key: name, value: solution) in _lessons().entries) {
      expect(solution.isSuccess, isTrue, reason: name);
      await tester.pumpWidget(
        _app(StepPlayerScreen(solution: solution, topicTitle: name)),
      );
      await tester.pump();
      final cubit = tester
          .element(find.byType(MatrixDisplayGrid))
          .read<PlayerCubit>();
      cubit.pause();
      for (var i = 0; i < solution.steps.length; i++) {
        cubit.jumpToStep(i);
        await tester.pump();
        // Mid-operation frames carry the per-cell formulas.
        for (final ms in [300, 1500, 3000, 6000, 12000]) {
          await tester.pump(Duration(milliseconds: ms));
          seen.addAll(_formulas(tester));
        }
      }
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: SolutionSummary(
              solution: solution,
              decimal: false,
              onViewSteps: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      seen.addAll(_formulas(tester));
    }
    await tester.pumpWidget(const SizedBox());

    expect(seen, isNotEmpty);
    for (final latex in seen) {
      final label = mathSemanticsLabel(latex);
      expect(
        _texResidue.hasMatch(label),
        isFalse,
        reason: '"$latex" is read as "$label"',
      );
    }
  });

  test('Formulas read as their mathematics', () {
    expect(mathSemanticsLabel(r'\det(A) = -45'), 'det(A) = -45');
    expect(
      mathSemanticsLabel(r'A_{1,1} = 1 \quad B_{1,1} = 4'),
      'A₁,₁ = 1 B₁,₁ = 4',
    );
    expect(
      mathSemanticsLabel(
        r'A \cdot A^{-1} = \begin{pmatrix}1 & 0 \\ 0 & 1\end{pmatrix} = I',
      ),
      'A · A⁻¹ = (1, 0; 0, 1) = I',
    );
    // A column vector keeps reading as a list.
    expect(
      mathSemanticsLabel(
        r'\mathbf{x} = \begin{pmatrix}5 \\ 3 \\ -2\end{pmatrix}',
      ),
      'x = (5, 3, -2)',
    );
    expect(mathSemanticsLabel(r'\frac{a + b}{2}'), '(a + b)/2');
  });

  testWidgets('Playback speed is written with one ×', (tester) async {
    await tester.pumpWidget(_app(const SettingsScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('more-settings')));
    await tester.pumpAndSettle();
    expect(find.text('Speed: 1×'), findsOneWidget);

    await tester.pumpWidget(
      _app(StepPlayerScreen(solution: _lessons()['add']!, topicTitle: 'add')),
    );
    await tester.pump();
    expect(find.byTooltip('Speed: 1×'), findsOneWidget);
    expect(find.textContaining('××'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Result status chips are read as text, not as checkboxes', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: SolutionSummary(
            solution: _lessons()['determinant 3x3']!,
            decimal: false,
            onViewSteps: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final label in ['Exact', 'Complete']) {
      expect(
        tester.getSemantics(find.bySemanticsLabel(label)),
        isSemantics(
          label: label,
          hasSelectedState: false,
          hasCheckedState: false,
          isButton: false,
        ),
      );
    }
    semantics.dispose();
  });

  test('Steps of one lesson have distinct titles', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    for (final MapEntry(key: name, value: solution) in _lessons().entries) {
      final titles = [
        for (final step in solution.steps)
          localizedStepText(l10n, step.titleKey, step.titleParams),
      ];
      expect(titles.toSet().length, titles.length, reason: '$name: $titles');
    }
  });

  testWidgets('Size buttons say whether they change rows or columns', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(MatrixInputScreen(topic: TopicItem.of(TopicType.gauss))),
    );
    await tester.pumpAndSettle();
    for (final tooltip in [
      'Remove a row',
      'Add a row',
      'Remove a column',
      'Add a column',
    ]) {
      expect(find.byTooltip(tooltip), findsOneWidget, reason: tooltip);
    }
  });

  test('Counts agree with their nouns', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(en.system_infinite_title(1), 'Infinite Solutions (1 Free Variable)');
    expect(
      en.system_infinite_title(2),
      'Infinite Solutions (2 Free Variables)',
    );
    expect(
      en.rank_nullity_desc(3, 1, 2),
      startsWith('The matrix has 2 pivot columns and 1 free column.'),
    );
    expect(
      en.rank_nullity_desc(3, 2, 1),
      startsWith('The matrix has 1 pivot column and 2 free columns.'),
    );
    final es = lookupAppLocalizations(const Locale('es'));
    expect(es.system_infinite_title(1), contains('1 variable libre'));
    expect(
      es.rank_nullity_desc(3, 1, 2),
      startsWith('Hay 2 columnas pivote y 1 libre.'),
    );
    final ru = lookupAppLocalizations(const Locale('ru'));
    expect(ru.system_infinite_title(1), contains('1 свободная переменная'));
    expect(ru.system_infinite_title(2), contains('2 свободные переменные'));
    expect(ru.system_infinite_title(5), contains('5 свободных переменных'));
  });

  testWidgets('Only a zero the operation produced is marked as its result', (
    tester,
  ) async {
    // R3 ← R3 - R2 turns (0, 1, 2) into (0, 0, 0): the first 0 was there
    // before and is not a result of this step.
    final step = _lessons()['ref']!.steps.last;
    expect(step.matrixBefore.get(2, 0), Rational.zero);
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: MatrixDisplayGrid(
            snapshot: step.matrixAfter,
            snapshotBefore: step.matrixBefore,
            transformation: step.transformation,
            highlights: step.highlights,
            staticStep: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(MatrixCellWidget),
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets(
    'An eigen result explains its check once, and its scope when it applies',
    (tester) async {
      final l10n = lookupAppLocalizations(const Locale('en'));
      Future<void> show(StepSolution solution) async {
        await tester.pumpWidget(
          _app(
            Scaffold(
              body: SolutionSummary(
                solution: solution,
                decimal: false,
                onViewSteps: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await show(_lessons()['eigen 2x2']!);
      expect(find.text(l10n.checkEigen), findsOneWidget);
      // Distinct eigenvalues: each vector already spans its eigenspace.
      expect(find.text(l10n.eigenBasisScope), findsNothing);

      final repeated = EigenSolver.solve(
        Matrix.fromInts([
          [2, 1],
          [0, 2],
        ]),
      );
      expect(repeated.completeness, ResultCompleteness.partial);
      await show(repeated);
      expect(find.text(l10n.eigenBasisScope), findsOneWidget);
    },
  );

  testWidgets('A quiz option is announced with its answer', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(PracticeScreen(onReturnTopics: () {})));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(RegExp(r'^A: R₂ ← R₂ - 2R₁$')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('Bottom navigation labels stay on one line (text ×$scale)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const MatrixEducatorApp());
      await tester.pumpAndSettle();
      for (final label in [
        'Topics',
        'Practice',
        'Transformations',
        'Settings',
      ]) {
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(label).last,
        );
        expect(
          paragraph.size.height,
          paragraph.getMaxIntrinsicHeight(double.infinity),
          reason: '$label wraps',
        );
      }
    });
  }

  testWidgets('Chip labels are not faded', (tester) async {
    await tester.pumpWidget(const MatrixEducatorApp());
    await tester.pumpAndSettle();
    final label = tester.renderObject<RenderParagraph>(find.text('All Topics'));
    expect(label.overflow, TextOverflow.visible);
  });

  testWidgets('Tab finishes the navigation rail before entering the page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MatrixEducatorApp());
    await tester.pumpAndSettle();
    final inRail = <bool>[];
    for (var i = 0; i < 14; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final context = FocusManager.instance.primaryFocus?.context;
      inRail.add(
        context?.findAncestorWidgetOfExactType<NavigationRail>() != null,
      );
    }
    final runs = [
      for (var i = 0; i < inRail.length; i++)
        if (inRail[i] && (i == 0 || !inRail[i - 1])) i,
    ];
    expect(inRail.where((v) => v).length, 4, reason: '$inRail');
    expect(runs.length, 1, reason: 'rail focus is interleaved: $inRail');
  });

  test('The rank check can fail', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final a = Matrix.fromInts([
      [1, 2, 3],
      [2, 4, 6],
      [1, 0, 1],
    ]);
    expect(resultChecks(RankNullitySolver.solve(a), l10n).single.holds, isTrue);
    // A wrong rank with a nullity to match: rank + nullity = n still holds,
    // so only an independent rank can expose it.
    final wrong = StepSolution(
      operationKey: 'op_rank_nullity',
      initialMatrix: a,
      steps: const [],
      finalMatrix: a,
      result: const RankNullityResult(
        rank: 3,
        nullity: 0,
        totalCols: 3,
        pivotColumnIndices: [0, 1, 2],
        freeColumnIndices: [],
      ),
    );
    expect(resultChecks(wrong, l10n).single.holds, isFalse);
  });

  testWidgets('Opening Practice from the navigation is where you left off', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MatrixEducatorApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    final settings = tester
        .element(find.byType(PracticeScreen))
        .read<SettingsCubit>();
    expect(settings.state.lastTopic, 'practice');
    await tester.tap(find.text('Transformations'));
    await tester.pumpAndSettle();
    expect(settings.state.lastTopic, 'transform2d');
  });

  testWidgets('Topic rows are buttons', (tester) async {
    tester.view.physicalSize = const Size(1280, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const MatrixEducatorApp());
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Matrix Addition')),
      isSemantics(isButton: true),
    );
    semantics.dispose();
  });
}
