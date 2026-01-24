part of 'extensions.dart';

/// Extension for JSON formatting
extension JsonExtension on dynamic {
  /// Convert to pretty formatted JSON string
  String get toPrettyJson {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(this);
    } catch (e) {
      LogService.e('Failed to convert to JSON: $e');
      return toString();
    }
  }

  /// Convert to compact JSON string
  String get toCompactJson {
    try {
      return jsonEncode(this);
    } catch (e) {
      LogService.e('Failed to convert to JSON: $e');
      return toString();
    }
  }
}

/// Extension for Map utilities
extension MapExtension<K, V> on Map<K, V> {
  /// Remove entries where value is null
  Map<K, V> get removeNulls {
    return Map.fromEntries(
      entries.where((entry) => entry.value != null),
    );
  }

  /// Remove entries where value is null or empty
  Map<K, V> get removeNullsAndEmpty {
    return Map.fromEntries(
      entries.where((entry) {
        final value = entry.value;
        if (value == null) return false;
        if (value is String && value.isEmpty) return false;
        if (value is List && value.isEmpty) return false;
        if (value is Map && value.isEmpty) return false;
        return true;
      }),
    );
  }

  /// Deep copy of map
  Map<K, V> get deepCopy {
    return Map.from(
      map((key, value) {
        dynamic copiedValue = value;
        if (value is Map) {
          copiedValue = Map.from(value);
        } else if (value is List) {
          copiedValue = List.from(value);
        }
        return MapEntry(key, copiedValue);
      }),
    );
  }

  /// Safely get value with default
  V getOrDefault(K key, V defaultValue) {
    return containsKey(key) ? this[key] as V : defaultValue;
  }

  /// Try get value, returns null if key doesn't exist
  V? tryGet(K key) {
    return containsKey(key) ? this[key] : null;
  }

  /// Convert map keys to snake_case
  Map<String, V> toSnakeCaseKeys() {
    if (K != String) return this as Map<String, V>;

    return map((key, value) {
      final snakeKey = (key as String).toSnakeCase;
      return MapEntry(snakeKey, value);
    });
  }
}

/// Extension for List utilities
extension ListExtension<T> on List<T> {
  /// Safely get element at index
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Safely get element at index with default value
  T getOrDefault(int index, T defaultValue) {
    if (index < 0 || index >= length) return defaultValue;
    return this[index];
  }

  /// Get first element or null
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null
  T? get lastOrNull => isEmpty ? null : last;

  /// Chunk list into smaller lists
  List<List<T>> chunk(int size) {
    if (size <= 0) return [];

    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      final end = (i + size < length) ? i + size : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }

  /// Remove duplicates
  List<T> get unique => toSet().toList();

  /// Remove duplicates by key
  List<T> uniqueBy<R>(R Function(T element) keySelector) {
    final seen = <R>{};
    return where((element) {
      final key = keySelector(element);
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }

  /// Group by key
  Map<K, List<T>> groupBy<K>(K Function(T element) keySelector) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keySelector(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }

  /// Sum of numeric values
  num sumBy(num Function(T element) selector) {
    return fold(0, (sum, element) => sum + selector(element));
  }

  /// Average of numeric values
  double? averageBy(num Function(T element) selector) {
    if (isEmpty) return null;
    return sumBy(selector) / length;
  }

  /// Max by selector
  T? maxBy(Comparable Function(T element) selector) {
    if (isEmpty) return null;
    return reduce((a, b) =>
    selector(a).compareTo(selector(b)) > 0 ? a : b);
  }

  /// Min by selector
  T? minBy(Comparable Function(T element) selector) {
    if (isEmpty) return null;
    return reduce((a, b) =>
    selector(a).compareTo(selector(b)) < 0 ? a : b);
  }
}