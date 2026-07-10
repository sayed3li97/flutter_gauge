## 0.6.0

- **Dashboard Kit** — a new high-level widget layer (`gauge_kit_dashboard_kit.dart`)
  built on top of the core engine, for the card-based "smart dashboard" style
  used by modern in-car booking/rental UIs: dark glass cards, gradient
  rings/bars, and accent glow, in a responsive bento grid. Nothing here is a
  new rendering engine — every widget is a thin `StatelessWidget` that
  configures `ArcGauge`/`LinearGauge` via `GaugeStyle`/`GaugeTokensOverride`.
  - `DashboardCard` / `DashboardCardHeader` / `DashboardCardStyle` — shared
    glass-card chrome (background, border, glow, text styles).
  - `GaugeRingCard` / `GaugeBarCard` — composite gauge widgets that wrap
    `ArcGauge`/`LinearGauge` in a `DashboardCard`, with an `accentColor` +
    `colorForValue` shorthand for the common case and a `gaugeStyle` escape
    hatch for full token-level control.
  - Eight ready-made car-domain presets — `SpeedStatCard`, `BatteryStatCard`,
    `RangeStatCard`, `EcoScoreStatCard`, `ClimateStatCard`,
    `TirePressureStatCard`, `FuelStatCard`, `TripStatCard` — each needing
    only a `GaugeController` to drop in.
  - `GaugeListTile` — a full-width *row* primitive (icon, label, big value,
    slim inline indicator), for a settings-style grouped list instead of a
    grid of tiles. Stack several inside one `DashboardCard` with dividers.
  - `StatCardGrid` — a responsive hero-card-plus-grid layout that adapts its
    column count to the available width.
- `LinearGauge` now honours `GaugeTokens.valueGradient` for its bar fill,
  matching the gradient support `RadialGauge` and `ArcGauge` already had.
  This was a genuine gap — the pill-shaped gradient bars used by
  `GaugeBarCard` were not achievable before this fix.
- `DashboardCardHeader`'s label is now wrapped in `Flexible` with an ellipsis,
  so longer labels (e.g. "TYRE PRESSURE") no longer overflow narrow grid tiles.
- `DashboardCardStyle.trackColor` — new field controlling the unfilled
  portion of a ring/bar/list-tile gauge. Previously hardcoded to a faint
  white wash inside `GaugeRingCard`/`GaugeBarCard`/`GaugeListTile`, which made
  the empty track invisible against a light/white card background — a real
  bug found while building a light-themed layout variant. `GaugeRingCard`,
  `GaugeBarCard`, and `GaugeListTile` now all read this from `cardStyle`.
- `SpeedStatCard` gained a `trackWidth` parameter (default `10`, matching
  `GaugeRingCard`) so an oversized hero ring can use a proportionally
  thicker stroke.
- Example app: new "Kit" tab (`SmartCarDashboardKitScreen`) — an in-app
  switcher across four *structurally different* dashboard compositions
  (not just a recolor of one grid), each pairing a distinct layout with a
  distinct palette:
  - **Bento Grid** (Midnight) — hero ring + `StatCardGrid`.
  - **List** (Luxury Gold) — compact hero banner + one grouped
    `GaugeListTile` list.
  - **Carousel** (Neon Aurora) — an oversized centred hero dial with a
    horizontally swipeable strip of secondary cards.
  - **Split Console** (Daylight) — a wide dual-pane layout (hero left,
    scrollable stat list right), the shape of an actual in-car centre
    console rather than a phone screen.
  All four share the same eight `GaugeController`s and a live-updating
  speed/battery/range simulation with a Start/End Trip toggle.

## 0.5.0

- `RadialGauge.fillColor` — new parameter for a solid dial-face fill drawn
  beneath the track, ticks, and needle. `ArcGauge` already had this; `RadialGauge`
  did not, which made classic skeuomorphic analog gauge clusters (opaque dial
  face against a transparent background) impossible to build. Threaded through
  all four named presets (`.speedometer`, `.tachometer`, `.fuel`, `.compass`).
- Example app: new "Styles" tab (`CarStylesDashboardScreen`) showcasing three
  automotive instrument-cluster design languages built entirely from existing
  gauge_kit widgets:
  - **Minimalist EV cluster** — plain digital speed readout, `DeltaGauge` as a
    centre-zero regen/power meter, `ArcGauge` battery, compact heading indicator
  - **Analog twin-dial cluster** — two large `RadialGauge` dials with a solid
    dark face via the new `fillColor`, flanked by a digital gear readout and
    `LinearGauge` fuel/temp bars
  - **Centered tachometer cluster** — a five-dial classic layout with an
    oversized centre tachometer, all sharing a cream analog face via `fillColor`
- README: documented `RadialGauge.fillColor` and added the three new gallery
  screenshots.

## 0.4.0

- `SparklineGauge` — new 15th gauge type: a compact trend-line widget that plots a
  rolling window of sample history, for showing a recent trend next to a live
  number (CPU load, network throughput, sensor readings, etc.).
- `SparklineController` — new controller type backing `SparklineGauge`. Unlike
  `GaugeController`, it tracks a bounded history of discrete samples (`addSample`,
  `samples`, `latest`, `clear`) rather than a single live value, so it isn't
  polluted by per-frame animation ticks.
- `SparklineGauge` supports auto-scaling (`min`/`max` default to the visible
  sample window), an optional area fill under the line, a last-point marker, and
  the existing `valueGlowRadius`/`valueGlowColor` glow tokens.
- Example app: `ServerDashboardScreen` now includes a live "CPU Core 1" sparkline
  fed from the same controller driving the CPU arc gauge.
- `gauge_kit_rendering.dart` now also exports `SparklineGaugeRenderBox` for direct
  render-object access.

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
