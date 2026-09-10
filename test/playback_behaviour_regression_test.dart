import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/settings/cubit/settings_state.dart';
import 'package:matriks/features/step_player/cubit/player_state.dart';
import 'package:matriks/features/step_player/widgets/instruction_timeline.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';
import 'package:matrix_engine/matrix_engine.dart';

/// The animation controller owns lesson time, so these checks drive a real
/// widget clock rather than asserting on cubit state alone.
Widget _host(PlayerCubit cubit) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: BlocBuilder<PlayerCubit, PlayerState>(
        bloc: cubit,
        builder: (context, state) {
          final step = state.currentStep!;
          return SingleChildScrollView(
            child: MatrixDisplayGrid(
              key: const ValueKey('grid'),
              snapshot: step.matrixAfter,
              snapshotBefore: step.matrixBefore,
              highlights: step.highlights,
              subCalculations: step.subCalculations,
              transformation: step.transformation,
              playbackSpeed: state.playbackSpeed,
              stepIndex: state.currentStepIndex,
              isAnimating: state.isAnimating,
              animationRevision: state.animationRevision,
              onAnimationCompleted: cubit.animationCompleted,
              onScrubStart: cubit.scrub,
              onReplay: cubit.replay,
            ),
          );
        },
      ),
    ),
  );
}

StepSolution _elimination() => GaussJordanSolver.solve(
  Matrix.fromInts([
    [2, 4, 6],
    [1, 3, 5],
    [0, 1, 2],
  ]),
);

int _totalMs(StepSolution s, int index) =>
    InstructionTimeline.forTransformation(s.steps[index].transformation)
        .totalMs;

/// A step's controller only starts at the end of the frame after its widget is
/// rebuilt, so lesson time is sampled with a uniform tick instead of one long
/// jump; mixing the two misattributes where a step began.
const Duration _tick = Duration(milliseconds: 100);

/// Restarting a step costs a few post-frame callbacks. This is the settling
/// budget on top of a nominal animation, never a second whole animation.
const int _restartSlackMs = 700;

Future<void> _advanceUntil(
  WidgetTester tester,
  bool Function() done, {
  required Duration budget,
}) async {
  var spent = Duration.zero;
  while (spent < budget) {
    await tester.pump(_tick);
    spent += _tick;
    if (done()) return;
  }
}

/// Ticks uniformly and returns the elapsed milliseconds between each observed
/// step change.
Future<List<int>> _stepGaps(
  WidgetTester tester,
  PlayerCubit cubit, {
  required int changes,
  int limitMs = 90000,
}) async {
  final gaps = <int>[];
  var elapsed = 0;
  var lastChange = 0;
  var lastIndex = cubit.state.currentStepIndex;
  while (gaps.length < changes && elapsed < limitMs) {
    await tester.pump(_tick);
    elapsed += _tick.inMilliseconds;
    if (cubit.state.currentStepIndex != lastIndex) {
      expect(
        cubit.state.currentStepIndex,
        lastIndex + 1,
        reason: 'autoplay skipped a step',
      );
      lastIndex = cubit.state.currentStepIndex;
      gaps.add(elapsed - lastChange);
      lastChange = elapsed;
    }
  }
  return gaps;
}

