import 'package:flutter/material.dart';

import 'app.dart';
import 'features/settings/data/preferences_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MatrixEducatorApp(preferences: LocalPreferencesRepository()));
}
