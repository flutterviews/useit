import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:useit/app_state/localization.dart';
import 'package:useit/services/logger.dart';
import 'package:useit/services/storage_service.dart';

part 'app_state.dart';

/// Cubit for managing app-wide state (theme, locale)
class AppCubit extends Cubit<AppState> {
  AppCubit({
    required IStorageService storageService,
    ThemeMode? themeMode,
    Locale? locale,
  })  : _storageService = storageService,
        super(
        AppState(
          themeMode: themeMode ?? ThemeMode.system,
          locale: locale ?? Localization.uz,
        ),
      );

  final IStorageService _storageService;

  static const String _localeKey = 'app_locale_lang_code';
  static const String _themeModeKey = 'app_theme_data';

  /// Initialize app state from storage
  /// Loads saved preferences in parallel for better performance
  Future<void> init() async {
    if (isClosed) return;

    try {
      // Load both values in parallel
      final results = await Future.wait([
        _storageService.getString(_localeKey),
        _storageService.getString(_themeModeKey),
      ]);

      if (isClosed) return;

      final localeCode = results[0];
      final themeModeStr = results[1];

      // Parse and emit new state
      emit(
        state.copyWith(
          locale: _parseLocale(localeCode),
          themeMode: _parseThemeMode(themeModeStr),
        ),
      );

      LogService.i('App state initialized: locale=$localeCode, theme=$themeModeStr');
    } catch (e, s) {
      LogService.e('Failed to initialize app state: $e');
      LogService.e('Stack trace: $s');
      // Continue with default values
    }
  }

  /// Parse locale from string
  Locale? _parseLocale(String? code) {
    if (code == null) return null;

    try {
      // Check if locale is supported
      final locale = Locale(code);
      if (Localization.all.any((l) => l.languageCode == code)) {
        return locale;
      }
      LogService.w('Unsupported locale code: $code, using default');
      return null;
    } catch (e) {
      LogService.e('Failed to parse locale: $e');
      return null;
    }
  }

  /// Parse theme mode from string
  ThemeMode _parseThemeMode(String? mode) {
    if (mode == null) return ThemeMode.system;

    try {
      return ThemeMode.values.firstWhere(
            (e) => e.name == mode,
        orElse: () => ThemeMode.system,
      );
    } catch (e) {
      LogService.e('Failed to parse theme mode: $e');
      return ThemeMode.system;
    }
  }

  /// Change theme mode and persist to storage
  Future<void> changeThemeMode(ThemeMode mode) async {
    if (isClosed) return;

    // Update state immediately for better UX
    emit(state.copyWith(themeMode: mode));

    // Persist to storage
    try {
      await _storageService.setString(_themeModeKey, mode.name);
      LogService.i('Theme mode changed to: ${mode.name}');
    } catch (e, s) {
      LogService.e('Failed to save theme mode: $e');
      LogService.e('Stack trace: $s');
    }
  }

  /// Change locale and persist to storage
  Future<void> changeLocale(Locale locale) async {
    if (isClosed) return;

    // Validate locale
    if (!Localization.all.any((l) => l.languageCode == locale.languageCode)) {
      LogService.w('Attempted to set unsupported locale: ${locale.languageCode}');
      return;
    }

    // Update state immediately for better UX
    emit(state.copyWith(locale: locale));

    // Persist to storage
    try {
      await _storageService.setString(_localeKey, locale.languageCode);
      LogService.i('Locale changed to: ${locale.languageCode}');
    } catch (e, s) {
      LogService.e('Failed to save locale: $e');
      LogService.e('Stack trace: $s');
    }
  }

  /// Reset to default settings
  Future<void> reset() async {
    if (isClosed) return;

    try {
      await Future.wait([
        _storageService.remove(_localeKey),
        _storageService.remove(_themeModeKey),
      ]);

      if (isClosed) return;

      emit(
        AppState(
          themeMode: ThemeMode.system,
          locale: Localization.uz,
        ),
      );

      LogService.i('App state reset to defaults');
    } catch (e, s) {
      LogService.e('Failed to reset app state: $e');
      LogService.e('Stack trace: $s');
    }
  }
}