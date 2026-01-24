part of 'extensions.dart';

/// Extension for creating padding and spacing
extension PaddingExtension on num {
  /// Create horizontal padding
  SizedBox get pw => SizedBox(width: toDouble());

  /// Create vertical padding
  SizedBox get ph => SizedBox(height: toDouble());

  /// Create EdgeInsets with all sides equal
  EdgeInsets get padding => EdgeInsets.all(toDouble());

  /// Create horizontal EdgeInsets
  EdgeInsets get paddingH => EdgeInsets.symmetric(horizontal: toDouble());

  /// Create vertical EdgeInsets
  EdgeInsets get paddingV => EdgeInsets.symmetric(vertical: toDouble());

  /// Create top EdgeInsets
  EdgeInsets get paddingTop => EdgeInsets.only(top: toDouble());

  /// Create bottom EdgeInsets
  EdgeInsets get paddingBottom => EdgeInsets.only(bottom: toDouble());

  /// Create left EdgeInsets
  EdgeInsets get paddingLeft => EdgeInsets.only(left: toDouble());

  /// Create right EdgeInsets
  EdgeInsets get paddingRight => EdgeInsets.only(right: toDouble());

  /// Create BorderRadius with all corners equal
  BorderRadius get radius => BorderRadius.circular(toDouble());

  /// Create top BorderRadius
  BorderRadius get radiusTop => BorderRadius.vertical(
    top: Radius.circular(toDouble()),
  );

  /// Create bottom BorderRadius
  BorderRadius get radiusBottom => BorderRadius.vertical(
    bottom: Radius.circular(toDouble()),
  );

  /// Create left BorderRadius
  BorderRadius get radiusLeft => BorderRadius.horizontal(
    left: Radius.circular(toDouble()),
  );

  /// Create right BorderRadius
  BorderRadius get radiusRight => BorderRadius.horizontal(
    right: Radius.circular(toDouble()),
  );

  /// Create Radius
  Radius get circularRadius => Radius.circular(toDouble());
}

/// Extension for Widget padding shortcuts
extension WidgetPaddingExtension on Widget {
  /// Add padding on all sides
  Widget padding(double value) {
    return Padding(
      padding: EdgeInsets.all(value),
      child: this,
    );
  }

  /// Add symmetric padding
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      ),
      child: this,
    );
  }

  /// Add custom padding
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  /// Add padding from EdgeInsets
  Widget paddingFrom(EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: this,
    );
  }

  /// Add margin using Container
  Widget margin(double value) {
    return Container(
      margin: EdgeInsets.all(value),
      child: this,
    );
  }

  /// Add symmetric margin
  Widget marginSymmetric({double horizontal = 0, double vertical = 0}) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      ),
      child: this,
    );
  }

  /// Add custom margin
  Widget marginOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }
}