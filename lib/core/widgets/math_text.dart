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
  // A column vector reads as its entries, a matrix as rows of entries:
  // (5, 3, -2) and (1, 0; 0, 1).
  result = result.replaceAllMapped(
    RegExp(r'\\begin\{[bp]matrix\}(.*?)\\end\{[bp]matrix\}', dotAll: true),
    (match) {
      final rows = [
        for (final row in match[1]!.split(r'\\'))
          if (row.trim().isNotEmpty)
            row.split('&').map((e) => e.trim()).join(', '),
      ];
      final matrix = match[1]!.contains('&');
      return '(${rows.join(matrix ? '; ' : ', ')})';
    },
  );
  // Wrappers carry font styling only; the enclosed text is what the reader needs.
  result = result.replaceAllMapped(
    RegExp(r'\\(?:mathbf|mathrm|text|operatorname)\{([^{}]*)\}'),
    (match) => match[1]!,
  );
  // Indices such as R_{2} and A_{1,2}; a comma between indices stays.
  result = result.replaceAllMapped(
    RegExp(r'(\S)_(?:\{(\d+(?:,\d+)*)\}|(\d+))'),
    (match) {
      final digits = match[2] ?? match[3]!;
      final index = digits
          .split('')
          .map((c) => c == ',' ? c : subscripts[int.parse(c)])
          .join();
      return '${match[1]}$index';
    },
  );
  result = result.replaceAllMapped(RegExp(r'\^(?:\{(-?\d+)\}|(\d+))'), (match) {
    final digits = match[1] ?? match[2]!;
    return digits
        .split('')
        .map((c) => c == '-' ? '⁻' : superscripts[int.parse(c)])
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
    // Screen readers get readable text, not the glyphs the renderer lays
    // out ("1/2" rather than "1", "2").
    final label = mathSemanticsLabel(cleaned);
    if (!wrapLines) {
      return Semantics(label: label, excludeSemantics: true, child: math);
    }

    // Break between top-level terms. Each later piece starts with its
    // operator after an empty group, so TeX keeps the space on both sides of
    // it; fractions and bracketed factors stay whole.
    final parts = splitTexTerms(cleaned);
    if (parts.length < 2) {
      return Semantics(label: label, excludeSemantics: true, child: math);
    }
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) => Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8,
          children: [
            for (final part in parts)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                    part,
                    textScaleFactor: 1,
                    textStyle: TextStyle(
                      fontSize: MediaQuery.textScalerOf(context)
                          .scale(fontSize),
                      color: effectiveColor,
                      fontWeight: textStyle?.fontWeight,
                    ),
                    onErrorFallback: (_) => const SizedBox.shrink(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// [readableMathProse] with the spacing and grouping commands a formula may
/// still carry removed, for use as a semantics label.
String mathSemanticsLabel(String latex) {
  var text = readableMathProse(latex);
  // Fractions of expressions, innermost first: \frac{a + b}{2} is (a + b)/2.
  String operand(String s) => RegExp(r'^-?[\w.·⁻¹₀-₉]+$').hasMatch(s.trim())
      ? s.trim()
      : '(${s.trim()})';
  for (var previous = ''; previous != text;) {
    previous = text;
    text = text.replaceAllMapped(
      RegExp(r'\\frac\{([^{}]*)\}\{([^{}]*)\}'),
      (m) => '${operand(m[1]!)}/${operand(m[2]!)}',
    );
  }
  text = text
      .replaceAll(r'\Rightarrow', '⇒')
      .replaceAll(r'\mathbf', '')
      .replaceAll(RegExp(r'\\(left|right)'), '')
      .replaceAll(RegExp(r'\\[,;:! ]'), ' ')
      // Operator names are read as words (det, rank); any other command
      // only formats, and a reader would spell out its backslash.
      .replaceAllMapped(
        RegExp(r'\\([a-zA-Z]+)'),
        (m) => const {'det', 'dim', 'ker', 'rank', 'tr'}.contains(m[1])
            ? m[1]!
            : '',
      )
      .replaceAll(RegExp(r'[{}]'), '');
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Splits [latex] before each top-level ` + `, ` - `, ` = ` or
/// ` \approx `, outside braces and \left…\right groups. Every piece after
/// the first begins with `{}` and its operator, so it renders with the same
/// spacing as the unbroken formula.
List<String> splitTexTerms(String latex) {
  const operators = [' + ', ' - ', ' = ', r' \approx '];
  final parts = <String>[];
  var depth = 0;
  var start = 0;
  var i = 0;
  while (i < latex.length) {
    final ch = latex[i];
    if (ch == '{') {
      depth++;
    } else if (ch == '}') {
      depth--;
    } else if (latex.startsWith(r'\left', i)) {
      depth++;
    } else if (latex.startsWith(r'\right', i)) {
      depth--;
    } else if (depth == 0 && i > start) {
      final op = operators.where((o) => latex.startsWith(o, i)).firstOrNull;
      if (op != null) {
        parts.add(latex.substring(start, i).trim());
        start = i + 1;
        i += op.length;
        continue;
      }
    }
    i++;
  }
  parts.add(latex.substring(start).trim());
  return [
    for (final (index, part) in parts.indexed)
      if (part.isNotEmpty) index == 0 ? part : '{}$part',
  ];
}
