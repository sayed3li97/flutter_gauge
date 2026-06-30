## 0.2.0

- `GaugeController.animateTo()` — new self-contained animation API; no external
  `AnimationController` required. Accepts optional `duration` and `curve` overrides.
- `GaugeTokens` — all constructor parameters are now optional with sensible defaults,
  making it easier to create partial token overrides in custom styles.
- `GaugePointer` — new class for adding extra needles to `RadialGauge` with independent
  controllers, colors, and optional labels.
- `RadialGauge.extraPointers` — accepts a `List<GaugePointer>` to render multiple
  concentric needles on a single gauge face.
- `DeltaGauge.lowerIsBetter` — boolean flag that inverts the positive/negative color
  semantics for "lower is better" metrics such as loss functions or lap times.
- Semantics — all 14 gauge widgets now wrap their canvas in a `Semantics` node and
  announce the current value to screen readers on every update.
- `semanticsLabel` param — added to all gauge widgets; overrides the default
  auto-generated accessibility label with a custom string.
- `gauge_kit_rendering.dart` — new advanced barrel export exposing internal render box
  types for consumers who need direct access to the render layer.
- Internal cleanup: engine render boxes (`RenderRadialGauge`, `RenderArcGauge`, etc.)
  removed from the main `gauge_kit.dart` public export to keep the default surface area
  small; import `gauge_kit_rendering.dart` to access them.

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
