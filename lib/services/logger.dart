import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:useit/extensions/extensions.dart';

/// Centralized logging service
class LogService {
  LogService._();

  static final _logger = Logger(
    filter: _CustomFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      levelEmojis: {
        Level.trace: '📍',
        Level.debug: '🐛',
        Level.info: '💡',
        Level.warning: '⚠️',
        Level.error: '⛔',
        Level.fatal: '💀',
      },
    ),
    output: _CustomOutput(),
  );

  /// Log trace message (very detailed)
  static void t(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Log debug message
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info message
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning message
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error message
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal error message
  static void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Legacy alias for fatal
  static void s(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log HTTP request
  static void request(RequestOptions options) {
    if (!kDebugMode) return;

    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📤 REQUEST: ${options.method} $options');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (options.headers.isNotEmpty) {
      buffer.writeln('📋 HEADERS:');
      options.headers.forEach((key, value) {
        buffer.writeln('   $key: $value');
      });
    }

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('🔍 QUERY PARAMETERS:');
      options.queryParameters.forEach((key, value) {
        buffer.writeln('   $key: $value');
      });
    }

    if (options.data != null) {
      buffer.writeln('📦 BODY:');
      try {
        buffer.writeln('   ${options.data.toPrettyJson}');
      } catch (e) {
        buffer.writeln('   ${options.data}');
      }
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.w(buffer.toString());
  }

  /// Log successful HTTP response
  static void response(Response response) {
    if (!kDebugMode) return;
    if (!response.isSuccessful) return;

    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📥 RESPONSE: ${response.statusCode} ${response.statusMessage}');
    buffer.writeln('🔗 URL: ${response.realUri}');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (response.headers.map.isNotEmpty) {
      buffer.writeln('📋 HEADERS:');
      response.headers.map.forEach((key, value) {
        buffer.writeln('   $key: ${value.join(', ')}');
      });
    }

    if (response.data != null) {
      buffer.writeln('📦 DATA:');
      try {
        final dataStr = response.data.toPrettyJson;
        // Truncate if too long
        if (dataStr.length > 10000) {
          buffer.writeln('   ${dataStr.substring(0, 10000)}...');
          buffer.writeln('   (truncated, total length: ${dataStr.length})');
        } else {
          buffer.writeln('   $dataStr');
        }
      } catch (e) {
        buffer.writeln('   ${response.data}');
      }
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.f(buffer.toString());
  }

  /// Log HTTP error response
  static void errorResponse(DioException error) {
    if (!kDebugMode) return;

    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (error.isNoConnection) {
      buffer.writeln('🔌 NO CONNECTION');
      buffer.writeln('🔗 URL: ${error.requestOptions}');
      buffer.writeln('💬 MESSAGE: ${error.message}');
    } else {
      buffer.writeln(
        '❌ ERROR: ${error.response?.statusCode} ${error.response?.statusMessage}',
      );
      buffer.writeln('🔗 URL: ${error.response?.realUri}');

      if (error.response?.data != null) {
        buffer.writeln('📦 ERROR DATA:');
        try {
          final dataStr = error.response!.data.toPrettyJson;
          if (dataStr.length > 5000) {
            buffer.writeln('   ${dataStr.substring(0, 5000)}...');
          } else {
            buffer.writeln('   $dataStr');
          }
        } catch (e) {
          buffer.writeln('   ${error.response!.data}');
        }
      }
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.e(buffer.toString());
  }
}

/// Custom filter that only logs in debug mode
class _CustomFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return kDebugMode;
  }
}

/// Custom output that uses debugPrint
class _CustomOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      debugPrint(line);
    }
  }
}