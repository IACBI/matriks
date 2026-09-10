import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/features/step_player/widgets/instruction_timeline.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

// Optional debug workload. RSS includes the test runtime and is not a leak test
// or a substitute for release-mode GPU/heap profiling on target devices.
void main() {
  for (final fractions in [false, true]) {
    testWidgets('Repeated 5x5 multiplication, fractions=$fractions', (
      tester,
    ) async {
      final matrix = Matrix(
        List.generate(
          5,
          (r) => List.generate(
            5,
            (c) => fractions
                ? Rational(
                    BigInt.parse('-123456789012345') + BigInt.from(r + c),
                    BigInt.parse('987654321012347'),
                  )
                : Rational.fromInt(r + c + 1),
          ),
        ),
      );
      final solution = MatrixArithmeticSolver.multiply(matrix, matrix);
      final samples = <int>[];
      final rss = <int>[];
      for (var run = 0; run < 8; run++) {
        final step = solution.steps[run % solution.steps.length];
        final timeline = InstructionTimeline.forTransformation(
          step.transformation,
        );
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: MatrixDisplayGrid(
                  snapshot: step.matrixAfter,
                  snapshotBefore: step.matrixBefore,
                  transformation: step.transformation,
                  highlights: step.highlights,
                  subCalculations: step.subCalculations,
                  animationRevision: run,
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        for (var frame = 0; frame < (timeline.totalMs / 16).ceil(); frame++) {
          final watch = Stopwatch()..start();
          await tester.pump(const Duration(milliseconds: 16));
          watch.stop();
          if (run > 0) samples.add(watch.elapsedMicroseconds);
        }
        await tester.pumpAndSettle();
        rss.add(ProcessInfo.currentRss);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      samples.sort();
      debugPrint(
        jsonEncode({
          'fractions': fractions,
          'samples': samples.length,
          'medianPumpUs': samples[samples.length ~/ 2],
          'p95PumpUs': samples[(samples.length * .95).floor()],
          'processRssAfterEachRunBytes': rss,
          'processRssAfterDisposalBytes': ProcessInfo.currentRss,
        }),
      );
    });
  }
}
