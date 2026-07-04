## 0.3.4

- No code changes — fixes the automated publishing pipeline dispatching
  `publish.yml` against `main` instead of the newly created tag. pub.dev's trusted
  publishing config requires the OIDC token's ref to have `refType: tag` matching
  `v{{version}}`; dispatching against a branch caused `0.3.3`'s publish attempt to
  fail with "publishing is only allowed from 'tag' refType".

## 0.3.3

- No code changes — end-to-end test of the fixed automated publishing pipeline
  (`release.yml` now explicitly dispatches `publish.yml` instead of relying on a
  tag-push event, which GitHub's loop-prevention rule silently drops when the tag
  is created by `GITHUB_TOKEN`).

## 0.3.2

- No code changes — republishes the `0.3.1` metadata fix through the new automated
  pub.dev publishing pipeline (GitHub Actions OIDC trusted publishing).

## 0.3.1

- `pubspec.yaml` — shortened `description` to fit pub.dev's recommended 60–180
  character range, fixing a lost "Follow Dart file conventions" pub point.

## 0.3.0

- `GaugeAnnotation` — new class for pinning arbitrary Flutter widgets at specific value
  positions around the `RadialGauge` arc. Supports `radiusFraction` and `offset` for
  precise placement.
- `RadialGauge` — converted to `StatelessWidget` wrapper supporting `child` (centre
  overlay), `annotations` (`List<GaugeAnnotation>`), `labelFormatter` (custom tick
  text), and `unitText` (centre value suffix).
- `ArcGauge` — converted to `StatelessWidget` wrapper with a full new layout tier:
  `child` (centre overlay), `header` / `footer` labels, `fillColor` (inner circle),
  `widgetIndicator` (moving tip widget), `reverse` (fill from far end), `showValue`,
  `unitText`, and `backgroundWidth` (override track stroke width).
- `LinearGauge` — converted to `StatelessWidget` wrapper with `leading` / `trailing`
  end widgets, `center` overlay, `widgetIndicator` (moving tip widget), `reverse`,
  `showValue`, `unitText`, `labelFormatter`, and `barRadius` (rounded filled-bar mode).
- Glow effects — `GaugeTokens.valueGlowRadius` (`double`, default `0.0`) and
  `GaugeTokens.valueGlowColor` (`Color?`) added to all arc/linear render engines;
  positive radius renders a soft outer glow behind the value arc or bar.
- `GaugeController.animateTo()` — new `onAnimationEnd` callback fires when the
  animation completes.
- All new params are optional with sensible defaults — existing code requires zero
  changes.

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
