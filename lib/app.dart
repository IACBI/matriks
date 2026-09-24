import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'l10n/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'features/settings/cubit/settings_state.dart';
import 'core/widgets/studio_shell.dart';
import 'features/settings/data/preferences_repository.dart';

class MatrixEducatorApp extends StatelessWidget {
  final PreferencesRepository? preferences;

  /// Preferences already read from [preferences]. When absent they are
  /// restored asynchronously after the first frame.
  final SettingsState? initialSettings;
  const MatrixEducatorApp({super.key, this.preferences, this.initialSettings});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final initial = initialSettings;
        if (initial != null) {
          return SettingsCubit(repository: preferences, initial: initial);
        }
        return SettingsCubit(repository: preferences)..restore();
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp(
            // Resolved per locale so the task switcher matches the interface.
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)?.appTitle ??
                'Matriks · Linear Algebra',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.studio(
              false,
              compact: settings.compact,
            ),
            darkTheme: AppTheme.studio(
              true,
              compact: settings.compact,
            ),
            themeMode: settings.themeMode,
            locale: settings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeListResolutionCallback: (preferred, supported) {
              for (final locale in preferred ?? <Locale>[]) {
                if (SettingsState.languages.contains(locale.languageCode)) {
                  return Locale(locale.languageCode);
                }
              }
              return const Locale('en');
            },
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                disableAnimations:
                    settings.reduceMotion ||
                    MediaQuery.disableAnimationsOf(context),
              ),
              child: child!,
            ),
            home: const StudioShell(),
          );
        },
      ),
    );
  }
}
