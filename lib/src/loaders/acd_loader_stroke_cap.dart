/// How the ends of a loader's stroke are drawn.
///
/// [square] only affects [ACDCircularPercentIndicator]-style ring/arc
/// strokes (it maps to [StrokeCap.square]); [roundAll] only affects
/// bar-shaped loaders ([ACDLinearPercentIndicator],
/// [ACDMultiSegmentLinearIndicator]), rounding every corner of the bar
/// (including the background) rather than just the leading progress edge.
enum ACDLoaderStrokeCap {
  /// Flat, unrounded ends — the default.
  butt,

  /// Rounded leading/trailing progress edge.
  round,

  /// Square-projected ends. Circular loaders only; treated as [butt] on bar
  /// loaders.
  square,

  /// Rounds every corner of the bar, background included. Bar loaders only;
  /// treated as [round] on circular loaders.
  roundAll,
}
