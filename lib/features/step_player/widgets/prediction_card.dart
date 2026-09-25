import 'package:flutter/material.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/widgets/math_text.dart';
import '../../../l10n/generated/app_localizations.dart';

class PredictionCard extends StatefulWidget {
  final RowEliminationTransformation transformation;
  final VoidCallback onContinue;

  /// Varies where the correct choice appears; the step index is enough.
  final int seed;
  const PredictionCard({
    super.key,
    required this.transformation,
    required this.onContinue,
    this.seed = 0,
  });

  /// Three choices for the multiplier m in R_t ← R_t - m R_s.
  ///
  /// Distractors are the usual mistakes before arbitrary neighbours: the sign
  /// error (-m) and the inverted ratio pivot ÷ target (1/m). m ± 1 only fills
  /// in when those coincide with m or each other. The order is rotated by
  /// [seed], so the answer is not always in the same place.
  static List<Rational> choices(Rational correct, int seed) {
    final options = <Rational>[correct];
    void add(Rational value) {
      if (options.length < 3 && !options.contains(value)) options.add(value);
    }

    add(-correct);
    if (!correct.isZero) add(correct.inverse());
    add(correct + Rational.one);
    add(correct - Rational.one);
    final shift = seed % options.length;
    return [...options.skip(shift), ...options.take(shift)];
  }

  @override
  State<PredictionCard> createState() => _PredictionCardState();
}

class _PredictionCardState extends State<PredictionCard> {
  Rational? _answer;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final correct = -widget.transformation.factor;
    final options = PredictionCard.choices(correct, widget.seed);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.predictTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l.predictPrompt),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in options)
                  OutlinedButton(
                    onPressed: _answer == null
                        ? () => setState(() => _answer = value)
                        : null,
                    child: MathText(value.toLatex(), fontSize: 20),
                  ),
              ],
            ),
            if (_answer != null) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  _answer == correct ? l.predictCorrect : l.predictIncorrect,
                ),
              ),
              if (_answer != correct) MathText(correct.toLatex(), fontSize: 20),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: widget.onContinue,
                child: Text(_answer == null ? l.skip : l.continueLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
