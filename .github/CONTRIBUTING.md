# Contributing to gauge_kit

Thank you for taking the time to contribute! This document covers how to set up the
project, the coding conventions used across the codebase, and the pull-request process.

---

## Table of Contents

1. [Project layout](#project-layout)
2. [Setting up locally](#setting-up-locally)
3. [Coding conventions](#coding-conventions)
4. [Running the example app](#running-the-example-app)
5. [Pull request checklist](#pull-request-checklist)
6. [Reporting bugs and requesting features](#reporting-bugs-and-requesting-features)

---

## Project Layout

```
gauge_kit/
├── lib/
│   ├── gauge_kit.dart           # Main public barrel export
│   ├── gauge_kit_rendering.dart # Advanced: exposes RenderBox subclasses
│   └── src/
│       ├── core/                # GaugeController, GaugeRange, GaugePointer, …
│       ├── engine/              # RenderBox subclasses (one per gauge type)
│       ├── styles/              # GaugeStyle, GaugeTokens, built-in styles
│       └── widgets/             # Stateless wrappers (one per gauge type)
├── example/                     # Full Flutter example app (8 dashboards)
└── test/                        # Widget and unit tests
```

---

## Setting Up Locally

```bash
git clone https://github.com/sayed3li97/flutter_gauge.git
cd flutter_gauge
flutter pub get
```

Verify everything compiles:

```bash
dart analyze
flutter test
```

---

## Coding Conventions

- **Zero external dependencies.** The `dependencies` block in `pubspec.yaml` must
  only contain `flutter: sdk: flutter`. Never add third-party packages.

- **Pure Canvas rendering.** All visual output goes through a `RenderBox.paint()`
  override using `dart:ui` primitives. No widget composition inside
  `LeafRenderObjectWidget` subclasses.

- **No `setState` in render objects.** Controllers notify via `ChangeNotifier`;
  render boxes call `markNeedsPaint()` directly.

- **Immutable data models.** `GaugeRange`, `GaugeAnnotation`, `GaugePointer`, and
  `GaugeTokens` are `const`-constructable immutable value types.

- **Dartdoc on every public API.** Every public class, constructor, and parameter
  must have a doc comment. Use `///` triple-slash style.

- **Follow existing file structure.** Adding a new gauge type requires:
  1. `lib/src/engine/my_gauge_render.dart` — the `RenderBox` subclass
  2. `lib/src/widgets/my_gauge.dart` — the `StatelessWidget` + `LeafRenderObjectWidget`
  3. Barrel export in `lib/gauge_kit.dart`
  4. Optional rendering export in `lib/gauge_kit_rendering.dart`

- **CVD-safe color defaults.** Default palette follows the Paul Tol scheme
  (`#0077BB`, `#EE7733`, `#CC3311`). Avoid pure red/green pairs as defaults.

---

## Running the Example App

```bash
cd example
flutter run
```

The app shows eight live dashboards accessible via the bottom navigation bar.

---

## Pull Request Checklist

Before opening a PR please verify:

- [ ] `dart analyze` reports zero issues
- [ ] `flutter test` passes
- [ ] New public APIs have Dartdoc comments
- [ ] No new external dependencies added
- [ ] `CHANGELOG.md` updated with a description of the change under a new or
      existing version heading
- [ ] Example app updated if a new widget or parameter was added

---

## Reporting Bugs and Requesting Features

Use GitHub Issues:

- **Bug report** → select the "Bug Report" template
- **Feature request** → select the "Feature Request" template

For security vulnerabilities, please email the maintainer directly rather than
opening a public issue.
