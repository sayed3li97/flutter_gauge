---
name: Bug Report
about: Report a reproducible defect in gauge_kit
title: "[Bug] "
labels: bug
assignees: ''
---

## Describe the bug

A clear and concise description of what the bug is.

## To reproduce

Steps to reproduce the behaviour:

1. Create a `GaugeController(initialValue: ...)`
2. Add `RadialGauge(...)` (or whichever gauge) to the widget tree
3. Call `ctrl.animateTo(...)`
4. See error / incorrect render

## Expected behaviour

A clear and concise description of what you expected to happen.

## Screenshots / recordings

If applicable, add screenshots or a screen recording to help explain the problem.

## Code sample

```dart
// Minimal reproducible example
import 'package:flutter/material.dart';
import 'package:gauge_kit/gauge_kit.dart';

void main() {
  runApp(const MaterialApp(home: _Demo()));
}

class _Demo extends StatelessWidget {
  const _Demo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 200, height: 200,
          child: RadialGauge(
            controller: GaugeController(initialValue: 50),
          ),
        ),
      ),
    );
  }
}
```

## Environment

- gauge_kit version: `0.x.x`
- Flutter version: `flutter --version`
- Platform: Android / iOS / Web / macOS / Linux / Windows
- Device / browser:

## Additional context

Any other context about the problem.
