/// The outline shape an [ACDDottedDecoration] paints.
enum ACDDottedShape {
  /// A single dashed edge, positioned per `linePosition`.
  line,

  /// A dashed rectangle (optionally rounded via `borderRadius`).
  box,

  /// A dashed oval inscribed in the decorated box.
  oval,
}
