import 'package:dio/dio.dart';
import 'package:useit/resources/base_response.dart';

/// Message converter function type
typedef MessageConverter = String Function(Response<dynamic>? response);

/// Default message converter implementation
String defaultMessageConverter(Response<dynamic>? response) {
  return response?.data?['message'] ?? 'Bad request';
}

/// Core configuration for the application
/// This replaces global mutable variables with immutable configuration
class CoreConfig {
  const CoreConfig({
    this.badInternetConnection = 'No Internet Connection',
    this.appError = 'Something went wrong',
    required this.dataModelFactories,
    this.messageConverter = defaultMessageConverter,
  });

  /// Error message for no internet connection
  final String badInternetConnection;

  /// Generic error message
  final String appError;

  /// Factory map for creating data models from JSON
  final Map<Type, DataFactory> dataModelFactories;

  /// Converter for extracting messages from responses
  final MessageConverter messageConverter;

  /// Create a copy with optional new values
  CoreConfig copyWith({
    String? badInternetConnection,
    String? appError,
    Map<Type, DataFactory>? dataModelFactories,
    MessageConverter? messageConverter,
  }) {
    return CoreConfig(
      badInternetConnection: badInternetConnection ?? this.badInternetConnection,
      appError: appError ?? this.appError,
      dataModelFactories: dataModelFactories ?? this.dataModelFactories,
      messageConverter: messageConverter ?? this.messageConverter,
    );
  }

  /// Default configuration with basic types
  static CoreConfig get defaultConfig => CoreConfig(
    dataModelFactories: {
      dynamic: (dynamic json) => json,
      String: (dynamic json) => '$json',
      bool: (dynamic json) => json as bool,
      int: (dynamic json) => json as int,
      double: (dynamic json) => json as double,
      List: (dynamic json) => json as List,
      Map: (dynamic json) => json as Map,
    },
  );
}

/// Singleton manager for core configuration
/// Provides global access to configuration without mutable state
class CoreConfigManager {
  CoreConfigManager._(this._config);

  static CoreConfigManager? _instance;

  final CoreConfig _config;

  /// Initialize the configuration manager
  /// Must be called before accessing [instance]
  static void initialize(CoreConfig config) {
    if (_instance != null) {
      throw StateError('CoreConfigManager already initialized');
    }
    _instance = CoreConfigManager._(config);
  }

  /// Get the singleton instance
  /// Throws if not initialized
  static CoreConfigManager get instance {
    if (_instance == null) {
      throw StateError(
        'CoreConfigManager not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  /// Check if manager is initialized
  static bool get isInitialized => _instance != null;

  /// Get the configuration
  CoreConfig get config => _config;

  /// Reset the manager (useful for testing)
  static void reset() {
    _instance = null;
  }
}