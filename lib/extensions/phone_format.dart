part of 'extensions.dart';

/// Extension for phone number formatting
extension PhoneFormatExtension on String? {
  // Cache regex patterns for better performance
  static final _phone13Regex = RegExp(r'(\d{3})(\d{2})(\d{3})(\d{2})(\d{2})');
  static final _phone9Regex = RegExp(r'(\d{2})(\d{3})(\d{2})(\d{2})');
  static final _phone12Regex = RegExp(r'(\d{3})(\d{2})(\d{3})(\d{2})(\d{2})');
  static final _digitsOnlyRegex = RegExp(r'\D');

  /// Format phone number based on length
  /// 13 digits: +998 XX XXX XX XX
  /// 9 digits: XX XXX XX XX
  String get toPhone {
    final value = this;
    if (value == null || value.isEmpty) return '';

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(_digitsOnlyRegex, '');

    return switch (digitsOnly.length) {
      13 => digitsOnly.replaceAllMapped(
        _phone13Regex,
            (m) => '+${m[1]} ${m[2]} ${m[3]} ${m[4]} ${m[5]}',
      ),
      12 => digitsOnly.replaceAllMapped(
        _phone12Regex,
            (m) => '+${m[1]} ${m[2]} ${m[3]} ${m[4]} ${m[5]}',
      ),
      9 => digitsOnly.replaceAllMapped(
        _phone9Regex,
            (m) => '${m[1]} ${m[2]} ${m[3]} ${m[4]}',
      ),
      _ => value,
    };
  }

  /// Format as Uzbekistan phone number
  /// Always adds +998 prefix
  String get toUzPhone {
    final value = this;
    if (value == null || value.isEmpty) return '';

    final digitsOnly = value.replaceAll(_digitsOnlyRegex, '');

    // Remove country code if present
    String number = digitsOnly;
    if (number.startsWith('998')) {
      number = number.substring(3);
    }

    if (number.length == 9) {
      return number.replaceAllMapped(
        _phone9Regex,
            (m) => '+998 ${m[1]} ${m[2]} ${m[3]} ${m[4]}',
      );
    }

    return value;
  }

  /// Get only digits from phone number
  String get phoneDigitsOnly {
    final value = this;
    if (value == null || value.isEmpty) return '';
    return value.replaceAll(_digitsOnlyRegex, '');
  }

  /// Validate if string is a valid phone number
  bool get isValidPhone {
    final digits = phoneDigitsOnly;
    // Check if it's 9 digits (local) or 12-13 digits (with country code)
    return digits.length == 9 || digits.length == 12 || digits.length == 13;
  }

  /// Validate if string is a valid Uzbekistan phone number
  bool get isValidUzPhone {
    final digits = phoneDigitsOnly;

    // Check if it's 9 digits or 12 digits with 998 prefix
    if (digits.length == 9) return true;
    if (digits.length == 12 && digits.startsWith('998')) return true;
    if (digits.length == 13 && digits.startsWith('998')) return true;

    return false;
  }

  /// Add country code if not present
  String addCountryCode(String countryCode) {
    final value = this;
    if (value == null || value.isEmpty) return '';

    final digits = phoneDigitsOnly;
    if (digits.startsWith(countryCode)) return value;

    return '$countryCode$digits';
  }

  /// Remove country code
  String removeCountryCode([String? countryCode]) {
    final value = this;
    if (value == null || value.isEmpty) return '';

    final digits = phoneDigitsOnly;

    if (countryCode != null && digits.startsWith(countryCode)) {
      return digits.substring(countryCode.length);
    }

    // Remove common country codes
    if (digits.startsWith('998') && digits.length > 9) {
      return digits.substring(3);
    }

    return value;
  }
}

/// Extension for masking phone numbers
extension PhoneMaskExtension on String {
  /// Mask phone number for privacy
  /// Example: +998 90 123 45 67 => +998 90 XXX XX 67
  String get maskPhone {
    if (isEmpty) return '';

    final formatted = toPhone;
    final parts = formatted.split(' ');

    if (parts.length >= 4) {
      return '${parts[0]} ${parts[1]} XXX XX ${parts[parts.length - 1]}';
    }

    return formatted;
  }
}