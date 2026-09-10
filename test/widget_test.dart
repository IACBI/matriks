import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matriks/app.dart';

void main() {
  testWidgets('Catalog exposes all core learning topics through search', (
    tester,
  ) async {
    await tester.pumpWidget(const MatrixEducatorApp());
    await tester.pumpAndSettle();
    expect(find.text('Matriks'), findsOneWidget);
    for (final title in [
      'Gauss-Jordan Elimination (RREF)',
      'Gaussian Elimination (REF)',
      'Linear Systems (Ax = b)',
      'Determinant',
    ]) {
      await tester.enterText(find.byType(TextField), title);
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data == title,
        ),
        findsOneWidget,
      );
    }
  });
}
