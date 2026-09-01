import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'acd_loader_stroke_cap.dart';

/// Internal to the package: shared painting math for every loader in this
/// folder, so a fix (or a bug) only has one place to live in — not
/// re-derived per widget.

/// Resolves [StrokeCap] for a circular (ring/arc) stroke. [ACDLoaderStrokeCap.roundAll]
/// (a bar-only concept) is treated as [StrokeCap.round].
StrokeCap acdCircularStrokeCap(ACDLoaderStrokeCap cap) => switch (cap) {
  ACDLoaderStrokeCap.round || ACDLoaderStrokeCap.roundAll => StrokeCap.round,
  ACDLoaderStrokeCap.square => StrokeCap.square,
  ACDLoaderStrokeCap.butt => StrokeCap.butt,
};

/// A ready-to-paint stroke [Paint] for a ring/arc, filled with [color] or
/// [gradient] (gradient wins when both are supplied) sized to [shaderRect].
Paint acdLoaderStrokePaint({
  required double strokeWidth,
  required ACDLoaderStrokeCap strokeCap,
  required Rect shaderRect,
  Color? color,
  Gradient? gradient,
  MaskFilter? maskFilter,
}) {
  final Paint paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = acdCircularStrokeCap(strokeCap)
    ..maskFilter = maskFilter;
  if (gradient != null) {
    paint.shader = gradient.createShader(shaderRect);
  } else {
    paint.color = color ?? const Color(0xFFB8C7CB);
  }
  return paint;
}

/// A ready-to-paint fill [Paint] (pie slices, bar segments), filled with
/// [color] or [gradient] (gradient wins when both are supplied) sized to
/// [shaderRect].
Paint acdLoaderFillPaint({
  required Rect shaderRect,
  Color? color,
  Gradient? gradient,
  MaskFilter? maskFilter,
}) {
  final Paint paint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = maskFilter;
  if (gradient != null) {
    paint.shader = gradient.createShader(shaderRect);
  } else {
    paint.color = color ?? const Color(0xFFB8C7CB);
  }
  return paint;
}

/// Converts degrees to radians.
double acdRadians(double degrees) => degrees * (math.pi / 180.0);

/// The `(startRadians, sweepRadians)` for a circular fill of [percent]
/// (already clamped `0.0`–`1.0`) across an arc spanning [sweepAngleDeg]
/// degrees from [startAngleDeg], honoring [reverse].
///
/// When [percent] would produce a sweep equal to a full [sweepAngleDeg] of
/// exactly `360`, the sweep is pulled in by a hair (see
/// [acdFullCircleEpsilonDeg]) — `canvas.drawArc` degenerates to nothing for
/// an exact full-circle sweep, which is what makes a 100%-full ring
/// silently vanish if this isn't handled explicitly.
(double start, double sweep) acdLoaderArc({
  required double percent,
  required double startAngleDeg,
  required double sweepAngleDeg,
  required bool reverse,
}) {
  double sweepDeg = sweepAngleDeg * percent;
  if (sweepAngleDeg >= 360 && sweepDeg >= 360) {
    sweepDeg = 360 - acdFullCircleEpsilonDeg;
  }
  if (reverse) sweepDeg = -sweepDeg;
  return (acdRadians(startAngleDeg), acdRadians(sweepDeg));
}

/// The tiny pull-in applied by [acdLoaderArc] to avoid a degenerate
/// exact-360° `drawArc` sweep.
const double acdFullCircleEpsilonDeg = 0.1;

/// Paints a rounded/flat bar segment of [rect] with [paint]. Corner
/// rounding is controlled purely by [radius] — independent of [strokeCap],
/// which a bar-shaped fill has no real "stroke" for; passing a non-null,
/// non-zero [radius] always rounds all four corners, whether or not
/// [strokeCap] is also set to [ACDLoaderStrokeCap.round]/
/// [ACDLoaderStrokeCap.roundAll].
void acdDrawLoaderBar(
  Canvas canvas,
  Rect rect,
  Paint paint, {
  required ACDLoaderStrokeCap strokeCap,
  Radius? radius,
}) {
  final bool rounded = radius != null && radius != Radius.zero;
  if (rounded) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);
  } else {
    canvas.drawRect(rect, paint);
  }
}
