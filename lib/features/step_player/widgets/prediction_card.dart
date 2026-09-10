import 'package:flutter/material.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/widgets/math_text.dart';
import '../../../l10n/generated/app_localizations.dart';

class PredictionCard extends StatefulWidget {
  final RowEliminationTransformation transformation;
  final VoidCallback onContinue;
  const PredictionCard({
    super.key,
    required this.transformation,
    required this.onContinue,
  });
  @override
  State<PredictionCard> createState() => _PredictionCardState();
}

class _PredictionCardState extends State<PredictionCard> {
  Rational? _answer;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final correct = -widget.transformation.factor;
    final options = [correct, correct + Rational.one, correct - Rational.one]
      ..sort((a, b) => a.compareTo(b));
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
