part of 'extensions.dart';

/// Extension for converting hex string to Color
extension ColorExtension on String? {
  /// Convert hex string to Color
  /// Supports formats: "#RRGGBB", "#AARRGGBB", "RRGGBB", "AARRGGBB"
  /// Returns null if string is null or invalid
  Color? get toColor {
    final value = this;
    if (value == null || value.isEmpty) return null;

    try {
      String hexColor = value.toUpperCase().replaceAll('#', '');

      // Add alpha if not present
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }

      // Validate length
      if (hexColor.length != 8) {
        LogService.w('Invalid hex color format: $value');
        return null;
      }

      final colorValue = int.tryParse(hexColor, radix: 16);
      if (colorValue == null) {
        LogService.w('Failed to parse hex color: $value');
        return null;
      }

      return Color(colorValue);
    } catch (e) {
      LogService.e('Error converting hex to color: $e');
      return null;
    }
  }

  /// Convert hex string to Color with fallback
  Color toColorOrDefault([Color defaultColor = Colors.black]) {
    return toColor ?? defaultColor;
  }
}

/// Extension for Color to hex string conversion
extension ColorToHex on Color {
  /// Convert Color to hex string with alpha
  /// Format: #AARRGGBB
  String toHex({bool includeAlpha = true}) {
    if (includeAlpha) {
      return '#${(a * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0')}'
          '${(r * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0')}'
          '${(g * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0')}'
          '${(b * 255.0).round().clamp(0, 255)..toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();
    } else {
      return '#${(r * 255.0).round().clamp(0, 255)..toRadixString(16).padLeft(2, '0')}'
          '${(g * 255.0).round().clamp(0, 255)..toRadixString(16).padLeft(2, '0')}'
          '${(b * 255.0).round().clamp(0, 255)..toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();
    }
  }

  /// Get contrasting color (black or white)
  Color get contrastColor {
    final luminance = computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Lighten color by percentage (0.0 to 1.0)
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);

    return hsl.withLightness(lightness).toColor();
  }

  /// Darken color by percentage (0.0 to 1.0)
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);

    return hsl.withLightness(lightness).toColor();
  }
}