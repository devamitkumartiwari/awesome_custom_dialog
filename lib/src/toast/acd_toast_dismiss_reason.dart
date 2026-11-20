/// Why a toast closed — the value of `ACDToastController.closed` (and
/// `ACDDialog.toastClosed`).
enum ACDToastDismissReason {
  /// Its display duration ran out.
  timeout,

  /// The user tapped it (`dismissOnTap`) or its close button.
  user,

  /// The user swiped it away (`dragToDismiss`).
  swipe,

  /// Code closed it: `ACDDialog.dismiss()`, `ACDToastManager.dismissAll()`
  /// / `dismissById()` / `dismissFirst()` / `dismissLast()`.
  programmatic,

  /// A newer toast pushed it out (`cancelPrevious`, or the `dropOldest`
  /// overflow policy).
  replaced,
}
