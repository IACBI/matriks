import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/features/step_player/widgets/instruction_timeline.dart';

void main() {
  testWidgets('5x5 elimination pump cost (debug harness, not raster timing)', (
    tester,
  ) async {
    final solution = GaussJordanSolver.solve(
      Matrix.fromInts([
        [1, 2, 3, 4, 5],
        [2, 5, 7, 9, 11],
        [3, 7, 12, 14, 16],
        [4, 9, 14, 20, 23],
        [5, 11, 16, 23, 30],
      ]),
    );
    final step = solution.steps.firstWhere(
      (s) => s.transformation is RowEliminationTransformation,
    );
    final timeline = InstructionTimeline.forTransformation(
      step.transformation,
      columns: step.matrixAfter.cols,
    );
    final frames = (timeline.totalMs / 16).ceil();
    final samples = <int>[];
    for (var run = 0; run < 4; run++) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MatrixDisplayGrid(
                key: ValueKey(run),
                snapshot: step.matrixAfter,
                snapshotBefore: step.matrixBefore,
                transformation: step.transformation,
                highlights: step.highlights,
                subCalculations: step.subCalculations,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      for (var frame = 0; frame < frames; frame++) {
        final watch = Stopwatch()..start();
        await tester.pump(const Duration(milliseconds: 16));
        watch.stop();
        if (run > 0) samples.add(watch.elapsedMicroseconds);
      }
      await tester.pumpAndSettle();
    }
    samples.sort();
    debugPrint(
      jsonEncode({
        'samples': samples.length,
        'instructionDurationMs': timeline.totalMs,
        'medianPumpUs': samples[samples.length ~/ 2],
        'p95PumpUs': samples[(samples.length * .95).floor()],
      }),
    );
  });
}
