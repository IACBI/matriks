import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/core/widgets/math_text.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/step_player/widgets/solution_summary.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

import 'product_accessibility_test.dart' show host;

void main() {
  group('A screen reader hears exact values', () {
    for (final (latex, spoken) in [
      (r'\frac{1}{2} + \frac{\sqrt{5}}{2}', '1/2 + √5/2'),
      (r'2\cos\left(\frac{7\pi}{9}\right)', '2cos(7π/9)'),
      (r'\sqrt[3]{2}', '∛2'),
      (r'3 \pm 2\sqrt{5}\,i', '3 ± 2√5 i'),
      (
        r'\sqrt[3]{-68621 + \frac{5\sqrt{2843118898}}{4}}',
        '∛(-68621 + 5√2843118898/4)',
      ),
      (r'\lambda = -\frac{\sqrt{3}}{2}', 'λ = -√3/2'),
    ]) {
      test(latex, () => expect(mathSemanticsLabel(latex), spoken));
    }
  });

  final inconsistent = LinearSystemsSolver.solve(
    Matrix.fromInts([
      [1, 1, 2],
      [1, 1, 3],
    ]),
  );

  for (final language in ['tr', 'zh']) {
    testWidgets('A system with no solution is stated in $language', (
      tester,
    ) async {
      final l10n = lookupAppLocalizations(Locale(language));
      await tester.pumpWidget(
        host(
          Scaffold(
            body: SolutionSummary(
              solution: inconsistent,
              decimal: false,
              onViewSteps: () {},
            ),
          ),
          language: language,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(l10n.systemNoSolution), findsOneWidget);
      expect(find.textContaining('No Solution'), findsNothing);

      await tester.pumpWidget(
        host(
          StepPlayerScreen(solution: inconsistent, topicTitle: 'Ax = b'),
          language: language,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(l10n.systemNoSolution), findsOneWidget);
    });
  }

  test('The contradiction is written without English', () {
    final contradiction = inconsistent.steps.last;
    expect(contradiction.titleKey, 'system_inconsistent_title');
    expect(contradiction.subCalculations, isNotEmpty);
    for (final sub in contradiction.subCalculations) {
      expect(sub.formulaLatex, isNot(contains(r'\text')));
      expect(sub.formulaLatex, contains(r'\neq'));
    }
  });
}
