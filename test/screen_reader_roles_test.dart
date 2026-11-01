import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/core/theme/app_theme.dart';
import 'package:matriks/core/widgets/option_chip.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/settings/cubit/settings_state.dart';
import 'package:matriks/features/settings/views/settings_screen.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/transform_visualizer/views/transform_visualizer_screen.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

// The Windows accessibility bridge picks a UI Automation control type from
// these flags, button first. These tests hold the flags Narrator was seen to
// need when the release build's UI Automation tree was read.

Widget _host(Widget home, {SettingsState settings = const SettingsState()}) =>
    BlocProvider(
      create: (_) => SettingsCubit(initial: settings),
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: home,
      ),
    );

SemanticsData _node(WidgetTester tester, Finder finder) =>
    tester.getSemantics(finder).getSemanticsData();

void main() {
  testWidgets('An option chip is a radio button that says whether it is '
      'chosen, activates, and reports keyboard focus', (tester) async {
    final handle = tester.ensureSemantics();
    var chosen = 'a';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Row(
              children: [
                for (final option in ['a', 'b'])
                  OptionChip(
                    label: option,
                    selected: chosen == option,
                    onSelected: () => setState(() => chosen = option),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    final a = _node(tester, find.byType(OptionChip).first);
    expect(a.label, 'a');
    expect(a.flagsCollection.isButton, isFalse);
    expect(a.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
    expect(a.flagsCollection.isChecked, CheckedState.isTrue);
    expect(
      _node(tester, find.byType(OptionChip).last).flagsCollection.isChecked,
      CheckedState.isFalse,
    );

    // A screen reader's activation reaches the chip.
    tester.semantics.tap(find.semantics.byLabel('b'));
    await tester.pump();
    expect(chosen, 'b');

    // Keyboard focus is on the node a screen reader reads.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      _node(tester, find.byType(OptionChip).first).flagsCollection.isFocused,
      Tristate.isTrue,
    );
    handle.dispose();
  });

  testWidgets('Settings theme options are radio buttons, one checked', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(const SettingsScreen()));
    final chips = find.byType(OptionChip);
    expect(chips, findsWidgets);
    final checked = [
      for (final e in chips.evaluate())
        _node(tester, find.byWidget(e.widget)).flagsCollection.isChecked,
    ];
    expect(checked.where((c) => c == CheckedState.isTrue), hasLength(1));
    handle.dispose();
  });

  testWidgets('The playback speed menu is one button named once', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        StepPlayerScreen(
          solution: DeterminantSolver.solve(Matrix.identity(3)),
          topicTitle: 'det',
        ),
        settings: const SettingsState(predictions: false),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    final data = _node(tester, find.byType(PopupMenuButton<double>));
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    expect(data.tooltip, 'Speed: 1×');
    expect(data.label, isEmpty);
    handle.dispose();
  });

  testWidgets('Both progress sliders carry their own name', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(const TransformVisualizerScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    final transform = _node(tester, find.byType(Slider));
    expect(transform.label, 'Transition progress');
    expect(transform.value, isNotEmpty);

    await tester.pumpWidget(
      _host(
        StepPlayerScreen(
          solution: DeterminantSolver.solve(Matrix.identity(3)),
          topicTitle: 'det',
        ),
        settings: const SettingsState(predictions: false),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    final drawer = find.byKey(const ValueKey('operation-inspector'));
    await tester.ensureVisible(drawer);
    await tester.pump();
    await tester.tap(
      find.descendant(of: drawer, matching: find.byType(ListTile)),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final scrub = _node(
      tester,
      find.byKey(const ValueKey('instruction-progress')),
    );
    expect(scrub.label, 'This operation');
    expect(scrub.value, endsWith('%'));
    handle.dispose();
  });
}
