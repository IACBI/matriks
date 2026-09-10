import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../cubit/settings_state.dart';

abstract interface class PreferencesRepository {
  Future<SettingsState?> load();
  Future<void> save(SettingsState settings);
}

class LocalPreferencesRepository implements PreferencesRepository {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  static const _key = 'matriks.preferences.v1';

  @override
  Future<SettingsState?> load() async {
    final raw = await _preferences.getString(_key);
    if (raw == null) return null;
    return SettingsState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(SettingsState settings) =>
      _preferences.setString(_key, jsonEncode(settings.toJson()));
}
