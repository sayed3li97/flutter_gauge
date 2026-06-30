import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Paints a [TextPainter] at [offset] via a [PictureRecorder].
///
/// In Flutter CanvasKit, [TextPainter.paint] called directly on
/// [PaintingContext.canvas] does not produce visible output. Recording the text
/// into a [ui.Picture] first and replaying it via [Canvas.drawPicture] works
/// around this limitation.
void paintTextOnCanvas(Canvas canvas, TextPainter tp, Offset offset) {
  final recorder = ui.PictureRecorder();
  tp.paint(Canvas(recorder), Offset.zero);
  canvas.save();
  canvas.translate(offset.dx, offset.dy);
  canvas.drawPicture(recorder.endRecording());
  canvas.restore();
}
