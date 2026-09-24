import 'package:flutter/material.dart';

/// One side of a square matrix bracket drawn with borders.
class MatrixBracket extends StatelessWidget {
  final double height;
  final bool isLeft;
  final Color? color;
  final double width;
  final double thickness;

  const MatrixBracket({
    super.key,
    required this.height,
    required this.isLeft,
    this.color,
    this.width = 10,
    this.thickness = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(
      color:
          color ??
          (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF64748B)
              : const Color(0xFF475569)),
      width: thickness,
    );
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          top: side,
          bottom: side,
          left: isLeft ? side : BorderSide.none,
          right: isLeft ? BorderSide.none : side,
        ),
      ),
    );
  }
}
