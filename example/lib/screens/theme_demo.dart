import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

class ThemeDemoScreen extends StatefulWidget {
  const ThemeDemoScreen({super.key});

  @override
  State<ThemeDemoScreen> createState() => _ThemeDemoScreenState();
}

class _ThemeDemoScreenState extends State<ThemeDemoScreen> {
  int _styleIndex = 0;
  int _modeIndex = 0;
  final _ctrl = GaugeController(initialValue: 65);

  static const _styleNames = ['Material 3', 'Cupertino', 'Executive'];
  static final _styles = [
    const MaterialGaugeStyle(),
    const CupertinoGaugeStyle(),
    const ExecutiveGaugeStyle(),
  ];

  static const _modeNames = ['Ambient', 'Instrument'];
  static const _modes = [GaugeMode.ambient, GaugeMode.instrument];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Themes & Styles')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          SegmentedButton<int>(
            segments: [
              for (var i = 0; i < _styleNames.length; i++)
                ButtonSegment(value: i, label: Text(_styleNames[i])),
            ],
            selected: {_styleIndex},
            onSelectionChanged: (s) => setState(() => _styleIndex = s.first),
          ),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: [
              for (var i = 0; i < _modeNames.length; i++)
                ButtonSegment(value: i, label: Text(_modeNames[i])),
            ],
            selected: {_modeIndex},
            onSelectionChanged: (s) => setState(() => _modeIndex = s.first),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: SizedBox(
                height: 240,
                width: 240,
                child: RadialGauge.speedometer(
                  controller: _ctrl,
                  style: _styles[_styleIndex],
                  mode: _modes[_modeIndex],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Slider(
              value: _ctrl.value,
              min: 0,
              max: 180,
              onChanged: (v) => setState(() => _ctrl.value = v),
            ),
          ),
        ],
      ),
    );
  }
}
