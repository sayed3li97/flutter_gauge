import 'package:flutter_test/flutter_test.dart';
import 'package:gauge_kit/gauge_kit.dart';

void main() {
  group('UnitConverter', () {
    test('msToKmh: 1 m/s = 3.6 km/h', () {
      expect(UnitConverter.msToKmh(1), closeTo(3.6, 0.001));
    });

    test('msToMph: 1 m/s ≈ 2.237 mph', () {
      expect(UnitConverter.msToMph(1), closeTo(2.237, 0.001));
    });

    test('celsiusToFahrenheit: 0°C = 32°F', () {
      expect(UnitConverter.celsiusToFahrenheit(0), closeTo(32, 0.001));
    });

    test('celsiusToFahrenheit: 100°C = 212°F', () {
      expect(UnitConverter.celsiusToFahrenheit(100), closeTo(212, 0.001));
    });

    test('fahrenheitToCelsius: 32°F = 0°C', () {
      expect(UnitConverter.fahrenheitToCelsius(32), closeTo(0, 0.001));
    });

    test('round-trip C→F→C', () {
      const c = 37.0;
      expect(
        UnitConverter.fahrenheitToCelsius(UnitConverter.celsiusToFahrenheit(c)),
        closeTo(c, 0.001),
      );
    });

    test('paToBar: 100000 Pa = 1 bar', () {
      expect(UnitConverter.paToBar(100000), closeTo(1, 0.001));
    });

    test('wToHp: 745.7 W ≈ 1 hp', () {
      expect(UnitConverter.wToHp(745.7), closeTo(1, 0.001));
    });
  });

  group('TemperatureScale', () {
    test('Celsius conversion is identity', () {
      expect(TemperatureScale.celsius.convert(25), closeTo(25, 0.001));
    });

    test('Fahrenheit conversion: 100°C → 212°F', () {
      expect(TemperatureScale.fahrenheit.convert(100), closeTo(212, 0.001));
    });

    test('Kelvin: 0°C → 273.15 K', () {
      expect(TemperatureScale.kelvin.convert(0), closeTo(273.15, 0.001));
    });

    test('symbols', () {
      expect(TemperatureScale.celsius.symbol, '°C');
      expect(TemperatureScale.fahrenheit.symbol, '°F');
      expect(TemperatureScale.kelvin.symbol, 'K');
    });
  });
}
