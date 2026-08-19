/// How long a toast stays on screen before auto-dismissing. Pass to
/// `ACDDialog.toast(length: ...)` as a shortcut for `showDuration`.
enum ACDToastLength {
  /// About 2 seconds.
  short,

  /// About 3.5 seconds.
  long,
}

/// Resolves an [ACDToastLength] to its actual [Duration].
extension ACDToastLengthX on ACDToastLength {
  /// The duration this length represents.
  Duration get duration => switch (this) {
    ACDToastLength.short => const Duration(milliseconds: 2000),
    ACDToastLength.long => const Duration(milliseconds: 3500),
  };
}
