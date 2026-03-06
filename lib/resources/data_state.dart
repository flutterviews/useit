import 'dart:async';

/// Base class for data state
/// Uses sealed class for exhaustive pattern matching
sealed class DataState<T> {
  const DataState();

  /// Get data if available, null otherwise
  T? get dataOrNull => switch (this) {
    DataSuccess(:final data) => data,
    _ => null,
  };

  /// Get message if available
  String? get messageOrNull => switch (this) {
    DataSuccess(:final message) => message,
    DataFailed(:final message) => message,
  };

  /// Check if state is success
  bool get isSuccess => this is DataSuccess<T>;

  /// Check if state is failed
  bool get isFailed => this is DataFailed<T>;

  /// Pattern matching helper
  R when<R>({
    required R Function(
      T data,
      String? message,
      int? code,
      bool accept,
      num? total,
    )
    success,
    required R Function(String message, int? code) failed,
  }) {
    return switch (this) {
      DataSuccess(
        :final data,
        :final message,
        :final code,
        :final accept,
        :final total,
      ) =>
        success(data, message, code, accept, total),
      DataFailed(:final message, :final code) => failed(message, code),
    };
  }

  /// Map data if success, otherwise return failed state
  DataState<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      DataSuccess(
        :final data,
        :final message,
        :final code,
        :final accept,
        :final total,
      ) =>
        DataSuccess(
          data: transform(data),
          message: message,
          code: code,
          accept: accept,
          total: total,
        ),
      DataFailed(:final message, :final code) => DataFailed(
        message: message,
        code: code,
      ),
    };
  }

  /// FlatMap for chaining operations
  DataState<R> flatMap<R>(DataState<R> Function(T data) transform) {
    return switch (this) {
      DataSuccess(:final data) => transform(data),
      DataFailed(:final message, :final code) => DataFailed(
        message: message,
        code: code,
      ),
    };
  }

  /// Alias for [flatMap] for more natural "pipelining"
  DataState<R> then<R>(DataState<R> Function(T data) transform) =>
      flatMap(transform);

  /// Asynchronous version of [map].
  Future<DataState<R>> mapAsync<R>(
    FutureOr<R> Function(T data) transform,
  ) async {
    return switch (this) {
      DataSuccess(
        :final data,
        :final message,
        :final code,
        :final accept,
        :final total,
      ) =>
        DataSuccess(
          data: await transform(data),
          message: message,
          code: code,
          accept: accept,
          total: total,
        ),
      DataFailed(:final message, :final code) => DataFailed(
        message: message,
        code: code,
      ),
    };
  }

  /// Asynchronous version of [flatMap] / [then] for chaining futures.
  Future<DataState<R>> thenAsync<R>(
    FutureOr<DataState<R>> Function(T data) transform,
  ) async {
    return switch (this) {
      DataSuccess(:final data) => await transform(data),
      DataFailed(:final message, :final code) => DataFailed(
        message: message,
        code: code,
      ),
    };
  }

  /// Returns data if successful, or computes fallback from failure.
  T getOrElse(T Function(DataFailed<T> failed) onFailure) {
    return switch (this) {
      DataSuccess(:final data) => data,
      DataFailed() => onFailure(this as DataFailed<T>),
    };
  }
}

/// Success state with data
final class DataSuccess<T> extends DataState<T> {
  const DataSuccess({
    required this.data,
    this.message,
    this.code,
    this.accept = false,
    this.total,
  });

  final T data;
  final String? message;
  final int? code;
  final bool accept;
  final num? total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataSuccess<T> &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          message == other.message &&
          code == other.code &&
          accept == other.accept &&
          total == other.total;

  @override
  int get hashCode =>
      data.hashCode ^
      message.hashCode ^
      code.hashCode ^
      accept.hashCode ^
      total.hashCode;

  @override
  String toString() =>
      'DataSuccess(data: $data, message: $message, code: $code, accept: $accept, total: $total)';
}

/// Failed state with error message
final class DataFailed<T> extends DataState<T> {
  const DataFailed({required this.message, this.code});

  final String message;
  final int? code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataFailed<T> &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;

  @override
  String toString() => 'DataFailed(message: $message, code: $code)';
}

/// Generic Result type for better error handling
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    _ => null,
  };

  Object? get errorOrNull => switch (this) {
    Failure(:final error) => error,
    _ => null,
  };

  R when<R>({
    required R Function(T data) success,
    required R Function(Object error, StackTrace? stackTrace) failure,
  }) {
    return switch (this) {
      Success(:final data) => success(data),
      Failure(:final error, :final stackTrace) => failure(error, stackTrace),
    };
  }

  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(:final data) => Success(transform(data)),
      Failure(:final error, :final stackTrace) => Failure(error, stackTrace),
    };
  }

  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success(:final data) => transform(data),
      Failure(:final error, :final stackTrace) => Failure(error, stackTrace),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

final class Failure<T> extends Result<T> {
  const Failure(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure(error: $error)';
}
