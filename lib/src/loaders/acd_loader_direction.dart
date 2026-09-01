/// Which way a loader fills as its value increases.
enum ACDLoaderDirection {
  /// Left-to-right (linear) or clockwise from [ACDCircularPercentIndicator.startAngle]
  /// (circular) — the default.
  forward,

  /// Right-to-left (linear) or counter-clockwise (circular).
  reverse,
}
