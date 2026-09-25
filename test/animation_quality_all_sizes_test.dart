import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/core/theme/app_theme.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';
import 'package:matrix_engine/matrix_engine.dart';

/// Drives every topic's lesson to completion at every supported matrix size.
/// A lesson must finish on its own, land on the last step, never skip a step
/// and never throw while animating.

Matrix _sample(int rows, int cols) => Matrix(
  List.generate(
    rows,
    (r) => List.generate(cols, (c) {
      // Mixed signs and denominators; a zero on the leading diagonal forces
      // pivot searches and row swaps rather than a trivial path.
      final n = (r == 0 && c == 0)
          ? 0
          : ((r + c).isEven ? 1 : -1) * (r * 3 + c + 2);
      return Rational(BigInt.from(n), BigInt.from((c % 3) + 1));
    }),
  ),
);

Map<String, StepSolution> _lessons() {
  final out = <String, StepSolution>{};
  for (var n = 1; n <= 5; n++) {
    out['rref $n'] = GaussJordanSolver.solve(_sample(n, n));
    out['ref $n'] = GaussJordanSolver.solve(
      _sample(n, n),
      const EliminationOptions(toRref: false),
    );
    out['determinant $n'] = DeterminantSolver.solve(_sample(n, n));
    out['inverse $n'] = InverseSolver.solve(_sample(n, n));
    out['rank $n'] = RankNullitySolver.solve(_sample(n, n));
    out['lu $n'] = LUDecompositionSolver.solve(_sample(n, n));
    out['add $n'] = MatrixArithmeticSolver.add(_sample(n, n), _sample(n, n));
    out['multiply $n'] = MatrixArithmeticSolver.multiply(
      _sample(n, n),
      _sample(n, n),
    );
    if (n >= 2) {
      out['system $n'] = LinearSystemsSolver.solve(_sample(n, n + 1));
    }
    if (n == 2 || n == 3) {
      out['eigen $n'] = EigenSolver.solve(_sample(n, n));
    }
  }
  // Rectangular shapes the catalog also allows.
  out['rref 2x5'] = GaussJordanSolver.solve(_sample(2, 5));
  out['rref 5x2'] = GaussJordanSolver.solve(_sample(5, 2));
  out['rank 3x5'] = RankNullitySolver.solve(_sample(3, 5));
  out['multiply 2x5*5x3'] = MatrixArithmeticSolver.multiply(
    _sample(2, 5),
    _sample(5, 3),
  );
  out['add 5x2'] = MatrixArithmeticSolver.add(_sample(5, 2), _sample(5, 2));
  return out;
}

Widget _host(Widget child, {bool dark = false}) => BlocProvider(
  create: (_) => SettingsCubit(),
  child: MaterialApp(
    theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: child,
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final lessons = _lessons();

  group('Every lesson animates to completion', () {
    lessons.forEach((label, solution) {
      testWidgets(label, (tester) async {
        if (solution.steps.isEmpty) {
          // Unsupported combinations must fail loudly, not animate an empty
          // lesson; nothing to drive here.
          expect(solution.isSuccess, isFalse, reason: '$label: empty lesson');
          return;
        }
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _host(StepPlayerScreen(solution: solution, topicTitle: label)),
        );
        await tester.pump();

        final cubit = tester
            .element(find.byType(MatrixDisplayGrid))
            .read<PlayerCubit>();
        // 4x keeps virtual time bounded on long 5x5 eliminations.
        cubit.setPlaybackSpeed(4);
        await tester.pump();

        final total = solution.steps.length;
        var seen = cubit.state.currentStepIndex;
        var elapsed = 0;
        const tick = Duration(milliseconds: 100);
        const cap = 400000;

        while (elapsed < cap &&
            !(cubit.state.currentStepIndex == total - 1 &&
                cubit.state.hasCompletedAnimation)) {
          await tester.pump(tick);
          elapsed += tick.inMilliseconds;
          final now = cubit.state.currentStepIndex;
          if (now != seen) {
            expect(
              now,
              seen + 1,
              reason: '$label: autoplay jumped $seen -> $now',
            );
            seen = now;
          }
          expect(
            tester.takeException(),
            isNull,
            reason: '$label: threw at step ${cubit.state.currentStepIndex}',
          );
        }

        expect(
          cubit.state.currentStepIndex,
          total - 1,
          reason:
              '$label: stalled at step ${cubit.state.currentStepIndex} '
              'of $total after ${elapsed}ms',
        );
        expect(
          cubit.state.hasCompletedAnimation,
          isTrue,
          reason: '$label: final step never completed',
        );
        expect(
          cubit.state.isPlaying,
          isFalse,
          reason: '$label: still playing after the last step',
        );

        cubit.pause();
        await tester.pumpAndSettle();
      });
    });
  });

  testWidgets('Largest lessons stay exception-free in dark theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final label in ['rref 5', 'lu 5', 'multiply 5', 'determinant 5']) {
      final solution = lessons[label]!;
      await tester.pumpWidget(
        _host(
          StepPlayerScreen(solution: solution, topicTitle: label),
          dark: true,
        ),
      );
      await tester.pump();
      final cubit = tester
          .element(find.byType(MatrixDisplayGrid))
          .read<PlayerCubit>();
      cubit.setPlaybackSpeed(4);
      for (var i = 0; i < 200; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: '$label dark');
      }
      cubit.pause();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });
}
