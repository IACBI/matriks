import 'package:flutter/material.dart';

/// Builds [child], a [Slider], only while its part of the screen is active.
///
/// A Slider keeps an OverlayPortal open for its value indicator, and the
/// portal's semantics node is placed under the slider's own. Where the
/// slider is hidden (a background tab of the shell, a route covered by
/// another, a collapsed drawer) its node is gone and the portal's is left
/// without a parent; the Windows accessibility bridge rejects that update
/// and every later one, so a screen reader stops seeing the app. Hidden
/// content has its tickers disabled in each of those places, which is the
/// signal used here.
class SliderWhileShown extends StatelessWidget {
  final Widget child;

  const SliderWhileShown({super.key, required this.child});

  @override
  Widget build(BuildContext context) => TickerMode.valuesOf(context).enabled
      ? child
      : const SizedBox(height: kMinInteractiveDimension);
}
