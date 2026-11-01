import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../cubit/settings_cubit.dart';
import 'language_menu.dart';

/// The language and theme controls every top-level screen offers in its app
/// bar, in the same order and with the same icons.
class PreferenceActions extends StatelessWidget {
  const PreferenceActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LanguageMenu(),
        IconButton(
          tooltip: l10n.toggleTheme,
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
          onPressed: () => context.read<SettingsCubit>().toggleTheme(
            currentBrightness: theme.brightness,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
