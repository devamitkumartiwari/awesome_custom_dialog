import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'acd_motion_rest_effect.dart';

/// Turns one point in a continuously-repeating rest-effect cycle into a
/// single composed [Matrix4] for the given [phase] (`0`–`1`, already curved
/// by the caller).
///
/// Internal to the package: shared by [ACDMotion] and [ACDAnimatedText] so
/// every [ACDMotionRestEffect] preset's waveform math is written once.
Matrix4 acdRestEffectMatrix({
  required ACDMotionRestEffect effect,
  required double phase,
  required double strength,
}) {
  final double wave = math.sin(phase * 2 * math.pi);
  final Matrix4 matrix = Matrix4.identity();
  switch (effect) {
    case ACDMotionRestEffect.wave:
      matrix.translateByDouble(0.0, wave * 10 * strength, 0.0, 1.0);
    case ACDMotionRestEffect.pulse:
      final double s = 1 + wave.abs() * 0.25 * strength;
      matrix.scaleByDouble(s, s, 1.0, 1.0);
    case ACDMotionRestEffect.rotate:
      matrix.rotateZ(phase * 2 * math.pi * strength);
    case ACDMotionRestEffect.bounce:
      matrix.translateByDouble(0.0, -wave.abs() * 12 * strength, 0.0, 1.0);
    case ACDMotionRestEffect.slide:
      matrix.translateByDouble(wave * 12 * strength, 0.0, 0.0, 1.0);
    case ACDMotionRestEffect.swing:
      matrix.rotateZ(wave * 0.35 * strength);
    case ACDMotionRestEffect.size:
      final double s = 1 + wave * 0.15 * strength;
      matrix.scaleByDouble(s, s, 1.0, 1.0);
    case ACDMotionRestEffect.fidget:
      final double jitterX = math.sin(phase * 2 * math.pi * 5) * 3 * strength;
      final double jitterR =
          math.sin(phase * 2 * math.pi * 3) * 0.05 * strength;
      matrix
        ..translateByDouble(jitterX, 0.0, 0.0, 1.0)
        ..rotateZ(jitterR);
    case ACDMotionRestEffect.dangle:
      matrix.rotateZ(wave * 0.12 * strength);
    case ACDMotionRestEffect.vibrate:
      matrix.translateByDouble(
        math.sin(phase * 2 * math.pi * 8) * 2 * strength,
        0.0,
        0.0,
        1.0,
      );
  }
  return matrix;
}
