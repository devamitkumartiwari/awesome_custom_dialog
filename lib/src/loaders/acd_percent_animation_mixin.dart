import 'package:material_ui/material_ui.dart';

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

  CurvedAnimation? _curved;
  Animation<double>? _animation;
  VoidCallback? _listener;

  /// Detaches the in-flight run's listener and disposes its
  /// [CurvedAnimation]. Required because retargeting `stop()`s the
  /// controller, which cancels the previous `forward()` — whose plain future
  /// then never completes, so cleanup placed after `await` would never run.
  void _detachPercentAnimation() {
    if (_listener != null) _animation?.removeListener(_listener!);
    _curved?.dispose();
    _curved = null;
    _animation = null;
    _listener = null;
  }

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

    _detachPercentAnimation();
    if (!animate || duration == Duration.zero) {
      _percentAnimController?.stop();
      setState(() => currentAnimatedPercent = clampedTarget);
      onTick?.call(currentAnimatedPercent);
      return;
    }

    _controller
      ..stop()
      ..duration = duration
      ..value = 0;
    final CurvedAnimation curved = CurvedAnimation(
      parent: _controller,
      curve: curve,
    );
    final Animation<double> animation = Tween<double>(
      begin: begin,
      end: clampedTarget,
    ).animate(curved);
    void listener() {
      if (mounted) setState(() => currentAnimatedPercent = animation.value);
      onTick?.call(animation.value);
    }

    _curved = curved;
    _animation = animation;
    _listener = listener;
    animation.addListener(listener);
    try {
      await _controller.forward().orCancel;
    } on TickerCanceled {
      // Superseded by a newer run (or disposed) — that path cleans up.
    } finally {
      if (identical(_animation, animation)) _detachPercentAnimation();
    }
  }

  /// Releases the shared [AnimationController], if one was ever created —
  /// call from `dispose`.
  void disposePercentAnimation() {
    _detachPercentAnimation();
    _percentAnimController?.dispose();
  }
}
