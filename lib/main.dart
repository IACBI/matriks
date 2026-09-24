import 'package:flutter/material.dart';

import 'app.dart';
import 'features/settings/cubit/settings_state.dart';
import 'features/settings/data/preferences_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = LocalPreferencesRepository();
  // Read saved preferences before the first frame so a dark-mode or
  // non-English user never sees one frame in the defaults. A slow or failing
  // store falls back to restoring after startup, as before.
  SettingsState? initial;
  var restored = false;
  try {
    initial = await preferences.load().timeout(
      const Duration(milliseconds: 800),
    );
    restored = true;
  } catch (_) {}
  runApp(
    MatrixEducatorApp(
      preferences: preferences,
      initialSettings: restored ? (initial ?? const SettingsState()) : null,
    ),
  );
}
