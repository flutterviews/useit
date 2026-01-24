/// Status enum for base operations
enum BaseStatus {
  initial,
  loading,
  success,
  error;

  bool get isInitial => this == BaseStatus.initial;
  bool get isLoading => this == BaseStatus.loading;
  bool get isSuccess => this == BaseStatus.success;
  bool get isError => this == BaseStatus.error;
}

/// Generic state for simple data fetching
class BaseState<T> {
  const BaseState({
    this.data,
    this.status = BaseStatus.initial,
    this.error,
  });

  final T? data;
  final BaseStatus status;
  final String? error;

  /// Quick status checks
  bool get hasData => data != null;
  bool get hasError => error != null;
  bool get noData => data == null;
  bool get noError => error == null;

  /// Pattern matching helper
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String error) error,
  }) {
    return switch (status) {
      BaseStatus.initial => initial(),
      BaseStatus.loading => loading(),
      BaseStatus.success when data != null => success(data as T),
      BaseStatus.error when this.error != null => error(this.error!),
      _ => initial(),
    };
  }

  /// Copy with new values
  BaseState<T> copyWith({
    T? data,
    BaseStatus? status,
    String? error,
  }) {
    return BaseState(
      data: data ?? this.data,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  /// Factory for initial state
  factory BaseState.initial() => const BaseState();

  /// Factory for loading state
  factory BaseState.loading([T? data]) => BaseState(
    data: data,
    status: BaseStatus.loading,
  );

  /// Factory for success state
  factory BaseState.success(T data) => BaseState(
    data: data,
    status: BaseStatus.success,
  );

  /// Factory for error state
  factory BaseState.error(String error, [T? data]) => BaseState(
    data: data,
    status: BaseStatus.error,
    error: error,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BaseState<T> &&
              runtimeType == other.runtimeType &&
              data == other.data &&
              status == other.status &&
              error == other.error;

  @override
  int get hashCode => data.hashCode ^ status.hashCode ^ error.hashCode;

  @override
  String toString() =>
      'BaseState(data: $data, status: $status, error: $error)';
}

/// Status enum for pagination
enum BasePagingStatus {
  initial,
  loading,
  paging,
  success,
  error;

  bool get isInitial => this == BasePagingStatus.initial;
  bool get isLoading => this == BasePagingStatus.loading;
  bool get isPaging => this == BasePagingStatus.paging;
  bool get isSuccess => this == BasePagingStatus.success;
  bool get isError => this == BasePagingStatus.error;
}

/// State for paginated data
class BasePagingState<T, Q> {
  const BasePagingState({
    this.list = const [],
    required this.query,
    this.status = BasePagingStatus.initial,
    this.reachedMax = false,
    this.error,
    this.page = 1,
    this.size = 10,
  });

  final List<T> list;
  final Q query;
  final BasePagingStatus status;
  final bool reachedMax;
  final String? error;
  final int page;
  final int size;

  /// Quick checks
  bool get hasData => list.isNotEmpty;
  bool get isEmpty => list.isEmpty;
  bool get hasError => error != null;
  bool get canLoadMore => !reachedMax && status != BasePagingStatus.loading;

  /// Pattern matching helper
  R when<R>({
    required R Function() initial,
    required R Function(List<T> list) loading,
    required R Function(List<T> list) paging,
    required R Function(List<T> list, bool reachedMax) success,
    required R Function(String error, List<T> list) error,
  }) {
    return switch (status) {
      BasePagingStatus.initial => initial(),
      BasePagingStatus.loading => loading(list),
      BasePagingStatus.paging => paging(list),
      BasePagingStatus.success => success(list, reachedMax),
      BasePagingStatus.error when this.error != null => error(this.error!, list),
      _ => initial(),
    };
  }

  /// Copy with new values
  BasePagingState<T, Q> copyWith({
    List<T>? list,
    Q? query,
    BasePagingStatus? status,
    bool? reachedMax,
    String? error,
    int? page,
    int? size,
  }) {
    return BasePagingState(
      list: list ?? this.list,
      query: query ?? this.query,
      status: status ?? this.status,
      reachedMax: reachedMax ?? this.reachedMax,
      error: error ?? this.error,
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }

  /// Factory for initial state
  factory BasePagingState.initial(Q query, {int size = 10}) {
    return BasePagingState(
      query: query,
      size: size,
    );
  }

  /// Factory for loading state (first page)
  factory BasePagingState.loading(Q query, {int size = 10}) {
    return BasePagingState(
      query: query,
      status: BasePagingStatus.loading,
      size: size,
    );
  }

  /// Factory for paging state (loading more)
  BasePagingState<T, Q> toPaging() {
    return copyWith(status: BasePagingStatus.paging);
  }

  /// Factory for success state
  BasePagingState<T, Q> toSuccess(List<T> newItems, {bool? reachedMax}) {
    return copyWith(
      list: [...list, ...newItems],
      status: BasePagingStatus.success,
      reachedMax: reachedMax ?? (newItems.length < size),
      page: page + 1,
      error: null,
    );
  }

  /// Factory for error state
  BasePagingState<T, Q> toError(String error) {
    return copyWith(
      status: BasePagingStatus.error,
      error: error,
    );
  }

  /// Reset to initial state with new query
  BasePagingState<T, Q> reset({Q? newQuery}) {
    return BasePagingState.initial(
      newQuery ?? query,
      size: size,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BasePagingState<T, Q> &&
              runtimeType == other.runtimeType &&
              list == other.list &&
              query == other.query &&
              status == other.status &&
              reachedMax == other.reachedMax &&
              error == other.error &&
              page == other.page &&
              size == other.size;

  @override
  int get hashCode =>
      list.hashCode ^
      query.hashCode ^
      status.hashCode ^
      reachedMax.hashCode ^
      error.hashCode ^
      page.hashCode ^
      size.hashCode;

  @override
  String toString() =>
      'BasePagingState(list: ${list.length} items, query: $query, status: $status, page: $page/$size, reachedMax: $reachedMax, error: $error)';
}