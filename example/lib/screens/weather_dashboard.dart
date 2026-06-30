import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

class WeatherDashboardScreen extends StatefulWidget {
  const WeatherDashboardScreen({super.key});

  @override
  State<WeatherDashboardScreen> createState() => _WeatherDashboardScreenState();
}

class _WeatherDashboardScreenState extends State<WeatherDashboardScreen> {
  final _tempCtrl = GaugeController(initialValue: 22.0);
  final _windCtrl = GaugeController(initialValue: 18.0);
  final _pressCtrl = GaugeController(initialValue: 1013.0);
  final _humidCtrl = GaugeController(initialValue: 64.0);
  final _uvCtrl = GaugeController(initialValue: 6.0);
  final _rainCtrl = GaugeController(initialValue: 34.0);

  Timer? _timer;
  double _phase = 0.0;
  String _conditions = 'PARTLY CLOUDY';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      _phase += 0.09;

      _tempCtrl.value = (22.0 + 5.0 * sin(_phase * 0.3)).clamp(-10.0, 45.0);
      _windCtrl.value = (18.0 + 12.0 * sin(_phase * 0.7) + 5.0 * sin(_phase * 1.8)).clamp(0.0, 120.0);
      _pressCtrl.value = (1013.0 + 8.0 * sin(_phase * 0.15)).clamp(950.0, 1050.0);
      _humidCtrl.value = (64.0 + 10.0 * sin(_phase * 0.4)).clamp(0.0, 100.0);
      _uvCtrl.value = (6.0 + 2.0 * sin(_phase * 0.5)).clamp(0.0, 11.0);
      _rainCtrl.value = (34.0 + 8.0 * sin(_phase * 0.25)).clamp(0.0, 100.0);

