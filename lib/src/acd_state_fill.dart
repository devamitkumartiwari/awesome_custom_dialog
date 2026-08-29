import 'package:flutter/material.dart';

/// Resolves the effective fill for a widget surface with active/inactive/
/// disabled color and gradient variants layered over a shared base
/// fallback. A resolved gradient always wins over a resolved color for the
/// same state.
///
/// Internal to the package: shared by [ACDSwitch] and [ACDRatingBar] so the
/// active/inactive/disabled → color/gradient resolution this package's
/// widgets already repeat several times over (see `ACDSlideAction`'s track
/// and thumb color/gradient trios) is written once.
({Color? color, Gradient? gradient}) acdResolveStateFill({
  required bool active,
  bool enabled = true,
  Color? color,
  Color? activeColor,
  Color? inactiveColor,
  Color? disabledColor,
  Gradient? gradient,
  Gradient? activeGradient,
  Gradient? inactiveGradient,
}) {
  if (!enabled) {
    return (color: disabledColor ?? color, gradient: null);
  }
  final Gradient? effectiveGradient =
      (active ? activeGradient : inactiveGradient) ?? gradient;
  if (effectiveGradient != null) {
    return (color: null, gradient: effectiveGradient);
  }
  final Color? effectiveColor = (active ? activeColor : inactiveColor) ?? color;
  return (color: effectiveColor, gradient: null);
}
