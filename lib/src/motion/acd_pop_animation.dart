import 'package:flutter/animation.dart';

/// The canonical duration for this package's "pop" scale animation — shared
/// by [ACDRatingBar] (per-item pop on rating change) and [ACDMotion]
/// (default tap effect) so every "something just changed" moment looks the
/// same across the package.
const Duration acdPopAnimationDuration = Duration(milliseconds: 220);

/// Builds the pop scale [TweenSequence]: `1.0` → [peakScale] → `1.0`.
///
/// Internal to the package: shared by [ACDRatingBar] and [ACDMotion].
TweenSequence<double> acdPopScaleTween({double peakScale = 1.25}) {
  return TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: peakScale,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 40,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: peakScale,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 60,
    ),
  ]);
}
