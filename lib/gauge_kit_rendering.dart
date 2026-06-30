/// Advanced export — gives access to the [RenderBox] subclass for every gauge.
///
/// Import this in addition to `gauge_kit.dart` when you need to embed gauge
/// render objects directly into a custom [MultiChildRenderObjectWidget] or
/// inspect the Flutter render tree.
///
/// ```dart
/// import 'package:gauge_kit/gauge_kit.dart';
/// import 'package:gauge_kit/gauge_kit_rendering.dart';
/// ```
library;

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
export 'src/engine/paint_utils.dart';
