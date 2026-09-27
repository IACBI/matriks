import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/step_player/widgets/solution_summary.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';
import 'package:matrix_engine/matrix_engine.dart';

/// The eigen result screen states exact values and only true notes.
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<void> show(WidgetTester tester, StepSolution solution) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => SettingsCubit(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SolutionSummary(
              solution: solution,
              decimal: false,
              onViewSteps: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  StepSolution solve(List<List<int>> rows) =>
      EigenSolver.solve(Matrix.fromInts(rows));

  testWidgets('A cubic with a complex pair is exact, complete and checked', (
    tester,
  ) async {
    await show(
      tester,
      solve([
        [0, 1, 0],
        [0, 0, 1],
        [2, 0, 0],
      ]),
    );
    expect(find.text(l10n.resultExact), findsOneWidget);
    expect(find.text(l10n.resultComplete), findsOneWidget);
    expect(find.text(l10n.resultApproximate), findsNothing);
    expect(find.text(l10n.eigenComplexNote), findsOneWidget);
    expect(find.text(l10n.eigenCubicNote), findsOneWidget);
    expect(find.text(l10n.eigenBasisScope), findsNothing);
    expect(find.text(l10n.checkHolds), findsNWidgets(3));
    expect(find.text(l10n.checkFails), findsNothing);
  });

  testWidgets('Irrational real eigenvalues carry no complex or cubic note', (
    tester,
  ) async {
    await show(
      tester,
      solve([
        [1, 1],
        [1, 0],
      ]),
    );
    expect(find.text(l10n.resultExact), findsOneWidget);
    expect(find.text(l10n.eigenComplexNote), findsNothing);
    expect(find.text(l10n.eigenCubicNote), findsNothing);
    expect(find.text(l10n.checkHolds), findsNWidgets(2));
  });

  testWidgets('Long closed forms scroll instead of overflowing at 320 px', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final rows in [
      [
        [0, 1, 0],
        [0, 0, 1],
        [-7, 7, 0],
      ],
      [
        [1, 2, 0],
        [0, 1, 3],
        [4, 0, 1],
      ],
    ]) {
      await show(tester, solve(rows));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('On a phone every eigenvector starts on screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // x³ - 2: Cardano's closed forms are far wider than a phone.
    await show(
      tester,
      solve([
        [0, 0, 2],
        [1, 0, 0],
        [0, 1, 0],
      ]),
    );
    final vectors = find.byWidgetPredicate(
      (w) => w is MathText && w.latex.startsWith(r'\mathbf{v}'),
    );
    expect(vectors, findsNWidgets(3));
    for (final element in vectors.evaluate()) {
      final left = tester.getRect(find.byWidget(element.widget)).left;
      expect(
        left,
        lessThan(390 - 48),
        reason: (element.widget as MathText).latex,
      );
    }
  });
}
