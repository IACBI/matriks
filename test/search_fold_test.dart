import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/core/theme/app_theme.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/topics/search_fold.dart';
import 'package:matriks/features/topics/views/topics_screen.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

/// The unit group pins the folding rules; the widget group proves the topic
/// list actually uses them, which is the part a reader notices.

Widget _host(String locale) => BlocProvider(
  create: (_) => SettingsCubit(),
  child: MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: Locale(locale),
    home: const TopicsScreen(),
  ),
);

Future<void> _search(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(TextField).first, query);
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  group('foldForSearch', () {
    test('strips Turkish diacritics', () {
      expect(foldForSearch('Özdeğerler'), 'ozdegerler');
      expect(foldForSearch('Ayrışım'), 'ayrisim');
      expect(foldForSearch('Sıfırlık'), 'sifirlik');
      expect(foldForSearch('Dönüşümler'), 'donusumler');
    });

    test('makes the Turkish dotless i symmetric', () {
      // Dart lowercases "IŞIK" to "işik" but leaves "ışık" alone, so without
      // folding the same word typed in either case does not match itself.
      expect('IŞIK'.toLowerCase() == 'ışık'.toLowerCase(), isFalse);
      expect(foldForSearch('IŞIK'), foldForSearch('ışık'));
      expect(foldForSearch('İndirgeme'), foldForSearch('indirgeme'));
    });

    test('strips Spanish accents and folds eszett', () {
      expect(foldForSearch('Descomposición'), 'descomposicion');
      expect(foldForSearch('Año'), 'ano');
      expect(foldForSearch('Straße'), 'strasse');
    });

    test('folds Russian ë but keeps и and й distinct', () {
      expect(foldForSearch('Ё'), 'е');
      expect(foldForSearch('й') == foldForSearch('и'), isFalse);
    });

    test('leaves text without marks and non-Latin scripts alone', () {
      expect(foldForSearch('Determinant'), 'determinant');
      expect(foldForSearch('矩阵'), '矩阵');
      expect(foldForSearch(''), '');
    });

    test('folds decomposed input to the same result as composed', () {
      // o + U+0308 combining diaeresis, as an IME or pasted text may produce.
      const decomposed = 'o\u0308zdeg\u0306er';
      expect(decomposed == 'özdeğer', isFalse, reason: 'fixture is composed');
      expect(foldForSearch(decomposed), foldForSearch('özdeğer'));
    });

    test('is idempotent', () {
      const input = 'Özdeğerler ve Özvektörler';
      expect(foldForSearch(foldForSearch(input)), foldForSearch(input));
    });
  });

  group('Topic search', () {
    testWidgets('finds a Turkish topic typed without diacritics', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host('tr'));
      await tester.pumpAndSettle();

      expect(find.text('Özdeğerler ve Özvektörler'), findsOneWidget);

      await _search(tester, 'ozdeger');
      expect(
        find.text('Özdeğerler ve Özvektörler'),
        findsOneWidget,
        reason: '"ozdeger" should still find the eigen topic',
      );

      await _search(tester, 'ÖZDEĞER');
      expect(find.text('Özdeğerler ve Özvektörler'), findsOneWidget);

      await _search(tester, 'donusum');
      expect(find.text('Özdeğerler ve Özvektörler'), findsNothing);
    });

    testWidgets('matches a dotless i typed as a plain i', (tester) async {
      tester.view.physicalSize = const Size(1280, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host('tr'));
      await tester.pumpAndSettle();

      await _search(tester, 'ayrisim');
      expect(find.text('LU Ayrışımı (A = LU)'), findsOneWidget);
    });

    testWidgets('still filters when nothing matches', (tester) async {
      tester.view.physicalSize = const Size(1280, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host('tr'));
      await tester.pumpAndSettle();

      await _search(tester, 'zzzzz');
      expect(find.text('Determinant'), findsNothing);
    });

    testWidgets('English search is unaffected', (tester) async {
      tester.view.physicalSize = const Size(1280, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host('en'));
      await tester.pumpAndSettle();

      await _search(tester, 'determinant');
      expect(find.text('Determinant'), findsOneWidget);
    });
  });
}
