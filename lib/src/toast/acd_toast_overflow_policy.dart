/// Governs what happens when a toast is shown at a position that already
/// has `ACDToastConfig.maxVisible` toasts visible.
enum ACDToastOverflowPolicy {
  /// Hold the newest toast back until a slot frees up, then promote the
  /// oldest queued one (the default).
  queue,

  /// Immediately dismiss the oldest visible toast to make room.
  dropOldest,

  /// Ignore `maxVisible` — show every toast immediately.
  unlimited,
}
