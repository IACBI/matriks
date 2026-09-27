import 'package:flutter/material.dart';

/// Content that scrolls sideways when it is wider than the screen, with a
/// visible scrollbar.
///
/// Flutter adds no scrollbar to a horizontal scroll view by itself, and a
/// matrix cut at the edge (the L of a 5×5 LU on a phone, the column of B
/// beside a long row of A, the last column of the editor) otherwise looks
/// complete. Room for the thumb is reserved only while the content
/// overflows, so content that fits keeps its spacing. Only this view's own
/// metrics count, so a vertical scroll view inside it is left alone.
class SidewaysScroll extends StatefulWidget {
  final Widget child;
  const SidewaysScroll({super.key, required this.child});

  @override
  State<SidewaysScroll> createState() => _SidewaysScrollState();
}

class _SidewaysScrollState extends State<SidewaysScroll> {
  final _controller = ScrollController();
  var _overflows = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _onMetrics(ScrollMetricsNotification notification) {
    if (notification.depth == 0) {
      final overflows =
          notification.metrics.maxScrollExtent >
          notification.metrics.minScrollExtent;
      if (overflows != _overflows) setState(() => _overflows = overflows);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _onMetrics,
      child: Scrollbar(
        controller: _controller,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(bottom: _overflows ? 10 : 0),
          child: widget.child,
        ),
      ),
    );
  }
}
