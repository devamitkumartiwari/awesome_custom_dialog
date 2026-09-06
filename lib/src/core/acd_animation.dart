import 'package:flutter/material.dart';

/// Built-in entrance/exit transitions for [ACDDialog], [ACDDialog.toast],
/// and [ACDDialog.snackbar]. Assign to `ACDDialog.animation`.
enum ACDAnimation {
  /// No transition — the dialog appears instantly.
  none,

  /// Fades in/out.
  fade,

  /// Scales up from the center with an overshoot curve.
  scale,

  /// Slides up from below the dialog's final position.
  slideUp,

  /// Slides down from above the dialog's final position.
  slideDown,

  /// Slides in from the right.
  slideLeft,

  /// Slides in from the left.
  slideRight,

  /// Scales up with a springy bounce curve.
  bounce,

  /// Spins in a full turn while appearing.
  rotate,
}

// FEAT-08: map enum to animation function
//
// textDirection resolves slideLeft/slideRight to "visual start"/"visual end"
// under RTL, matching acdResolveGravityForDirection's mirroring of
// left/right-flavored gravities — without this, a dialog's slide-in
// direction would silently disagree with its (already RTL-aware) docking
// side under right-to-left locales.
Function(Widget, Animation<double>) acdPresetAnimFn(
  ACDAnimation anim, [
  TextDirection textDirection = TextDirection.ltr,
]) {
  final bool rtl = textDirection == TextDirection.rtl;
  switch (anim) {
    case ACDAnimation.fade:
      return (child, anim) => FadeTransition(opacity: anim, child: child);

    case ACDAnimation.scale:
      return (child, anim) => ScaleTransition(
        scale: Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
        child: child,
      );

    case ACDAnimation.bounce:
      return (child, anim) => ScaleTransition(
        scale: Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.bounceOut)),
        child: child,
      );

    case ACDAnimation.slideUp:
      return (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      );

    case ACDAnimation.slideDown:
      return (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      );

    case ACDAnimation.slideLeft:
      return (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: Offset(rtl ? -1 : 1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      );

    case ACDAnimation.slideRight:
      return (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: Offset(rtl ? 1 : -1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      );

    case ACDAnimation.rotate:
      return (child, anim) => RotationTransition(
        turns: Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      );

    case ACDAnimation.none:
      return (child, anim) => child;
  }
}
