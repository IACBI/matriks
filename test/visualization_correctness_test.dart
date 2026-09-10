import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/core/theme/app_theme.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/transform_visualizer/models/transform_matrix.dart';
import 'package:matriks/features/transform_visualizer/views/transform_visualizer_screen.dart';
import 'package:matriks/features/transform_visualizer/widgets/transform_grid_painter.dart';
import 'package:matriks/features/transform_visualizer/widgets/coefficient_field.dart';
import 'package:matriks/features/step_player/widgets/instruction_lesson.dart';
import 'package:matriks/features/step_player/widgets/instruction_timeline.dart';
import 'package:matriks/features/step_player/widgets/multiplication_sources.dart';
import 'package:matriks/features/step_player/widgets/matrix_display_grid.dart';
import 'package:matriks/features/step_player/widgets/matrix_cell_widget.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

Widget host(Widget child, {bool reduced = false}) => BlocProvider(
  create: (_) => SettingsCubit(),
  child: MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
      child: child!,
    ),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

TransformGridPainter scene(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((p) => p.painter)
    .whereType<TransformGridPainter>()
    .single;

Future<void> openTransform(
  WidgetTester tester, {
  bool reduced = false,
  Size size = const Size(1280, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  // A scaffold requires bounded height, unlike the small instructional widgets.
  await tester.pumpWidget(
    BlocProvider(
      create: (_) => SettingsCubit(),
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: child!,
        ),
        home: const TransformVisualizerScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Mobile preset controls keep the animated canvas visible', (
    tester,
  ) async {
    await openTransform(tester, size: const Size(390, 844));
    await tester.ensureVisible(find.text('Scale'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scale'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final canvas = find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint && widget.painter is TransformGridPainter,
    );
    expect(canvas, findsOneWidget);
    final rect = tester.getRect(canvas);
    expect(rect.top, greaterThanOrEqualTo(kToolbarHeight));
    expect(rect.bottom, lessThan(844));
    expect(scene(tester).a, greaterThan(1));
    expect(scene(tester).a, lessThan(1.5));
    await tester.pumpAndSettle();
  });

  testWidgets('Transform pauses in the background until explicitly resumed', (
    tester,
  ) async {
    await openTransform(tester);
    await tester.tap(find.text('Scale'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final paused = scene(tester).a;
    addTearDown(
      () => tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      ),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump(const Duration(seconds: 2));
    expect(scene(tester).a, paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.byTooltip('Play'), findsOneWidget);
    await tester.tap(find.byTooltip('Play'));
    await tester.pumpAndSettle();
    expect(scene(tester).a, 1.5);
  });

  testWidgets('Hidden transform retains its visible frame on return', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var enabled = true;
    late StateSetter update;
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => SettingsCubit(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return TickerMode(
                enabled: enabled,
                child: const TransformVisualizerScreen(),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Scale'));
    await tester.tap(find.text('Scale'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final paused = scene(tester).a;
    update(() => enabled = false);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    update(() => enabled = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(scene(tester).a, paused);
    expect(find.byTooltip('Play'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  test(
    'Projection fixes its image and rotation preserves lengths at every phase',
    () {
      final p = TransformMatrix.preset('projection');
      expect(p.determinant, 0);
      for (final v in [(1.0, 0.0), (0.0, 1.0), (-3.0, 5.0)]) {
        final x = p.a * v.$1 + p.b * v.$2;
        final y = p.c * v.$1 + p.d * v.$2;
        expect(p.a * x + p.b * y, closeTo(x, 1e-12));
        expect(p.c * x + p.d * y, closeTo(y, 1e-12));
      }
      final r = TransformMatrix.preset('rotation');
      expect(math.atan2(r.c, r.a), closeTo(math.pi / 4, 1e-12));
      for (final t in [0.0, .25, .5, .75, 1.0]) {
        final frame = TransformMatrix.identity.interpolate(r, t);
        expect(frame.determinant, closeTo(1, 1e-12));
        expect(frame.a * frame.a + frame.c * frame.c, closeTo(1, 1e-12));
        expect(frame.a * frame.b + frame.c * frame.d, closeTo(0, 1e-12));
      }
    },
  );

  testWidgets(
    'Retargeting starts at the visible frame, including rapid changes',
    (tester) async {
      await openTransform(tester);
      await tester.tap(find.text('Scale'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final before = scene(tester);
      await tester.tap(find.byTooltip('Increase coefficient b'));
      await tester.pump();
      final after = scene(tester);
      expect(after.a, closeTo(before.a, 1e-12));
      expect(after.b, closeTo(before.b, 1e-12));
      await tester.pump(const Duration(milliseconds: 200));
      final interrupted = scene(tester);
      await tester.tap(find.text('Reflection'));
      await tester.pump();
      expect(scene(tester).a, closeTo(interrupted.a, 1e-12));
      expect(scene(tester).b, closeTo(interrupted.b, 1e-12));
      await tester.pumpAndSettle();
      expect(scene(tester).d, -1);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Paused reverse resumes toward its original start', (
    tester,
  ) async {
    await openTransform(tester);
    await tester.tap(find.text('Scale'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.play_circle_fill_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byIcon(Icons.pause_circle_filled_rounded));
    await tester.pump();
    final paused = scene(tester).a;
    await tester.pump(const Duration(milliseconds: 200));
    expect(scene(tester).a, paused);
    await tester.tap(find.byIcon(Icons.play_circle_fill_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(scene(tester).a, lessThan(paused));
    await tester.pumpAndSettle();
    expect(scene(tester).a, 1);
  });

  testWidgets(
    'Coefficient entry rejects invalid values and preserves other drafts',
    (tester) async {
      await openTransform(tester);
      final a = find.byKey(const ValueKey('coefficient-a'));
      final b = find.byKey(const ValueKey('coefficient-b'));
      for (final invalid in ['', '-', 'NaN', 'Infinity', '1001']) {
        await tester.enterText(a, invalid);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(find.text('Enter a number from −1000 to 1000.'), findsOneWidget);
        expect(
          tester
              .widget<CoefficientField>(find.byType(CoefficientField).first)
              .value,
          1,
        );
      }
      await tester.enterText(b, '2,25');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(a).controller!.text, '1001');
      expect(tester.widget<TextField>(b).controller!.text, '2.25');
      expect(find.text('Custom'), findsOneWidget);
      await tester.enterText(a, '-0.125');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(scene(tester).a, -.125);
      expect(find.text('Enter a number from −1000 to 1000.'), findsNothing);
      await tester.tap(find.text('Rotation 45°'));
      await tester.pumpAndSettle();
      expect(scene(tester).a, closeTo(math.sqrt1_2, 1e-12));
    },
  );

  testWidgets('Reduced motion applies transform immediately', (tester) async {
    await openTransform(tester, reduced: true);
    await tester.tap(find.text('Projection (det=0)'));
    await tester.pump();
    expect(scene(tester).a, .5);
    expect(scene(tester).b, .5);
    expect(scene(tester).c, .5);
    expect(scene(tester).d, .5);
    expect(find.byIcon(Icons.pause_circle_filled_rounded), findsNothing);
    await tester.pump(const Duration(milliseconds: 400));
    expect(scene(tester).a, .5);
    expect(scene(tester).d, .5);
  });

  testWidgets(
    'Dot product highlights actual source factors and delays output',
    (tester) async {
      final trans = MatrixElementMultiplicationTransformation(
        targetRow: 0,
        targetCol: 0,
        rowElements: [Rational(2), Rational(-3)],
        colElements: [Rational(5), Rational(4)],
        result: Rational(-2),
      );
      final explanation = InstructionLesson.forStep(
        transformation: trans,
        after: MatrixSnapshot(
          rows: 1,
          cols: 1,
          values: [
            [Rational(-2)],
          ],
        ),
      );
      expect(explanation.rationale, contains('whole row of A'));
      expect(explanation.rationale, isNot(contains('= -2')));
      final timeline = InstructionTimeline.forTransformation(trans);
      await tester.pumpWidget(
        host(
          MatrixDisplayGrid(
            snapshot: MatrixSnapshot(
              rows: 1,
              cols: 1,
              values: [
                [Rational(-2)],
              ],
            ),
            snapshotBefore: MatrixSnapshot(
              rows: 1,
              cols: 1,
              values: [
                [Rational.zero],
              ],
            ),
            transformation: trans,
            highlights: const [
              CellHighlight(
                row: 0,
                col: 0,
                type: HighlightType.target,
                badgeText: '-2',
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('A · row 1'), findsOneWidget);
      expect(
        tester
            .widget<MatrixCellWidget>(find.byType(MatrixCellWidget))
            .highlight
            ?.badgeText,
        isNull,
      );
      expect(find.text('B · column 1'), findsOneWidget);
      expect(
        tester.widget<MatrixCellWidget>(find.byType(MatrixCellWidget)).value,
        Rational.zero,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is MathText && w.latex.contains('= -2'),
        ),
        findsNothing,
      );
      await tester.pump(Duration(milliseconds: timeline.sourceMs + 100));
      expect(
        tester
            .widget<MultiplicationSources>(find.byType(MultiplicationSources))
            .activeTerm,
        0,
      );
      await tester.pump(const Duration(milliseconds: 1400));
      expect(
        tester
            .widget<MultiplicationSources>(find.byType(MultiplicationSources))
            .activeTerm,
        1,
      );
      expect(
        tester.widget<MatrixCellWidget>(find.byType(MatrixCellWidget)).value,
        Rational.zero,
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<MatrixCellWidget>(find.byType(MatrixCellWidget)).value,
        Rational(-2),
      );
      expect(
        tester
            .widget<MatrixCellWidget>(find.byType(MatrixCellWidget))
            .highlight
            ?.badgeText,
        '-2',
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is MathText && w.latex.contains('= -2'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Worked results reveal progressively and reduced motion retains reasoning',
    (tester) async {
      const lesson = InstructionLesson(
        'source reason',
        'operation reason',
        'result reason',
        ['2 \\cdot 3 = 6', '4 \\cdot 5 = 20', '6 + 20 = 26'],
      );
      await tester.pumpWidget(
        host(
          const InstructionExplanation(
            lesson: lesson,
            phase: InstructionPhase.source,
          ),
        ),
      );
      expect(find.byType(MathText), findsNothing);
      await tester.pumpWidget(
        host(
          const InstructionExplanation(
            lesson: lesson,
            phase: InstructionPhase.operation,
            activeCalculation: 0,
          ),
        ),
      );
      expect(find.byType(MathText), findsOneWidget);
      await tester.pumpWidget(
        host(
          const InstructionExplanation(
            lesson: lesson,
            phase: InstructionPhase.result,
            showAllPhases: true,
          ),
        ),
      );
      expect(find.byType(MathText), findsNWidgets(3));
      expect(
        find.text('source reason\n\noperation reason\n\nresult reason'),
        findsOneWidget,
      );
    },
  );
}
