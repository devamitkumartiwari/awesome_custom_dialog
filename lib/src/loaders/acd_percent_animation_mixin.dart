import 'package:flutter/material.dart';

/// Internal to the package: shared animation lifecycle for every percent
/// loader in this folder ([ACDLinearPercentIndicator],
/// [ACDCircularPercentIndicator], and per-segment in
/// [ACDMultiSegmentLinearIndicator]).
///
/// [animateToPercent] always tweens from the *current live* animated value
/// to the new target — never from a hardcoded `0` — so a value change mid
/// rebuild animates its actual delta instead of visibly restarting. This is
/// also the one place an [AnimationController] is created and disposed for
/// this whole widget family, so every loader built on this mixin gets
/// correct cleanup for free.
mixin ACDPercentAnimationMixin<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  AnimationController? _percentAnimController;

  AnimationController get _controller =>
      _percentAnimController ??= AnimationController(vsync: this);

  /// The most recently animated value, read by the painter/build method.
  double currentAnimatedPercent = 0;

  Animation<double>? _animation;

  /// Seeds [currentAnimatedPercent] without animating — call once from
  /// `initState`.
  void initPercentAnimation(double startPercent) {
    currentAnimatedPercent = startPercent.clamp(0.0, 1.0);
  }

  /// Animates [currentAnimatedPercent] from its current value to [target]
  /// (clamped `0.0`–`1.0`). Skips the tween entirely — an immediate
  /// `setState` jump — when [animate] is `false` or [duration] is
  /// [Duration.zero], so a zero-length [AnimationController]/[Tween] is
  /// never constructed.
  Future<void> animateToPercent(
    double target, {
    required Duration duration,
    required Curve curve,
    required bool animate,
    ValueChanged<double>? onTick,
  }) async {
    if (!mounted) return;
    final double clampedTarget = target.clamp(0.0, 1.0);
    final double begin = currentAnimatedPercent;
    if (begin == clampedTarget) return;

    if (!animate || duration == Duration.zero) {
      setState(() => currentAnimatedPercent = clampedTarget);
      onTick?.call(currentAnimatedPercent);
      return;
    }

    _controller
      ..stop()
      ..duration = duration
      ..value = 0;
    final Animation<double> animation = Tween<double>(
      begin: begin,
      end: clampedTarget,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));
    _animation = animation;
    void listener() {
      if (mounted) setState(() => currentAnimatedPercent = animation.value);
      onTick?.call(animation.value);
    }

    animation.addListener(listener);
    try {
      await _controller.forward();
    } finally {
      animation.removeListener(listener);
      if (identical(_animation, animation)) _animation = null;
    }
  }

  /// Releases the shared [AnimationController], if one was ever created —
  /// call from `dispose`.
  void disposePercentAnimation() {
    _percentAnimController?.dispose();
  }
}
