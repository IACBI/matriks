import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/core/number_format.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/step_player/widgets/matrix_cell_widget.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

/// The measurement before bounding: every number converted to text.
int exactDigits(StepSolution solution, {required bool decimal}) {
  var digits = 1;
  for (final step in solution.steps) {
    for (final snapshot in [step.matrixBefore, step.matrixAfter]) {
      for (final row in snapshot.values) {
        for (final value in row) {
          final latex = decimalLatex(value);
          final fraction = math.max(
            value.num.toString().length,
            value.den.toString().length,
          );
          digits = math.max(
            digits,
            !decimal || latex.contains(r'\frac')
                ? fraction
                : latex
                      .replaceAll(r'\overline{', '')
                      .replaceAll('}', '')
                      .length,
          );
        }
      }
    }
  }
  return digits;
}

BigInt randomDigits(math.Random random, int count) => BigInt.parse(
  List.generate(
    count,
    (i) => random.nextInt(i == 0 ? 9 : 10) + (i == 0 ? 1 : 0),
  ).join(),
);

/// Gauss-Jordan on 5×5 entries with 30-digit numerators and denominators:
/// intermediate entries run to hundreds of digits.
StepSolution hugeSolution() {
  final random = math.Random(3);
  final matrix = Matrix([
    for (var r = 0; r < 5; r++)
      [
        for (var c = 0; c < 5; c++)
          Rational(randomDigits(random, 30), randomDigits(random, 30)),
      ],
  ]);
  return GaussJordanSolver.solve(
    matrix,
    const EliminationOptions(toRref: true),
  );
}

Widget _host(Widget child) => BlocProvider(
  create: (_) => SettingsCubit(),
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ),
);

void main() {
  test('layoutLength is exact to 130 bits and a bound of 40+ beyond', () {
    for (var bits = 0; bits <= 400; bits++) {
      final power = BigInt.one << bits;
      for (final n in [power - BigInt.one, power, power + BigInt.one]) {
        for (final signed in [n, -n]) {
          final exact = signed.toString().length;
          if (signed.abs().bitLength <= 130) {
            expect(layoutLength(signed), exact, reason: '$signed');
          } else {
            expect(layoutLength(signed), lessThanOrEqualTo(exact));
            expect(layoutLength(signed), greaterThanOrEqualTo(40));
          }
        }
      }
    }
  });

  test('the hint matches the exact measurement for ordinary solutions', () {
    final random = math.Random(5);
    for (var i = 0; i < 40; i++) {
      final n = 2 + i % 4;
      final matrix = Matrix([
        for (var r = 0; r < n; r++)
          [
            for (var c = 0; c < n; c++)
              Rational(random.nextInt(41) - 20, random.nextInt(9) + 1),
          ],
      ]);
      for (final solution in [
        GaussJordanSolver.solve(matrix, const EliminationOptions(toRref: true)),
        InverseSolver.solve(matrix),
        DeterminantSolver.solve(matrix),
      ]) {
        for (final decimal in [false, true]) {
          expect(
            MatrixLayoutHint.forSolution(
              solution,
              decimal: decimal,
            ).minimumDigits,
            exactDigits(solution, decimal: decimal),
          );
        }
      }
    }
  });

  test('huge entries saturate the hint in both views', () {
    final solution = hugeSolution();
    for (final decimal in [false, true]) {
      final exact = exactDigits(solution, decimal: decimal);
      final hint = MatrixLayoutHint.forSolution(solution, decimal: decimal);
      expect(exact, greaterThan(300));
      expect(hint.minimumDigits, greaterThanOrEqualTo(40));
      expect(hint.minimumDigits, lessThanOrEqualTo(exact));
    }
  });

  testWidgets('a bounded hint gives the same cell width as the exact one', (
    tester,
  ) async {
    final solution = hugeSolution();
    final snapshot = MatrixSnapshot.fromMatrix(Matrix.identity(3));
    Future<Size> cellSize(MatrixLayoutHint hint) async {
      await tester.pumpWidget(
        _host(
          SingleChildScrollView(
            child: MatrixDisplayGrid(
              snapshot: snapshot,
              highlights: const [],
              isAnimating: false,
              layoutHint: hint,
            ),
          ),
        ),
      );
      await tester.pump();
      return tester.getSize(find.byType(MatrixCellWidget).first);
    }

    final bounded = await cellSize(
      MatrixLayoutHint.forSolution(solution, decimal: false),
    );
    final exact = await cellSize(
      MatrixLayoutHint(minimumDigits: exactDigits(solution, decimal: false)),
    );
    // Just under saturation still grows with every digit.
    final belowSaturation = await cellSize(
      const MatrixLayoutHint(minimumDigits: 25),
    );
    expect(bounded, exact);
    expect(belowSaturation.width, lessThan(exact.width));
  });
}
