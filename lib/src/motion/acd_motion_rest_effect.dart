/// A built-in looping "at-rest" effect for [ACDMotion]/[ACDAnimatedText],
/// configured via [ACDRestEffectConfig].
///
/// Each case is a Dart enhanced enum carrying its own sensible
/// [defaultStrength]/[defaultPeriod], so `ACDRestEffectConfig(effect: .vibrate)`
/// looks right with zero further tuning instead of forcing every caller to
/// hand-pick numbers.
enum ACDMotionRestEffect {
  /// A gentle up-down bob, like a wave passing under the widget.
  wave(defaultStrength: 0.4, defaultPeriod: Duration(milliseconds: 1600)),

  /// A rhythmic scale in/out, like a heartbeat.
  pulse(defaultStrength: 0.5, defaultPeriod: Duration(milliseconds: 1000)),

  /// A continuous full rotation.
  rotate(defaultStrength: 1.0, defaultPeriod: Duration(milliseconds: 2000)),

  /// A vertical bounce, like a ball settling.
  bounce(defaultStrength: 0.5, defaultPeriod: Duration(milliseconds: 900)),

  /// A horizontal back-and-forth slide.
  slide(defaultStrength: 0.4, defaultPeriod: Duration(milliseconds: 1400)),

  /// A pendulum-like rotational swing around `ACDRestEffectConfig.alignment`.
  swing(defaultStrength: 0.3, defaultPeriod: Duration(milliseconds: 1200)),

  /// A gentle grow/shrink, like breathing.
  size(defaultStrength: 0.3, defaultPeriod: Duration(milliseconds: 1800)),

  /// A quick, small, irregular-feeling jitter.
  fidget(defaultStrength: 0.25, defaultPeriod: Duration(milliseconds: 500)),

  /// A slow rotational sway, like something hanging loosely.
  dangle(defaultStrength: 0.2, defaultPeriod: Duration(milliseconds: 2200)),

  /// A rapid, low-amplitude shake.
  vibrate(defaultStrength: 0.15, defaultPeriod: Duration(milliseconds: 180));

  const ACDMotionRestEffect({
    required this.defaultStrength,
    required this.defaultPeriod,
  });

  /// A sensible default `strength` (`0`–`1`) for this effect, used by
  /// [ACDRestEffectConfig] when its own `strength` isn't overridden.
  final double defaultStrength;

  /// A sensible default `period` for this effect, used by
  /// [ACDRestEffectConfig] when its own `period` isn't overridden.
  final Duration defaultPeriod;
}
