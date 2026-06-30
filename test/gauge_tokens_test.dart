import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit/gauge_kit.dart';

GaugeTokens _makeTokens({Color? valueColor}) {
  return GaugeTokens(
    trackColor: const Color(0x1F000000),
    trackStrokeWidth: 10,
    trackStrokeCap: StrokeCap.round,
    trackBorderRadius: 4,
    valueColor: valueColor ?? const Color(0xFF6750A4),
    valueStrokeWidth: 10,
    needleColor: const Color(0xFF6750A4),
    needleWidth: 3,
    needleTipStyle: NeedleTipStyle.sharp,
    needleDropShadow: false,
    knobColor: const Color(0xFF6750A4),
    knobRadius: 8,
    knobBorderWidth: 0,
    majorTick: const GaugeTickStyle(
      color: Color(0xFF49454F),
      strokeWidth: 1.5,
      length: 12,
    ),
    minorTick: const GaugeTickStyle(
      color: Color(0xFF79747E),
      strokeWidth: 1,
      length: 6,
    ),
    labelStyle: const TextStyle(fontSize: 12),
    labelOffset: 16,
    zoneNormal: const Color(0xFF0077BB),
    zoneWarning: const Color(0xFFEE7733),
    zoneDanger: const Color(0xFFCC3311),
    annotationTextStyle: const TextStyle(fontSize: 11),
    dragOverlayColor: const Color(0x336750A4),
    dragOverlayRadius: 20,
    animationDuration: const Duration(milliseconds: 600),
    animationCurve: Curves.easeInOut,
  );
}

void main() {
  group('GaugeTokens', () {
    test('copyWith preserves unset fields', () {
      final t = _makeTokens();
      final t2 = t.copyWith(trackStrokeWidth: 8);
      expect(t2.trackStrokeWidth, 8);
      expect(t2.valueColor, t.valueColor);
    });

    test('lerp at t=0 returns a', () {
      final a = _makeTokens(valueColor: const Color(0xFF0000FF));
      final b = _makeTokens(valueColor: const Color(0xFFFF0000));
      final result = GaugeTokens.lerp(a, b, 0);
      expect(result.valueColor, a.valueColor);
    });

    test('lerp at t=1 returns b', () {
      final a = _makeTokens(valueColor: const Color(0xFF0000FF));
      final b = _makeTokens(valueColor: const Color(0xFFFF0000));
      final result = GaugeTokens.lerp(a, b, 1);
      expect(result.valueColor, b.valueColor);
    });

    test('knobBorderColor can be null', () {
      final t = _makeTokens();
      expect(t.knobBorderColor, isNull);
    });
  });
}
