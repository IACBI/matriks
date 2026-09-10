import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'math_text.dart';

/// Fits the typeset equation without reducing text below a readable size.
/// Exceptionally long exact expressions remain horizontally scrollable.
class ReadableMathFit extends StatelessWidget {
  final String latex;
  final double fontSize;
  final double minimumFontSize;
  final Color? color;

  const ReadableMathFit(
    this.latex, {
    super.key,
    required this.fontSize,
    this.minimumFontSize = 14,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _BoundedScale(
            availableWidth: constraints.maxWidth,
            minimumScale:
                (scaler.scale(minimumFontSize) / scaler.scale(fontSize)).clamp(
                  0.0,
                  1.0,
                ),
            child: MathText(latex, fontSize: fontSize, color: color),
          ),
        );
      },
    );
  }
}

class _BoundedScale extends SingleChildRenderObjectWidget {
  final double availableWidth;
  final double minimumScale;

  const _BoundedScale({
    required this.availableWidth,
    required this.minimumScale,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderBoundedScale(availableWidth, minimumScale);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderBoundedScale renderObject,
  ) {
    renderObject.update(availableWidth, minimumScale);
  }
}

class _RenderBoundedScale extends RenderProxyBox {
  double _availableWidth;
  double _minimumScale;
  double _scale = 1;

  _RenderBoundedScale(this._availableWidth, this._minimumScale);

  void update(double width, double minimumScale) {
    if (_availableWidth == width && _minimumScale == minimumScale) return;
    _availableWidth = width;
    _minimumScale = minimumScale;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    child!.layout(const BoxConstraints(), parentUsesSize: true);
    final widthScale = child!.size.width > 0
        ? _availableWidth / child!.size.width
        : 1.0;
    final heightScale = child!.size.height > 0
        ? constraints.maxHeight / child!.size.height
        : 1.0;
    _scale = math.min(widthScale, heightScale).clamp(_minimumScale, 1.0);
    size = constraints.constrain(child!.size * _scale);
  }

  Matrix4 get _transform => Matrix4.diagonal3Values(_scale, _scale, 1);

  @override
  void paint(PaintingContext context, Offset offset) {
    context.pushTransform(needsCompositing, offset, _transform, super.paint);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      result.addWithPaintTransform(
        transform: _transform,
        position: position,
        hitTest: (result, position) =>
            super.hitTestChildren(result, position: position),
      );

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(_transform);
  }
}
