import 'dart:async';

import 'package:flutter/material.dart';

import 'acd_toast_config.dart';
import 'acd_toast_lifecycle.dart';

/// The single source of truth for one active toast's lifecycle. Owns its
/// `Timer`/`AnimationController`s and is the only place either gets
/// disposed — both the auto-dismiss timer firing and a manual/drag/
/// dismiss-all call go through [requestDismiss], which is a no-op once
/// already dismissing/disposed, so the two can never race into a
/// double-dispose.
class ACDToastController {
  /// Creates an [ACDToastController] for [config], identified by [id].
  ACDToastController({required this.id, required this.config, this.onChanged});

  /// Identifies this toast for `ACDToastManager.findById`/`dismissById`.
  final String id;

  /// This toast's fully-resolved configuration.
  ACDToastConfig config;

  /// Invoked whenever [state] changes, so the owning `ACDToastStack` can
  /// rebuild.
  VoidCallback? onChanged;

  /// This toast's current lifecycle state.
  ACDToastLifecycle state = const ACDToastQueued();

  /// The entrance/exit transition controller — created by `ACDToastStack`
  /// once this toast leaves [ACDToastQueued], disposed by this controller
  /// exactly once in [dispose].
  AnimationController? animationController;

  /// Drives the progress bar, mirroring the auto-dismiss timer. Also owned
  /// by `ACDToastStack`, disposed alongside [animationController].
  AnimationController? progressController;

  Timer? _timer;
  Stopwatch? _stopwatch;
  Duration? _remaining;
  bool _disposed = false;

  /// Whether this toast is already tearing down or torn down — used to make
  /// [requestDismiss] idempotent.
  bool get isDismissing =>
      state is ACDToastDismissing || state is ACDToastDisposed;

  /// Transitions [ACDToastQueued] → [ACDToastInserted]. A no-op once past
  /// that state.
  void markInserted() {
    if (state is! ACDToastQueued) return;
    state = const ACDToastInserted();
    onChanged?.call();
  }

  /// Transitions to [ACDToastShowing], fires `onShown`, and starts the
  /// auto-dismiss timer (if configured). Called once the entrance
  /// transition completes.
  void markShowing() {
    if (isDismissing) return;
    state = const ACDToastShowing();
    onChanged?.call();
    config.onShown?.call();
    _startAutoDismiss();
  }

  void _startAutoDismiss() {
    final Duration? total = config.autoDismissAfter;
    // Duration.zero is the sticky sentinel (see ACDToastConfig.autoDismissAfter)
    // — plain `null` can't mean "no timer" here since it means "inherit from
    // the base config" everywhere else in the resolve chain.
    if (total == null || total == Duration.zero) return;
    _remaining = total;
    _stopwatch = Stopwatch()..start();
    _timer = Timer(total, () => requestDismiss(auto: true));
    progressController
      ?..duration = total
      ..forward(from: 0.0);
  }

  /// Freezes the auto-dismiss timer and progress bar at their current
  /// position — used for pause-on-hover and app-lifecycle backgrounding.
  /// A no-op for sticky toasts (no timer to pause) or once dismissing.
  void pause() {
    if (_timer == null || _stopwatch == null || isDismissing) return;
    _timer!.cancel();
    _timer = null;
    final Duration elapsed = _stopwatch!.elapsed;
    _stopwatch!.stop();
    final Duration remaining = _remaining! - elapsed;
    _remaining = remaining.isNegative ? Duration.zero : remaining;
    progressController?.stop();
  }

  /// Resumes a [pause]d auto-dismiss timer/progress bar with whatever
  /// duration was left. A no-op if nothing was paused, or once dismissing.
  void resume() {
    if (_remaining == null || _timer != null || isDismissing) return;
    final Duration remaining = _remaining!;
    _stopwatch = Stopwatch()..start();
    _timer = Timer(remaining, () => requestDismiss(auto: true));
    progressController?.animateTo(1.0, duration: remaining);
  }

  /// Requests this toast be dismissed. Idempotent — a second call (e.g. the
  /// auto-dismiss timer firing while a manual dismiss is already in
  /// flight) is a no-op. Pass `immediate: true` to skip the exit animation
  /// (e.g. drag-to-dismiss, which already animated its own removal).
  Future<void> requestDismiss({
    bool immediate = false,
    bool auto = false,
  }) async {
    if (isDismissing) return;
    _timer?.cancel();
    _timer = null;
    state = const ACDToastDismissing();
    onChanged?.call();
    if (auto) config.onAutoDismiss?.call();

    if (!immediate && animationController != null) {
      try {
        await animationController!.reverse();
      } on TickerCanceled {
        // The owning widget was torn down mid-animation — fine, proceed to
        // dispose below regardless.
      }
    }
    dispose();
  }

  /// Tears down every resource this controller owns. Guarded so it only
  /// ever runs once, however it's reached (timer, manual dismiss, drag,
  /// dismissAll, or the stack widget disposing directly).
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    state = const ACDToastDisposed();
    _timer?.cancel();
    _timer = null;
    animationController?.dispose();
    animationController = null;
    progressController?.dispose();
    progressController = null;
    config.onDismissed?.call();
    onChanged?.call();
  }
}
