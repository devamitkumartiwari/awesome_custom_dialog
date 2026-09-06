import 'dart:ui' show Offset;

import 'package:flutter/widgets.dart'
    show BuildContext, Directionality, TextDirection;

/// A shared, immutable begin→end visual-effect configuration consumed
/// identically by [ACDMotion]'s entrance/exit effects, [ACDAnimatedText]'s
/// per-character effect, and [ACDMotion]'s one-shot tap effect — one typed
/// vocabulary instead of a dozen loose params duplicated per widget.
///
/// Every field describes a linear begin→end change; the owning widget
/// applies its own `duration`/`curve`/`delay` on top. [beginOffsetFactor]/
/// [endOffsetFactor] are size-relative fractions of the animated widget's
/// own size (matching `SlideTransition`'s resolution-independent model, not
/// pixels). [beginBlurSigma]/[endBlurSigma] carry independent X/Y sigma, so
/// an elliptical blur is possible, not just a uniform radius.
final class ACDMotionEffect {
  /// Creates an [ACDMotionEffect]. Every field defaults to its identity
  /// value, so leaving all of them unset produces a no-op effect —
  /// equivalent to [ACDMotionEffect.none].
  const ACDMotionEffect({
    this.beginOpacity = 1,
    this.endOpacity = 1,
    this.beginOffsetFactor = Offset.zero,
    this.endOffsetFactor = Offset.zero,
    this.beginScale = 1,
    this.endScale = 1,
    this.beginRotationTurns = 0,
    this.endRotationTurns = 0,
    this.beginSkewX = 0,
    this.endSkewX = 0,
    this.beginSkewY = 0,
    this.endSkewY = 0,
    this.beginBlurSigma = Offset.zero,
    this.endBlurSigma = Offset.zero,
  });

  /// Starting opacity (`0`–`1`).
  final double beginOpacity;

  /// Ending opacity (`0`–`1`).
  final double endOpacity;

  /// Starting translation, as a fraction of the widget's own size.
  final Offset beginOffsetFactor;

  /// Ending translation, as a fraction of the widget's own size.
  final Offset endOffsetFactor;

  /// Starting scale.
  final double beginScale;

  /// Ending scale.
  final double endScale;

  /// Starting rotation, in turns (matches `RotationTransition`).
  final double beginRotationTurns;

  /// Ending rotation, in turns.
  final double endRotationTurns;

  /// Starting horizontal shear.
  final double beginSkewX;

  /// Ending horizontal shear.
  final double endSkewX;

  /// Starting vertical shear.
  final double beginSkewY;

  /// Ending vertical shear.
  final double endSkewY;

  /// Starting Gaussian blur sigma, independent per axis (`dx`/`dy`).
  final Offset beginBlurSigma;

  /// Ending Gaussian blur sigma, independent per axis (`dx`/`dy`).
  final Offset endBlurSigma;

  /// This effect with every begin/end pair swapped — used to derive a
  /// default exit effect from an entrance effect (and vice versa) when the
  /// caller doesn't supply one explicitly.
  ACDMotionEffect get reversed => ACDMotionEffect(
    beginOpacity: endOpacity,
    endOpacity: beginOpacity,
    beginOffsetFactor: endOffsetFactor,
    endOffsetFactor: beginOffsetFactor,
    beginScale: endScale,
    endScale: beginScale,
    beginRotationTurns: endRotationTurns,
    endRotationTurns: beginRotationTurns,
    beginSkewX: endSkewX,
    endSkewX: beginSkewX,
    beginSkewY: endSkewY,
    endSkewY: beginSkewY,
    beginBlurSigma: endBlurSigma,
    endBlurSigma: beginBlurSigma,
  );

  /// A no-op effect — every field at its identity value.
  static const ACDMotionEffect none = ACDMotionEffect();

  /// Fades in from transparent.
  static const ACDMotionEffect fadeIn = ACDMotionEffect(beginOpacity: 0);

  /// Fades out to transparent.
  static const ACDMotionEffect fadeOut = ACDMotionEffect(endOpacity: 0);

  /// Scales up from nothing.
  static const ACDMotionEffect scaleIn = ACDMotionEffect(beginScale: 0);

  /// Scales up from nothing (alias of [scaleIn]).
  static const ACDMotionEffect scaleUp = scaleIn;

  /// Scales down to nothing.
  static const ACDMotionEffect scaleOut = ACDMotionEffect(endScale: 0);

  /// Scales down to nothing (alias of [scaleOut]).
  static const ACDMotionEffect scaleDown = scaleOut;

