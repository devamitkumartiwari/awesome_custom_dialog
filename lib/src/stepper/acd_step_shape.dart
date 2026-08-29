/// The default step marker shape an [ACDStepper] paints, when [ACDStepper]'s
/// `customStep` builder isn't supplied.
enum ACDStepShape {
  /// A circular marker.
  circle,

  /// A rounded-rectangle marker — corner rounding via `stepBorderRadius`.
  roundedRectangle,
}
