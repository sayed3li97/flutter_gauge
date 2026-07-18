import 'package:flutter/widgets.dart';

import 'gauge_controller.dart';

/// Internal helper that owns a [GaugeController] driven by a plain [value].
///
/// This is what lets the value-only gauge constructors — e.g.
/// `RadialGauge(value: 60)` — work with **no** external controller and **no**
/// `dispose()`: the host creates the controller, implicitly animates it to the
/// latest [value] whenever the widget rebuilds, and disposes it automatically.
///
/// Not exported from the public barrels — it's an implementation detail of the
/// gauge widgets. Use a [GaugeController] directly for full control.
class GaugeValueHost extends StatefulWidget {
  const GaugeValueHost({
    super.key,
    required this.value,
    required this.builder,
    this.animate = true,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOut,
  });

  /// The current target value. When it changes, the hosted controller is
  /// (optionally) animated to the new value.
  final double value;

  /// Builds the gauge with the internally-managed controller.
  final Widget Function(BuildContext context, GaugeController controller)
      builder;

  /// Whether value changes animate ([animate] `true`, the default) or snap
  /// immediately.
  final bool animate;

  /// Animation duration used when [animate] is `true`.
  final Duration duration;

  /// Animation curve used when [animate] is `true`.
  final Curve curve;

  @override
  State<GaugeValueHost> createState() => _GaugeValueHostState();
}

class _GaugeValueHostState extends State<GaugeValueHost> {
  late final GaugeController _controller =
      GaugeController(initialValue: widget.value);

  @override
  void didUpdateWidget(GaugeValueHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.animate) {
        _controller.animateTo(
          widget.value,
          duration: widget.duration,
          curve: widget.curve,
        );
      } else {
        _controller.value = widget.value;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}
