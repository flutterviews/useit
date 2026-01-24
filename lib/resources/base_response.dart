import 'dart:convert' as convert;
import 'package:useit/config/core_config.dart';
import 'package:useit/services/logger.dart';

/// Type definition for data factory functions
typedef DataFactory<T> = T Function(dynamic json);

/// Base response wrapper for API responses
class BaseResponse<T> {
  const BaseResponse({
    this.data,
    this.message,
    this.messages,
    this.accept = false,
    this.total,
  });

  final T? data;
  final String? message;
  final Map<String, String>? messages;
  final bool accept;
  final num? total;

  /// Parse JSON response with proper error handling
  factory BaseResponse.fromJson(
      Map<String, dynamic> json, [
        DataFactory<T>? fromJsonT,
      ]) {
    try {
      final rawData = json['data'];

      // Parse data using factory if available
      T? parsedData;
      if (rawData != null) {
        if (fromJsonT != null) {
          parsedData = fromJsonT(rawData);
        } else {
          parsedData = _makeModel<T>(rawData);
        }
      }

      // Extract total from various possible locations
      num? total;
      if (rawData is Map<String, dynamic>) {
        total = rawData['total'] as num?;
      }
      total ??= json['totalElements'] as num?;
      total ??= json['total'] as num?;

      // Parse messages
      String? message;
      Map<String, String>? messages;
      final rawMessage = json['message'];

      if (rawMessage is String) {
        message = rawMessage;
      } else if (rawMessage is Map) {
        messages = Map<String, String>.from(rawMessage);
      }

      return BaseResponse(
        data: parsedData,
        message: message,
        messages: messages,
        accept: json['accept'] as bool? ?? false,
        total: total,
      );
    } catch (e, s) {
      LogService.e('BaseResponse parsing error: $e');
      LogService.e('Raw JSON: ${convert.json.encode(json)}');
      LogService.e('Stack trace: $s');
      rethrow;
    }
  }

  /// Internal method to create model from JSON using registered factories
  static T? _makeModel<T>(dynamic json) {
    if (!CoreConfigManager.isInitialized) {
      LogService.e('CoreConfigManager not initialized');
      return null;
    }

    final factories = CoreConfigManager.instance.config.dataModelFactories;

    if (!factories.containsKey(T)) {
      LogService.e('No factory registered for type $T');
      LogService.e('Available factories: ${factories.keys.toList()}');
      return null;
    }

    try {
      return factories[T]!(json) as T;
    } catch (e, s) {
      LogService.e('Error creating model of type $T: $e');
      LogService.e('Raw data: ${convert.json.encode(json)}');
      LogService.e('Stack trace: $s');
      rethrow;
    }
  }

  /// Convert response to map
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'message': message,
      'messages': messages,
      'accept': accept,
      'total': total,
    };
  }

  /// Create a copy with new values
  BaseResponse<T> copyWith({
    T? data,
    String? message,
    Map<String, String>? messages,
    bool? accept,
    num? total,
  }) {
    return BaseResponse(
      data: data ?? this.data,
      message: message ?? this.message,
      messages: messages ?? this.messages,
      accept: accept ?? this.accept,
      total: total ?? this.total,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BaseResponse<T> &&
              runtimeType == other.runtimeType &&
              data == other.data &&
              message == other.message &&
              messages == other.messages &&
              accept == other.accept &&
              total == other.total;

  @override
  int get hashCode =>
      data.hashCode ^
      message.hashCode ^
      messages.hashCode ^
      accept.hashCode ^
      total.hashCode;

  @override
  String toString() =>
      'BaseResponse(data: $data, message: $message, accept: $accept, total: $total)';
}

/// Helper function to create model from JSON (backward compatibility)
T? makeModel<T>(dynamic json) {
  return BaseResponse._makeModel<T>(json);
}