/// Dashboard Kit — pre-styled "smart car dashboard" composite widgets built
/// entirely on top of the core gauge_kit engine.
///
/// This is a high-level abstraction layer, not a new rendering engine: every
/// widget here is a `StatelessWidget` that configures [ArcGauge] or
/// [LinearGauge] (via [GaugeStyle]/[GaugeTokensOverride]) and wraps the
/// result in a rounded "glass card". Use it when you want the bento-grid,
/// gradient-ring look of a modern in-car dashboard without hand-tuning
/// tokens yourself — drop in a preset, or compose [GaugeRingCard] /
/// [GaugeBarCard] directly for a custom stat.
///
/// Import alongside `gauge_kit.dart`:
/// ```dart
/// import 'package:gauge_kit/gauge_kit.dart';
/// import 'package:gauge_kit/gauge_kit_dashboard_kit.dart';
/// ```
library;

// Chrome
export 'src/kits/dashboard/dashboard_card.dart';
export 'src/kits/dashboard/dashboard_card_style.dart';

// Composite gauge cards
export 'src/kits/dashboard/gauge_bar_card.dart';
export 'src/kits/dashboard/gauge_list_tile.dart';
export 'src/kits/dashboard/gauge_ring_card.dart';

// Layout
export 'src/kits/dashboard/stat_card_grid.dart';

// Ready-made car-domain presets
export 'src/kits/dashboard/stat_card_presets.dart';
