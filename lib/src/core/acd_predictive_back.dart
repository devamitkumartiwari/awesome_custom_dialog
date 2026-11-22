import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PredictiveBackEvent, SwipeEdge;
import 'package:material_ui/material_ui.dart';

import '../design/internal/acd_platform_support.dart';

/// Internal: Android predictive back for a dialog route.
///
/// Flutter animates predictive back for *pages*
/// (`PredictiveBackPageTransitionsBuilder`), but a dialog would just vanish
/// when the gesture commits. This listens to the same back-gesture events
/// and, while the user swipes, shrinks the dialog toward 90 % and nudges it
/// 8 dp toward the swipe — the Material 3 predictive-back treatment for
/// dialogs. Releasing past the threshold pops the route (its normal exit
/// plays from the shrunken state); cancelling eases it back.
///
/// Only claims the gesture on Android, when its route is the current one and
/// allows popping (`PopScope(canPop: false)` opts out), and not under reduce
/// motion — otherwise the system back behaves exactly as before.
class ACDPredictiveBackDialog extends StatefulWidget {
  /// Creates the wrapper.
  const ACDPredictiveBackDialog({
    super.key,
    required this.enabled,
    required this.child,
  });

  /// Whether to animate at all (e.g. off for the Cupertino design).
  final bool enabled;

  /// The dialog content.
  final Widget child;

  @override
  State<ACDPredictiveBackDialog> createState() =>
      _ACDPredictiveBackDialogState();
}

class _ACDPredictiveBackDialogState extends State<ACDPredictiveBackDialog>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // Gesture progress, 0 (at rest) → 1 (fully swiped).
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  bool _active = false;
  SwipeEdge _edge = SwipeEdge.left;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progress.dispose();
    super.dispose();
  }

  bool get _eligible {
    if (!widget.enabled || !mounted) return false;
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    if (acdReduceMotion(context)) return false;
    final ModalRoute<Object?>? route = ModalRoute.of(context);
    return route != null && route.isCurrent && route.popGestureEnabled;
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (!_eligible) return false;
    _active = true;
    _edge = backEvent.swipeEdge;
    _progress.value = backEvent.progress;
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    if (_active) _progress.value = backEvent.progress;
  }

  @override
  void handleCancelBackGesture() {
    if (!_active) return;
    _active = false;
    _progress.animateBack(0, curve: Curves.easeOutCubic);
  }

  @override
  void handleCommitBackGesture() {
    if (!_active) return;
    _active = false;
    // Keep the shrunken pose: the route's exit transition continues from it.
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        final double p = Curves.easeOut.transform(_progress.value);
        final double direction = _edge == SwipeEdge.left ? 1 : -1;
        return Transform.translate(
          offset: Offset(direction * 8 * p, 0),
          child: Transform.scale(scale: 1 - 0.1 * p, child: child),
        );
      },
      child: widget.child,
    );
  }
}
