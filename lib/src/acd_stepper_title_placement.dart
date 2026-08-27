/// Where an [ACDStepper] places each step's title, when `direction` is
/// `Axis.vertical`. Ignored for `Axis.horizontal`, where titles always sit
/// below the step marker.
enum ACDStepperTitlePlacement {
  /// Title sits beside the step marker.
  side,

  /// Title sits below the step marker.
  below,
}