void main() {
  testWidgets('Autoplay advances one step per completed animation', (
    tester,
  ) async {
    final solution = _elimination();
    final nominal = _totalMs(solution, 0);
    for (final step in solution.steps) {
      expect(
        InstructionTimeline.forTransformation(step.transformation).totalMs,
        nominal,
        reason: 'fixture assumes a uniform step duration',
      );
    }
    final cubit = PlayerCubit(solution);
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await tester.pump();

    expect(cubit.state.currentStepIndex, 0);
    expect(cubit.state.isPlaying, isTrue);

    final gaps = await _stepGaps(tester, cubit, changes: 3);
    expect(gaps.length, 3, reason: 'autoplay stalled: $gaps');
    for (final gap in gaps) {
      // Below the nominal budget means an independent timer drove the lesson;
      // far above it means a step was left waiting after its animation ended.
      expect(
        gap,
        greaterThanOrEqualTo(nominal),
        reason: 'a step advanced before its animation finished: $gaps',
      );
      expect(
        gap,
        lessThanOrEqualTo(nominal + _restartSlackMs),
        reason: 'a step lingered after its animation finished: $gaps',
      );
    }
    cubit.pause();
    await tester.pumpAndSettle();
  });

  testWidgets('Pause freezes progress and resume continues the same step', (
    tester,
  ) async {
    final solution = _elimination();
    final nominal = _totalMs(solution, 0);
    final cubit = PlayerCubit(solution);
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await tester.pump();

    await _advanceUntil(
      tester,
      () => false,
      budget: Duration(milliseconds: nominal ~/ 2),
    );
    cubit.pause();
    await tester.pump();
    final frozen = cubit.state.currentStepIndex;
    expect(frozen, 0, reason: 'the first step ended before it was paused');

    // Far beyond a full animation: a paused lesson must not advance.
    await _advanceUntil(
      tester,
      () => false,
      budget: const Duration(seconds: 20),
    );
    expect(cubit.state.currentStepIndex, frozen);
    expect(cubit.state.isPlaying, isFalse);
    expect(cubit.state.isAnimating, isFalse);

    cubit.play();
    await tester.pump();
    expect(cubit.state.isAnimating, isTrue);

    final gaps = await _stepGaps(tester, cubit, changes: 1);
    expect(gaps.length, 1, reason: 'resume did not continue the lesson');
    expect(cubit.state.currentStepIndex, frozen + 1);
    // Resume replays the whole step, so the remaining budget is a full one.
    expect(gaps.single, lessThanOrEqualTo(nominal + _restartSlackMs));
    cubit.pause();
    await tester.pumpAndSettle();
  });

  testWidgets('Speed change mid-operation keeps the step and rescales time', (
    tester,
  ) async {
    final solution = _elimination();
    final cubit = PlayerCubit(solution);
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await tester.pump();

    final nominal = _totalMs(solution, 0);
    await _advanceUntil(
      tester,
      () => false,
      budget: Duration(milliseconds: nominal ~/ 4),
    );
    expect(cubit.state.currentStepIndex, 0);

    cubit.setPlaybackSpeed(4);
    await tester.pump();
    expect(
      cubit.state.currentStepIndex,
      0,
      reason: 'speed change skipped a step',
    );
    expect(cubit.state.playbackSpeed, 4);

    // The remainder now runs four times faster, so the step must finish well
    // inside what the unscaled timeline would still have needed.
    await _advanceUntil(
      tester,
      () => cubit.state.currentStepIndex != 0,
      budget: Duration(milliseconds: nominal ~/ 2),
    );
    expect(
      cubit.state.currentStepIndex,
      1,
      reason: 'speed increase did not shorten the remaining animation',
    );
    cubit.pause();
    await tester.pumpAndSettle();
  });

  testWidgets('Speed is clamped and invalid values are ignored', (
    tester,
  ) async {
    final cubit = PlayerCubit(_elimination());
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await tester.pump();
    cubit.pause();

    cubit.setPlaybackSpeed(99);
    expect(cubit.state.playbackSpeed, 4);
    cubit.setPlaybackSpeed(0.01);
    expect(cubit.state.playbackSpeed, 0.25);
    cubit.setPlaybackSpeed(0);
    expect(cubit.state.playbackSpeed, 0.25);
    cubit.setPlaybackSpeed(double.nan);
    expect(cubit.state.playbackSpeed, 0.25);
    cubit.setPlaybackSpeed(double.infinity);
    expect(cubit.state.playbackSpeed, 0.25);
    await tester.pumpAndSettle();
  });

  testWidgets('Manual navigation stops autoplay and never skips a step', (
    tester,
  ) async {
    final solution = _elimination();
    final cubit = PlayerCubit(solution);
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await tester.pump();
    cubit.pause();
    await tester.pump();

    for (var i = 1; i < 4; i++) {
      cubit.nextStep();
      await tester.pump();
      expect(cubit.state.currentStepIndex, i);
      expect(
        cubit.state.isPlaying,
        isFalse,
        reason: 'manual navigation resumed automatic progression',
      );
    }
    for (var i = 2; i >= 0; i--) {
      cubit.prevStep();
      await tester.pump();
      expect(cubit.state.currentStepIndex, i);
      expect(cubit.state.isPlaying, isFalse);
    }
    await tester.pumpAndSettle();
  });

  testWidgets('Jump clamps out-of-range targets instead of throwing', (
    tester,
  ) async {
    final solution = _elimination();
    final cubit = PlayerCubit(solution);
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await tester.pump();
    cubit.pause();

    cubit.jumpToStep(9999);
    await tester.pump();
    expect(cubit.state.currentStepIndex, solution.steps.length - 1);
    cubit.jumpToStep(-5);
    await tester.pump();
    expect(cubit.state.currentStepIndex, 0);
    await tester.pumpAndSettle();
  });

  testWidgets('A completion callback for a stale revision is rejected', (
    tester,
  ) async {
    final solution = _elimination();
    final cubit = PlayerCubit(solution);
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await tester.pump();

    final staleRevision = cubit.state.animationRevision;
    cubit.jumpToStep(2);
    await tester.pump();
    final index = cubit.state.currentStepIndex;
    expect(cubit.state.animationRevision, isNot(staleRevision));

    cubit.animationCompleted(staleRevision);
    await tester.pump();
    expect(
      cubit.state.currentStepIndex,
      index,
      reason: 'a stale animation completion advanced the lesson',
    );
    cubit.pause();
    await tester.pumpAndSettle();
  });

  testWidgets('Rapid navigation during playback lands on one settled step', (
    tester,
  ) async {
    final solution = _elimination();
    final cubit = PlayerCubit(solution);
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await tester.pump();

    // Hammer navigation inside a single frame budget.
    for (var i = 0; i < 6; i++) {
      cubit.nextStep();
      cubit.prevStep();
      await tester.pump(const Duration(milliseconds: 16));
    }
    final settled = cubit.state.currentStepIndex;
    expect(settled, inInclusiveRange(0, solution.steps.length - 1));
    cubit.pause();
    await tester.pump();
    await tester.pump(const Duration(seconds: 15));
    expect(
      cubit.state.currentStepIndex,
      settled,
      reason: 'a queued completion fired after pause',
    );
    await tester.pumpAndSettle();
  });

  testWidgets('Scrubbing stops playback and replay restarts the same step', (
    tester,
  ) async {
    final solution = _elimination();
    final cubit = PlayerCubit(solution);
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await tester.pump();

    cubit.jumpToStep(2);
    await tester.pump();
    cubit.scrub();
    await tester.pump();
    expect(cubit.state.isPlaying, isFalse);
    expect(cubit.state.isAnimating, isFalse);
    expect(cubit.state.hasCompletedAnimation, isFalse);

    await tester.pump(const Duration(seconds: 15));
    expect(
      cubit.state.currentStepIndex,
      2,
      reason: 'scrubbed lesson kept advancing',
    );

    final revision = cubit.state.animationRevision;
    cubit.replay();
    await tester.pump();
    expect(cubit.state.currentStepIndex, 2);
    expect(cubit.state.animationRevision, greaterThan(revision));
    cubit.pause();
    await tester.pumpAndSettle();
  });

  testWidgets('Finishing the last step stops instead of wrapping', (
    tester,
  ) async {
    final solution = DeterminantSolver.solve(
      Matrix.fromInts([
        [3, 1],
        [2, 4],
      ]),
    );
    final cubit = PlayerCubit(solution);
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await tester.pump();

    for (var i = 0; i < solution.steps.length + 2; i++) {
      await tester.pump(const Duration(seconds: 10));
      await tester.pump();
    }
    expect(cubit.state.currentStepIndex, solution.steps.length - 1);
    expect(cubit.state.isPlaying, isFalse);
    expect(cubit.state.hasCompletedAnimation, isTrue);

    // Play on a finished lesson restarts from the beginning.
    cubit.play();
    await tester.pump();
    expect(cubit.state.currentStepIndex, 0);
    cubit.pause();
    await tester.pumpAndSettle();
  });

  testWidgets('Mode switches invalidate the running animation revision', (
    tester,
  ) async {
    final solution = _elimination();
    final cubit = PlayerCubit(solution);
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await tester.pump();

    final revision = cubit.state.animationRevision;
    cubit.setMode(SolutionMode.steps);
    await tester.pump();
    expect(cubit.state.animationRevision, greaterThan(revision));
    expect(cubit.state.isPlaying, isFalse);
    expect(cubit.state.hasCompletedAnimation, isTrue);

    await tester.pump(const Duration(seconds: 15));
    expect(
      cubit.state.isPlaying,
      isFalse,
      reason: 'static steps resumed automatic playback',
    );

    cubit.setMode(SolutionMode.guided);
    await tester.pump();
    expect(cubit.state.isPlaying, isTrue);
    expect(cubit.state.isAnimating, isTrue);
    cubit.pause();
    await tester.pumpAndSettle();
  });

  testWidgets('Inspecting a cell pauses the lesson', (tester) async {
    final solution = _elimination();
    final cubit = PlayerCubit(solution);
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await tester.pump();

    final index = solution.steps.indexWhere(
      (s) => s.subCalculations.isNotEmpty,
    );
    expect(index, greaterThanOrEqualTo(0));
    cubit.jumpToStep(index);
    await tester.pump();
    final sub = solution.steps[index].subCalculations.first;
    cubit.inspectCell(sub.targetRow, sub.targetCol);
    await tester.pump();

    expect(cubit.state.inspectedCalculation, isNotNull);
    expect(cubit.state.isPlaying, isFalse);
    await tester.pump(const Duration(seconds: 15));
    expect(
      cubit.state.currentStepIndex,
      index,
      reason: 'inspection did not stop automatic progression',
    );
    await tester.pumpAndSettle();
  });

  testWidgets('Disposing mid-animation does not deliver a late completion', (
    tester,
  ) async {
    final cubit = PlayerCubit(_elimination());
    await tester.pumpWidget(_host(cubit));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump(const Duration(seconds: 15));
    await cubit.close();
    // Reaching here without an exception is the assertion.
    expect(cubit.isClosed, isTrue);
  });
}
