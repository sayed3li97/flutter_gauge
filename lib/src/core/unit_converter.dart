/// Utility class for common unit conversions used by gauge widgets.
class UnitConverter {
  const UnitConverter._();

  static double msToKmh(double ms) => ms * 3.6;
  static double msToMph(double ms) => ms * 2.23694;
  static double kmhToMs(double kmh) => kmh / 3.6;
  static double mphToMs(double mph) => mph / 2.23694;
  static double kmhToMph(double kmh) => kmh * 0.621371;
  static double mphToKmh(double mph) => mph * 1.60934;

  static double celsiusToFahrenheit(double c) => c * 9 / 5 + 32;
  static double fahrenheitToCelsius(double f) => (f - 32) * 5 / 9;
  static double celsiusToKelvin(double c) => c + 273.15;
  static double kelvinToCelsius(double k) => k - 273.15;

  static double paToBar(double pa) => pa / 100000;
  static double barToPa(double bar) => bar * 100000;
  static double paToKpa(double pa) => pa / 1000;
  static double kpaToPa(double kpa) => kpa * 1000;
  static double paToMmHg(double pa) => pa / 133.322;
  static double mmHgToPa(double mmHg) => mmHg * 133.322;
  static double paToAtm(double pa) => pa / 101325;
  static double atmToPa(double atm) => atm * 101325;
  static double paToPsi(double pa) => pa / 6894.76;
  static double psiToPa(double psi) => psi * 6894.76;

  static double rpmToHz(double rpm) => rpm / 60;
  static double hzToRpm(double hz) => hz * 60;
  static double rpmToRadS(double rpm) => rpm * (2 * 3.141592653589793) / 60;

  static double mToFt(double m) => m * 3.28084;
  static double ftToM(double ft) => ft / 3.28084;
  static double mToNm(double m) => m / 1852;
  static double nmToM(double nm) => nm * 1852;

  static double wToKw(double w) => w / 1000;
  static double kwToW(double kw) => kw * 1000;
  static double wToHp(double w) => w / 745.7;
  static double hpToW(double hp) => hp * 745.7;
}

/// Temperature scale selector.
enum TemperatureScale { celsius, fahrenheit, kelvin }

extension TemperatureScaleConvert on TemperatureScale {
  /// Convert [celsius] (internal storage) to this scale's display value.
  double convert(double celsius) {
    switch (this) {
      case TemperatureScale.celsius:
        return celsius;
      case TemperatureScale.fahrenheit:
        return UnitConverter.celsiusToFahrenheit(celsius);
      case TemperatureScale.kelvin:
        return UnitConverter.celsiusToKelvin(celsius);
    }
  }

  String get symbol {
    switch (this) {
      case TemperatureScale.celsius:
        return '°C';
      case TemperatureScale.fahrenheit:
        return '°F';
      case TemperatureScale.kelvin:
        return 'K';
    }
  }
}
