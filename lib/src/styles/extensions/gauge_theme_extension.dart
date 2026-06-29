import 'package:flutter/material.dart';

import '../../core/gauge_mode.dart';
import '../gauge_style.dart';

/// Flutter [ThemeExtension] that supplies [GaugeStyle] and [defaultMode]
/// to any widget in the subtree.
class GaugeThemeExtension extends ThemeExtension<GaugeThemeExtension> {
  const GaugeThemeExtension({
    required this.style,
    this.defaultMode = GaugeMode.ambient,
  });

  final GaugeStyle style;
  final GaugeMode defaultMode;

  @override
  GaugeThemeExtension copyWith({
    GaugeStyle? style,
    GaugeMode? defaultMode,
  }) {
    return GaugeThemeExtension(
      style: style ?? this.style,
      defaultMode: defaultMode ?? this.defaultMode,
    );
  }

  @override
  GaugeThemeExtension lerp(GaugeThemeExtension? other, double t) {
    if (other == null) return this;
    return GaugeThemeExtension(
      style: t < 0.5 ? style : other.style,
      defaultMode: t < 0.5 ? defaultMode : other.defaultMode,
    );
  }
}
