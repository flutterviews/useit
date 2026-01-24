import 'dart:async';

import 'package:flutter/material.dart';

/// Hide keyboard
void hideKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

/// Show keyboard
void showKeyboard(BuildContext context, FocusNode focusNode) {
  FocusScope.of(context).requestFocus(focusNode);
}

/// Unfocus all
void unfocusAll() {
  FocusManager.instance.primaryFocus?.unfocus();
}

/// Create TextPainter for measuring text
TextPainter textPainter({
  String? text,
  TextStyle? style,
  int maxLines = 1,
  TextDirection textDirection = TextDirection.ltr,
}) {
  return TextPainter(
    text: TextSpan(
      text: text,
      style: style ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    ),
    maxLines: maxLines,
    textDirection: textDirection,
  )..layout(minWidth: 0, maxWidth: double.infinity);
}

/// Calculate text size
Size calculateTextSize({
  required String text,
  required TextStyle style,
  int maxLines = 1,
  double maxWidth = double.infinity,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: maxLines,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: maxWidth);

  return painter.size;
}

/// Check if text will overflow
bool willTextOverflow({
  required String text,
  required TextStyle style,
  required double maxWidth,
  int maxLines = 1,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: maxLines,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: maxWidth);

  return painter.didExceedMaxLines;
}

/// Debouncer for rate limiting function calls
class Debouncer {
  Debouncer({required this.duration});

  final Duration duration;
  Timer? _timer;

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Throttler for rate limiting function calls
class Throttler {
  Throttler({required this.duration});

  final Duration duration;
  Timer? _timer;
  bool _isWaiting = false;

  void call(VoidCallback action) {
    if (_isWaiting) return;

    action();
    _isWaiting = true;
    _timer = Timer(duration, () {
      _isWaiting = false;
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Delayed executor
class DelayedExecutor {
  DelayedExecutor({required this.duration});

  final Duration duration;
  Timer? _timer;

  void execute(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Retry helper
Future<T> retry<T>({
  required Future<T> Function() action,
  int maxAttempts = 3,
  Duration delay = const Duration(seconds: 1),
  bool Function(dynamic error)? retryIf,
}) async {
  var attempts = 0;

  while (true) {
    try {
      return await action();
    } catch (e) {
      attempts++;

      if (attempts >= maxAttempts) {
        rethrow;
      }

      if (retryIf != null && !retryIf(e)) {
        rethrow;
      }

      await Future.delayed(delay * attempts);
    }
  }
}

/// Safe async call with error handling
Future<T?> safeAsync<T>(
    Future<T> Function() action, {
      void Function(Object error, StackTrace stackTrace)? onError,
    }) async {
  try {
    return await action();
  } catch (e, s) {
    onError?.call(e, s);
    return null;
  }
}

/// Batch processor
class BatchProcessor<T> {
  BatchProcessor({
    required this.batchSize,
    required this.processor,
    this.delayBetweenBatches = Duration.zero,
  });

  final int batchSize;
  final Future<void> Function(List<T> batch) processor;
  final Duration delayBetweenBatches;

  Future<void> process(List<T> items) async {
    for (var i = 0; i < items.length; i += batchSize) {
      final end = (i + batchSize < items.length) ? i + batchSize : items.length;
      final batch = items.sublist(i, end);

      await processor(batch);

      if (delayBetweenBatches > Duration.zero && end < items.length) {
        await Future.delayed(delayBetweenBatches);
      }
    }
  }
}
