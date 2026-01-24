import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences_foundation/shared_preferences_foundation.dart';

/// Abstract interface for storage operations
/// Allows easy testing and mocking
abstract class IStorageService {
  Future<Set<String>> getKeys();
  Future<Object?> get(String key);
  Future<bool?> getBool(String key);
  Future<int?> getInt(String key);
  Future<double?> getDouble(String key);
  Future<String?> getString(String key);
  Future<List<String>?> getStringList(String key);
  Future<bool> containsKey(String key);
  Future<bool> setBool(String key, bool value);
  Future<bool> setInt(String key, int value);
  Future<bool> setDouble(String key, double value);
  Future<bool> setString(String key, String value);
  Future<bool> setStringList(String key, List<String> value);
  Future<bool> remove(String key);
  Future<bool> clear();
  Future<void> reload();
}

/// SharedPreferences implementation of storage service
class SharedPrefsService implements IStorageService {
  SharedPrefsService._(this._prefs);

  final SharedPreferences _prefs;

  /// Factory method to create and initialize the service
  static Future<SharedPrefsService> create() async {
    // Register platform-specific plugins
    if (Platform.isAndroid) {
      SharedPreferencesAndroid.registerWith();
    } else if (Platform.isIOS) {
      SharedPreferencesFoundation.registerWith();
    }

    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsService._(prefs);
  }

  @override
  Future<Set<String>> getKeys() async => _prefs.getKeys();

  @override
  Future<Object?> get(String key) async => _prefs.get(key);

  @override
  Future<bool?> getBool(String key) async => _prefs.getBool(key);

  @override
  Future<int?> getInt(String key) async => _prefs.getInt(key);

  @override
  Future<double?> getDouble(String key) async => _prefs.getDouble(key);

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<List<String>?> getStringList(String key) async =>
      _prefs.getStringList(key);

  @override
  Future<bool> containsKey(String key) async => _prefs.containsKey(key);

  @override
  Future<bool> setBool(String key, bool value) async =>
      _prefs.setBool(key, value);

  @override
  Future<bool> setInt(String key, int value) async => _prefs.setInt(key, value);

  @override
  Future<bool> setDouble(String key, double value) async =>
      _prefs.setDouble(key, value);

  @override
  Future<bool> setString(String key, String value) async =>
      _prefs.setString(key, value);

  @override
  Future<bool> setStringList(String key, List<String> value) async =>
      _prefs.setStringList(key, value);

  @override
  Future<bool> remove(String key) async => _prefs.remove(key);

  @override
  Future<bool> clear() async => _prefs.clear();

  @override
  Future<void> reload() async => _prefs.reload();
}

/// In-memory storage for testing
class InMemoryStorageService implements IStorageService {
  final Map<String, Object> _storage = {};

  @override
  Future<Set<String>> getKeys() async => _storage.keys.toSet();

  @override
  Future<Object?> get(String key) async => _storage[key];

  @override
  Future<bool?> getBool(String key) async => _storage[key] as bool?;

  @override
  Future<int?> getInt(String key) async => _storage[key] as int?;

  @override
  Future<double?> getDouble(String key) async => _storage[key] as double?;

  @override
  Future<String?> getString(String key) async => _storage[key] as String?;

  @override
  Future<List<String>?> getStringList(String key) async =>
      _storage[key] as List<String>?;

  @override
  Future<bool> containsKey(String key) async => _storage.containsKey(key);

  @override
  Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _storage.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _storage.clear();
    return true;
  }

  @override
  Future<void> reload() async {
    // No-op for in-memory storage
  }
}