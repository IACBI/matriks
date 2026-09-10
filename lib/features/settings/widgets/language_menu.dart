import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../cubit/settings_cubit.dart';

class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key});
  static const names = {
    'tr': 'Türkçe',
    'en': 'English',
    'zh': '简体中文',
    'es': 'Español',
    'ru': 'Русский',
  };
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      tooltip: l.changeLanguage,
      icon: const Icon(Icons.language_rounded),
      initialValue:
          context.watch<SettingsCubit>().state.locale?.languageCode ?? 'system',
      onSelected: (code) => context.read<SettingsCubit>().setLocale(
        code == 'system' ? null : Locale(code),
      ),
      itemBuilder: (_) => [
        for (final entry in names.entries)
          PopupMenuItem(
            value: entry.key,
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Image.asset(
                    'assets/flags/${entry.key}.png',
                    width: 28,
                    height: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(entry.value),
              ],
            ),
          ),
        PopupMenuItem(value: 'system', child: Text(l.systemDefault)),
      ],
    );
  }
}
