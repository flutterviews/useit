part of 'extensions.dart';

/// Extension for screen size and responsive design
extension ScreenSizeExtension on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Shorthand for screen width
  double get mw => screenWidth;

  /// Shorthand for screen height
  double get mh => screenHeight;

  /// Get safe area padding
  EdgeInsets get safeArea => MediaQuery.of(this).padding;

  /// Get view insets (keyboard height, etc.)
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  /// Get device pixel ratio
  double get pixelRatio => MediaQuery.of(this).devicePixelRatio;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// Get keyboard height
  double get keyboardHeight => viewInsets.bottom;

  /// Get status bar height
  double get statusBarHeight => safeArea.top;

  /// Get bottom safe area height (for iPhone notch, etc.)
  double get bottomSafeArea => safeArea.bottom;

  /// Check if device is in landscape mode
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  /// Check if device is in portrait mode
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  /// Responsive breakpoints
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;
  bool get isSmallMobile => screenWidth < 360;
  bool get isLargeMobile => screenWidth >= 360 && screenWidth < 600;

  /// Responsive value selector
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Get responsive font size
  double fontSize(double size) {
    if (isSmallMobile) return size * 0.9;
    if (isTablet) return size * 1.1;
    if (isDesktop) return size * 1.2;
    return size;
  }

  /// Get responsive spacing
  double spacing(double space) {
    if (isSmallMobile) return space * 0.8;
    if (isTablet) return space * 1.2;
    if (isDesktop) return space * 1.5;
    return space;
  }

  /// Get percentage of screen width
  double widthPercent(double percent) {
    assert(percent >= 0 && percent <= 100);
    return screenWidth * (percent / 100);
  }

  /// Get percentage of screen height
  double heightPercent(double percent) {
    assert(percent >= 0 && percent <= 100);
    return screenHeight * (percent / 100);
  }

  /// Get responsive padding
  EdgeInsets get responsivePadding {
    return EdgeInsets.all(responsive(
      mobile: 16,
      tablet: 24,
      desktop: 32,
    ));
  }

  /// Get horizontal padding
  EdgeInsets get responsiveHorizontalPadding {
    return EdgeInsets.symmetric(
      horizontal: responsive(
        mobile: 16,
        tablet: 24,
        desktop: 32,
      ),
    );
  }

  /// Get vertical padding
  EdgeInsets get responsiveVerticalPadding {
    return EdgeInsets.symmetric(
      vertical: responsive(
        mobile: 16,
        tablet: 24,
        desktop: 32,
      ),
    );
  }

  /// Check if device has notch (rough estimation)
  bool get hasNotch => statusBarHeight > 24;

  /// Get usable screen height (excluding status bar and safe areas)
  double get usableHeight =>
      screenHeight - statusBarHeight - bottomSafeArea;

  /// Get usable screen width (excluding safe areas)
  double get usableWidth => screenWidth - safeArea.left - safeArea.right;
}

/// Extension for responsive sizing on numbers
extension ResponsiveSizeExtension on num {
  /// Get responsive width percentage
  double wp(BuildContext context) {
    return context.screenWidth * (this / 100);
  }

  /// Get responsive height percentage
  double hp(BuildContext context) {
    return context.screenHeight * (this / 100);
  }

  /// Get responsive font size
  double sp(BuildContext context) {
    return context.fontSize(toDouble());
  }

  /// Get responsive spacing
  double rp(BuildContext context) {
    return context.spacing(toDouble());
  }
}