import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/user_model.dart';

/// Local storage service using SharedPreferences
class StorageService {
  static const String _keyUser = 'current_user';
  static const String _keyTheme = 'theme_mode';
  static const String _keyFontSize = 'code_font_size';
  static const String _keyFirstLaunch = 'first_launch';

  SharedPreferences? _prefs;

  /// Initialize storage
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // ============ User Data ============

  /// Save current user
  Future<bool> saveUser(User user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      return await _preferences.setString(_keyUser, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    try {
      final jsonString = _preferences.getString(_keyUser);
      if (jsonString == null) return null;
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return User.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Clear user data
  Future<bool> clearUser() async {
    return await _preferences.remove(_keyUser);
  }

  // ============ App Preferences ============

  /// Save theme mode
  Future<bool> saveThemeMode(String mode) async {
    return await _preferences.setString(_keyTheme, mode);
  }

  /// Get theme mode
  String? getThemeMode() {
    return _preferences.getString(_keyTheme);
  }

  /// Save code font size
  Future<bool> saveFontSize(double size) async {
    return await _preferences.setDouble(_keyFontSize, size);
  }

  /// Get code font size
  double? getFontSize() {
    return _preferences.getDouble(_keyFontSize);
  }

  /// Check if first launch
  bool isFirstLaunch() {
    return _preferences.getBool(_keyFirstLaunch) ?? true;
  }

  /// Set first launch complete
  Future<bool> setFirstLaunchComplete() async {
    return await _preferences.setBool(_keyFirstLaunch, false);
  }

  // ============ General ============

  /// Clear all data
  Future<bool> clearAll() async {
    return await _preferences.clear();
  }

  /// Save string
  Future<bool> saveString(String key, String value) async {
    return await _preferences.setString(key, value);
  }

  /// Get string
  String? getString(String key) {
    return _preferences.getString(key);
  }

  /// Save int
  Future<bool> saveInt(String key, int value) async {
    return await _preferences.setInt(key, value);
  }

  /// Get int
  int? getInt(String key) {
    return _preferences.getInt(key);
  }

  /// Save bool
  Future<bool> saveBool(String key, bool value) async {
    return await _preferences.setBool(key, value);
  }

  /// Get bool
  bool? getBool(String key) {
    return _preferences.getBool(key);
  }
}
