/// Visibility rule for a toast's close button.
enum ACDToastCloseButtonMode {
  /// No close button — and no space is reserved for one either (a hidden
  /// `always` button previously left a leftover gap; this mode removes the
  /// slot from layout entirely).
  never,

  /// Always visible.
  always,

  /// Only visible while the pointer hovers the toast (desktop/web). Touch
  /// platforms never see a hover event, so prefer [always] or [never] for
  /// touch-only apps.
  onHover,
}
