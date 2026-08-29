/// How an [ACDMotionSequence]/[ACDAnimatedTextSequence] advances between
/// steps.
enum ACDMotionSequenceTrigger {
  /// Steps advance automatically after each step's `duration` (plus its
  /// `holdDuration`) elapses.
  auto,

  /// Steps advance only when the sequence is tapped.
  tap,
}
