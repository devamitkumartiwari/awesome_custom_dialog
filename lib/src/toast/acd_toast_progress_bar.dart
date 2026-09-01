import 'package:flutter/material.dart';

/// A thin countdown bar tracking a toast's auto-dismiss timer. Purely
/// presentational — [controller] (owned and driven by `ACDToastController`)
/// supplies the animated value; this widget never starts/stops it itself,
/// so pause-on-hover and app-lifecycle pausing (which stop/resume that same
/// controller) are reflected automatically.
class ACDToastProgressBar extends StatelessWidget {
  /// Creates an [ACDToastProgressBar].
  const ACDToastProgressBar({
    super.key,
    required this.controller,
    required this.color,
    this.trackColor,
    this.height = 3.0,
  });

  /// Drives the filled fraction, `0.0`-`1.0`.
  final Animation<double> controller;

  /// Fill color.
  final Color color;

  /// Track (background) color. Falls back to [color] at low opacity.
  final Color? trackColor;

  /// Bar thickness.
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Container(
        height: height,
        color: trackColor ?? color.withValues(alpha: 0.25),
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          widthFactor: controller.value.clamp(0.0, 1.0),
          child: Container(color: color),
        ),
      ),
    );
  }
}
