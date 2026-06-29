/// gauge_kit — Production-ready Flutter gauge library.
///
/// Import this file to access all gauges, styles, and utilities:
/// ```dart
/// import 'package:gauge_kit/gauge_kit.dart';
/// ```
library;

// Core
export 'src/core/gauge_controller.dart';
export 'src/core/gauge_mode.dart';
export 'src/core/gauge_range.dart';
export 'src/core/gauge_animation.dart';
export 'src/core/gauge_tick_style.dart';
export 'src/core/gauge_label_style.dart';
export 'src/core/unit_converter.dart';
export 'src/core/value_to_angle.dart';

// Styles
export 'src/styles/gauge_style.dart';
export 'src/styles/gauge_tokens.dart';
export 'src/styles/gauge_tokens_override.dart';
export 'src/styles/extensions/gauge_theme_extension.dart';
export 'src/styles/built_in/material_style.dart';
export 'src/styles/built_in/cupertino_style.dart';
export 'src/styles/built_in/executive_style.dart';

// Engine (internal — exported for advanced custom rendering)
export 'src/engine/radial_render.dart';
export 'src/engine/linear_render.dart';
export 'src/engine/segmented_render.dart';
export 'src/engine/arc_render.dart';
export 'src/engine/thermometer_render.dart';
export 'src/engine/bullet_render.dart';
export 'src/engine/tank_render.dart';
export 'src/engine/inclinometer_render.dart';
export 'src/engine/status_render.dart';
export 'src/engine/delta_render.dart';
export 'src/engine/horizon_render.dart';
export 'src/engine/odometer_render.dart';
export 'src/engine/level_meter_render.dart';
export 'src/engine/tape_render.dart';

// Widgets
export 'src/widgets/radial_gauge.dart';
export 'src/widgets/linear_gauge.dart';
export 'src/widgets/segmented_gauge.dart';
export 'src/widgets/arc_gauge.dart';
export 'src/widgets/thermometer_gauge.dart';
export 'src/widgets/bullet_gauge.dart';
export 'src/widgets/tank_gauge.dart';
export 'src/widgets/inclinometer_gauge.dart';
export 'src/widgets/status_gauge.dart';
export 'src/widgets/delta_gauge.dart';
export 'src/widgets/artificial_horizon_gauge.dart';
export 'src/widgets/odometer_gauge.dart';
export 'src/widgets/level_meter_gauge.dart';
export 'src/widgets/tape_gauge.dart';
