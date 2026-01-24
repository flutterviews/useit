import 'package:useit/resources/data_state.dart';

/// Base use case interface
/// T: Return type
/// P: Parameters type
abstract class UseCase<T, P> {
  /// Execute the use case
  Future<T> call({required P params});
}

/// Use case with DataState result
abstract class DataUseCase<T, P> extends UseCase<DataState<T>, P> {
  @override
  Future<DataState<T>> call({required P params});
}

/// Use case with Result type
abstract class ResultUseCase<T, P> extends UseCase<Result<T>, P> {
  @override
  Future<Result<T>> call({required P params});
}

/// Use case without parameters
abstract class NoParamsUseCase<T> extends UseCase<T, NoParams> {
  @override
  Future<T> call({NoParams params = const NoParams()});

  /// Convenience method without params
  Future<T> execute() => call(params: const NoParams());
}

/// No parameters marker class
class NoParams {
  const NoParams();
}

/// Stream use case for reactive data
abstract class StreamUseCase<T, P> {
  Stream<T> call({required P params});
}

/// Stream use case with DataState
abstract class DataStreamUseCase<T, P> extends StreamUseCase<DataState<T>, P> {
  @override
  Stream<DataState<T>> call({required P params});
}

/// Synchronous use case (no async)
abstract class SyncUseCase<T, P> {
  T call({required P params});
}

/// Example implementations:

/// Example: Fetch user use case
/// ```dart
/// class FetchUserUseCase extends DataUseCase<User, String> {
///   final UserRepository repository;
///
///   FetchUserUseCase(this.repository);
///
///   @override
///   Future<DataState<User>> call({required String params}) async {
///     return await repository.getUser(userId: params);
///   }
/// }
/// ```

/// Example: No params use case
/// ```dart
/// class GetCurrentUserUseCase extends NoParamsUseCase<DataState<User>> {
///   final UserRepository repository;
///
///   GetCurrentUserUseCase(this.repository);
///
///   @override
///   Future<DataState<User>> call({NoParams params = const NoParams()}) async {
///     return await repository.getCurrentUser();
///   }
/// }
/// ```

/// Example: Stream use case
/// ```dart
/// class WatchUserUseCase extends DataStreamUseCase<User, String> {
///   final UserRepository repository;
///
///   WatchUserUseCase(this.repository);
///
///   @override
///   Stream<DataState<User>> call({required String params}) {
///     return repository.watchUser(userId: params);
///   }
/// }
/// ```