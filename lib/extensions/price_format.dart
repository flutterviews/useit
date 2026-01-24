part of 'extensions.dart';

/// Extension for formatting numbers as prices/currency
extension NumberFormatExtension on num? {
  /// Format number as price with decimal places
  /// Default: 2 decimal places
  String toPrice([int maxFractionDigits = 2]) {
    final value = this;
    if (value == null) return '';

    final formatter = NumberFormat.decimalPatternDigits(
      decimalDigits: maxFractionDigits,
    );
    return formatter.format(value).replaceAll(',', '.');
  }

  /// Format number as compact price (1K, 1M, etc.)
  /// Shows full number if less than 1M
  String get toPriceCompact {
    final value = this;
    if (value == null) return '';

    if (value > 999999) {
      return NumberFormat.compact(locale: 'en_US')
          .format(value)
          .replaceAll(',', '.');
    }

    return toPrice();
  }

  /// Format number as currency with symbol
  /// Example: toCurrency(symbol: '₽') => "1,000₽"
  String toCurrency({String? symbol, int decimalDigits = 0}) {
    final value = this;
    if (value == null) return '';

    final formatter = NumberFormat.compactCurrency(
      symbol: symbol ?? '',
      decimalDigits: decimalDigits,
    );

    var result = formatter.format(value).replaceAll(',', '.');

    // Remove trailing symbol if no symbol provided
    if (symbol == null && result.isNotEmpty) {
      result = result.substring(0, result.length - 1);
    }

    return result;
  }

  /// Format as percentage
  /// Example: 0.5.toPercent() => "50%"
  String toPercent([int decimalDigits = 0]) {
    final value = this;
    if (value == null) return '';

    final percentage = value * 100;
    return '${percentage.toStringAsFixed(decimalDigits)}%';
  }

  /// Format with thousands separator
  /// Example: 1000000 => "1.000.000"
  String get withSeparator {
    final value = this;
    if (value == null) return '';

    return NumberFormat('#,###', 'en_US')
        .format(value)
        .replaceAll(',', '.');
  }

  /// Format as file size (bytes to KB, MB, GB)
  String get toFileSize {
    final value = this;
    if (value == null) return '';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = value.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  /// Clamp value between min and max
  num clampBetween(num min, num max) {
    final value = this;
    if (value == null) return min;
    return value.clamp(min, max);
  }
}

/// Extension for non-nullable numbers
extension NumberFormatNonNullExtension on num {
  /// Format number as price (non-nullable version)
  String toPrice([int maxFractionDigits = 2]) {
    final formatter = NumberFormat.decimalPatternDigits(
      decimalDigits: maxFractionDigits,
    );
    return formatter.format(this).replaceAll(',', '.');
  }

  /// Round to specific decimal places
  double roundToDecimal(int places) {
    final mod = 10.0 * places;
    return (this * mod).round() / mod;
  }

  /// Check if number is between min and max (inclusive)
  bool isBetween(num min, num max) => this >= min && this <= max;

  /// Check if number is positive
  bool get isPositive => this > 0;

  /// Check if number is negative
  bool get isNegative => this < 0;

  /// Check if number is zero
  bool get isZero => this == 0;

  /// Check if number is even
  bool get isEven => this % 2 == 0;

  /// Check if number is odd
  bool get isOdd => this % 2 != 0;
}

/// Extension for parsing strings to numbers
extension StringToNumberExtension on String {
  /// Parse string to number (handles formatted prices)
  /// Example: "1.234,56" or "1,234.56" => 1234.56
  num? get fromPrice {
    try {
      // Replace dots with empty string, commas with dots
      final normalized = replaceAll('.', '').replaceAll(',', '.');
      return num.tryParse(normalized);
    } catch (e) {
      LogService.e('Failed to parse price: $e');
      return null;
    }
  }

  /// Parse string to int
  int? get toInt => int.tryParse(this);

  /// Parse string to double
  double? get toDouble => double.tryParse(this);

  /// Parse string to num
  num? get toNum => num.tryParse(this);

  /// Parse with fallback value
  int toIntOr(int defaultValue) => int.tryParse(this) ?? defaultValue;

  /// Parse with fallback value
  double toDoubleOr(double defaultValue) => double.tryParse(this) ?? defaultValue;
}