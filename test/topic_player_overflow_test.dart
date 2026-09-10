import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/core/theme/app_theme.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';
import 'package:matrix_engine/matrix_engine.dart';

/// Every topic's player is laid out with content that is deliberately awkward:
/// long signed fractions, 5x5 grids and wide parametric solutions.
Matrix _awkward(int rows, int cols) => Matrix(
  List.generate(
    rows,
    (r) => List.generate(
      cols,
      (c) => Rational(
        BigInt.from(((r * cols + c) % 2 == 0 ? -1 : 1) * (10 * r + c + 7)),
        BigInt.from(c + 3),
      ),
    ),
  ),
);

Map<String, StepSolution> _solutions() => {
  'rref-5x5': GaussJordanSolver.solve(_awkward(5, 5)),
  'ref-5x5': GaussJordanSolver.solve(
    _awkward(5, 5),
    const EliminationOptions(toRref: false),
  ),
  'system-unique': LinearSystemsSolver.solve(_awkward(4, 5)),
  'system-infinite': LinearSystemsSolver.solve(
    Matrix.fromInts([
      [1, 1, 1, 1, 3],
      [2, 2, 2, 2, 6],
      [0, 0, 0, 0, 0],
    ]),
  ),
  'system-inconsistent': LinearSystemsSolver.solve(
    Matrix.fromInts([
      [1, 1, 1],
      [1, 1, 2],
    ]),
  ),
  'determinant-2x2': DeterminantSolver.solve(_awkward(2, 2)),
  'determinant-3x3': DeterminantSolver.solve(_awkward(3, 3)),
  'determinant-5x5': DeterminantSolver.solve(_awkward(5, 5)),
  'inverse-2x2': InverseSolver.solve(_awkward(2, 2)),
  'inverse-5x5': InverseSolver.solve(_awkward(5, 5)),
  'inverse-singular': InverseSolver.solve(
    Matrix.fromInts([
      [1, 2],
      [2, 4],
    ]),
  ),
  'rank-5x5': RankNullitySolver.solve(_awkward(5, 5)),
  'eigen-exact': EigenSolver.solve(
    Matrix.fromInts([
      [4, 1],
      [2, 3],
    ]),
  ),
  'eigen-irrational': EigenSolver.solve(
    Matrix.fromInts([
      [1, 1],
      [1, 0],
    ]),
  ),
  'eigen-complex': EigenSolver.solve(
    Matrix.fromInts([
      [0, -1],
      [1, 0],
    ]),
  ),
  'eigen-3x3': EigenSolver.solve(
    Matrix.fromInts([
      [2, 0, 0],
      [1, 3, 0],
      [0, 1, 4],
    ]),
  ),
  'eigen-3x3-no-rational-root': EigenSolver.solve(
    Matrix.fromInts([
      [1, 1, 0],
      [1, 0, 1],
      [0, 1, 1],
    ]),
  ),
  'lu-5x5': LUDecompositionSolver.solve(_awkward(5, 5)),
  'add-5x5': MatrixArithmeticSolver.add(_awkward(5, 5), _awkward(5, 5)),
  'multiply-5x5': MatrixArithmeticSolver.multiply(
    _awkward(5, 5),
    _awkward(5, 5),
  ),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Animations stay enabled: the wider animated cell layout is where a
  // horizontal overflow would appear first.
  Widget host(
    Widget child, {
    required bool dark,
    required String language,
    double scale = 1,
  }) {
    return BlocProvider(
      create: (_) => SettingsCubit(),
      child: MaterialApp(
        locale: Locale(language),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        builder: (context, inner) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: inner!,
        ),
        home: child,
      ),
    );
  }

  final sizes = <Size>[
    const Size(320, 568),
    const Size(390, 844),
    const Size(600, 800),
    const Size(1440, 900),
  ];

  for (final entry in _solutions().entries) {
    testWidgets('${entry.key} player lays out without overflow', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final size in sizes) {
        for (final dark in [false, true]) {
          tester.view.physicalSize = size;
          await tester.pumpWidget(
            host(
              StepPlayerScreen(solution: entry.value, topicTitle: entry.key),
              dark: dark,
              language: 'en',
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(
            tester.takeException(),
            isNull,
            reason: '${entry.key} @ $size dark=$dark',
          );
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        }
      }
    });
  }

  testWidgets('Wide topics stay laid out in every language at 320px', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final wide = {
      'lu': LUDecompositionSolver.solve(_awkward(5, 5)),
      'multiply': MatrixArithmeticSolver.multiply(
        _awkward(5, 5),
        _awkward(5, 5),
      ),
      'eigen': EigenSolver.solve(
        Matrix.fromInts([
          [1, 1],
          [1, 0],
        ]),
      ),
      'system': LinearSystemsSolver.solve(
        Matrix.fromInts([
          [1, 1, 1, 1, 3],
          [2, 2, 2, 2, 6],
          [0, 0, 0, 0, 0],
        ]),
      ),
    };

    for (final language in ['en', 'tr', 'zh', 'es', 'ru']) {
      for (final entry in wide.entries) {
        await tester.pumpWidget(
          host(
            StepPlayerScreen(solution: entry.value, topicTitle: entry.key),
            dark: false,
            language: language,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(
          tester.takeException(),
          isNull,
          reason: '${entry.key} in $language at 320px',
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
    }
  });
}
