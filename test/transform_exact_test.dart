import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix_engine/matrix_engine.dart';
import 'package:matriks/core/theme/app_theme.dart';
import 'package:matriks/features/settings/cubit/settings_cubit.dart';
import 'package:matriks/features/transform_visualizer/models/quadratic_surd.dart';
import 'package:matriks/features/transform_visualizer/models/transform_matrix.dart';
import 'package:matriks/features/transform_visualizer/views/transform_visualizer_screen.dart';
import 'package:matriks/features/transform_visualizer/widgets/coefficient_field.dart';
import 'package:matriks/features/transform_visualizer/widgets/transform_grid_painter.dart';
import 'package:matriks/l10n/generated/app_localizations.dart';

QuadraticSurd q(int n, [int den = 1, int rootN = 0, int rootDen = 1]) =>
    QuadraticSurd(Rational(n, den), Rational(rootN, rootDen));

final half = QuadraticSurd.halfRootTwo;

TransformGridPainter scene(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((p) => p.painter)
    .whereType<TransformGridPainter>()
    .single;

Future<void> openTransform(
  WidgetTester tester, {
  TransformMatrix? initial,
}) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    BlocProvider(
      create: (_) => SettingsCubit(),
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: TransformVisualizerScreen(initial: initial),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder field(String name) => find.byKey(ValueKey('coefficient-$name'));

String fieldText(WidgetTester tester, String name) =>
    tester.widget<TextField>(field(name)).controller!.text;

QuadraticSurd fieldValue(WidgetTester tester, String name) => tester
    .widget<CoefficientField>(
      find.ancestor(of: field(name), matching: find.byType(CoefficientField)),
    )
    .exact;

/// Every plain text on screen except the animation progress percentage.
Set<String> shownTexts(WidgetTester tester) => {
  for (final text in tester.widgetList<Text>(find.byType(Text)))
    if (text.data != null && !text.data!.endsWith('%')) text.data!,
  for (final name in ['a', 'b', 'c', 'd']) fieldText(tester, name),
};

// The app writes î and ĵ as a letter and a combining circumflex (U+0302).
final circumflex = String.fromCharCode(0x302);
String basisI(String x, String y) => 'i$circumflex = ($x, $y)';
String basisJ(String x, String y) => 'j$circumflex = ($x, $y)';

const error = 'Enter a number from −1000 to 1000.';

void main() {
  group('QuadraticSurd', () {
    test('is closed under + − × ÷ without rounding', () {
      expect(half * half, q(1, 2));
      expect(half + half, q(0, 1, 1));
      expect(q(1) / half, q(0, 1, 1));
      expect(q(1, 3) * q(3), QuadraticSurd.one);
      final x = q(2, 3, -5, 7);
      final y = q(-1, 4, 3, 2);
      expect(x / y * y, x);
      expect(x - x, QuadraticSurd.zero);
      expect(() => x / QuadraticSurd.zero, throwsA(isA<Exception>()));
    });

    test('orders exactly, including values that differ by less than 1e-12', () {
      expect(q(1, 2, 0).sign, 1);
      expect(q(-3, 2, 1).sign, -1); // −1.5 + 1.41…
      expect(q(3, 2, -1).sign, 1);
      expect(q(0, 1, -1, 2).sign, -1);
      expect(QuadraticSurd.zero.sign, 0);
      // 1393/985 is within 4e-7 of √2 and 3363/2378 within 9e-8.
      expect(q(1393, 985) < q(0, 1, 1), isTrue);
      expect(q(3363, 2378) > q(0, 1, 1), isTrue);
      expect(q(-1000) <= q(1000), isTrue);
      expect(q(0, 1, -1000).abs(), q(0, 1, 1000));
    });

    test('writes exact text and reads back everything it writes', () {
      final cases = {
        q(1): '1',
        q(0): '0',
        q(-7): '−7',
        q(9, 4): '2.25',
        q(-1, 8): '−0.125',
        q(1, 3): '1/3',
        q(-2, 3): '−2/3',
        half: '√2/2',
        -half: '−√2/2',
        q(0, 1, 1): '√2',
        q(0, 1, -3, 4): '−3√2/4',
        q(1, 2, 1, 2): '0.5 + √2/2',
        q(1, 3, -1): '1/3 − √2',
        q(-1, 1, 2): '−1 + 2√2',
      };
      cases.forEach((value, text) {
        expect(value.toString(), text);
        expect(QuadraticSurd.tryParse(text), value, reason: text);
      });
    });

    test('parses integers, decimals and fractions exactly', () {
      expect(QuadraticSurd.tryParse('1/3'), q(1, 3));
      expect(QuadraticSurd.tryParse(' -0.125 '), q(-1, 8));
      expect(QuadraticSurd.tryParse('2,25'), q(9, 4));
      expect(QuadraticSurd.tryParse('−4/6'), q(-2, 3));
      expect(QuadraticSurd.tryParse('0.1'), q(1, 10));
      expect(QuadraticSurd.tryParse('-√2/2'), -half);
      expect(QuadraticSurd.tryParse('0.5√2'), half);
      for (final invalid in [
        '',
        '-',
        'NaN',
        'Infinity',
        '1e3',
        '0x10',
        '1/0',
        '1/2/3',
        '√3',
        '√2/0',
        'abc',
      ]) {
        expect(QuadraticSurd.tryParse(invalid), isNull, reason: invalid);
      }
    });

    test('reads decimals written without a digit on one side of the point', () {
      expect(QuadraticSurd.tryParse('.5'), q(1, 2));
      expect(QuadraticSurd.tryParse('-.5'), q(-1, 2));
      expect(QuadraticSurd.tryParse('+.5'), q(1, 2));
      expect(QuadraticSurd.tryParse('−.25'), q(-1, 4));
      expect(QuadraticSurd.tryParse(',5'), q(1, 2));
      expect(QuadraticSurd.tryParse('3.'), q(3));
      expect(QuadraticSurd.tryParse('-3.'), q(-3));
      expect(QuadraticSurd.tryParse('.5√2'), half);
      expect(
        QuadraticSurd.tryParse('.5 + √2'),
        QuadraticSurd(Rational(1, 2), Rational.one),
      );
      for (final invalid in ['.', '-.', '..5', '3..', '.5.', '1./2', '.√2']) {
        expect(QuadraticSurd.tryParse(invalid), isNull, reason: invalid);
      }
    });

    test('reads a double as the decimal it was written as', () {
      expect(QuadraticSurd.fromDouble(0.1), q(1, 10));
      expect(QuadraticSurd.fromDouble(-2.5), q(-5, 2));
      expect(QuadraticSurd.fromDouble(1e-7), q(1, 10000000));
      expect(QuadraticSurd.fromDouble(4), q(4));
      expect(() => QuadraticSurd.fromDouble(double.nan), throwsArgumentError);
    });
  });

  group('Exact presets', () {
    test("the rotation's determinant is exactly 1", () {
      final r = TransformMatrix.preset('rotation');
      expect(r.exactDeterminant, QuadraticSurd.one);
      expect(r.exactA, half);
      expect(r.exactB, -half);
    });

    test('the rotation preserves lengths exactly in Q(√2)', () {
      final r = TransformMatrix.preset('rotation');
      expect(r.exactA * r.exactA + r.exactC * r.exactC, QuadraticSurd.one);
      expect(r.exactB * r.exactB + r.exactD * r.exactD, QuadraticSurd.one);
      expect(r.exactA * r.exactB + r.exactC * r.exactD, QuadraticSurd.zero);
      for (final (x, y) in [(3, 4), (-5, 12), (1, 0)]) {
        final vx = q(x), vy = q(y);
        final rx = r.exactA * vx + r.exactB * vy;
        final ry = r.exactC * vx + r.exactD * vy;
        expect(rx * rx + ry * ry, vx * vx + vy * vy);
      }
    });

    test('the projection is exactly idempotent with determinant 0', () {
      final p = TransformMatrix.preset('projection');
      final (a, b, c, d) = (p.exactA, p.exactB, p.exactC, p.exactD);
      expect(a * a + b * c, a);
      expect(a * b + b * d, b);
      expect(c * a + d * c, c);
      expect(c * b + d * d, d);
      expect(p.exactDeterminant, QuadraticSurd.zero);
    });

    test('fromRationals keeps entries exact and doubles for drawing', () {
      final m = TransformMatrix.fromRationals(
        Rational(1, 3),
        Rational(-2),
        Rational(5, 7),
        Rational(1, 2),
      );
      expect(m.exactA, q(1, 3));
      expect(m.exactC, q(5, 7));
      expect(m.exactDeterminant, q(1, 6) + q(10, 7));
      expect(m.a, closeTo(1 / 3, 1e-15));
      expect(m.b, -2);
    });
  });

  testWidgets('The rotation preset shows √2/2 entries and determinant 1', (
    tester,
  ) async {
    await openTransform(tester);
    await tester.tap(find.text('Rotation 45°'));
    await tester.pumpAndSettle();
    expect(fieldText(tester, 'a'), '√2/2');
    expect(fieldText(tester, 'b'), '−√2/2');
    expect(fieldText(tester, 'c'), '√2/2');
    expect(fieldText(tester, 'd'), '√2/2');
    expect(find.text(basisI('√2/2', '√2/2')), findsOneWidget);
    expect(find.text(basisJ('−√2/2', '√2/2')), findsOneWidget);
    expect(find.text('Target determinant: 1'), findsOneWidget);

    await tester.tap(find.text('Projection (det=0)'));
    await tester.pumpAndSettle();
    expect(fieldText(tester, 'a'), '0.5');
    expect(find.text('Target determinant: 0'), findsOneWidget);
  });

  testWidgets('Fraction input 1/3 is shown and used exactly', (tester) async {
    await openTransform(tester);
    await tester.enterText(field('a'), '1/3');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(fieldValue(tester, 'a'), q(1, 3));
    expect(fieldText(tester, 'a'), '1/3');
    expect(find.text(basisI('1/3', '0')), findsOneWidget);
    expect(find.text('Target determinant: 1/3'), findsOneWidget);
    expect(scene(tester).a, closeTo(1 / 3, 1e-15));
    expect(find.text(error), findsNothing);

    // Stepping keeps the fraction exact.
    await tester.tap(find.byTooltip('Increase coefficient a'));
    await tester.pumpAndSettle();
    expect(fieldText(tester, 'a'), '5/6');
    expect(find.text('Target determinant: 5/6'), findsOneWidget);
  });

  testWidgets('An initial rational matrix opens exactly', (tester) async {
    await openTransform(
      tester,
      initial: TransformMatrix.fromRationals(
        Rational(1, 3),
        Rational(2),
        Rational(-1, 7),
        Rational(1),
      ),
    );
    expect(fieldText(tester, 'a'), '1/3');
    expect(fieldText(tester, 'c'), '−1/7');
    expect(find.text('Target determinant: 13/21'), findsOneWidget);
  });

  testWidgets('No interpolated number is displayed mid-animation', (
    tester,
  ) async {
    await openTransform(tester);
    await tester.tap(find.text('Scale'));
    await tester.pumpAndSettle();
    final settled = shownTexts(tester);

    await tester.tap(find.text('Rotation 45°'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final rotatingA = scene(tester).a;
    expect(rotatingA, isNot(closeTo(1.5, 1e-3)));
    expect(rotatingA, isNot(closeTo(0.7071, 1e-3)));
    final rotating = shownTexts(tester);
    expect(rotating, contains(basisI('√2/2', '√2/2')));
    expect(rotating, contains('Target determinant: 1'));
    await tester.pumpAndSettle();
    expect(shownTexts(tester), rotating);

    await tester.tap(find.text('Scale'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(shownTexts(tester), settled);

    // Scrubbing and reversing show the same exact target.
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Play'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(scene(tester).a, inExclusiveRange(0.71, 1.5));
    expect(shownTexts(tester), settled);
    await tester.pumpAndSettle();
  });

  testWidgets('Invalid input stays as a draft and √2/2 stays editable', (
    tester,
  ) async {
    await openTransform(tester);
    await tester.tap(find.text('Rotation 45°'));
    await tester.pumpAndSettle();

    for (final invalid in ['abc', '1/0', '2/3/4', '1001', '-1000.5', '√3']) {
      await tester.enterText(field('a'), invalid);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text(error), findsOneWidget, reason: invalid);
      expect(fieldText(tester, 'a'), invalid);
      expect(fieldValue(tester, 'a'), half);
      expect(find.text('Target determinant: 1'), findsOneWidget);
    }

    // Submitting an untouched √2 entry is not an edit and not an error.
    await tester.tap(field('b'));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(fieldText(tester, 'b'), '−√2/2');
    expect(find.text(error), findsOneWidget);
    expect(fieldText(tester, 'a'), '√3');

    // Typing replaces the √2 entry with an exact value.
    await tester.enterText(field('b'), '1/4');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(fieldValue(tester, 'b'), q(1, 4));
    expect(fieldText(tester, 'b'), '0.25');
    // √2/2 · √2/2 − 1/4 · √2/2 = 1/2 − √2/8
    expect(find.text('Target determinant: 0.5 − √2/8'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);

    // The bound is inclusive and exact.
    await tester.enterText(field('a'), '−1000');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(fieldValue(tester, 'a'), q(-1000));
    expect(find.text(error), findsNothing);
  });
}