      final wind = _windCtrl.value;
      setState(() {
        if (wind < 5) {
          _conditions = 'CALM';
        } else if (wind < 25) {
          _conditions = 'LIGHT BREEZE';
        } else if (wind < 50) {
          _conditions = 'MODERATE WIND';
        } else if (wind < 75) {
          _conditions = 'STRONG WIND';
        } else {
          _conditions = 'GALE FORCE';
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tempCtrl.dispose();
    _windCtrl.dispose();
    _pressCtrl.dispose();
    _humidCtrl.dispose();
    _uvCtrl.dispose();
    _rainCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF0F4FA);
    const cardColor = Colors.white;
    const style = MaterialGaugeStyle();
    const mode = GaugeMode.ambient;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WEATHER STATION',
                          style: TextStyle(
                            color: Color(0xFF1A2A4A),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Text(
                          _conditions,
                          style: const TextStyle(
                            color: Color(0xFF5577AA),
                            fontSize: 12,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2255AA),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x442255AA),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'LIVE',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Top row: Temperature + Wind ──────────────────────────────
              Row(
                children: [
                  // Temperature card
                  Expanded(
                    child: _WeatherCard(
                      title: 'TEMPERATURE',
                      color: cardColor,
                      child: SizedBox(
                        height: 200,
                        child: Row(
                          children: [
                            Expanded(
                              child: ThermometerGauge(
                                controller: _tempCtrl,
                                minCelsius: -10,
                                maxCelsius: 45,
                                scale: TemperatureScale.celsius,
                                showScale: true,
                                style: style,
                                mode: mode,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ListenableBuilder(
                                  listenable: _tempCtrl,
                                  builder: (_, __) => Text(
                                    '${_tempCtrl.value.toStringAsFixed(1)}°C',
                                    style: const TextStyle(
                                      color: Color(0xFFCC3311),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text('Outdoor', style: TextStyle(color: Color(0xFF888888), fontSize: 11)),
                                const SizedBox(height: 16),
                                const Text('Feels like', style: TextStyle(color: Color(0xFF888888), fontSize: 11)),
                                ListenableBuilder(
                                  listenable: _tempCtrl,
                                  builder: (_, __) => Text(
                                    '${(_tempCtrl.value - 2.0).toStringAsFixed(1)}°C',
                                    style: const TextStyle(
                                      color: Color(0xFF334466),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Wind speed card with colored zones + live overlay
                  Expanded(
                    child: _WeatherCard(
                      title: 'WIND SPEED',
                      color: cardColor,
                      child: SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: RadialGauge(
                                controller: _windCtrl,
                                min: 0,
                                max: 120,
                                startAngleDeg: 150,
                                sweepAngleDeg: 240,
                                ranges: const [
                                  GaugeRange(min: 0, max: 20, color: Color(0xFF0077BB)),
                                  GaugeRange(min: 20, max: 50, color: Color(0xFF228833)),
                                  GaugeRange(min: 50, max: 80, color: Color(0xFFEE7733)),
                                  GaugeRange(min: 80, max: 120, color: Color(0xFFCC3311)),
                                ],
                                majorDivisions: 6,
                                showLabels: true,
                                showNeedle: true,
                                style: style,
                                mode: mode,
                              ),
                            ),
                            Align(
                              alignment: const Alignment(0, 0.6),
                              child: ListenableBuilder(
                                listenable: _windCtrl,
                                builder: (_, __) => Text(
                                  '${_windCtrl.value.toStringAsFixed(0)} km/h',
                                  style: const TextStyle(
                                    color: Color(0xFF1A2A4A),
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Middle row: Pressure + Humidity ──────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _WeatherCard(
                      title: 'BAROMETRIC PRESSURE',
                      color: cardColor,
                      child: SizedBox(
                        height: 150,
                        child: ListenableBuilder(
                          listenable: _pressCtrl,
                          builder: (_, __) => ArcGauge(
                            controller: _pressCtrl,
                            min: 950,
                            max: 1050,
                            startAngleDeg: 160,
                            sweepAngleDeg: 220,
                            centerLabel: '${_pressCtrl.value.toStringAsFixed(0)} hPa',
                            ranges: const [
                              GaugeRange(min: 950, max: 980, color: Color(0xFF0077BB)),
                              GaugeRange(min: 980, max: 1020, color: Color(0xFF228833)),
                              GaugeRange(min: 1020, max: 1050, color: Color(0xFFEE7733)),
                            ],
                            style: style,
                            mode: mode,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _WeatherCard(
                      title: 'HUMIDITY',
                      color: cardColor,
                      child: SizedBox(
                        height: 150,
                        child: ListenableBuilder(
                          listenable: _humidCtrl,
                          builder: (_, __) => ArcGauge(
                            controller: _humidCtrl,
                            min: 0,
                            max: 100,
                            startAngleDeg: 160,
                            sweepAngleDeg: 220,
                            centerLabel: '${_humidCtrl.value.toStringAsFixed(0)}% RH',
                            ranges: const [
                              GaugeRange(min: 0, max: 30, color: Color(0xFFEE7733)),
                              GaugeRange(min: 30, max: 70, color: Color(0xFF228833)),
                              GaugeRange(min: 70, max: 100, color: Color(0xFF0077BB)),
                            ],
                            style: style,
                            mode: mode,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Bottom row: UV Index + Rain Gauge ────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // UV Index segmented
                  Expanded(
                    flex: 2,
                    child: _WeatherCard(
                      title: 'UV INDEX',
                      color: cardColor,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 60,
                            child: SegmentedGauge(
                              controller: _uvCtrl,
                              min: 0,
                              max: 11,
                              segmentCount: 11,
                              horizontal: true,
                              gap: 2,
                              style: style,
                              mode: mode,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _UvLabel('LOW', const Color(0xFF0077BB)),
                              _UvLabel('MOD', const Color(0xFF228833)),
                              _UvLabel('HIGH', const Color(0xFFEE7733)),
                              _UvLabel('V.HIGH', const Color(0xFFCC3311)),
                              _UvLabel('EXT', const Color(0xFF882244)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ListenableBuilder(
                            listenable: _uvCtrl,
                            builder: (_, __) => Text(
                              'Index: ${_uvCtrl.value.toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: Color(0xFF334466),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Rain tank gauge
                  Expanded(
                    child: _WeatherCard(
                      title: 'RAIN GAUGE',
                      color: cardColor,
                      child: SizedBox(
                        height: 160,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              child: TankGauge.water(
                                controller: _rainCtrl,
                                style: style,
                                mode: mode,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ListenableBuilder(
                                  listenable: _rainCtrl,
                                  builder: (_, __) => Text(
                                    _rainCtrl.value.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Color(0xFF0077BB),
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Text('mm', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                                const Text('24h total', style: TextStyle(color: Color(0xFF888888), fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Data updates every 800 ms  •  All readings simulated',
                  style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color color;

  const _WeatherCard({required this.title, required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF334466),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _UvLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _UvLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold));
  }
}
