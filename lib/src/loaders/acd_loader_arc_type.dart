/// Convenience presets for [ACDCircularPercentIndicator]'s arc extent —
/// shortcuts for common [ACDCircularPercentIndicator.startAngle]/
/// [ACDCircularPercentIndicator.sweepAngle]/[ACDCircularPercentIndicator.reverse]
/// combinations. Set [ACDCircularPercentIndicator.arcType] to `null` (the
/// default) to use `startAngle`/`sweepAngle`/`reverse` directly instead.
enum ACDLoaderArcType {
  /// A full 360° ring/pie, starting at [ACDCircularPercentIndicator.startAngle].
  full,

  /// A 180° half ring/pie, starting at [ACDCircularPercentIndicator.startAngle].
  half,

  /// A full 360° ring/pie filled in [ACDLoaderDirection.reverse].
  fullReversed,
}
