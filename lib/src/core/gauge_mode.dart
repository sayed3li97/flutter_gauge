/// Controls the visual density and animation timing of every gauge widget.
///
/// The mode can be set globally via [GaugeThemeExtension] or overridden
/// per-widget through the `mode` parameter on any gauge constructor.
///
/// ```dart
/// // Global default
/// GaugeThemeExtension(defaultMode: GaugeMode.instrument)
///
/// // Per-widget override
/// RadialGauge(controller: ctrl, mode: GaugeMode.ambient)
/// ```
enum GaugeMode {
  /// Spacious layout, rounded caps, 600 ms easeInOut animation, no minor ticks.
  ///
  /// Suited for dashboard tiles, kiosk displays, and consumer-facing UIs where
  /// readability at a glance matters more than information density.
  ambient,

  /// Dense layout, butt caps, 300 ms easeOut animation, minor ticks, tabular figures.
  ///
  /// Suited for cockpit panels, industrial control rooms, and developer tools
  /// where precise readings and compact layouts are required.
  instrument,
}
