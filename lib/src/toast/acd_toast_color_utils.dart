import 'package:flutter/material.dart';

/// Returns [color] with its alpha channel replaced by [alpha] (`0.0`-`1.0`).
///
/// Every alpha/opacity color computation in the toast subsystem goes through
/// this one function — isolating the package from Flutter's periodic
/// `Color.withOpacity` → `Color.withValues` API churn to a single place.
/// Deliberately never derives a `MaterialColor` swatch from [color] — a
/// user-supplied color must always render exactly as given.
Color acdToastColorWithAlpha(Color color, double alpha) {
  return color.withValues(alpha: alpha.clamp(0.0, 1.0));
}
