import 'dart:ui';

/// Walks [source]'s path metrics and returns the dashed version implied by
/// [pattern] — an alternating dash-length/gap-length list (must be
/// non-empty, even in length, and every entry positive), repeated for the
/// path's full length. [phase] shifts the starting offset into the pattern.
///
/// Rounded dash caps are not this function's concern — apply
/// `Paint()..strokeCap = StrokeCap.round` at the call site instead.
///
/// Internal to the package: shared by [ACDDashedLine], [ACDDottedDecoration],
/// and [ACDDashedBorder] so the segment-interpolation math is written once.
Path acdDashPath(
  Path source, {
  required List<double> pattern,
  double phase = 0.0,
}) {
  assert(pattern.isNotEmpty, 'pattern must not be empty');
  assert(pattern.length.isEven, 'pattern must have an even length');
  assert(pattern.every((d) => d > 0), 'pattern entries must be positive');

  final Path dest = Path();
  for (final PathMetric metric in source.computeMetrics()) {
    double distance = phase % pattern.reduce((a, b) => a + b);
    int patternIndex = 0;
    // Fast-forward the starting pattern index/offset for a non-zero phase.
    while (distance >= pattern[patternIndex]) {
      distance -= pattern[patternIndex];
      patternIndex = (patternIndex + 1) % pattern.length;
    }

    double start = -distance;
    bool draw = patternIndex.isEven;
    while (start < metric.length) {
      final double end = start + pattern[patternIndex];
      if (draw) {
        dest.addPath(
          metric.extractPath(
            start.clamp(0.0, metric.length),
            end.clamp(0.0, metric.length),
          ),
          Offset.zero,
        );
      }
      start = end;
      patternIndex = (patternIndex + 1) % pattern.length;
      draw = !draw;
    }
  }
  return dest;
}
