import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../l10n/generated/app_localizations.dart';

// Inline prose uses readable symbols; complete formulas remain in MathText.
//
// A repeating decimal is spelled out with [repeating] (0.1\overline{6} reads
// "0.1 repeating 6"): the bundled fonts have no combining overline, and
// screen readers skip the brackets of the 0.1(6) notation, which would leave
// "0.16".
String readableMathProse(String text, {String repeating = 'repeating'}) {
  const subscripts = '₀₁₂₃₄₅₆₇₈₉';
  const superscripts = '⁰¹²³⁴⁵⁶⁷⁸⁹';
  var result = text.replaceAllMapped(
    RegExp(r'\\overline\{(\d+)\}'),
    (match) => ' $repeating ${match[1]}',
  );
  result = result.replaceAllMapped(
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
      displayStyleMatrixCells(cleaned),
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
    final repeating = AppLocalizations.of(context)?.mathRepeating;
    final label = repeating == null
        ? mathSemanticsLabel(cleaned)
        : mathSemanticsLabel(cleaned, repeating: repeating);
    if (!wrapLines) {
      return Semantics(label: label, excludeSemantics: true, child: math);
    }

    // Break between top-level terms. Each later piece starts with its
    // operator after an empty group, so TeX keeps the space on both sides of
    // it; fractions and bracketed factors stay whole.
    final parts = splitTexTerms(cleaned);
    if (parts.length < 2) {
      // Nothing to break at (a lone product, pmatrix -> pmatrix): scroll
      // rather than overflow a narrow screen.
      return Semantics(
        label: label,
        excludeSemantics: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: math,
        ),
      );
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
                    displayStyleMatrixCells(part),
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

final _matrixEnvironment = RegExp(
  r'\\begin\{([pbvBV]?matrix)\}(.*?)\\end\{\1\}',
  dotAll: true,
);

// A zero-width strut from 0.95em below the baseline to 1.65em above it: the
// renderer sizes array rows for text style, so display-style fractions need
// it to keep neighbouring rows apart.
const _displayCell = r'\rule[-0.95em]{0pt}{2.6em}\displaystyle ';

/// [latex] with the entries of every matrix that holds a fraction set in
/// display style.
///
/// TeX sets matrix entries in text style, where a fraction shrinks to script
/// size: in a column vector 27/13 above -23/65 nearly touch, and an L or U
/// with fractions is hard to read. Display-style entries are full size and
/// the rows grow to fit them. Integer matrices are left as they are.
String displayStyleMatrixCells(String latex) =>
    latex.replaceAllMapped(_matrixEnvironment, (match) {
      final body = match[2]!;
      if (!body.contains(r'\frac')) return match[0]!;
      final cells = body.replaceAllMapped(
        RegExp(r'(\\\\|&)'),
        (separator) => '${separator[0]}$_displayCell',
      );
      return '\\begin{${match[1]}}$_displayCell$cells\\end{${match[1]}}';
    });

/// [readableMathProse] with the spacing and grouping commands a formula may
/// still carry removed, for use as a semantics label.
String mathSemanticsLabel(String latex, {String repeating = 'repeating'}) {
  var text = readableMathProse(
    latex,
    repeating: repeating,
  ).replaceAll(RegExp(r'\\pi(?![a-zA-Z])'), 'π');
  // Fractions and roots of expressions, innermost first: \frac{a + b}{2} is
  // (a + b)/2 and \sqrt[3]{2} is ∛2, so a surd such as \frac{\sqrt{5}}{2}
  // reads √5/2 instead of losing its root.
  String operand(String s) => RegExp(r'^-?[\w.·⁻¹₀-₉π√∛]+$').hasMatch(s.trim())
      ? s.trim()
      : '(${s.trim()})';
  for (var previous = ''; previous != text;) {
    previous = text;
    text = text
        .replaceAllMapped(
          RegExp(r'\\sqrt\[3\]\{([^{}]*)\}'),
          (m) => '∛${operand(m[1]!)}',
        )
        .replaceAllMapped(
          RegExp(r'\\sqrt\{([^{}]*)\}'),
          (m) => '√${operand(m[1]!)}',
        )
        .replaceAllMapped(
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
        (m) =>
            const {
              'det',
              'dim',
              'ker',
              'rank',
              'tr',
              'cos',
              'sin',
              'arccos',
            }.contains(m[1])
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
