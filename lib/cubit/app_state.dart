part of 'app_cubit.dart';

/// State for app-wide configuration
class AppState {
  const AppState({
    required this.themeMode,
    required this.locale,
  });

  final ThemeMode themeMode;
  final Locale locale;

  /// Create a copy with optional new values
  AppState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  /// Check if using system theme
  bool get isSystemTheme => themeMode == ThemeMode.system;

  /// Check if using dark theme
  bool get isDarkTheme => themeMode == ThemeMode.dark;

  /// Check if using light theme
  bool get isLightTheme => themeMode == ThemeMode.light;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppState &&
              runtimeType == other.runtimeType &&
              themeMode == other.themeMode &&
              locale == other.locale;

  @override
  int get hashCode => themeMode.hashCode ^ locale.hashCode;

  @override
  String toString() => 'AppState(themeMode: $themeMode, locale: $locale)';
}