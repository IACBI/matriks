import 'package:flutter/material.dart';

/// Outlines the focused control while the keyboard is in use.
///
/// Material marks keyboard focus with a light overlay that changes a control
/// by about 1.3:1, below the 3:1 a focus indicator needs against its
/// unfocused state (WCAG 1.4.11). The ring is drawn over the whole app, so it
/// reaches custom rows and cells as well as Material controls, and only in
/// [FocusHighlightMode.traditional]: pointer and touch users see no change.
class FocusRing extends StatefulWidget {
  final Widget child;

  const FocusRing({super.key, required this.child});

  @override
  State<FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<FocusRing> {
  final _ring = ValueNotifier<Rect?>(null);
  bool _checkQueued = false;

  FocusManager get _focus => FocusManager.instance;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_scheduleCheck);
    _focus.addHighlightModeListener(_onModeChanged);
  }

  @override
  void dispose() {
    _focus.removeListener(_scheduleCheck);
    _focus.removeHighlightModeListener(_onModeChanged);
    _ring.dispose();
    super.dispose();
  }

  void _onModeChanged(FocusHighlightMode _) => _scheduleCheck();

  /// Focus or highlight mode changed: measure after the next frame.
  void _scheduleCheck() {
    _queueCheck();
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  /// Measures after a frame, when the focused control has its final layout.
  /// While a ring is shown this repeats after every later frame, whatever
  /// caused it, so a control that scrolls, slides in with a route or is
  /// pushed by content growing above it keeps its ring. It asks for no frames
  /// of its own: an idle screen stays idle.
  void _queueCheck() {
    if (_checkQueued || !mounted) return;
    _checkQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkQueued = false;
      if (!mounted) return;
      final rect = _focusedRect();
      _ring.value = rect;
      if (rect != null) _queueCheck();
    });
  }

  Rect? _focusedRect() {
    if (_focus.highlightMode != FocusHighlightMode.traditional) return null;
    final node = _focus.primaryFocus;
    final context = node?.context;
    if (node == null || node is FocusScopeNode || context == null) return null;
    // Text fields show focus with their own border and caret.
    if (context.findAncestorWidgetOfExactType<EditableText>() != null) {
      return null;
    }
    final box = context.findRenderObject();
    final own = this.context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return null;
    if (own is! RenderBox || !own.hasSize) return null;
    final rect = MatrixUtils.transformRect(
      box.getTransformTo(own),
      Offset.zero & box.size,
    );
    // A node spanning most of the window listens for shortcuts on a whole
    // screen; outlining it would frame the screen, not a control.
    final area = own.size.width * own.size.height;
    if (rect.isEmpty || rect.width * rect.height > area * .5) return null;
    return rect;
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: RepaintBoundary(
                child: CustomPaint(painter: _RingPainter(_ring, color)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final ValueNotifier<Rect?> ring;
  final Color color;

  _RingPainter(this.ring, this.color) : super(repaint: ring);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = ring.value;
    if (rect == null) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(2), const Radius.circular(10)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.ring != ring || old.color != color;
}
