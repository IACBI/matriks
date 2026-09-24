import 'dart:math' as math;

import 'package:matrix_engine/matrix_engine.dart';

/// Reading time belongs to the lesson; only spatial movement is eased.
enum InstructionPhase { source, operation, result }

/// Columns a row operation actually changes, in order.
///
/// Where the source row (or the scaled row) holds 0 the entry cannot change,
/// so animating "0 - 2·0" there only spends the learner's time. Any other
/// transformation reports every column.
List<int> changingColumns(
  StepTransformation? step,
  MatrixSnapshot? before,
  int columns,
) {
  final all = List<int>.generate(columns, (c) => c);
  if (before == null) return all;
  final int row;
  if (step is RowEliminationTransformation) {
    row = step.sourceRow;
  } else if (step is RowScaleTransformation) {
    row = step.row;
  } else {
    return all;
  }
  if (row >= before.rows) return all;
  final changing = [
    for (final c in all)
      if (c < before.cols && !before.get(row, c).isZero) c,
  ];
  return changing.isEmpty ? all : changing;
}

class InstructionTimeline {
  final int sourceMs;
  final int operationMs;
  final int resultMs;

  const InstructionTimeline({
    this.sourceMs = 1400,
    this.operationMs = 2200,
    this.resultMs = 2200,
  });

  /// Reading time for one row operation column. Elimination and scaling
  /// reveal one changing column at a time, so wider rows get proportionally
  /// longer; three columns or fewer keep the 3600 ms operation phase.
  static const rowOperationColumnMs = 1200;

  /// [columns] is the number of columns the operation changes (see
  /// [changingColumns]); [cells] the number of entries of the matrix.
  factory InstructionTimeline.forTransformation(
    StepTransformation? step, {
    int columns = 3,
    int cells = 4,
  }) {
    if (step is RowSwapTransformation) {
      return const InstructionTimeline(
        sourceMs: 1200,
        operationMs: 1100,
        resultMs: 1700,
      );
    }
    if (step is RowEliminationTransformation ||
        step is RowScaleTransformation) {
      return InstructionTimeline(
        sourceMs: 1500,
        operationMs: math.max(3, columns) * rowOperationColumnMs,
        resultMs: 2400,
      );
    }
    // One addition is quick to read; a long sum of cells should not drag.
    if (step is MatrixElementAdditionTransformation) {
      return const InstructionTimeline(
        sourceMs: 900,
        operationMs: 1300,
        resultMs: 1200,
      );
    }
    if (step is AdjugateTransformation) {
      return const InstructionTimeline(
        sourceMs: 1400,
        operationMs: 2400,
        resultMs: 1800,
      );
    }
    if (step is MatrixScaleTransformation) {
      return InstructionTimeline(
        sourceMs: 1500,
        operationMs: math.max(1, cells) * 900,
        resultMs: 2000,
      );
    }
    final int count;
    if (step is MatrixElementMultiplicationTransformation) {
      count = step.rowElements.length.clamp(1, 5);
    } else if (step is DeterminantDiagonalProductTransformation) {
      count = step.diagonalElements.length;
    } else if (step is DeterminantSarrusTransformation) {
      // A recap only combines the two totals already shown.
      count = step.recap ? 1 : (step.phase == 3 ? 6 : 3);
    } else if (step is DeterminantCrossProductTransformation) {
      count = step.recap ? 1 : (step.phase == 3 ? 2 : 1);
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
