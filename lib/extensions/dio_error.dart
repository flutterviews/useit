part of 'extensions.dart';

/// Extension for DioException error handling
extension DioExceptionExtension on DioException {
  /// Check if error is due to no internet connection
  bool get isNoConnection {
    return (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.connectionError ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout) &&
        error is SocketException;
  }

  /// Check if error is a bad request (4xx status codes)
  bool get isBadRequest {
    final statusCode = response?.statusCode ?? -1;
    return statusCode >= 400 && statusCode < 500;
  }

  /// Check if error is a server error (5xx status codes)
  bool get isServerError {
    final statusCode = response?.statusCode ?? -1;
    return statusCode >= 500 && statusCode < 600;
  }

  /// Check if error is unauthorized (401)
  bool get isUnauthorized => response?.statusCode == 401;

  /// Check if error is forbidden (403)
  bool get isForbidden => response?.statusCode == 403;

  /// Check if error is not found (404)
  bool get isNotFound => response?.statusCode == 404;

  /// Check if request was cancelled
  bool get isCancelled => type == DioExceptionType.cancel;

  /// Get user-friendly error message
  String get userMessage {
    if (isNoConnection) {
      return 'No internet connection. Please check your network.';
    }

    if (isCancelled) {
      return 'Request was cancelled.';
    }

    if (isUnauthorized) {
      return 'Unauthorized. Please login again.';
    }

    if (isForbidden) {
      return 'You do not have permission to perform this action.';
    }

    if (isNotFound) {
      return 'Resource not found.';
    }

    if (isServerError) {
      return 'Server error. Please try again later.';
    }

    if (isBadRequest) {
      // Try to extract message from response
      final data = response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return 'Invalid request. Please check your input.';
    }

    return 'An error occurred. Please try again.';
  }
}

/// Extension for Response success checking
extension ResponseExtension on Response {
  /// Check if response is successful (2xx status codes)
  bool get isSuccessful {
    final statusCode = this.statusCode ?? -1;
    return statusCode >= 200 && statusCode < 300;
  }

  /// Check if response is created (201)
  bool get isCreated => statusCode == 201;

  /// Check if response is no content (204)
  bool get isNoContent => statusCode == 204;

  /// Check if response has data
  bool get hasData => data != null;

  /// Safely get data as Map
  Map<String, dynamic>? get dataAsMap {
    final responseData = data;
    if (responseData is Map<String, dynamic>) {
      return responseData;
    }
    return null;
  }

  /// Safely get data as List
  List<dynamic>? get dataAsList {
    final responseData = data;
    if (responseData is List) {
      return responseData;
    }
    return null;
  }
}

/// Extension for RequestOptions
extension RequestOptionsExtension on RequestOptions {
  /// Get full URL with query parameters
  String get fullUrl {
    final buffer = StringBuffer('$baseUrl$path');

    if (queryParameters.isNotEmpty) {
      buffer.write('?');
      queryParameters.forEach((key, value) {
        buffer.write('$key=$value&');
      });
      // Remove trailing &
      return buffer.toString().substring(0, buffer.length - 1);
    }

    return buffer.toString();
  }

  /// Check if request is GET
  bool get isGet => method.toUpperCase() == 'GET';

  /// Check if request is POST
  bool get isPost => method.toUpperCase() == 'POST';

  /// Check if request is PUT
  bool get isPut => method.toUpperCase() == 'PUT';

  /// Check if request is DELETE
  bool get isDelete => method.toUpperCase() == 'DELETE';

  /// Check if request is PATCH
  bool get isPatch => method.toUpperCase() == 'PATCH';
}