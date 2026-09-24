import 'package:flutter/material.dart';

/// Shared tokens; instructional accents preserve their mathematical roles.
class AppTheme {
  static const primaryBlue = Color(0xFF2455B2);
  static const primaryBlueDark = Color(0xFFAAC7FF);
  static const accentAmber = Color(0xFFB77913);
  static const accentCyan = Color(0xFF1683A5);
  static const accentGreen = Color(0xFF208466);
  static const accentRed = Color(0xFFD14848);
  static const accentIndigo = Color(0xFF6575C5);
  static const scaffoldLight = Color(0xFFF5F7FA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceVariantLight = Color(0xFFEDF0F4);
  static const borderLight = Color(0xFFD7DDE5);
  static const borderSubtleLight = Color(0xFF8793A4);
  static const textPrimaryLight = Color(0xFF202938);
  static const textSecondaryLight = Color(0xFF526174);
  static const textMutedLight = Color(0xFF5D6B7D);
  static const scaffoldDark = Color(0xFF101A29);
  static const surfaceDark = Color(0xFF182537);
  static const surfaceVariantDark = Color(0xFF252F3D);
  static const borderDark = Color(0xFF3B4758);
  static const borderSubtleDark = Color(0xFF77869B);
  static const textPrimaryDark = Color(0xFFEEF2F7);
  static const textSecondaryDark = Color(0xFFBCC7D6);
  static const textMutedDark = Color(0xFFA8B6C9);
  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 20.0;
  static const radiusXl = 24.0;
  static const contentWidth = 1280.0;
  static const pressMs = 120;
  static const stateMs = 180;
  static const panelMs = 220;

  /// Bundled glyphs for arrows, sub/superscripts and math symbols that the
  /// default text font lacks (see pubspec.yaml). Without it the web build
  /// fetches a fallback font from Google at runtime, and shows boxes offline.
  static const symbolFallback = ['MatriksSymbols'];

  static Duration motion(BuildContext context, [int milliseconds = stateMs]) =>
      MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : Duration(milliseconds: milliseconds);
  static final ThemeData lightTheme = _build(false);
  static final ThemeData darkTheme = _build(true);

  static ThemeData studio(bool dark, {bool compact = false}) =>
      _build(dark, compact: compact);

  static ThemeData _build(bool dark, {bool compact = false}) {
    final surface = dark ? surfaceDark : surfaceLight;
    final background = dark ? scaffoldDark : scaffoldLight;
    final variant = dark ? surfaceVariantDark : surfaceVariantLight;
    final ink = dark ? textPrimaryDark : textPrimaryLight;
    final secondaryInk = dark ? textSecondaryDark : textSecondaryLight;
    final border = dark ? borderDark : borderLight;
    // One brand colour for actions; amber and cyan stay free for the
    // mathematical roles they mark.
    final primary = dark ? primaryBlueDark : primaryBlue;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: dark ? Brightness.dark : Brightness.light,
        ).copyWith(
          primary: primary,
          onPrimary: dark ? const Color(0xFF10274D) : Colors.white,
          surface: surface,
          onSurface: ink,
          onSurfaceVariant: secondaryInk,
          surfaceContainerHighest: variant,
          outline: dark ? borderSubtleDark : borderSubtleLight,
          outlineVariant: border,
          error: dark ? const Color(0xFFFFB4AB) : const Color(0xFFB3261E),
        );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    );
    const buttonText = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamilyFallback: symbolFallback,
    );
    return base.copyWith(
      listTileTheme: ListTileThemeData(
        minTileHeight: compact ? 48 : 64,
        contentPadding: EdgeInsets.symmetric(horizontal: compact ? 12 : 20),
      ),
      scaffoldBackgroundColor: background,
      dividerColor: border,
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          visualDensity: VisualDensity.standard,
        ),
      ),
      focusColor: primary.withValues(alpha: 0.18),
      hoverColor: primary.withValues(alpha: 0.06),
      textTheme: base.textTheme
          .apply(bodyColor: ink, displayColor: ink)
          .copyWith(
            headlineLarge: TextStyle(
              fontSize: 30,
              height: 1.15,
              letterSpacing: -1.2,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              height: 1.2,
              letterSpacing: -0.7,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
            titleLarge: TextStyle(
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: ink,
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: ink,
            ),
            bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: ink),
            bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: ink),
            bodySmall: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: secondaryInk,
            ),
            labelLarge: TextStyle(
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: ink,
            ),
            labelMedium: TextStyle(
              fontSize: 12,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: secondaryInk,
            ),
          )
          .apply(fontFamilyFallback: symbolFallback),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamilyFallback: symbolFallback,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: shape.copyWith(side: BorderSide(color: border)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(48, 48),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: shape,
          textStyle: buttonText,
          animationDuration: const Duration(milliseconds: pressMs),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(48, 48),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: buttonText,
          animationDuration: const Duration(milliseconds: pressMs),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(48, 48),
          side: BorderSide(color: scheme.outline),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: buttonText,
          animationDuration: const Duration(milliseconds: pressMs),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(48, 48),
          shape: shape,
          textStyle: buttonText,
          animationDuration: const Duration(milliseconds: pressMs),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          color: secondaryInk,
          fontFamilyFallback: symbolFallback,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: background,
        selectedColor: primary.withValues(alpha: 0.12),
        side: BorderSide(color: border),
        shape: shape,
        labelStyle: TextStyle(
          fontSize: 13,
          color: ink,
          fontFamilyFallback: symbolFallback,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: shape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? textPrimaryDark : textPrimaryLight,
        contentTextStyle: TextStyle(
          color: background,
          fontSize: 14,
          fontFamilyFallback: symbolFallback,
        ),
        shape: shape,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: ink,
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        textStyle: TextStyle(
          color: background,
          fontSize: 12,
          fontFamilyFallback: symbolFallback,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
