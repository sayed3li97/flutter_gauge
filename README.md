# gauge_kit

> 14 Flutter gauge widgets · zero dependencies · Material 3, Cupertino & Executive styles · MIT

[![pub.dev](https://img.shields.io/pub/v/gauge_kit.svg)](https://pub.dev/packages/gauge_kit)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0-blue.svg)](https://flutter.dev)

---

## Gallery

> screenshots coming soon

The example app ships 7 live dashboards: Car • Flight • Weather • Audio • Server • Submarine • ML

---

## Why gauge_kit?

- **14 purpose-built gauge types** vs 2–4 in every other package
- **Zero external dependencies** — pure Flutter/Dart canvas
- **MIT license** — no vendor lock-in (unlike Syncfusion's commercial license)
- **GaugeStyle / GaugeTokens architecture** — swap themes globally or per-widget
- **LeafRenderObjectWidget + ui.Picture cache** — only the pointer layer repaints
- **Built-in semantics** — every gauge announces its value to screen readers
- **Works on all 6 Flutter platforms**

---

## Installation

```yaml
dependencies:
  gauge_kit: ^0.1.0
```

---

## Quick start

```dart
import 'package:gauge_kit/gauge_kit.dart';

// 1. Create a controller
final ctrl = GaugeController(initialValue: 60);

// 2. Use any gauge widget
RadialGauge.speedometer(controller: ctrl, max: 200)

// 3. Update the value (instant)
ctrl.value = 120;

// 4. Or animate it smoothly
await ctrl.animateTo(120, duration: Duration(milliseconds: 600));
```

---

## Gauge types

| Widget | Best for |
|--------|----------|
| `RadialGauge` | Speedometers, tachometers, compasses |
| `ArcGauge` | KPI tiles, CPU/GPU usage rings |
| `LinearGauge` | Progress bars, thermometer bands |
| `BulletGauge` | Stephen Few-style KPI comparisons |
| `SegmentedGauge` | LED bar graphs, signal strength |
| `DeltaGauge` | Change-from-baseline tracking |
| `TapeGauge` | Airspeed / altimeter tapes |
| `OdometerGauge` | Rolling digit counters |
| `LevelMeterGauge` | VU meters, audio levels |
| `TankGauge` | Fuel, water, oxygen reserves |
| `ThermometerGauge` | Temperature with liquid fill |
| `StatusGauge` | OK / Warning / Danger dot |
| `InclinometerGauge` | Roll / pitch angles |
| `ArtificialHorizonGauge` | AHRS / attitude indicator |

---

## Styling

```dart
// Global style via ThemeExtension
MaterialApp(
  theme: ThemeData(
    extensions: [
      GaugeThemeExtension(
        style: const ExecutiveGaugeStyle(),
        defaultMode: GaugeMode.instrument,
      ),
    ],
  ),
)

// Per-widget override
RadialGauge(
  controller: ctrl,
  style: const CupertinoGaugeStyle(),
  mode: GaugeMode.ambient,
)

// Custom brand style — only specify what you change
class BrandStyle extends GaugeStyle {
  const BrandStyle();
  @override
  GaugeTokens resolve(BuildContext context, GaugeMode mode) =>
      GaugeTokens(valueColor: const Color(0xFFE91E63));
}
```

---

## Multiple pointers

```dart
RadialGauge(
  controller: speedCtrl,
  min: 0, max: 200,
  extraPointers: [
    GaugePointer(
      controller: limitCtrl,
      color: Colors.red,
      label: 'Speed limit',
    ),
  ],
)
```

---

## Accessibility

Every gauge announces its current value to screen readers automatically.
Provide a custom label via the `semanticsLabel` parameter:

```dart
RadialGauge(
  controller: ctrl,
  semanticsLabel: 'Engine RPM',
)
```

---

## GaugeMode

| Mode | Layout | Animation | Use case |
|------|--------|-----------|----------|
| `GaugeMode.ambient` | Spacious, rounded | 600 ms easeInOut | Dashboard tiles, kiosk displays |
| `GaugeMode.instrument` | Compact, butt caps, tabular figures | 300 ms easeOut | Cockpit, industrial panels |

---

## Animation

```dart
// Simple — no AnimationController needed
await ctrl.animateTo(85.0);

// With custom timing
await ctrl.animateTo(85.0,
  duration: const Duration(milliseconds: 300),
  curve: Curves.bounceOut,
);

// Stop mid-flight
ctrl.stopAnimation();
```

---

## Performance

- Static layers (track, ranges, ticks) cached to `ui.Picture`
- Only the pointer/value layer repaints on every controller update
- Each gauge is a `LeafRenderObjectWidget` with `isRepaintBoundary = true`
- No `setState` in the render layer — controller notifies via `ChangeNotifier`

---

## License

MIT — see [LICENSE](LICENSE).
