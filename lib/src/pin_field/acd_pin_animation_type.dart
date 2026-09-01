/// The entry animation played in a cell when a new digit is typed into it.
enum ACDPinAnimationType {
  /// No entry animation.
  none,

  /// Scales in from nothing.
  scale,

  /// Fades in.
  fade,

  /// Slides in from [ACDPinField.slideTransitionBeginOffset].
  slide,

  /// Rotates in.
  rotation,
}
