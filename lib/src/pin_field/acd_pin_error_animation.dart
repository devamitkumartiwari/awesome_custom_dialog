/// How an `ACDPinField` reacts when an error appears.
enum ACDPinErrorAnimation {
  /// A short horizontal shake (skipped under reduce motion) — the default.
  shake,

  /// No motion; only the error colours/text.
  none,
}
