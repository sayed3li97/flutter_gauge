import 'package:flutter/painting.dart';

class GaugeLabelStyle {
  const GaugeLabelStyle({
    required this.textStyle,
    required this.offset,
  });

  final TextStyle textStyle;
  final double offset;

  GaugeLabelStyle copyWith({
    TextStyle? textStyle,
    double? offset,
  }) {
    return GaugeLabelStyle(
      textStyle: textStyle ?? this.textStyle,
      offset: offset ?? this.offset,
    );
  }
}
