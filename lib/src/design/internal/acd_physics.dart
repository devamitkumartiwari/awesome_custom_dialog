import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

/// The spring used when a dragged thumb (switch, slide action) is released:
/// lightly under-damped, so a fling settles with a hint of follow-through
/// but no visible bounce.
final SpringDescription acdThumbSpring = SpringDescription.withDampingRatio(
  mass: 1,
  stiffness: 500,
  ratio: 0.85,
);

/// Settles [controller] (a 0..1 progress) at [target], carrying the release
/// [velocity] (in progress-units per second) into a spring — or jumps
/// straight there under reduce motion.
///
/// Returns a future that completes when the motion ends, including when it
/// is interrupted (never strands an `await`).
Future<void> acdSettle(
  AnimationController controller, {
  required double target,
  double velocity = 0,
  required bool reduceMotion,
}) async {
  controller.stop();
  if (reduceMotion || controller.value == target && velocity == 0) {
    controller.value = target;
    return;
  }
  try {
    await controller
        .animateWith(
          SpringSimulation(
            acdThumbSpring,
            controller.value,
            target,
            velocity,
            // The controller clamps to 0..1; end once visually at rest.
            tolerance: const Tolerance(distance: 0.001, velocity: 0.01),
          ),
        )
        .orCancel;
  } on TickerCanceled {
    // Superseded by a newer drag/settle or dispose.
  }
}
