import 'package:matrix_engine/matrix_engine.dart';

import '../../settings/cubit/settings_state.dart';

class PlayerState {
  final SolutionMode mode;
  final StepSolution solution;
  final int currentStepIndex;
  final bool isPlaying;
  final bool isAnimating;
  final bool hasCompletedAnimation;
  final int animationRevision;
  final double playbackSpeed;
  final SubCalculation? inspectedCalculation;

  const PlayerState({
    this.mode = SolutionMode.guided,
    required this.solution,
    this.currentStepIndex = 0,
    this.isPlaying = false,
    this.isAnimating = true,
    this.hasCompletedAnimation = false,
    this.animationRevision = 0,
    this.playbackSpeed = 1.0,
    this.inspectedCalculation,
  });

  MatrixStep? get currentStep =>
      solution.steps.isNotEmpty && currentStepIndex < solution.steps.length
      ? solution.steps[currentStepIndex]
      : null;

  bool get isFirstStep => currentStepIndex == 0;
  bool get isLastStep => currentStepIndex >= solution.steps.length - 1;
  int get totalSteps => solution.steps.length;

  PlayerState copyWith({
    SolutionMode? mode,
    StepSolution? solution,
    int? currentStepIndex,
    bool? isPlaying,
    bool? isAnimating,
    bool? hasCompletedAnimation,
    int? animationRevision,
    double? playbackSpeed,
    SubCalculation? Function()? inspectedCalculation,
  }) {
    return PlayerState(
      mode: mode ?? this.mode,
      solution: solution ?? this.solution,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isAnimating: isAnimating ?? this.isAnimating,
      hasCompletedAnimation:
          hasCompletedAnimation ?? this.hasCompletedAnimation,
      animationRevision: animationRevision ?? this.animationRevision,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      inspectedCalculation: inspectedCalculation != null
          ? inspectedCalculation()
          : this.inspectedCalculation,
    );
  }
}
