part of 'extensions.dart';

/// Extension for creating Duration from numbers
/// Makes creating durations more readable and concise
extension NumDurationExtension on num {
  /// Create Duration from microseconds
  Duration get microseconds => Duration(microseconds: round());

  /// Create Duration from milliseconds
  Duration get milliseconds => Duration(milliseconds: round());

  /// Create Duration from seconds
  Duration get seconds => Duration(seconds: round());

  /// Create Duration from minutes
  Duration get minutes => Duration(minutes: round());

  /// Create Duration from hours
  Duration get hours => Duration(hours: round());

  /// Create Duration from days
  Duration get days => Duration(days: round());

  /// Create Duration from weeks
  Duration get weeks => Duration(days: round() * 7);
}

/// Extension for Duration utilities
extension DurationExtension on Duration {
  /// Get total milliseconds as int
  int get totalMilliseconds => inMilliseconds;

  /// Get total seconds as double
  double get totalSeconds => inMilliseconds / 1000;

  /// Get total minutes as double
  double get totalMinutes => inMilliseconds / 60000;

  /// Get total hours as double
  double get totalHours => inMilliseconds / 3600000;

  /// Get total days as double
  double get totalDays => inMilliseconds / 86400000;

  /// Format duration as HH:MM:SS
  String get toHHMMSS {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Format duration as MM:SS
  String get toMMSS {
    final minutes = inMinutes.toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Format duration as readable string
  /// Example: "2h 30m", "45m 20s", "30s"
  String get toReadable {
    if (inDays > 0) {
      final hours = inHours.remainder(24);
      return hours > 0 ? '${inDays}d ${hours}h' : '${inDays}d';
    }

    if (inHours > 0) {
      final minutes = inMinutes.remainder(60);
      return minutes > 0 ? '${inHours}h ${minutes}m' : '${inHours}h';
    }

    if (inMinutes > 0) {
      final seconds = inSeconds.remainder(60);
      return seconds > 0 ? '${inMinutes}m ${seconds}s' : '${inMinutes}m';
    }

    return '${inSeconds}s';
  }

  /// Check if duration is positive
  bool get isPositive => inMilliseconds > 0;

  /// Check if duration is negative
  bool get isNegative => inMilliseconds < 0;

  /// Check if duration is zero
  bool get isZero => inMilliseconds == 0;

  /// Delay execution by this duration
  Future<void> get delay => Future.delayed(this);

  /// Create a periodic timer with this duration
  Stream<int> periodic() {
    return Stream.periodic(this, (count) => count);
  }
}