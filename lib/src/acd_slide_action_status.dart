/// The lifecycle of an [ACDSlideAction] — reported by [ACDSlideActionController].
enum ACDSlideActionStatus {
  /// At rest, ready to be dragged.
  idle,

  /// Being actively dragged by the user.
  dragging,

  /// Confirmed; waiting on the caller's async work (set via `controller.loading()`).
  loading,

  /// The caller's async work finished successfully (set via `controller.success()`).
  success,
}
