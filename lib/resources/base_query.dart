/// Base query class for pagination
abstract class BaseQuery {
  const BaseQuery({
    this.page = 1,
    this.size = 20,
  });

  final int page;
  final int size;

  /// Create a copy with new values
  BaseQuery copyWith({int? page, int? size});

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson();

  /// Get next page query
  BaseQuery nextPage() => copyWith(page: page + 1);

  /// Get previous page query
  BaseQuery previousPage() => copyWith(page: page > 1 ? page - 1 : 1);

  /// Reset to first page
  BaseQuery resetPage() => copyWith(page: 1);

  /// Check if this is the first page
  bool get isFirstPage => page == 1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BaseQuery &&
              runtimeType == other.runtimeType &&
              page == other.page &&
              size == other.size;

  @override
  int get hashCode => page.hashCode ^ size.hashCode;

  @override
  String toString() => 'BaseQuery(page: $page, size: $size)';
}

/// Standard paging query with search functionality
class BasePagingQuery extends BaseQuery {
  const BasePagingQuery({
    super.page,
    super.size,
    this.search,
    this.filters,
    this.sortBy,
    this.sortOrder,
  });

  final String? search;
  final Map<String, dynamic>? filters;
  final String? sortBy;
  final String? sortOrder; // 'asc' or 'desc'

  @override
  BasePagingQuery copyWith({
    int? page,
    int? size,
    String? search,
    Map<String, dynamic>? filters,
    String? sortBy,
    String? sortOrder,
  }) {
    return BasePagingQuery(
      page: page ?? this.page,
      size: size ?? this.size,
      search: search ?? this.search,
      filters: filters ?? this.filters,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'page': page,
      'size': size,
      if (search != null && search!.isNotEmpty) 'search': search,
      if (sortBy != null && sortBy!.isNotEmpty) 'sortBy': sortBy,
      if (sortOrder != null && sortOrder!.isNotEmpty) 'sortOrder': sortOrder,
      if (filters != null) ...filters!,
    };

    // Remove null and empty values
    map.removeWhere((key, value) {
      if (value == null) return true;
      if (value is String && value.isEmpty) return true;
      if (value is Map && value.isEmpty) return true;
      if (value is List && value.isEmpty) return true;
      return false;
    });

    return map;
  }

  /// Update search query
  BasePagingQuery updateSearch(String? search) {
    return copyWith(search: search, page: 1); // Reset to first page
  }

  /// Add filter
  BasePagingQuery addFilter(String key, dynamic value) {
    final newFilters = Map<String, dynamic>.from(filters ?? {});
    newFilters[key] = value;
    return copyWith(filters: newFilters, page: 1);
  }

  /// Remove filter
  BasePagingQuery removeFilter(String key) {
    if (filters == null) return this;
    final newFilters = Map<String, dynamic>.from(filters!);
    newFilters.remove(key);
    return copyWith(
      filters: newFilters.isEmpty ? null : newFilters,
      page: 1,
    );
  }

  /// Clear all filters
  BasePagingQuery clearFilters() {
    return copyWith(filters: null, page: 1);
  }

  /// Update sort
  BasePagingQuery updateSort(String sortBy, [String sortOrder = 'asc']) {
    return copyWith(sortBy: sortBy, sortOrder: sortOrder, page: 1);
  }

  /// Toggle sort order
  BasePagingQuery toggleSortOrder() {
    return copyWith(
      sortOrder: sortOrder == 'asc' ? 'desc' : 'asc',
      page: 1,
    );
  }

  /// Check if has active search
  bool get hasSearch => search != null && search!.isNotEmpty;

  /// Check if has active filters
  bool get hasFilters => filters != null && filters!.isNotEmpty;

  /// Check if has sorting
  bool get hasSorting => sortBy != null && sortBy!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          super == other &&
              other is BasePagingQuery &&
              runtimeType == other.runtimeType &&
              search == other.search &&
              filters == other.filters &&
              sortBy == other.sortBy &&
              sortOrder == other.sortOrder;

  @override
  int get hashCode =>
      super.hashCode ^
      search.hashCode ^
      filters.hashCode ^
      sortBy.hashCode ^
      sortOrder.hashCode;

  @override
  String toString() =>
      'BasePagingQuery(page: $page, size: $size, search: $search, filters: $filters, sortBy: $sortBy, sortOrder: $sortOrder)';
}

/// Factory method for creating default query
extension BaseQueryFactory on BaseQuery {
  /// Create default paging query
  static BasePagingQuery defaultPaging({
    int page = 1,
    int size = 20,
  }) {
    return BasePagingQuery(page: page, size: size);
  }
}