import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

// Inline prose uses readable symbols; complete formulas remain in MathText.
String readableMathProse(String text) {
  const subscripts = '₀₁₂₃₄₅₆₇₈₉';
  const superscripts = '⁰¹²³⁴⁵⁶⁷⁸⁹';
  var result = text.replaceAllMapped(
    RegExp(r'\\frac\{(-?\d+)\}\{(-?\d+)\}'),
    (match) => '${match[1]}/${match[2]}',
  );
  // Column vectors and small matrices read as comma separated rows in prose.
  result = result.replaceAllMapped(
    RegExp(r'\\begin\{[bp]matrix\}(.*?)\\end\{[bp]matrix\}', dotAll: true),
    (match) => '(${match[1]!.split(r'\\').map((e) => e.trim()).join(', ')})',
  );
  // Wrappers carry font styling only; the enclosed text is what the reader needs.
  result = result.replaceAllMapped(
    RegExp(r'\\(?:mathbf|mathrm|text|operatorname)\{([^{}]*)\}'),
    (match) => match[1]!,
  );
  result = result.replaceAllMapped(RegExp(r'(\S)_(?:\{(\d+)\}|(\d+))'), (
    match,
  ) {
    final digits = match[2] ?? match[3]!;
    final index = digits
        .split('')
        .map((digit) => subscripts[int.parse(digit)])
        .join();
    return '${match[1]}$index';
  });
  result = result.replaceAllMapped(RegExp(r'\^(?:\{(\d+)\}|(\d+))'), (match) {
    final digits = match[1] ?? match[2]!;
    return digits
        .split('')
        .map((digit) => superscripts[int.parse(digit)])
        .join();
  });
  const symbols = {
    r'\leftrightarrow': '↔',
    r'\leftarrow': '←',
    r'\rightarrow': '→',
    r'\implies': '⟹',
    r'\approx': '≈',
    r'\cdot': '·',
    r'\times': '×',
    r'\lambda': 'λ',
    r'\quad': ' ',
    r'\pm': '±',
    r'\mp': '∓',
    r'\emptyset': '∅',
  };
  for (final entry in symbols.entries) {
    result = result.replaceAll(entry.key, entry.value);
  }
  return result.replaceAll(RegExp(r'[ \t]{2,}'), ' ').trim();
}

class MathText extends StatelessWidget {
  final String latex;
  final TextStyle? textStyle;
  final Color? color;
  final double fontSize;
  final TextAlign textAlign;
  final bool wrapLines;

  const MathText(
    this.latex, {
    super.key,
    this.textStyle,
    this.color,
    this.fontSize = 16.0,
    this.textAlign = TextAlign.center,
    this.wrapLines = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ??
        textStyle?.color ??
        Theme.of(context).textTheme.bodyLarge?.color ??
        Colors.black;

    // Clean up or wrap latex if not already math mode
    final cleaned = latex.trim();
    if (cleaned.isEmpty) return const SizedBox.shrink();

    final math = Math.tex(
      cleaned,
      // Apply Flutter's TextScaler once; Math otherwise scales it a second time.
      textScaleFactor: 1,
      textStyle: TextStyle(
        fontSize: MediaQuery.textScalerOf(context).scale(fontSize),
        color: effectiveColor,
        fontWeight: textStyle?.fontWeight,
      ),
      onErrorFallback: (err) => Text(
        latex,
        textScaler: TextScaler.noScaling,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: MediaQuery.textScalerOf(context).scale(fontSize),
          color: effectiveColor,
        ),
      ),
    );
    if (!wrapLines) return math;

    // TeX break points preserve fractions and grouped factors as whole units.
    final parts = math.texBreak().parts;
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 8,
        children: [
          for (final part in parts)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: part,
              ),
            ),
        ],
      ),
    );
  }
}
