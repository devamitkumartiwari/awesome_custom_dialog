import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import 'acd_motion_effect.dart';

/// One evaluated frame of an [ACDMotionEffect] (internal — shared by
/// `ACDMotion` and the staggered collections' shared clock).
typedef ACDMotionSample = ({
  Matrix4 matrix,
  double opacity,
  Offset offsetFactor,
  Offset blur,
});

/// Evaluates [effect] at curved progress [t] (0..1).
ACDMotionSample acdEvaluateMotion(ACDMotionEffect effect, double t) {
  final double opacity = ui.lerpDouble(
    effect.beginOpacity,
    effect.endOpacity,
    t,
  )!;
  final double scale = ui.lerpDouble(effect.beginScale, effect.endScale, t)!;
  final double rotation =
      ui.lerpDouble(effect.beginRotationTurns, effect.endRotationTurns, t)! *
      2 *
      math.pi;
  final double skewX = ui.lerpDouble(effect.beginSkewX, effect.endSkewX, t)!;
  final double skewY = ui.lerpDouble(effect.beginSkewY, effect.endSkewY, t)!;
  final Offset offsetFactor = Offset.lerp(
    effect.beginOffsetFactor,
    effect.endOffsetFactor,
    t,
  )!;
  final Offset blur = Offset.lerp(
    effect.beginBlurSigma,
    effect.endBlurSigma,
    t,
  )!;
  final Matrix4 matrix = Matrix4.identity()
    ..rotateZ(rotation)
    ..scaleByDouble(scale, scale, 1.0, 1.0)
    ..setEntry(0, 1, skewX)
    ..setEntry(1, 0, skewY);
  return (
    matrix: matrix,
    opacity: opacity,
    offsetFactor: offsetFactor,
    blur: blur,
  );
}

/// Wraps [child] in the blur → opacity → transform → fractional-offset
/// stack for [sample] — the exact composition `ACDMotion` paints.
Widget acdApplyMotionSample(ACDMotionSample sample, Widget child) {
  Widget result = child;
  final Offset blur = sample.blur;
  if (blur.dx > 0 || blur.dy > 0) {
    result = ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: blur.dx, sigmaY: blur.dy),
      child: result,
    );
  }
  result = Opacity(opacity: sample.opacity.clamp(0.0, 1.0), child: result);
  result = Transform(
    transform: sample.matrix,
    alignment: Alignment.center,
    child: result,
  );
  if (sample.offsetFactor != Offset.zero) {
    result = FractionalTranslation(
      translation: sample.offsetFactor,
      child: result,
    );
  }
  return result;
}
