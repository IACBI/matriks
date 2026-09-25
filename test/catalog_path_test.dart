import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/core/theme/app_theme.dart';
import 'package:matriks/features/matrix_input/views/matrix_input_screen.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/settings/cubit/settings_state.dart';
import 'package:matriks/features/topics/models/topic_item.dart';
import 'package:matriks/features/topics/views/topics_screen.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

void main() {
  test('The path lists every topic once', () {
    expect(TopicItem.pathOrder.toSet(), TopicType.values.toSet());
    expect(TopicItem.pathOrder, hasLength(TopicType.values.length));
  });

  testWidgets('The catalog follows the path, marks progress and continues', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final settings = SettingsCubit(
      initial: const SettingsState(
        lastTopic: 'eigen',
        completedTopics: {'add', 'rref'},
      ),
    );
    await tester.pumpWidget(
      BlocProvider.value(
        value: settings,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const TopicsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l = lookupAppLocalizations(const Locale('en'));

    expect(
      find.text(l.pathProgress(2, TopicType.values.length)),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(2));
    // Entry-wise operations come before elimination, eigenvalues after it.
    double top(String text) => tester.getTopLeft(find.text(text).last).dy;
    expect(top(l.topicAdd), lessThan(top(l.topicGauss)));
    expect(top(l.topicGauss), lessThan(top(l.topicEigen)));

    final card = find.byKey(const ValueKey('continue-card'));
    expect(
      find.descendant(of: card, matching: find.text(l.topicEigen)),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(of: card, matching: find.text(l.continueAction)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MatrixInputScreen), findsOneWidget);
    expect(settings.state.lastTopic, 'eigen');
    expect(tester.takeException(), isNull);
  });
}
