import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/retrofit.dart' as retrofit;
import 'package:useit/config/core_config.dart';
import 'package:useit/extensions/extensions.dart';
import 'package:useit/resources/base_response.dart';
import 'package:useit/resources/data_state.dart';
import 'package:useit/services/logger.dart';

/// Base repository with common response handling logic
abstract class BaseRepository {
  /// Handle standard API response with BaseResponse wrapper
  @protected
  Future<DataState<T>> handleResponse<T>({
    required Future<retrofit.HttpResponse<BaseResponse<T>>> Function() request,
  }) async {
    try {
      final httpResponse = await request();
      final data = httpResponse.data.data;

      // Check if data is null
      if (data == null) {
        return DataFailed(
          message: httpResponse.data.message ?? 'No data received',
          code: httpResponse.response.statusCode,
        );
      }

      final config = CoreConfigManager.instance.config;

      return DataSuccess(
        data: data,
        message: config.messageConverter(httpResponse.response),
        accept: httpResponse.data.accept,
        code: httpResponse.response.statusCode,
        total: httpResponse.data.total,
      );
    } on DioException catch (e, s) {
      return _handleDioError<T>(e, s);
    } catch (e, s) {
      LogService.e('Unexpected error in handleResponse: $e');
      LogService.e('Stack trace: $s');
      return DataFailed(
        message: CoreConfigManager.instance.config.appError,
      );
    }
  }

  /// Handle response without BaseResponse wrapper (legacy support)
  @protected
  Future<DataState<R>> handleResponseRaw<T, R>({
    required Future<retrofit.HttpResponse<T>> Function() request,
    R Function(T data)? transform,
  }) async {
    try {
      final httpResponse = await request();
      final data = httpResponse.data;

      final config = CoreConfigManager.instance.config;
      final transformedData = transform != null ? transform(data) : data as R;

      return DataSuccess(
        data: transformedData,
        message: config.messageConverter(httpResponse.response),
        code: httpResponse.response.statusCode,
        total: 0,
      );
    } on DioException catch (e, s) {
      return _handleDioError<R>(e, s);
    } catch (e, s) {
      LogService.e('Unexpected error in handleResponseRaw: $e');
      LogService.e('Stack trace: $s');
      return DataFailed(
        message: CoreConfigManager.instance.config.appError,
      );
    }
  }

  /// Handle DioException with proper error messages
  DataFailed<T> _handleDioError<T>(DioException e, StackTrace s) {
    final config = CoreConfigManager.instance.config;

    // No internet connection
    if (e.isNoConnection) {
      LogService.w('No internet connection: ${e.message}');
      return DataFailed(message: config.badInternetConnection);
    }

    // Bad request (4xx errors)
    if (e.isBadRequest) {
      final message = config.messageConverter(e.response);
      LogService.w('Bad request: $message');
      return DataFailed(
        message: message,
        code: e.response?.statusCode,
      );
    }

    // Other errors (5xx, network errors, etc.)
    LogService.e('API error: ${e.message}');
    LogService.e('Response: ${e.response?.data}');
    LogService.e('Stack trace: $s');

    return DataFailed(
      message: config.appError,
      code: e.response?.statusCode,
    );
  }

  /// Safe API call wrapper with automatic error handling
  @protected
  Future<DataState<T>> safeApiCall<T>({
    required Future<T> Function() call,
  }) async {
    try {
      final result = await call();
      return DataSuccess(data: result);
    } on DioException catch (e, s) {
      return _handleDioError<T>(e, s);
    } catch (e, s) {
      LogService.e('Unexpected error in safeApiCall: $e');
      LogService.e('Stack trace: $s');
      return DataFailed(
        message: CoreConfigManager.instance.config.appError,
      );
    }
  }

  /// Handle list response with pagination info
  @protected
  Future<DataState<List<T>>> handleListResponse<T>({
    required Future<retrofit.HttpResponse<BaseResponse<List<T>>>> Function()
    request,
  }) async {
    try {
      final httpResponse = await request();
      final data = httpResponse.data.data ?? [];

      final config = CoreConfigManager.instance.config;

      return DataSuccess(
        data: data,
        message: config.messageConverter(httpResponse.response),
        accept: httpResponse.data.accept,
        code: httpResponse.response.statusCode,
        total: httpResponse.data.total ?? data.length,
      );
    } on DioException catch (e, s) {
      return _handleDioError<List<T>>(e, s);
    } catch (e, s) {
      LogService.e('Unexpected error in handleListResponse: $e');
      LogService.e('Stack trace: $s');
      return DataFailed(
        message: CoreConfigManager.instance.config.appError,
      );
    }
  }
}