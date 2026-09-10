import 'package:matrix_engine/matrix_engine.dart';

/// Reading time belongs to the lesson; only spatial movement is eased.
enum InstructionPhase { source, operation, result }

class InstructionTimeline {
  final int sourceMs;
  final int operationMs;
  final int resultMs;

  const InstructionTimeline({
    this.sourceMs = 1400,
    this.operationMs = 2200,
    this.resultMs = 2200,
  });

  factory InstructionTimeline.forTransformation(StepTransformation? step) {
    if (step is RowSwapTransformation) {
      return const InstructionTimeline(
        sourceMs: 1200,
        operationMs: 1100,
        resultMs: 1700,
      );
    }
    if (step is RowEliminationTransformation ||
        step is RowScaleTransformation) {
      return const InstructionTimeline(
        sourceMs: 1500,
        operationMs: 3600,
        resultMs: 2400,
      );
    }
    final int count;
    if (step is MatrixElementMultiplicationTransformation) {
      count = step.rowElements.length.clamp(1, 5);
    } else if (step is DeterminantDiagonalProductTransformation) {
      count = step.diagonalElements.length;
    } else if (step is DeterminantSarrusTransformation) {
      count = step.phase == 3 ? 6 : 3;
    } else if (step is DeterminantCrossProductTransformation) {
      count = step.phase == 3 ? 2 : 1;
    } else {
      return const InstructionTimeline();
    }
    return InstructionTimeline(
      sourceMs: 1500,
      operationMs: count * 1400,
      resultMs: 2600,
    );
  }

  int get totalMs => sourceMs + operationMs + resultMs;

  InstructionPhase phase(double progress) => progress < sourceMs / totalMs
      ? InstructionPhase.source
      : progress < (sourceMs + operationMs) / totalMs
      ? InstructionPhase.operation
      : InstructionPhase.result;

  double operationProgress(double progress) =>
      ((progress * totalMs - sourceMs) / operationMs).clamp(0.0, 1.0);

  Duration duration(double speed) => Duration(
    microseconds: (totalMs * 1000 / (speed.isFinite && speed > 0 ? speed : 1))
        .round(),
  );
}
