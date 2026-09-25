import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'features/settings/cubit/settings_state.dart';
import 'features/settings/data/preferences_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The bundled symbol and CJK fonts are renamed subsets; their licenses
  // travel with them.
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'MatriksSymbols (DejaVu Sans subset)',
    ], await rootBundle.loadString('assets/fonts/LICENSE-MatriksSymbols.txt'));
  });
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'MatriksCJK (Noto Sans SC subset)',
    ], await rootBundle.loadString('assets/fonts/LICENSE-MatriksCJK.txt'));
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
