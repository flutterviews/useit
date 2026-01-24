part of 'extensions.dart';

/// Extension for string utilities
extension StringExtension on String {
  /// Convert camelCase to snake_case
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp('(?<=[a-z])[A-Z]'),
          (m) => '_${m.group(0)}',
    ).toLowerCase();
  }

  /// Convert snake_case to camelCase
  String get toCamelCase {
    return replaceAllMapped(
      RegExp('_([a-z])'),
          (m) => m.group(1)!.toUpperCase(),
    );
  }

  /// Convert to PascalCase
  String get toPascalCase {
    return split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join();
  }

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize first letter of each word
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Remove extra whitespace
  String get removeExtraSpaces {
    return trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Check if string is email
  bool get isEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is URL
  bool get isUrl {
    try {
      final uri = Uri.parse(this);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// Check if string contains only digits
  bool get isNumeric {
    return RegExp(r'^\d+$').hasMatch(this);
  }

  /// Check if string contains only letters
  bool get isAlpha {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// Check if string contains only letters and digits
  bool get isAlphanumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Reverse string
  String get reverse {
    return split('').reversed.join();
  }

  /// Count occurrences of substring
  int count(String substring) {
    if (isEmpty || substring.isEmpty) return 0;
    return split(substring).length - 1;
  }

  /// Check if string is palindrome
  bool get isPalindrome {
    final cleaned = toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return cleaned == cleaned.split('').reversed.join();
  }

  /// Remove all whitespace
  String get removeWhitespace {
    return replaceAll(RegExp(r'\s'), '');
  }

  /// Get initials from name
  /// Example: "John Doe" => "JD"
  String get initials {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';

    return words
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();
  }

  /// Check if string is empty or null
  bool get isNullOrEmpty => isEmpty;

  /// Check if string is not empty or null
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Convert to title case
  String get toTitleCase {
    if (isEmpty) return this;

    final words = split(' ');
    final titleCase = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    });

    return titleCase.join(' ');
  }

  /// Replace multiple strings at once
  String replaceMultiple(Map<String, String> replacements) {
    var result = this;
    replacements.forEach((from, to) {
      result = result.replaceAll(from, to);
    });
    return result;
  }

  /// Get words from string
  List<String> get words {
    return split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  /// Count words in string
  int get wordCount => words.length;
}

/// Extension for nullable strings
extension NullableStringExtension on String? {
  /// Check if string is null or empty
  bool get isNullOrEmpty {
    final value = this;
    return value == null || value.isEmpty;
  }

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty {
    final value = this;
    return value != null && value.isNotEmpty;
  }

  /// Get string or default value
  String orDefault([String defaultValue = '']) {
    final value = this;
    return value != null && value.isNotEmpty ? value : defaultValue;
  }

  /// Get string or null if empty
  String? get orNull {
    final value = this;
    return value != null && value.isNotEmpty ? value : null;
  }
}