import 'package:flutter/material.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/math_text.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/cubit/settings_state.dart';

/// The solver's description of a step, shown only when it adds something to
/// the caption under the matrix (for example why two rows are swapped).
class StepCard extends StatelessWidget {
  final ExplanationLevel explanationLevel;
  final MatrixStep step;
  final bool showTitle;
  final String localizedTitle;
  final String localizedDescription;

  /// The solver's description, when the caption does not already say the
  /// same thing.
  final bool showDescription;

  const StepCard({
    this.explanationLevel = ExplanationLevel.detailed,
    super.key,
    required this.step,
    this.showTitle = true,
    required this.localizedTitle,
    required this.localizedDescription,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description =
        explanationLevel != ExplanationLevel.hidden && showDescription;
    if (!description && !showTitle) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle)
          Semantics(
            header: true,
            child: Text(
              readableMathProse(localizedTitle),
              style: theme.textTheme.titleLarge,
            ),
          ),
        if (showTitle && description) const SizedBox(height: 10),
        if (description)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: ExcludeSemantics(
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  readableMathProse(localizedDescription),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Names the roles a row operation marks on the matrix. Only roles the step
/// really has are listed, and each has its own shape as well as its colour.
class RoleLegend extends StatelessWidget {
  final List<CellHighlight> highlights;

  const RoleLegend({super.key, required this.highlights});

  static bool hasRoles(List<CellHighlight> highlights) => highlights.any(
    (h) =>
        h.type == HighlightType.pivot ||
        h.type == HighlightType.source ||
        h.type == HighlightType.target ||
        h.type == HighlightType.zeroed,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final types = highlights.map((h) => h.type).toSet();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 6,
      children: [
        if (types.contains(HighlightType.pivot))
          _entry(
            context,
            _swatch(AppTheme.accentAmber, filled: true, width: 2.4),
            l10n?.legendPivot ?? 'Pivot',
          ),
        if (types.contains(HighlightType.source))
          _entry(
            context,
            _swatch(AppTheme.accentAmber, filled: false, width: 1.2),
            l10n?.legendSource ?? 'Source',
          ),
        if (types.contains(HighlightType.target))
          _entry(
            context,
            _swatch(AppTheme.accentCyan, filled: true, width: 1.5),
            l10n?.legendTarget ?? 'Target',
          ),
        if (types.contains(HighlightType.zeroed))
          _entry(
            context,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '0 ✓',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            l10n?.legendZeroResult ?? '0-Result',
          ),
      ],
    );
  }

  Widget _swatch(Color color, {required bool filled, required double width}) =>
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: filled ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(color: color, width: width),
          borderRadius: BorderRadius.circular(3),
        ),
      );

  Widget _entry(BuildContext context, Widget swatch, String label) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: swatch),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// What the details drawer under the caption holds: why the operation works
/// and, when the caption has no calculations of its own, each cell's formula.
class StepDetails extends StatelessWidget {
  final String? rationale;
  final List<SubCalculation> calculations;
  final void Function(SubCalculation)? onCalculationTap;

  const StepDetails({
    super.key,
    this.rationale,
    this.calculations = const [],
    this.onCalculationTap,
  });

  bool get isEmpty => rationale == null && calculations.isEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (rationale != null) ...[
          Text(
            l10n?.stepExplanation ?? 'Why this works',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          Text(
            readableMathProse(rationale!),
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 12),
        ],
        if (calculations.isNotEmpty) ...[
          Text(
            '${l10n?.cellCalculations ?? 'Cell calculations'} (${calculations.length})',
            style: theme.textTheme.labelLarge,
          ),
          for (final sub in calculations)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: MathText(sub.formulaLatex, fontSize: 16),
              ),
              trailing: const Icon(Icons.open_in_full_rounded, size: 16),
              onTap: onCalculationTap == null
                  ? null
                  : () => onCalculationTap!(sub),
            ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
