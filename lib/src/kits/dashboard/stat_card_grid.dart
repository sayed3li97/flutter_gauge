import 'package:flutter/material.dart';

/// A responsive "bento grid" layout for dashboard stat cards — an optional
/// full-width hero card up top, with the rest flowing into a fixed-column
/// grid beneath it.
///
/// This is the layout half of the dashboard kit: [GaugeRingCard],
/// [GaugeBarCard], and the presets in `stat_card_presets.dart` provide the
/// cards, and [StatCardGrid] arranges them the way a car's in-cabin
/// "booking" or status dashboard typically does — one hero stat (usually
/// speed) commanding attention, with secondary stats (battery, range,
/// climate, tyre pressure, ...) tiled below.
///
/// The column count adapts to the available width, so the same grid reads
/// as a single column on a phone-sized panel and multiple columns on a
/// tablet or in-car display.
///
/// ```dart
/// StatCardGrid(
///   hero: SpeedStatCard(controller: speedCtrl),
///   children: [
///     BatteryStatCard(controller: batteryCtrl),
///     RangeStatCard(controller: rangeCtrl),
///     ClimateStatCard(controller: climateCtrl),
///     TirePressureStatCard(controller: tireCtrl),
///   ],
/// )
/// ```
class StatCardGrid extends StatelessWidget {
  const StatCardGrid({
    super.key,
    this.hero,
    this.children = const [],
    this.spacing = 16,
    this.minTileWidth = 160,
    this.tileAspectRatio = 1.05,
    this.heroHeight = 240,
  });

  /// An optional full-width card shown above the grid — typically the
  /// single most important stat (e.g. current speed).
  final Widget? hero;

  /// The secondary stat cards, tiled into a responsive grid beneath [hero].
  final List<Widget> children;

  /// Gap between cards, both within the grid and between [hero] and the
  /// grid.
  final double spacing;

  /// The narrowest a grid tile is allowed to get before another column is
  /// dropped. Smaller values pack more columns into the same width.
  final double minTileWidth;

  /// Width-to-height ratio of each grid tile.
  final double tileAspectRatio;

  /// Fixed height reserved for [hero], regardless of the grid's column
  /// count.
  final double heroHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth.isFinite ? constraints.maxWidth : minTileWidth;
        final columns = ((width + spacing) / (minTileWidth + spacing))
            .floor()
            .clamp(1, children.length.clamp(1, 1 << 30));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hero != null) ...[
              SizedBox(height: heroHeight, child: hero),
              if (children.isNotEmpty) SizedBox(height: spacing),
            ],
            if (children.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: tileAspectRatio,
                ),
                itemCount: children.length,
                itemBuilder: (context, index) => children[index],
              ),
          ],
        );
      },
    );
  }
}
