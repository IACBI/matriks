import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/core/widgets/readable_math_fit.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/step_player/widgets/instruction_timeline.dart';
import 'package:matriks/features/step_player/widgets/matrix_cell_widget.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

Widget host(Widget child) => BlocProvider(
  create: (_) => SettingsCubit(),
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ),
);

void main() {
  testWidgets(
    'Cell operation shrinks legibly and result returns to its normal size',
    (tester) async {
      Widget cell(String? expression) => host(
        Center(
          child: SizedBox(
            width: 120,
            height: 64,
            child: MatrixCellWidget(
              value: Rational(6),
              calculationLatex: expression,
              fontSize: 22,
            ),
          ),
        ),
      );
      await tester.pumpWidget(cell(r'12 - 2 \cdot 3'));
      await tester.pumpAndSettle();
      final math = find.descendant(
        of: find.byType(ReadableMathFit),
        matching: find.byType(MathText),
      );
      final actual = tester.getRect(math).width / tester.getSize(math).width;
      expect(22 * actual, greaterThanOrEqualTo(14 - .001));
      expect(actual, lessThan(1));
      final scroll = tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(ReadableMathFit),
          matching: find.byType(Scrollable),
        ),
      );
      expect(scroll.position.maxScrollExtent, 0);
      await tester.pumpWidget(cell(null));
      await tester.pumpAndSettle();
      expect(find.byType(ReadableMathFit), findsNothing);
      final result = find.descendant(
        of: find.byType(MatrixCellWidget),
        matching: find.byType(MathText),
      );
      expect(tester.widget<MathText>(result).fontSize, 22);
      expect(
        tester.getRect(result).width,
        closeTo(tester.getSize(result).width, .01),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Elimination expression appears in the active cell and clears after completion',
    (tester) async {
      final solution = GaussJordanSolver.solve(
        Matrix.fromInts([
          [1, 2],
          [2, 5],
        ]),
      );
      final step = solution.steps.firstWhere(
        (s) => s.transformation is RowEliminationTransformation,
      );
      await tester.pumpWidget(
        host(
          SingleChildScrollView(
            child: MatrixDisplayGrid(
              snapshot: step.matrixAfter,
              snapshotBefore: step.matrixBefore,
              transformation: step.transformation,
              highlights: step.highlights,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ReadableMathFit), findsNothing);
      final timeline = InstructionTimeline.forTransformation(
        step.transformation,
      );
      await tester.pump(Duration(milliseconds: timeline.sourceMs + 100));
      final active = tester
          .widgetList<MatrixCellWidget>(find.byType(MatrixCellWidget))
          .where((cell) => cell.calculationLatex != null)
          .single;
      expect(active.calculationLatex, r'2 - 2 \cdot 1');
      await tester.pumpAndSettle();
      expect(find.byType(ReadableMathFit), findsNothing);
      expect(
        tester
            .widgetList<MatrixCellWidget>(find.byType(MatrixCellWidget))
            .every((c) => c.calculationLatex == null),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Long exact cell operations keep a readable lower bound', (
    tester,
  ) async {
    const expression =
        r'\frac{12345678901234567890}{7} - \frac{9876543210987654321}{13}';
    await tester.pumpWidget(
      host(
        const Center(
          child: SizedBox(
            width: 100,
            height: 64,
            child: ReadableMathFit(expression, fontSize: 22),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final math = find.byType(MathText);
    final actual = tester.getRect(math).width / tester.getSize(math).width;
    expect(22 * actual, closeTo(14, .001));
    expect(tester.widget<MathText>(math).latex, expression);
    expect(
      tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position
          .maxScrollExtent,
      greaterThan(0),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Math follows the system text scale exactly once', (
    tester,
  ) async {
    Future<Size> measure(double scale) async {
      await tester.pumpWidget(
        host(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: const Center(child: MathText('12345', fontSize: 20)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return tester.getSize(find.byType(MathText));
    }

    final normal = await measure(1);
    final large = await measure(2);
    expect(large.width, closeTo(normal.width * 2, .01));
    expect(large.height, closeTo(normal.height * 2, .01));
  });

  testWidgets(
    'Solution plays every step without user input and supports pause',
    (tester) async {
      final solution = DeterminantSolver.solve(
        Matrix.fromInts([
          [2, 3],
          [1, 4],
        ]),
      );
      await tester.pumpWidget(
        host(StepPlayerScreen(solution: solution, topicTitle: 'Determinant')),
      );
      await tester.pump();
      final player = tester
          .element(find.byType(MatrixDisplayGrid))
          .read<PlayerCubit>();
      expect(player.state.isPlaying, isTrue);
      player.pause();
      await tester.pump();
      await tester.pump(const Duration(seconds: 30));
      expect(player.state.currentStepIndex, 0);
      player.play();
      await tester.pump();
      await tester.pump();
      for (var i = 0; i < solution.steps.length; i++) {
        expect(player.state.currentStepIndex, i);
        expect(player.state.isPlaying, isTrue);
        final duration = InstructionTimeline.forTransformation(
          solution.steps[i].transformation,
        ).duration(1);
        await tester.pump(duration + const Duration(milliseconds: 17));
        await tester.pump();
        await tester.pump();
      }
      expect(player.state.isLastStep, isTrue);
      expect(player.state.hasCompletedAnimation, isTrue);
      expect(player.state.isPlaying, isFalse);
    },
  );

  testWidgets('Five numeric columns fit the available phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final snapshot = MatrixSnapshot(
      rows: 5,
      cols: 5,
      values: List.generate(5, (_) => List.filled(5, Rational(-3))),
    );
    await tester.pumpWidget(
      host(
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MatrixDisplayGrid(
              snapshot: snapshot,
              highlights: const [],
              staticStep: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final cell in find.byType(MatrixCellWidget).evaluate()) {
      final rect = tester.getRect(find.byWidget(cell.widget));
      expect(rect.left, greaterThanOrEqualTo(16));
      expect(rect.right, lessThanOrEqualTo(374));
    }
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('Exact calculations wrap at operators at text scale $scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: const SizedBox(
              width: 260,
              child: MathText(
                r'(123) + (456) + (789) + (101) + (112) = 1581',
                wrapLines: true,
                fontSize: 17,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      final tops = wrap.children
          .map((child) => tester.getTopLeft(find.byWidget(child)).dy)
          .toSet();
      expect(tops.length, greaterThan(1));
      for (final element in find.byType(Scrollable).evaluate()) {
        final scroll = (element as StatefulElement).state as ScrollableState;
        expect(scroll.position.maxScrollExtent, 0);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Wide multiplication automatically reveals the output column', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final value = Rational.parse('-1234567890123456789/1234567');
    final snapshot = MatrixSnapshot(
      rows: 1,
      cols: 5,
      values: [List.filled(5, value)],
    );
    await tester.pumpWidget(
      host(
        SingleChildScrollView(
          child: MatrixDisplayGrid(
            snapshot: snapshot,
            snapshotBefore: snapshot,
            highlights: const [],
            transformation: MatrixElementMultiplicationTransformation(
              targetRow: 0,
              targetCol: 4,
              rowElements: [value],
              colElements: [Rational.one],
              result: value,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    final rect = tester.getRect(find.byType(MatrixCellWidget).last);
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(320));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