  /// Blurs in from [sigma].
  static ACDMotionEffect blurIn({double sigma = 8}) =>
      ACDMotionEffect(beginBlurSigma: Offset(sigma, sigma));

  /// Blurs out to [sigma].
  static ACDMotionEffect blurOut({double sigma = 8}) =>
      ACDMotionEffect(endBlurSigma: Offset(sigma, sigma));

  /// Slides in from below, [distance] widget-heights away (default one full
  /// height). A purely physical (non-`Directionality`-aware) offset —
  /// unlike `ACDSlideAction`'s drag direction, a generic entrance slide has
  /// no inherent "reading direction" to mirror.
  static ACDMotionEffect slideInFromBottom([double distance = 1.0]) =>
      ACDMotionEffect(beginOffsetFactor: Offset(0, distance));

  /// Slides in from above, [distance] widget-heights away.
  static ACDMotionEffect slideInFromTop([double distance = 1.0]) =>
      ACDMotionEffect(beginOffsetFactor: Offset(0, -distance));

  /// Slides in from the left, [distance] widget-widths away.
  static ACDMotionEffect slideInFromLeft([double distance = 1.0]) =>
      ACDMotionEffect(beginOffsetFactor: Offset(-distance, 0));

  /// Slides in from the right, [distance] widget-widths away.
  static ACDMotionEffect slideInFromRight([double distance = 1.0]) =>
      ACDMotionEffect(beginOffsetFactor: Offset(distance, 0));

  /// Slides out downward, [distance] widget-heights away.
  static ACDMotionEffect slideOutToBottom([double distance = 1.0]) =>
      ACDMotionEffect(endOffsetFactor: Offset(0, distance));

  /// Slides out upward, [distance] widget-heights away.
  static ACDMotionEffect slideOutToTop([double distance = 1.0]) =>
      ACDMotionEffect(endOffsetFactor: Offset(0, -distance));

  /// Slides out to the left, [distance] widget-widths away.
  static ACDMotionEffect slideOutToLeft([double distance = 1.0]) =>
      ACDMotionEffect(endOffsetFactor: Offset(-distance, 0));

  /// Slides out to the right, [distance] widget-widths away.
  static ACDMotionEffect slideOutToRight([double distance = 1.0]) =>
      ACDMotionEffect(endOffsetFactor: Offset(distance, 0));

  /// Fades in while sliding up from below, [distance] widget-heights away —
  /// this package's default entrance effect for [ACDMotion]/
  /// [ACDAnimatedText].
  static ACDMotionEffect fadeSlideIn([double distance = 0.3]) =>
      ACDMotionEffect(beginOpacity: 0, beginOffsetFactor: Offset(0, distance));

  /// Fades out while sliding down, [distance] widget-heights away.
  static ACDMotionEffect fadeSlideOut([double distance = 0.3]) =>
      ACDMotionEffect(endOpacity: 0, endOffsetFactor: Offset(0, distance));

  /// Slides in from the reading-direction start (left under LTR, right
  /// under RTL) — resolved from the ambient `Directionality` at [context],
  /// unlike the purely physical [slideInFromLeft]/[slideInFromRight]. The
  /// recommended choice for staggered list/grid items, where entries should
  /// visually flow in from "before" regardless of locale.
  static ACDMotionEffect slideInFromStart(
    BuildContext context, [
    double distance = 1.0,
  ]) => Directionality.of(context) == TextDirection.rtl
      ? slideInFromRight(distance)
      : slideInFromLeft(distance);

  /// Slides in from the reading-direction end (right under LTR, left under
  /// RTL) — see [slideInFromStart].
  static ACDMotionEffect slideInFromEnd(
    BuildContext context, [
    double distance = 1.0,
  ]) => Directionality.of(context) == TextDirection.rtl
      ? slideInFromLeft(distance)
      : slideInFromRight(distance);

  /// Slides out toward the reading-direction start — see [slideInFromStart].
  static ACDMotionEffect slideOutToStart(
    BuildContext context, [
    double distance = 1.0,
  ]) => Directionality.of(context) == TextDirection.rtl
      ? slideOutToRight(distance)
      : slideOutToLeft(distance);

  /// Slides out toward the reading-direction end — see [slideInFromStart].
  static ACDMotionEffect slideOutToEnd(
    BuildContext context, [
    double distance = 1.0,
  ]) => Directionality.of(context) == TextDirection.rtl
      ? slideOutToLeft(distance)
      : slideOutToRight(distance);
}
