import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/app.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/settings/cubit/settings_state.dart';
import 'package:matriks/features/settings/views/settings_screen.dart';
import 'package:matriks/features/practice/views/practice_screen.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/step_player/cubit/player_cubit.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/features/step_player/widgets/solution_summary.dart';
import 'package:matriks/features/step_player/widgets/prediction_card.dart';
import 'package:matriks/features/topics/views/topics_screen.dart';
import 'package:matriks/features/topics/models/topic_item.dart';
import 'package:matriks/features/matrix_input/views/matrix_input_screen.dart';
import 'package:matriks/features/transform_visualizer/views/transform_visualizer_screen.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';
import 'package:matrix_engine/matrix_engine.dart';

import 'product_accessibility_test.dart' show host;

void main() {
  testWidgets('Prediction allows result shortcut without starting playback', (
    tester,
  ) async {
    final solution = GaussJordanSolver.solve(
      Matrix.fromInts([
        [1, 2],
        [2, 5],
      ]),
    );
    await tester.pumpWidget(
      host(
        StepPlayerScreen(
          solution: solution,
          topicTitle: 'Gauss',
          workedExample: true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    final player = tester
        .element(find.byType(MatrixDisplayGrid))
        .read<PlayerCubit>();
    expect(find.byType(PredictionCard), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(player.state.isAnimating, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.pumpAndSettle();
    expect(find.byType(SolutionSummary), findsOneWidget);
    expect(player.state.mode, SolutionMode.result);
    expect(player.state.isAnimating, isFalse);
  });

  testWidgets(
    'Failed results do not claim exactness or display a result matrix',
    (tester) async {
      final solution = InverseSolver.solve(
        Matrix.fromInts([
          [1, 2],
          [2, 4],
        ]),
      );
      expect(solution.isSuccess, isFalse);
      await tester.pumpWidget(
        host(
          SolutionSummary(
            solution: solution,
            decimal: false,
            onViewSteps: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MatrixDisplayGrid), findsNothing);
      expect(find.byType(SolutionStatus), findsOneWidget);
      final l = AppLocalizations.of(
        tester.element(find.byType(SolutionSummary)),
      )!;
      expect(find.text(l.resultExact), findsNothing);
      expect(find.text(l.error_matrix_is_singular), findsOneWidget);
    },
  );

  testWidgets('Hidden destinations cannot reclaim keyboard focus', (
    tester,
  ) async {
    await tester.pumpWidget(const MatrixEducatorApp());
    await tester.pumpAndSettle();
    final search = tester.widget<EditableText>(find.byType(EditableText).first);
    search.focusNode.requestFocus();
    await tester.pump();
    expect(search.focusNode.hasFocus, isTrue);
    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    search.focusNode.requestFocus();
    await tester.pump();
    expect(search.focusNode.hasFocus, isFalse);
    expect(search.focusNode.canRequestFocus, isFalse);
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    search.focusNode.requestFocus();
    await tester.pump();
    expect(search.focusNode.hasFocus, isTrue);
  });

  testWidgets('Changing quiz language preserves answer, score and question', (
    tester,
  ) async {
    await tester.pumpWidget(const MatrixEducatorApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('quiz-option-A')));
    await tester.tap(find.byKey(const ValueKey('quiz-option-A')));
    await tester.pumpAndSettle();
    expect(find.text('10 Points'), findsOneWidget);
    final settings = tester
        .element(find.byType(PracticeScreen))
        .read<SettingsCubit>();
    settings.setLocale(const Locale('es'));
    await tester.pumpAndSettle();
    expect(find.text('10 puntos'), findsOneWidget);
    expect(find.text('Pregunta 1 / 5'), findsOneWidget);
    expect(find.text('¡Respuesta correcta!'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('quiz-option-A')));
    await tester.tap(find.byKey(const ValueKey('quiz-option-A')));
    await tester.pumpAndSettle();
    expect(find.text('10 puntos'), findsOneWidget);
  });
  testWidgets('S shortcut shows exact result and returns to static steps', (
    tester,
  ) async {
    final solution = MatrixArithmeticSolver.multiply(
      Matrix.identity(2),
      Matrix.identity(2),
    );
    await tester.pumpWidget(
      host(StepPlayerScreen(solution: solution, topicTitle: 'Multiply')),
    );
    await tester.pump();
    final player = tester
        .element(find.byType(MatrixDisplayGrid))
        .read<PlayerCubit>();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.pumpAndSettle();
    expect(find.byType(SolutionSummary), findsOneWidget);
    expect(player.state.mode, SolutionMode.result);
    await tester.ensureVisible(find.text('Explore steps'));
    await tester.tap(find.text('Explore steps'));
    await tester.pumpAndSettle();
    expect(player.state.mode, SolutionMode.steps);
    expect(
      tester
          .widget<MatrixDisplayGrid>(find.byType(MatrixDisplayGrid))
          .staticStep,
      true,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('Worked example prediction pauses and can be skipped', (
    tester,
  ) async {
    final solution = GaussJordanSolver.solve(
      Matrix.fromInts([
        [1, 2],
        [2, 5],
      ]),
    );
    await tester.pumpWidget(
      host(
        StepPlayerScreen(
          solution: solution,
          topicTitle: 'Gauss',
          workedExample: true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(PredictionCard), findsOneWidget);
    final player = tester
        .element(find.byType(MatrixDisplayGrid))
        .read<PlayerCubit>();
    expect(player.state.isAnimating, false);
    await tester.ensureVisible(find.text('Skip'));
    await tester.tap(find.text('Skip'));
    await tester.pump();
    expect(find.byType(PredictionCard), findsNothing);
    expect(player.state.isAnimating, true);
  });
  for (final language in SettingsState.languages) {
    for (final dark in [false, true]) {
      testWidgets('Studio layouts $language dark=$dark at all target widths', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final screens = <Widget>[
          const TopicsScreen(),
          const SettingsScreen(),
          const PracticeScreen(),
          const TransformVisualizerScreen(),
          MatrixInputScreen(topic: TopicItem.allTopics.first),
          StepPlayerScreen(
            solution: MatrixArithmeticSolver.multiply(
              Matrix.identity(2),
              Matrix.identity(2),
            ),
            topicTitle: 'A × B',
          ),
        ];
        for (final size in [
          const Size(320, 568),
          const Size(390, 844),
          const Size(600, 800),
          const Size(960, 768),
          const Size(1440, 900),
          const Size(800, 380),
        ]) {
          tester.view.physicalSize = size;
          for (final screen in screens) {
            await tester.pumpWidget(
              host(
                screen,
                language: language,
                dark: dark,
                scale: size.width == 320 || size.height == 380 ? 2 : 1,
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '$language $dark $size ${screen.runtimeType}',
            );
            await tester.pumpWidget(const SizedBox.shrink());
          }
        }
      });
    }
  }
  testWidgets('Five language menu uses bundled flags and native names', (
    tester,
  ) async {
    await tester.pumpWidget(const MatrixEducatorApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Language'));
    await tester.pumpAndSettle();
    for (final name in ['Türkçe', 'English', '简体中文', 'Español', 'Русский']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.text('System Default'), findsOneWidget);
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(find.text('Темы'), findsOneWidget);
    expect(
      AppLocalizations.of(tester.element(find.byType(TopicsScreen)))!
          .localeName,
      'ru',
    );
  });
}
