import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Runs before every test in this directory.
///
/// A tap that misses its widget only prints a warning, and the tap still
/// lands on whatever is at that point: two tests passed that way without
/// doing what they describe (an answer below the screen at 200% text, a
/// topic tapped before its scroll was laid out). A miss fails the test.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  WidgetController.hitTestWarningShouldBeFatal = true;
  await testMain();
}
