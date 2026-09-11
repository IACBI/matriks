import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/core/theme/app_theme.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';
import 'package:matrix_engine/matrix_engine.dart';

/// Reads every step's headings back out of the rendered tree.
///
/// `math_prose_regression_test.dart` checks the conversion function. That is not
/// enough on its own: the eigenvector heading reached production reading
/// "lambda_1" because the screen rendered the resolved title directly while only
/// the card had been wrapped. These tests look at what is actually drawn.

Rational _r(int n) => Rational(BigInt.from(n), BigInt.one);

Matrix _m(List<List<int>> rows) =>
    Matrix(rows.map((row) => row.map(_r).toList()).toList());

Map<String, StepSolution> _lessons() => {
  // Distinct integer eigenvalues, so titles carry an index and a value.
  'eigen 2x2': EigenSolver.solve(
    _m([
      [2, 1],
      [1, 2],
    ]),
  ),
  'eigen 3x3': EigenSolver.solve(
    _m([
      [2, 0, 0],
      [0, 3, 0],
      [0, 0, 4],
    ]),
  ),
  'rref': GaussJordanSolver.solve(
    _m([
      [0, 2, 1],
      [1, -3, 2],
      [2, 1, -1],
    ]),
  ),
  'determinant': DeterminantSolver.solve(
    _m([
      [2, -5, 3],
      [1, 4, -2],
      [-3, 1, 6],
    ]),
  ),
  'inverse': InverseSolver.solve(
    _m([
      [4, 7],
      [2, 6],
    ]),
  ),
  'lu': LUDecompositionSolver.solve(
    _m([
      [4, 3],
      [6, 3],
    ]),
  ),
  'multiply': MatrixArithmeticSolver.multiply(
    _m([
      [1, -2],
      [3, 4],
    ]),
    _m([
      [-5, 6],
      [7, -8],
    ]),
  ),
  'rank': RankNullitySolver.solve(
    _m([
      [1, 2, 3],
      [2, 4, 6],
    ]),
  ),
};

/// Notation that must never survive conversion into a heading.
const _residue = <String, String>{
  r'backslash command': r'\[a-zA-Z]+',
  'brace group': r'[_^]\{',
  'bare subscript': r'\S_[0-9]',
  'bare superscript': r'\^[0-9]',
};

Widget _host(Widget child, String locale) => BlocProvider(
  create: (_) => SettingsCubit(),
  child: MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: Locale(locale),
    home: child,
  ),
);

List<String> _renderedStrings(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((text) => text.data ?? text.textSpan?.toPlainText() ?? '')
    .where((value) => value.isNotEmpty)
    .toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final lessons = _lessons();

  for (final locale in ['en', 'tr']) {
    group('No raw notation is rendered ($locale)', () {
      lessons.forEach((label, solution) {
        testWidgets(label, (tester) async {
          if (solution.steps.isEmpty) {
            expect(solution.isSuccess, isFalse, reason: '$label: empty lesson');
            return;
          }
          tester.view.physicalSize = const Size(1280, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            _host(
              StepPlayerScreen(solution: solution, topicTitle: label),
              locale,
            ),
          );
          await tester.pump();

          final cubit = tester
              .element(find.byType(MatrixDisplayGrid))
              .read<PlayerCubit>();
          cubit.pause();

          for (var i = 0; i < solution.steps.length; i++) {
            cubit.jumpToStep(i);
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 32));

            for (final value in _renderedStrings(tester)) {
              _residue.forEach((name, pattern) {
                expect(
                  RegExp(pattern).hasMatch(value),
                  isFalse,
                  reason: '$label step $i ($locale) renders $name in: $value',
                );
              });
            }
          }
        });
      });
    });
  }

  testWidgets('The eigenvector heading renders a real subscript', (
    tester,
  ) async {
    final solution = lessons['eigen 2x2']!;
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _host(StepPlayerScreen(solution: solution, topicTitle: 'eigen'), 'en'),
    );
    await tester.pump();

    final cubit = tester
        .element(find.byType(MatrixDisplayGrid))
        .read<PlayerCubit>();
    cubit.pause();

    var sawSubscript = false;
    for (var i = 0; i < solution.steps.length; i++) {
      cubit.jumpToStep(i);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 32));
      if (_renderedStrings(tester).any((v) => v.contains('λ₁'))) {
        sawSubscript = true;
      }
    }
    expect(
      sawSubscript,
      isTrue,
      reason:
          'no eigenvector heading rendered λ₁; the lesson steps were '
          '${solution.steps.map((s) => s.titleKey).toList()}',
    );
  });
}
