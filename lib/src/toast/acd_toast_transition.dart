import 'package:flutter/material.dart';

import '../core/acd_animation.dart';

/// Drives a toast's entrance **and** exit transition from a real
/// `AnimationController` (owned by the caller — see `ACDToastStack`),
/// unlike `ACDOverlayTransition` (used by `.snackbar()`/other overlay
/// dialogs), whose own doc comment notes exit animation is out of scope
/// there. `controller.forward()` plays the entrance; `controller.reverse()`
/// (awaited by `ACDToastController.requestDismiss`) plays the exit using
/// the same curve/offsets in reverse.
class ACDToastTransition extends StatelessWidget {
  /// Creates an [ACDToastTransition].
  const ACDToastTransition({
    super.key,
    required this.controller,
    required this.animatedFunc,
    required this.child,
  });

  /// Drives the transition; `0.0` is fully hidden, `1.0` fully shown.
  final AnimationController controller;

  /// Renders [child] at the controller's current value. Falls back to a
  /// fade if `null`.
  final Function(Widget, Animation<double>)? animatedFunc;

  /// The toast card.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Function(Widget, Animation<double>) fn =
        animatedFunc ??
        (child, anim) => FadeTransition(opacity: anim, child: child);
    return fn(child, controller);
  }
}

/// Resolves an entrance/exit [ACDAnimation] preset to the
/// `Function(Widget, Animation<double>)` shape [ACDToastTransition] expects,
/// mirroring `acdPresetAnimFn` (`lib/src/core/acd_animation.dart`) but kept
/// toast-local since exit-direction presets (e.g. mirroring `slideUp` on the
/// way out) are specific to this two-directional use.
Function(Widget, Animation<double>) acdToastPresetAnimFn(
  ACDAnimation anim, [
  TextDirection textDirection = TextDirection.ltr,
]) {
  final bool rtl = textDirection == TextDirection.rtl;
  return switch (anim) {
    ACDAnimation.none => (child, _) => child,
    ACDAnimation.fade => (child, anim) => FadeTransition(
      opacity: anim,
      child: child,
    ),
    ACDAnimation.scale => (child, anim) => ScaleTransition(
      scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
      child: child,
    ),
    ACDAnimation.bounce => (child, anim) => ScaleTransition(
      scale: CurvedAnimation(parent: anim, curve: Curves.bounceOut),
      child: child,
    ),
    ACDAnimation.slideUp => (child, anim) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
      child: FadeTransition(opacity: anim, child: child),
    ),
    ACDAnimation.slideDown => (child, anim) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
      child: FadeTransition(opacity: anim, child: child),
    ),
    ACDAnimation.slideLeft => (child, anim) => SlideTransition(
      position: Tween<Offset>(
        begin: Offset(rtl ? -1 : 1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
      child: FadeTransition(opacity: anim, child: child),
    ),
    ACDAnimation.slideRight => (child, anim) => SlideTransition(
      position: Tween<Offset>(
        begin: Offset(rtl ? 1 : -1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
      child: FadeTransition(opacity: anim, child: child),
    ),
    ACDAnimation.rotate => (child, anim) => RotationTransition(
      turns: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: FadeTransition(opacity: anim, child: child),
    ),
  };
}
