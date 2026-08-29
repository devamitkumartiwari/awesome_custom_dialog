import 'package:flutter/material.dart';

// FEAT-15/FEAT-16: drives the entrance animation for overlay-mode
// presentation without a route-provided AnimationController (none exists
// outside showGeneralDialog); reuses the same
// Function(Widget, Animation<double>) shape acdPresetAnimFn already produces.
// Exit animation is out of scope for v1 — dismiss() removes the
// OverlayEntry immediately.
//
// Core-internal only: not exported from the package barrel.
class ACDOverlayTransition extends StatelessWidget {
  const ACDOverlayTransition({
    super.key,
    required this.duration,
    required this.animatedFunc,
    required this.child,
  });

  final Duration duration;
  final Function(Widget, Animation<double>)? animatedFunc;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (animatedFunc == null) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, childWidget) =>
          animatedFunc!(childWidget!, AlwaysStoppedAnimation<double>(value)),
      child: child,
    );
  }
}
