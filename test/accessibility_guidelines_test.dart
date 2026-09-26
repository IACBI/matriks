import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/app.dart';
import 'package:matriks/features/matrix_input/views/matrix_input_screen.dart';
import 'package:matriks/features/settings/views/settings_screen.dart';
import 'package:matriks/features/step_player/views/step_player_screen.dart';
import 'package:matriks/features/topics/models/topic_item.dart';

import 'product_accessibility_test.dart' show host;

/// Flutter's automated checks: 44 px targets (the project minimum, see
/// AGENTS.md), labelled targets and text contrast.
Future<void> expectGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  for (final (lang, scale, width) in [
    ('en', 1.0, 390.0),
    ('en', 1.0, 1280.0),
    ('en', 2.0, 320.0),
    ('zh', 2.0, 390.0),
  ]) {
    for (final dark in [false, true]) {
      testWidgets(
        'Every tab meets the guidelines: $lang ${scale}x ${width.toInt()} px '
        '${dark ? 'dark' : 'light'}',
        (tester) async {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          tester.platformDispatcher.localesTestValue = [Locale(lang)];
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          tester.platformDispatcher.platformBrightnessTestValue = dark
              ? Brightness.dark
              : Brightness.light;
          addTearDown(tester.platformDispatcher.clearAllTestValues);
          final handle = tester.ensureSemantics();
          await tester.pumpWidget(const MatrixEducatorApp());
          await tester.pumpAndSettle();
          await expectGuidelines(tester);

          await tester.tap(find.byIcon(Icons.school_outlined).first);
          await tester.pumpAndSettle();
          await expectGuidelines(tester);
          await tester.tap(find.bySemanticsLabel(RegExp(r'^A: ')).first);
          await tester.pumpAndSettle();
          await expectGuidelines(tester);

          await tester.tap(find.byIcon(Icons.transform_rounded).first);
          await tester.pumpAndSettle();
          await expectGuidelines(tester);

          await tester.tap(find.byIcon(Icons.tune_rounded).first);
          await tester.pumpAndSettle();
          final more = find.byKey(const ValueKey('more-settings'));
          await tester.scrollUntilVisible(
            more,
            200,
            scrollable: find
                .descendant(
                  of: find.byType(SettingsScreen),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await tester.pumpAndSettle();
          await tester.tapAt(
            tester.getRect(more).topCenter + const Offset(0, 24),
          );
          await tester.pumpAndSettle();
          await expectGuidelines(tester);
          handle.dispose();
        },
      );
    }
  }

  for (final (width, scale) in [(320.0, 2.0), (1280.0, 1.0)]) {
    for (final dark in [false, true]) {
      testWidgets(
        'Editor and player meet the guidelines: ${width.toInt()} px ${scale}x '
        '${dark ? 'dark' : 'light'}',
        (tester) async {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final handle = tester.ensureSemantics();
          await tester.pumpWidget(
            host(
              MatrixInputScreen(topic: TopicItem.allTopics.first),
              dark: dark,
              scale: scale,
            ),
          );
          await tester.pumpAndSettle();
          await expectGuidelines(tester);

          await tester.pumpWidget(
            host(
              StepPlayerScreen(
                solution: InverseSolver.solve(
                  Matrix.fromInts([
                    [2, 1, -1],
                    [-3, -1, 2],
                    [-2, 1, 2],
                  ]),
                ),
                topicTitle: 'Inverse',
              ),
              dark: dark,
              scale: scale,
            ),
          );
          await tester.pumpAndSettle();
          await expectGuidelines(tester);
          final details = find.byKey(const ValueKey('operation-inspector'));
          await tester.ensureVisible(details);
          await tester.pumpAndSettle();
          await tester.tapAt(
            tester.getRect(details).topCenter + const Offset(0, 20),
          );
          await tester.pumpAndSettle();
          await expectGuidelines(tester);
          await tester.tap(find.byKey(const ValueKey('player-menu')));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Show result').last);
          await tester.pumpAndSettle();
          await expectGuidelines(tester);
          handle.dispose();
        },
      );
    }
  }
}
