import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_engine/matrix_engine.dart';

import 'player_state.dart';
import '../../settings/cubit/settings_state.dart';

/// Lesson navigation. The visible animation owns time; no independent timer
/// can advance a step while its explanation is still running.
class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit(
    StepSolution solution, {
    double initialSpeed = 1.0,
    SolutionMode mode = SolutionMode.guided,
  }) : super(
         PlayerState(
           mode: mode,
           isPlaying: mode == SolutionMode.guided && solution.steps.isNotEmpty,
           isAnimating:
               mode == SolutionMode.guided && solution.steps.isNotEmpty,
           hasCompletedAnimation: mode != SolutionMode.guided,
           solution: solution,
           playbackSpeed: initialSpeed.isFinite && initialSpeed > 0
               ? initialSpeed.clamp(0.25, 4.0)
               : 1,
         ),
       );

  void togglePlayPause() {
    if (state.isAnimating) {
      pause();
    } else {
      play();
    }
  }

  void play() {
    if (state.mode != SolutionMode.guided) return;
    if (state.totalSteps == 0) return;
    if (state.isLastStep && state.hasCompletedAnimation) {
      _selectStep(0, autoplay: true);
    } else if (state.hasCompletedAnimation) {
      _selectStep(state.currentStepIndex, autoplay: true);
    } else {
      emit(state.copyWith(isPlaying: true, isAnimating: true));
    }
  }

  void pause() => emit(state.copyWith(isPlaying: false, isAnimating: false));

  void scrub() => emit(
    state.copyWith(
      isPlaying: false,
      isAnimating: false,
      hasCompletedAnimation: false,
    ),
  );

  void nextStep() {
    if (!state.isLastStep) {
      _selectStep(state.currentStepIndex + 1);
    } else {
      pause();
    }
  }

  void prevStep() {
    if (!state.isFirstStep) {
      _selectStep(state.currentStepIndex - 1);
    } else {
      pause();
    }
  }

  void jumpToStep(int stepIndex) {
    if (state.totalSteps == 0) return;
    _selectStep(stepIndex.clamp(0, state.totalSteps - 1));
  }

  void replay() {
    if (state.totalSteps > 0) _selectStep(state.currentStepIndex);
  }

  void _selectStep(int index, {bool autoplay = false}) {
    emit(
      state.copyWith(
        currentStepIndex: index,
        isPlaying: autoplay,
        mode: state.mode == SolutionMode.result
            ? SolutionMode.steps
            : state.mode,
        isAnimating: state.mode == SolutionMode.guided,
        hasCompletedAnimation: state.mode != SolutionMode.guided,
        animationRevision: state.animationRevision + 1,
        inspectedCalculation: () => null,
      ),
    );
  }

  /// A revision also distinguishes repeated visits to the same step.
  void animationCompleted(int revision) {
    if (isClosed || revision != state.animationRevision || !state.isAnimating) {
      return;
    }
    if (state.isPlaying && !state.isLastStep) {
      _selectStep(state.currentStepIndex + 1, autoplay: true);
    } else {
      emit(
        state.copyWith(
          isPlaying: false,
          isAnimating: false,
          hasCompletedAnimation: true,
        ),
      );
    }
  }

  void setPlaybackSpeed(double speed) {
    if (!speed.isFinite || speed <= 0) return;
    emit(state.copyWith(playbackSpeed: speed.clamp(0.25, 4.0)));
  }

  void setMode(SolutionMode mode) {
    if (state.mode == mode) return;
    emit(
      state.copyWith(
        mode: mode,
        isPlaying: mode == SolutionMode.guided && state.totalSteps > 0,
        isAnimating: mode == SolutionMode.guided,
        hasCompletedAnimation: mode != SolutionMode.guided,
        animationRevision: state.animationRevision + 1,
        inspectedCalculation: () => null,
      ),
    );
  }

  void showResult() => setMode(SolutionMode.result);

  void inspectCell(int row, int col) {
    final step = state.currentStep;
    if (step == null) return;

    SubCalculation? match;
    for (final sub in step.subCalculations) {
      if (sub.targetRow == row && sub.targetCol == col) {
        match = sub;
        break;
      }
    }

    if (match != null) {
      emit(
        state.copyWith(
          isPlaying: false,
          isAnimating: false,
          inspectedCalculation: () => match,
        ),
      );
    }
  }

  void closeInspection() {
    emit(state.copyWith(inspectedCalculation: () => null));
  }
}
