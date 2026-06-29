# gauge_kit

Open-source Flutter gauge library with 14 widget types, 3 built-in design styles (Material 3, Cupertino, Executive), pluggable style architecture, and zero external dependencies.

## Features

| Feature | gauge_kit |
|---------|----------|
| Radial gauge | ✅ |
| Linear gauge | ✅ |
| Segmented / LED bar | ✅ |
| Arc / progress gauge | ✅ |
| Thermometer | ✅ |
| Bullet chart | ✅ |
| Tank / fill gauge | ✅ |
| Inclinometer | ✅ |
| Status indicator | ✅ |
| Delta / change gauge | ✅ |
| Artificial horizon | ✅ |
| Odometer | ✅ |
| Level meter | ✅ |
| Tape / altimeter | ✅ |
| Material 3 style | ✅ |
| Cupertino style | ✅ |
| Executive style | ✅ |
| GaugeMode (ambient/instrument) | ✅ |
| GaugeThemeExtension | ✅ |
| Zero external dependencies | ✅ |
| MIT license | ✅ |

## Getting started

Add to `pubspec.yaml`:

```yaml
dependencies:
  gauge_kit: ^0.1.0
```

## Usage

```dart
import 'package:gauge_kit/gauge_kit.dart';

// Create a controller
final controller = GaugeController(initialValue: 60);

// Use a preset
RadialGauge.speedometer(controller: controller, max: 200)

// Or the base widget
RadialGauge(
  controller: controller,
  min: 0,
  max: 100,
  ranges: [
    GaugeRange(min: 80, max: 100, color: Color(0xFFCC3311)),
  ],
)
```

## Theming

Apply a style globally via `ThemeExtension`:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      GaugeThemeExtension(
        style: const ExecutiveGaugeStyle(),
        defaultMode: GaugeMode.instrument,
      ),
    ],
  ),
  ...
)
```

Or per-widget:

```dart
RadialGauge(
  controller: ctrl,
  style: const CupertinoGaugeStyle(),
  mode: GaugeMode.ambient,
)
```

## GaugeMode

`GaugeMode.ambient` — spacious, rounded, 600 ms animation (default)
`GaugeMode.instrument` — dense, butt caps, 300 ms animation, tabular figures

## Custom styles

Extend `GaugeStyle` and return `GaugeTokens`:

```dart
class MyStyle extends GaugeStyle {
  const MyStyle();

  @override
  GaugeTokens resolve(dynamic context, GaugeMode mode) {
    return GaugeTokens(
      trackColor: const Color(0xFF1A1A1A),
      valueColor: const Color(0xFF00FF88),
      // ...
    );
  }
}
```

## Performance

- Static canvas layers (track, ticks, ranges) are cached to `ui.Picture`.
- Only the pointer/value layer repaints on controller updates.
- Each gauge is a `LeafRenderObjectWidget` with `isRepaintBoundary = true`.
- No `setState` in the render layer — `GaugeController` notifies via `ChangeNotifier`.

## License

MIT — see [LICENSE](LICENSE).