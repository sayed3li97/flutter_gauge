## 0.1.0

- Initial release.
- 14 gauge widget types: `RadialGauge`, `LinearGauge`, `SegmentedGauge`, `ArcGauge`,
  `ThermometerGauge`, `BulletGauge`, `TankGauge`, `InclinometerGauge`, `StatusGauge`,
  `DeltaGauge`, `ArtificialHorizonGauge`, `OdometerGauge`, `LevelMeterGauge`, `TapeGauge`.
- 3 built-in styles: `MaterialGaugeStyle`, `CupertinoGaugeStyle`, `ExecutiveGaugeStyle`.
- `GaugeMode` enum with `ambient` and `instrument` variants.
- `GaugeThemeExtension` for Flutter `ThemeExtension` integration.
- `GaugeController` (`ChangeNotifier`) for value management.
- Pure Canvas rendering via `LeafRenderObjectWidget` — zero external dependencies.
- Static-layer picture caching for performant animation.
- CVD-safe color defaults (Paul Tol scheme).
- `UnitConverter` utility for speed, temperature, pressure, and power conversions.
- MIT license.
