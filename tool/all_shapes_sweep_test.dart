import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/settings/cubit/settings_state.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/topics/models/topic_item.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

import '../test/all_shapes_ui_test.dart';

/// Exhaustive version of test/all_shapes_ui_test.dart, run by hand:
///
///     flutter test tool/all_shapes_sweep_test.dart
///
/// Every shape of every topic in the player (every step and the result, in
/// fractions and decimals, at 390×844 and 1280×800, and the largest shapes
/// at 320×568 with 200% text), every shape in the editor at three sizes,
/// and a real solve of every shape. It takes tens of minutes in debug mode;
/// each test prints a one-line summary.

const _long = Timeout(Duration(minutes: 90));

/// The player cases of [topic], in chunks small enough to report progress.
Map<String, List<ShapeCase>> _chunks(TopicType topic, List<ShapeCase> all) {
  final cases = all.where((c) => c.topic == topic).toList();
  if (topic != TopicType.multiply) return {'every shape': cases};
  return {
    for (var m = 1; m <= 5; m++)
      'A with $m row(s)': cases.where((c) => c.a.rows == m).toList(),
  };
}

void _summary(String what, Findings findings) => debugPrint(
  '$what: ${findings.frames} frames checked, '
  '${findings.isEmpty ? 'no problems' : 'PROBLEMS:\n$findings'}',
);

/// Semantics labels of exact eigenvalues keep the operation: a root, a cube
/// root, a cosine and π must survive the conversion from TeX.
List<String> _mathLabelProblems(String latex, String label) => [
  if (latex.contains(r'\sqrt{') && !label.contains('√'))
    'square root lost: "$latex" is read as "$label"',
  if (latex.contains(r'\sqrt[3]') && !label.contains('∛'))
    'cube root lost: "$latex" is read as "$label"',
  if (latex.contains(r'\cos') && !label.contains('cos'))
    'cosine lost: "$latex" is read as "$label"',
  if (latex.contains(r'\pi') && !label.contains('π'))
    'π lost: "$latex" is read as "$label"',
];

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadMathFonts();
  });
  final all = [...allShapeCases(), ...longEntryCases()];

  group('Player, every shape', () {
    for (final topic in editorTopics) {
      for (final MapEntry(key: chunk, value: cases) in _chunks(
        topic,
        all,
      ).entries) {
        testWidgets(
          '${topic.name} $chunk: ${cases.length} inputs',
          timeout: _long,
          (tester) async {
            final findings = await playerFindings(tester, cases);
            _summary('player ${topic.name} $chunk', findings);
            expect(findings.isEmpty, isTrue, reason: '$findings');
          },
        );
      }
    }
  });

  // Beyond the brief (200% text only for the largest shapes): every other
  // shape at 320×568 with 200% text, in fractions.
  group('Player, every smaller shape at 320x568@2x', () {
    for (final topic in editorTopics) {
      for (final MapEntry(key: chunk, value: cases) in _chunks(
        topic,
        all,
      ).entries) {
        final smaller = cases.where((c) => !c.largest).toList();
        if (smaller.isEmpty) continue;
        testWidgets(
          '${topic.name} $chunk: ${smaller.length} inputs',
          timeout: _long,
          (tester) async {
            final findings = await runFindings(tester, [
              for (final shape in smaller)
                (
                  shape: shape,
                  viewport: smallLargeText,
                  decimals: const [false],
                ),
            ]);
            _summary('large text ${topic.name} $chunk', findings);
            expect(findings.isEmpty, isTrue, reason: '$findings');
          },
        );
      }
    }
  });

  group('Editor, every shape at 390x844, 844x390 and 1280x800', () {
    for (final topic in editorTopics) {
      final shapes = editorShapes(topic);
      testWidgets('${topic.name}: ${shapes.length} shapes', timeout: _long, (
        tester,
      ) async {
        final findings = await editorFindings(tester, topic, shapes);
        _summary('editor ${topic.name}', findings);
        expect(findings.isEmpty, isTrue, reason: '$findings');
      });
    }
  });

  group('Solve, every shape at 390x844', () {
    for (final topic in editorTopics) {
      final shapes = editorShapes(topic);
      testWidgets('${topic.name}: ${shapes.length} shapes', timeout: _long, (
        tester,
      ) async {
        final findings = await solveFindings(tester, topic, shapes, const [
          Size(390, 844),
        ]);
        _summary('solve ${topic.name}', findings);
        expect(findings.isEmpty, isTrue, reason: '$findings');
      });
    }
  });

  group('Row and column buttons', () {
    for (final topic in editorTopics) {
      testWidgets(topic.name, (tester) async {
        addTearDown(tester.view.reset);
        final settings = await openEditor(tester, topic, const Size(390, 844));
        addTearDown(settings.close);
        final problems = await collectingErrors(
          (errors) => dimensionButtonProblems(tester, topic, errors),
        );
        expect(problems, isEmpty, reason: problems.join('\n'));
      });
    }
  });

  group('Probes beyond the shape checks', () {
    testWidgets('Exact eigenvalues keep roots and cosines in semantics', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      final problems = <String>{};
      for (final shape in eigenCases()) {
        final solution = shape.solution;
        tester.view.physicalSize = phone.size;
        tester.view.devicePixelRatio = 1;
        final settings = SettingsCubit(
          initial: const SettingsState(solutionMode: SolutionMode.result),
        );
        await tester.pumpWidget(
          shapesHost(
            StepPlayerScreen(solution: solution, topicTitle: 'Eigen'),
            settings,
          ),
        );
        await tester.pump(Duration.zero);
        for (final element in find.byType(MathText).evaluate()) {
          final latex = (element.widget as MathText).latex;
          // The label MathText gives its Semantics, as a screen reader hears.
          final semantics =
              find
                      .descendant(
                        of: find.byWidget(element.widget),
                        matching: find.byType(Semantics),
                      )
                      .evaluate()
                      .first
                      .widget
                  as Semantics;
          problems.addAll(
            _mathLabelProblems(latex, semantics.properties.label ?? ''),
          );
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await settings.close();
      }
      debugPrint(problems.join('\n'));
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    for (final language in ['tr', 'zh', 'es', 'ru']) {
      testWidgets('An inconsistent system is stated in $language', (
        tester,
      ) async {
        addTearDown(tester.view.reset);
        tester.view.physicalSize = phone.size;
        tester.view.devicePixelRatio = 1;
        final solution = LinearSystemsSolver.solve(inconsistentSystem(3, 4));
        final settings = SettingsCubit(
          initial: SettingsState(
            solutionMode: SolutionMode.steps,
            locale: Locale(language),
          ),
        );
        addTearDown(settings.close);
        await tester.pumpWidget(
          shapesHost(
            StepPlayerScreen(
              solution: solution,
              topicTitle: TopicItem.of(TopicType.linearSystems)
                  .title(lookupAppLocalizations(Locale(language))),
            ),
            settings,
            language: language,
          ),
        );
        await tester.pump(Duration.zero);
        final english = <String>{};
        void collect() {
          for (final element in find.byType(MathText).evaluate()) {
            final latex = (element.widget as MathText).latex;
            for (final word in ['No Solution', 'Inconsistent', 'False']) {
              if (latex.contains(word)) english.add(latex);
            }
          }
        }

        final player = playerOf(tester);
        player.jumpToStep(solution.steps.length - 1);
        await tester.pump(Duration.zero);
        collect();
        player.showResult();
        await tester.pump(Duration.zero);
        collect();
        debugPrint('$language: ${english.join(' | ')}');
        expect(english, isEmpty, reason: 'English formulas: $english');
      });
    }
  });
}
