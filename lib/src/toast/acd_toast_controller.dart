import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../core/acd_content_type.dart';
import 'acd_toast_config.dart';
import 'acd_toast_dismiss_reason.dart';
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
  final Completer<ACDToastDismissReason> _closed =
      Completer<ACDToastDismissReason>();
  ACDToastDismissReason _reason = ACDToastDismissReason.programmatic;

  /// Completes exactly once, when this toast is gone, with why it closed —
  /// `await` it to sequence work after a toast (e.g. undo windows).
  Future<ACDToastDismissReason> get closed => _closed.future;
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
    // Start the timer first: a throwing onShown must not make the toast
    // sticky by accident.
    _startAutoDismiss();
    _guard('onShown', config.onShown);
  }

  /// Set by the stack when a screen reader is navigating and this toast
  /// has actions: the auto-dismiss timer is skipped so the actions stay
  /// reachable.
  bool holdForAccessibility = false;

  void _startAutoDismiss() {
    if (holdForAccessibility) return;
    final Duration? total = config.autoDismissAfter;
    // Duration.zero is the sticky sentinel (see ACDToastConfig.autoDismissAfter)
    // — plain `null` can't mean "no timer" here since it means "inherit from
    // the base config" everywhere else in the resolve chain.
    if (total == null || total == Duration.zero) return;
    _remaining = total;
    _stopwatch = Stopwatch()..start();
    _timer = Timer(
      total,
      () => requestDismiss(reason: ACDToastDismissReason.timeout),
    );
    progressController
      ?..duration = total
      ..forward(from: 0.0);
  }

  /// Changes this toast in place — its message, look or timing — without
  /// replacing it (no exit/entrance animation, same position in the stack).
  /// A new [autoDismissAfter] restarts the timer from now
  /// (`Duration.zero` makes it sticky); otherwise a running timer restarts
  /// with the current duration when [restartTimer] is `true` (the default),
  /// so the updated content gets its full reading time.
  ///
  /// A no-op once the toast is dismissing. Used by promise toasts
  /// (loading → success/error).
  void update({
    String? message,
    ACDContentType? contentType,
    IconData? icon,
    bool? showIcon,
    bool? showLoadingIndicator,
    Color? backgroundColor,
    Color? textColor,
    List<Widget>? actions,
    Duration? autoDismissAfter,
    bool restartTimer = true,
  }) {
    if (isDismissing) return;
    config = config.copyWith(
      message: message,
      contentType: contentType,
      icon: icon,
      showIcon: showIcon,
      showLoadingIndicator: showLoadingIndicator,
      backgroundColor: backgroundColor,
      textColor: textColor,
      actions: actions,
      autoDismissAfter: autoDismissAfter,
    );
    if (actions != null) {
      holdForAccessibility =
          actions.isNotEmpty &&
          WidgetsBinding
              .instance
              .platformDispatcher
              .accessibilityFeatures
              .accessibleNavigation;
    }
    if (state is ACDToastShowing &&
        (restartTimer || autoDismissAfter != null)) {
      _timer?.cancel();
      _timer = null;
      _remaining = null;
      _stopwatch = null;
      _startAutoDismiss();
    }
    onChanged?.call();
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
    _timer = Timer(
      remaining,
      () => requestDismiss(reason: ACDToastDismissReason.timeout),
    );
    progressController?.animateTo(1.0, duration: remaining);
  }

  /// Requests this toast be dismissed. Idempotent — a second call (e.g. the
  /// auto-dismiss timer firing while a manual dismiss is already in
  /// flight) is a no-op. Pass `immediate: true` to skip the exit animation
  /// (e.g. drag-to-dismiss, which already animated its own removal).
  /// [reason] is what [closed] completes with (the first request wins).
  /// The deprecated [auto] flag is the same as
  /// `reason: ACDToastDismissReason.timeout`.
  Future<void> requestDismiss({
    bool immediate = false,
    @Deprecated('Use reason: ACDToastDismissReason.timeout') bool auto = false,
    ACDToastDismissReason reason = ACDToastDismissReason.programmatic,
  }) async {
    if (isDismissing) return;
    if (auto) reason = ACDToastDismissReason.timeout;
    _reason = reason;
    final bool timedOut = reason == ACDToastDismissReason.timeout;
    _timer?.cancel();
    _timer = null;
    state = const ACDToastDismissing();
    onChanged?.call();
    if (timedOut) _guard('onAutoDismiss', config.onAutoDismiss);

    if (!immediate && animationController != null) {
      try {
        // orCancel: a plain TickerFuture never completes when cancelled,
        // which would strand this dismiss (and skip dispose below).
        await animationController!.reverse().orCancel;
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
    // A throwing onDismissed must not strand `closed` or leave this
    // disposed controller registered with its stack.
    _guard('onDismissed', config.onDismissed);
    if (!_closed.isCompleted) _closed.complete(_reason);
    onChanged?.call();
  }

  /// Runs a user callback so an exception is reported (like any framework
  /// callback error) instead of aborting this lifecycle transition.
  void _guard(String name, VoidCallback? callback) {
    if (callback == null) return;
    try {
      callback();
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'awesome_custom_dialog',
          context: ErrorDescription("while calling a toast's $name callback"),
        ),
      );
    }
  }
}
