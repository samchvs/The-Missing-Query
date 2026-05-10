import 'package:shared_preferences/shared_preferences.dart';

/// Handles local device storage for the username key.
class SharedPrefsDataSource {
  static const String _usernameKey = 'local_username';

  final SharedPreferences _prefs;

  SharedPrefsDataSource(this._prefs);

  Future<void> saveUsername(String username) async {
    await _prefs.setString(_usernameKey, username);
  }

  String? getUsername() {
    return _prefs.getString(_usernameKey);
  }

  Future<void> clear() async {
    await _prefs.remove(_usernameKey);
  }
}
