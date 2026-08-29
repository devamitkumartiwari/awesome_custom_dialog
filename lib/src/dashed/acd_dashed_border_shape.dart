/// The outline shape an [ACDDashedBorder] paints around its child.
enum ACDDashedBorderShape {
  /// A dashed rectangle with square corners.
  rect,

  /// A dashed rectangle with rounded corners (see `borderRadius`).
  roundedRect,

  /// A dashed oval inscribed in the child's bounds.
  oval,

  /// A dashed circle inscribed in the child's bounds.
  circle,

  /// A dashed outline of a caller-supplied `Path`, via `customPathBuilder`.
  customPath,
}
