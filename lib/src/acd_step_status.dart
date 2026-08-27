/// A step's position relative to `activeStep` in an [ACDStepper] (or the
/// per-item status in [ACDStepperListView]).
enum ACDStepStatus {
  /// Comes after the active step — not yet reached.
  upcoming,

  /// The current step.
  active,

  /// Comes before the active step — already completed.
  finished,
}
