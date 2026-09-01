/// The lifecycle state of one active toast — exhaustively handled via a
/// `switch` expression wherever it matters, mirroring `ACDPinCellState`'s
/// pattern (`lib/src/pin_field/acd_pin_field_state.dart`).
///
/// Transition order: [ACDToastQueued] → [ACDToastInserted] →
/// [ACDToastShowing] → [ACDToastDismissing] → [ACDToastDisposed]. A toast
/// dismissed while still [ACDToastQueued] (never inserted into the overlay)
/// skips straight to [ACDToastDisposed] — there's nothing to animate out.
sealed class ACDToastLifecycle {
  const ACDToastLifecycle();
}

/// Registered with the manager, but not yet inserted into a stack — either
/// waiting on [ACDToastOverflowPolicy.queue] or a `showDelay`. Dismissable
/// at this stage with no exit animation (nothing is on screen yet).
final class ACDToastQueued extends ACDToastLifecycle {
  /// Creates an [ACDToastQueued] state.
  const ACDToastQueued();
}

/// Inserted into its position's stack; its entrance `AnimationController`
/// has been created and is running or has just completed.
final class ACDToastInserted extends ACDToastLifecycle {
  /// Creates an [ACDToastInserted] state.
  const ACDToastInserted();
}

/// Fully visible; its auto-dismiss timer (if any) is running.
final class ACDToastShowing extends ACDToastLifecycle {
  /// Creates an [ACDToastShowing] state.
  const ACDToastShowing();
}

/// Playing its exit transition (or already skipped it via `immediate:
/// true`). [ACDToastController.requestDismiss] is a no-op once a toast
/// reaches this state, so a racing timer and manual dismiss can't
/// double-fire.
final class ACDToastDismissing extends ACDToastLifecycle {
  /// Creates an [ACDToastDismissing] state.
  const ACDToastDismissing();
}

/// Fully torn down — its `Timer`/`AnimationController` have been disposed
/// exactly once and it has been removed from the manager's registry.
final class ACDToastDisposed extends ACDToastLifecycle {
  /// Creates an [ACDToastDisposed] state.
  const ACDToastDisposed();
}
