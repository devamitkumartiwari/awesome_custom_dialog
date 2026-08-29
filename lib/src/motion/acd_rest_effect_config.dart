import 'package:flutter/material.dart';

import 'acd_motion_rest_effect.dart';

/// Configures a looping "at-rest" effect on [ACDMotion]/[ACDAnimatedText].
///
/// ```dart
/// ACDMotion(
///   restEffect: const ACDRestEffectConfig(effect: ACDMotionRestEffect.pulse),
///   child: const Icon(Icons.favorite),
/// )
/// ```
final class ACDRestEffectConfig {
  /// Creates an [ACDRestEffectConfig]. [strength] and [period] default to
  /// [effect]'s own [ACDMotionRestEffect.defaultStrength]/
  /// [ACDMotionRestEffect.defaultPeriod] when left `null`.
  const ACDRestEffectConfig({
    required this.effect,
    this.strength,
    this.alignment = Alignment.center,
    this.period,
    this.repeatCount,
    this.curve = Curves.easeInOut,
    this.delay = Duration.zero,
    this.customEffect,
  });

  /// Which built-in waveform to play — ignored when [customEffect] is set.
  final ACDMotionRestEffect effect;

  /// Effect intensity (`0`–`1`). Falls back to
  /// `effect.defaultStrength` when `null`.
  final double? strength;

  /// Pivot for rotation/scale/dangle-style effects.
  final Alignment alignment;

  /// Duration of one full cycle. Falls back to `effect.defaultPeriod` when
  /// `null`.
  final Duration? period;

  /// Number of cycles to play before stopping. `null` loops forever.
  final int? repeatCount;

  /// Easing curve applied within each cycle.
  final Curve curve;

  /// Delay before the first cycle begins.
  final Duration delay;

  /// Escape hatch fully overriding the built-in [effect] math — receives the
  /// current cycle phase (`0`–`1`) and returns the composed transform
  /// matrix directly.
  final Matrix4 Function(double phase)? customEffect;

  /// Resolved strength — [strength] if set, else `effect.defaultStrength`.
  double get resolvedStrength => strength ?? effect.defaultStrength;

  /// Resolved period — [period] if set, else `effect.defaultPeriod`.
  Duration get resolvedPeriod => period ?? effect.defaultPeriod;
}
