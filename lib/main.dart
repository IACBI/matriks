import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'features/settings/cubit/settings_state.dart';
import 'features/settings/data/preferences_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The bundled symbol font is a renamed DejaVu Sans subset; its license
  // travels with it.
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'MatriksSymbols (DejaVu Sans subset)',
    ], await rootBundle.loadString('assets/fonts/LICENSE-MatriksSymbols.txt'));
  });
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
