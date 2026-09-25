import 'dart:math' as math;

import 'package:matriks/core/widgets/math_text.dart';

import 'package:flutter/material.dart';
import 'package:matriks/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/step_player/widgets/instruction_timeline.dart';
import 'package:matriks/features/step_player/widgets/matrix_cell_widget.dart';
import 'package:matriks/features/step_player/widgets/step_card.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

void main() {
  test(
    'Prose formatting preserves signed fractions and indexed row operations',
    () {
      expect(
        readableMathProse(r'R_2 \leftarrow R_2 - \frac{1}{4} R_{12}'),
        'R₂ ← R₂ - 1/4 R₁₂',
      );
      expect(readableMathProse(r'-\frac{3}{2}'), '-3/2');
      expect(readableMathProse('Plain text 3/4'), 'Plain text 3/4');
    },
  );

  final solution = GaussJordanSolver.solve(
    Matrix.fromInts([
      [1, 2],
      [2, 5],
    ]),
  );
  final step = solution.steps.firstWhere(
    (s) => s.transformation is RowEliminationTransformation,
  );

  final timeline = InstructionTimeline.forTransformation(step.transformation);
  final initialTimeline = InstructionTimeline.forTransformation(
    solution.steps.first.transformation,
  );
  test('Instruction stages have exact boundaries and uniform speed', () {
    expect(
      timeline.phase((timeline.sourceMs - 1) / timeline.totalMs),
      InstructionPhase.source,
    );
    expect(
      timeline.phase(timeline.sourceMs / timeline.totalMs),
      InstructionPhase.operation,
    );
    expect(
      timeline.phase(
        (timeline.sourceMs + timeline.operationMs) / timeline.totalMs,
      ),
      InstructionPhase.result,
    );
    expect(timeline.operationProgress(timeline.sourceMs / timeline.totalMs), 0);
    expect(
      timeline.operationProgress(
        (timeline.sourceMs + timeline.operationMs) / timeline.totalMs,
      ),
      1,
    );
    expect(timeline.duration(2).inMilliseconds, timeline.totalMs ~/ 2);
    expect(timeline.operationMs, greaterThanOrEqualTo(3000));
  });

  test('Completion advances only the active autoplay revision', () async {
    final cubit = PlayerCubit(solution);
    expect(cubit.state.isPlaying, true);
    expect(cubit.state.isAnimating, true);
    final first = cubit.state.animationRevision;
    cubit.animationCompleted(first);
    expect(cubit.state.currentStepIndex, 1);
    cubit.animationCompleted(first);
    expect(cubit.state.currentStepIndex, 1);
    cubit.jumpToStep(0);
    expect(cubit.state.isPlaying, false);
    cubit.animationCompleted(cubit.state.animationRevision);
    expect(cubit.state.currentStepIndex, 0);
    expect(cubit.state.isAnimating, false);
    await cubit.close();
    cubit.animationCompleted(first);
  });

  test('Pause on last step resumes it; finished lesson restarts', () async {
    final cubit = PlayerCubit(solution);
    cubit.jumpToStep(solution.steps.length - 1);
    final revision = cubit.state.animationRevision;
    cubit.pause();
    cubit.play();
    expect(cubit.state.animationRevision, revision);
    expect(cubit.state.isLastStep, true);
    cubit.animationCompleted(revision);
    expect(cubit.state.isAnimating, false);
    cubit.play();
    expect(cubit.state.currentStepIndex, 0);
    await cubit.close();
  });

  test('Replay and inspection pause automatic navigation', () async {
    final cubit = PlayerCubit(solution);
    cubit.play();
    cubit.replay();
    expect(cubit.state.isPlaying, false);
    expect(cubit.state.isAnimating, true);
    final index = solution.steps.indexWhere(
      (s) => s.subCalculations.isNotEmpty,
    );
    cubit.jumpToStep(index);
    cubit.play();
    final calculation = cubit.state.currentStep!.subCalculations.first;
    cubit.inspectCell(calculation.targetRow, calculation.targetCol);
    expect(cubit.state.isAnimating, false);
    expect(cubit.state.isPlaying, false);
    expect(cubit.state.inspectedCalculation, isNotNull);
    await cubit.close();
  });

  test('Empty lessons and invalid speeds are safe', () async {
    final cubit = PlayerCubit(
      StepSolution(
        operationKey: 'empty',
        initialMatrix: Matrix.identity(1),
        finalMatrix: Matrix.identity(1),
        steps: const [],
      ),
      initialSpeed: double.nan,
    );
    cubit.play();
    cubit.replay();
    cubit.jumpToStep(5);
    cubit.setPlaybackSpeed(double.infinity);
    expect(cubit.state.currentStep, isNull);
    expect(cubit.state.playbackSpeed, 1);
    await cubit.close();
  });

  Widget gridHost({
    double speed = 1,
    bool running = true,
    bool reduced = false,
    int revision = 0,
    ValueChanged<int>? complete,
    VoidCallback? scrub,
  }) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: Scaffold(
        body: MatrixDisplayGrid(
          snapshot: step.matrixAfter,
          snapshotBefore: step.matrixBefore,
          transformation: step.transformation,
          highlights: step.highlights,
          isAnimating: running,
          animationRevision: revision,
          playbackSpeed: speed,
          onAnimationCompleted: complete,
          onScrubStart: scrub,
          // The drawer holding the scrub slider is built only while open.
          detailsInitiallyExpanded: true,
        ),
      ),
    ),
  );
  double progress(WidgetTester tester) => tester
      .widget<Slider>(
        find.byKey(const ValueKey('instruction-progress'), skipOffstage: false),
      )
      .value;

  testWidgets(
    'Speed changes preserve linear progress and completion fires once',
    (tester) async {
      final completed = <int>[];
      await tester.pumpWidget(gridHost(complete: completed.add));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      final before = progress(tester);
      expect(before, closeTo(450 / timeline.totalMs, .01));
      await tester.pumpWidget(gridHost(speed: 2, complete: completed.add));
      expect(progress(tester), closeTo(before, .01));
      await tester.pump();
      await tester.pump(
        Duration(milliseconds: ((timeline.totalMs - 450) / 2).ceil() + 17),
      );
      await tester.pump();
      expect(completed, [0]);
      await tester.pumpAndSettle();
      expect(completed, [0]);
    },
  );

  testWidgets(
    'Pause freezes frame, replay rejects stale step completion, scrub never advances',
    (tester) async {
      final completed = <int>[];
      var scrubs = 0;
      await tester.pumpWidget(gridHost(complete: completed.add));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpWidget(
        gridHost(running: false, complete: completed.add),
      );
      final before = progress(tester);
      await tester.pump(const Duration(seconds: 2));
      expect(progress(tester), before);
      await tester.pumpWidget(
        gridHost(revision: 2, complete: completed.add, scrub: () => scrubs++),
      );
      await tester.pump();
      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('instruction-progress'), skipOffstage: false),
      );
      slider.onChanged!(1);
      await tester.pumpAndSettle();
      expect(scrubs, 1);
      expect(completed, isEmpty);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Reduced motion shows final values but preserves reading interval',
    (tester) async {
      final completed = <int>[];
      await tester.pumpWidget(gridHost(reduced: true, complete: completed.add));
      await tester.pump();
      final cells = tester
          .widgetList<MatrixCellWidget>(find.byType(MatrixCellWidget))
          .toList();
      expect(cells[2].value, step.matrixAfter.get(1, 0));
      await tester.pump(Duration(milliseconds: timeline.totalMs - 1));
      expect(completed, isEmpty);
      await tester.pump(const Duration(milliseconds: 17));
      await tester.pump();
      expect(completed, [0]);
    },
  );

  testWidgets('Lesson autoplay waits for visible animation completion', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => SettingsCubit(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StepPlayerScreen(solution: solution, topicTitle: 'Test'),
        ),
      ),
    );
    await tester.pump();
    final cubit = tester
        .element(find.byType(MatrixDisplayGrid))
        .read<PlayerCubit>();
    expect(cubit.state.isPlaying, true);
    await tester.pump();
    await tester.pump(Duration(milliseconds: initialTimeline.totalMs - 1));
    expect(cubit.state.currentStepIndex, 0);
    await tester.pump(const Duration(milliseconds: 17));
    await tester.pump();
    expect(cubit.state.currentStepIndex, 1);
    cubit.pause();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    expect(cubit.state.currentStepIndex, 1);
  });
  testWidgets('Resizing across the split layout preserves paused progress', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => SettingsCubit(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StepPlayerScreen(solution: solution, topicTitle: 'Resize'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    final cubit = tester
        .element(find.byType(MatrixDisplayGrid))
        .read<PlayerCubit>();
    cubit.pause();
    await tester.pump();
    // The scrub slider is built only while Details is open; opening it only
    // pauses, which the lesson already is.
    final details = find.byKey(const ValueKey('operation-inspector'));
    await tester.ensureVisible(details);
    await tester.tap(details);
    await tester.pump();
    final before = progress(tester);
    tester.view.physicalSize = const Size(1280, 800);
    await tester.pumpAndSettle();
    expect(progress(tester), closeTo(before, .001));
    expect(cubit.state.currentStepIndex, 0);
  });

  testWidgets('Long signed fractions remain exact in a scrollable 5x5 scene', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final value = Rational.parse('-1234567890123456789/1234567');
    final snapshot = MatrixSnapshot(
      rows: 5,
      cols: 5,
      values: List.generate(5, (_) => List.filled(5, value)),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(2),
            disableAnimations: true,
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: MatrixDisplayGrid(
                snapshot: snapshot,
                highlights: const [],
                isAnimating: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final cells = tester.widgetList<MatrixCellWidget>(
      find.byType(MatrixCellWidget),
    );
    expect(cells.length, 25);
    expect(cells.every((cell) => cell.value == value), true);
    expect(
      find.descendant(
        of: find.byType(MatrixCellWidget),
        matching: find.byType(FittedBox),
      ),
      findsNothing,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: MatrixDisplayGrid(
                snapshot: snapshot,
                snapshotBefore: snapshot,
                transformation: step.transformation,
                highlights: const [],
                animationRevision: 1,
                isAnimating: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.byType(FittedBox), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(FittedBox), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('Scrubbing a finished last step allows resuming without restarting the lesson', () async {
    final cubit = PlayerCubit(solution);
    cubit.jumpToStep(solution.steps.length - 1);
    cubit.animationCompleted(cubit.state.animationRevision);
    cubit.scrub();
    final revision = cubit.state.animationRevision;
    cubit.play();
    expect(cubit.state.isLastStep, true);
    expect(cubit.state.animationRevision, revision);
    await cubit.close();
  });
  testWidgets('Prose renders signed rational parameters without raw LaTeX', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepCard(
            step: step,
            localizedTitle: 'Scale',
            localizedDescription:
                r'Multiply by -\frac{1}{4}, then add \frac{3}{2}.',
          ),
        ),
      ),
    );
    expect(find.text('Multiply by -1/4, then add 3/2.'), findsOneWidget);
  });
  testWidgets('Instructional badge text meets normal-text contrast', (
    tester,
  ) async {
    for (final type in [
      HighlightType.pivot,
      HighlightType.source,
      HighlightType.target,
      HighlightType.zeroed,
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatrixCellWidget(
              value: Rational.one,
              highlight: CellHighlight(
                row: 0,
                col: 0,
                type: type,
                badgeText: 'badge',
              ),
            ),
          ),
        ),
      );
      final text = tester.widget<Text>(find.text('badge'));
      final background = switch (type) {
        HighlightType.pivot => AppTheme.accentAmber,
        HighlightType.source => AppTheme.accentAmber,
        _ => AppTheme.accentCyan,
      };
      final a = text.style!.color!.computeLuminance();
      final b = background.computeLuminance();
      expect(
        (math.max(a, b) + .05) / (math.min(a, b) + .05),
        greaterThanOrEqualTo(4.5),
      );
    }
  });
}
