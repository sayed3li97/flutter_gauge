import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

class GaugeController extends ChangeNotifier {
  GaugeController({double initialValue = 0.0}) : _value = initialValue;

  double _value;

  double get value => _value;

  set value(double newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners();
  }

  /// Animates [value] from its current level to [target] using [controller].
  void animateTo(
    double target,
    AnimationController controller, {
    Curve curve = Curves.easeInOut,
  }) {
    final start = _value;
    final tween = Tween<double>(begin: start, end: target);
    final curved = CurvedAnimation(parent: controller, curve: curve);
    void listener() {
      value = tween.evaluate(curved);
    }

    controller.addListener(listener);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.removeListener(listener);
      }
    });
    controller.forward(from: 0);
  }
}
