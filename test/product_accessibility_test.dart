import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/core/theme/app_theme.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/topics/models/topic_item.dart';
import 'package:matriks/features/topics/views/topics_screen.dart';
import 'package:matriks/features/matrix_input/views/matrix_input_screen.dart';
import 'package:matriks/features/matrix_input/matrix_input_cubit.dart';
import 'package:matriks/features/practice/views/practice_screen.dart';
import 'package:matriks/features/transform_visualizer/views/transform_visualizer_screen.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

Widget host(
  Widget screen, {
  bool dark = false,
  double scale = 1,
  String language = 'en',
}) => BlocProvider(
  create: (_) => SettingsCubit(),
  child: MaterialApp(
    theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: Locale(language),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
      child: child!,
    ),
    home: screen,
  ),
);

void main() {
  final screens = <String, Widget Function()>{
    'player': () => StepPlayerScreen(
      solution: DeterminantSolver.solve(Matrix.identity(3)),
      topicTitle: 'Determinant',
    ),
    'catalog': () => const TopicsScreen(),
    'input': () => MatrixInputScreen(topic: TopicItem.allTopics.first),
    'practice': () => const PracticeScreen(),
    'transform': () => const TransformVisualizerScreen(),
  };
  for (final entry in screens.entries) {
    for (final dark in [false, true]) {
      testWidgets(
        '${entry.key} supports narrow viewport, 200% text, and reduced motion ($dark)',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final layoutErrors = <FlutterErrorDetails>[];
          final previousHandler = FlutterError.onError;
          FlutterError.onError = (details) {
            layoutErrors.add(details);
            previousHandler?.call(details);
          };
          addTearDown(() => FlutterError.onError = previousHandler);
          await tester.pumpWidget(host(entry.value(), dark: dark, scale: 2));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: layoutErrors.map((error) => error.toString()).join("\n"),
          );
        },
      );
    }
  }

  for (final entry in screens.entries) {
    for (final config in [
      (const Size(600, 800), 1.0, 'tr', false),
      (const Size(960, 768), 1.0, 'en', true),
      (const Size(1440, 900), 1.0, 'tr', false),
      (const Size(800, 380), 2.0, 'tr', true),
    ]) {
      testWidgets('${entry.key} adapts to $config', (tester) async {
        tester.view.physicalSize = config.$1;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          host(
            entry.value(),
            scale: config.$2,
            language: config.$3,
            dark: config.$4,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Matrix input Tab moves focus to an actionable control', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(MatrixInputScreen(topic: TopicItem.allTopics.first)),
    );
    await tester.pumpAndSettle();
    final before = FocusManager.instance.primaryFocus;
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, isNot(same(before)));
  });

  testWidgets(
    'Search and selected category combine with a recoverable empty state',
    (tester) async {
      await tester.pumpWidget(host(const TopicsScreen()));
      await tester.pumpAndSettle();
      final chip = find.byType(ChoiceChip).at(1);
      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(TextField),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Determinant');
      await tester.pumpAndSettle();
      expect(find.text('No matching topics found'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    },
  );
  testWidgets('Correcting an invalid fraction removes its error announcement', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(MatrixInputScreen(topic: TopicItem.allTopics.first)),
    );
    await tester.pumpAndSettle();
    final solve = find.text('Solve');
    await tester.ensureVisible(solve);
    final cubit = tester.element(solve).read<MatrixInputCubit>();
    cubit.onKeyPressed('/');
    cubit.onKeyPressed('0');
    await tester.pump();
    await tester.tap(solve);
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.hint != null,
      ),
      findsWidgets,
    );
    cubit.onBackspace();
    cubit.onKeyPressed('2');
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.hint != null,
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
