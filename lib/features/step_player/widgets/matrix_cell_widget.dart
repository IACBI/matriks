import 'package:flutter/material.dart';
import 'package:matrix_engine/matrix_engine.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/math_text.dart';
import '../../../core/widgets/readable_math_fit.dart';
import '../../../l10n/generated/app_localizations.dart';

class MatrixCellWidget extends StatelessWidget {
  final String? calculationLatex;
  final Rational value;
  final double fontSize;
  final String? semanticLabel;
  final Rational? valueBefore;
  final CellHighlight? highlight;
  final bool isDecimalView;
  final bool hasSubCalculation;
  final VoidCallback? onTap;

  // Instructional Animation Parameters
  final bool isZeroResult;

  const MatrixCellWidget({
    this.calculationLatex,
    super.key,
    required this.value,
    this.fontSize = 18,
    this.semanticLabel,
    this.valueBefore,
    this.highlight,
    this.isDecimalView = false,
    this.hasSubCalculation = false,
    this.onTap,
    this.isZeroResult = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final containerDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 180);
    final textDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 220);

    Color bgColor = Colors.transparent;
    Color borderColor = Colors.transparent;
    Color textColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.textPrimaryLight;
    double borderWidth = 1;

    final hasValueChanged = valueBefore != null && valueBefore != value;

    if (highlight != null) {
      switch (highlight!.type) {
        case HighlightType.pivot:
          bgColor = AppTheme.accentAmber.withValues(
            alpha: isDark ? 0.18 : 0.08,
          );
          borderColor = AppTheme.accentAmber;
          borderWidth = 1.5;
          break;
        case HighlightType.target:
          bgColor = AppTheme.accentCyan.withValues(alpha: isDark ? 0.18 : 0.08);
          borderColor = AppTheme.accentCyan;
          borderWidth = 1.5;
          break;
        case HighlightType.source:
          bgColor = AppTheme.accentPurple.withValues(
            alpha: isDark ? 0.18 : 0.08,
          );
          borderColor = AppTheme.accentPurple;
          borderWidth = 1.5;
          break;
        case HighlightType.zeroed:
          bgColor = AppTheme.accentGreen.withValues(
            alpha: isDark ? 0.18 : 0.08,
          );
          borderColor = AppTheme.accentGreen;
          borderWidth = 1.5;
          break;
        case HighlightType.inactive:
          bgColor = isDark
              ? AppTheme.scaffoldDark
              : AppTheme.surfaceVariantLight;
          borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
          textColor = isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;
          break;
        case HighlightType.selected:
          borderColor = AppTheme.primaryBlue;
          borderWidth = 2.2;
          break;
      }
    } else if (hasValueChanged) {
      borderColor = AppTheme.accentCyan.withValues(alpha: 0.7);
      borderWidth = 1.8;
    }

    if (isZeroResult) {
      borderColor = AppTheme.accentGreen;
      bgColor = AppTheme.accentGreen.withValues(alpha: isDark ? 0.18 : 0.08);
    }

    final textToShow =
        calculationLatex ??
        (isDecimalView
            ? value.toDisplayString(asDecimal: true)
            : value.toLatex());

    final cellBody = AnimatedContainer(
      duration: containerDuration,
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
            child: AnimatedSwitcher(
              duration: textDuration,
              transitionBuilder: (child, animation) {
                if (reduceMotion) return child;
                return FadeTransition(opacity: animation, child: child);
              },
              child: KeyedSubtree(
                key: ValueKey<String>(textToShow),
                child: calculationLatex != null
                    ? ReadableMathFit(
                        textToShow,
                        fontSize: fontSize,
                        color: textColor,
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: MathText(
                          textToShow,
                          color: textColor,
                          fontSize: fontSize,
                        ),
                      ),
              ),
            ),
          ),
          // Static Badge text (e.g. "+", "-", "1", "0", etc.)
          if (highlight?.badgeText != null)
            Positioned(
              top: 2,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  highlight!.badgeText!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: borderColor.computeLuminance() > 0.179
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            ),
          // Stable zero-result confirmation.
          if (isZeroResult)
            Positioned(
              top: 2,
              right: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  borderRadius: BorderRadius.circular(5),
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
            ),
          // Sub-calc indicator dot
          if (hasSubCalculation)
            Positioned(
              bottom: 3,
              right: 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: borderColor,
                ),
              ),
            ),
        ],
      ),
    );

    final l10n = AppLocalizations.of(context);
    String semanticRole = '';
    if (highlight != null) {
      switch (highlight!.type) {
        case HighlightType.pivot:
          semanticRole = ', ${l10n?.legendPivot ?? 'pivot'}';
          break;
        case HighlightType.target:
          semanticRole = ', ${l10n?.legendTarget ?? 'Target'}';
          break;
        case HighlightType.source:
          semanticRole = ', ${l10n?.legendSource ?? 'Source'}';
          break;
        case HighlightType.zeroed:
          semanticRole = ', ${l10n?.legendZeroResult ?? 'Zero result'}';
          break;
        default:
          break;
      }
    }

    return Semantics(
      label:
          '${semanticLabel ?? 'Matrix cell, value ${value.toString()}'}$semanticRole',
      excludeSemantics: true,
      onTap: onTap,
      button: onTap != null,
      child: InkWell(onTap: onTap, child: cellBody),
    );
  }
}
