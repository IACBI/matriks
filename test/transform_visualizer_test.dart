import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matriks/app.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/transform_visualizer/views/transform_visualizer_screen.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

void main() {
  testWidgets(
    '2D Linear Transformation Visualizer: presets, metrics, and animation',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MatrixEducatorApp());
      await tester.pumpAndSettle();

      // 1. Scroll to or find 2D Geometric Transformation topic
      final topicFinder = find.text('2D Geometric Transformation');
      await tester.scrollUntilVisible(
        topicFinder,
        300.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(topicFinder);
      await tester.pumpAndSettle();
      expect(topicFinder, findsOneWidget);
      await tester.tap(topicFinder);
      await tester.pumpAndSettle();

      // 2. We should be on TransformVisualizerScreen
      expect(find.text('2D Linear Transformation'), findsOneWidget);

      // Initial state: a=1, b=1, c=0, d=1, so det = 1*1 - 1*0 = 1, exactly.
      expect(find.text('Target determinant: 1'), findsOneWidget);

      // 3. Test Shear preset
      final shearChip = find.text('Shear');
      expect(shearChip, findsOneWidget);
      await tester.ensureVisible(shearChip);
      await tester.pumpAndSettle();
      await tester.tap(shearChip);
      await tester.pumpAndSettle();
      expect(find.text('Target determinant: 1'), findsOneWidget);

      // 4. Test Projection preset (collapses 2D space, det = 0)
      final projChip = find.text('Projection (det=0)');
      expect(projChip, findsOneWidget);
      await tester.ensureVisible(projChip);
      await tester.pumpAndSettle();
      await tester.tap(projChip);
      await tester.pumpAndSettle();
      expect(find.text('Target determinant: 0'), findsOneWidget);

      // 5. Test Scale preset
      final scaleChip = find.text('Scale');
      expect(scaleChip, findsOneWidget);
      await tester.ensureVisible(scaleChip);
      await tester.pumpAndSettle();
      await tester.tap(scaleChip);
      await tester.pumpAndSettle();
      // Preserve the determinant rather than rounding away information.
      expect(find.text('Target determinant: 2.25'), findsOneWidget);

      final selectedScale = tester.widget<ChoiceChip>(
        find.ancestor(of: scaleChip, matching: find.byType(ChoiceChip)),
      );
      expect(selectedScale.selected, true);
      final increaseA = find.byTooltip('Increase coefficient a');
      await tester.ensureVisible(increaseA);
      await tester.pumpAndSettle();
      await tester.tap(increaseA);
      await tester.pumpAndSettle();
      expect(find.text('Custom'), findsOneWidget);
      expect(
        tester
            .widget<ChoiceChip>(
              find.ancestor(of: scaleChip, matching: find.byType(ChoiceChip)),
            )
            .selected,
        false,
      );

      // 6. Test Play animation button
      final playBtn = find.byIcon(Icons.play_circle_fill_rounded);
      expect(playBtn, findsOneWidget);
      await tester.ensureVisible(playBtn);
      await tester.pumpAndSettle();
      await tester.tap(playBtn);
      // Advance animation smoothly
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('An invalid coefficient does not push its neighbour down', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => SettingsCubit(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const TransformVisualizerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final a = find.byKey(const ValueKey('coefficient-a'));
    final b = find.byKey(const ValueKey('coefficient-b'));
    await tester.ensureVisible(a);
    await tester.pumpAndSettle();
    await tester.enterText(a, '2//3');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Enter a number from −1000 to 1000.'), findsOneWidget);
    expect(tester.getTopLeft(b).dy, tester.getTopLeft(a).dy);
  });
}
