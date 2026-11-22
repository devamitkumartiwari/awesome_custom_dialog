import 'dart:ui';

/// The smallest total dash+gap length [acdDashPath] draws. Below this the
/// pattern is visually indistinguishable from noise and would produce an
/// enormous number of segments, so nothing is drawn instead.
const double kMinDashPatternLength = 0.5;

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
  assert(
    pattern.every((d) => d.isFinite && d >= 0),
    'pattern entries must be finite and non-negative',
  );
  assert(
    pattern.fold(0.0, (a, b) => a + b) > 0,
    'pattern must have a positive total length',
  );

  final Path dest = Path();
  // Release-mode guard: the asserts above vanish in release builds, and a
  // negative/NaN entry or a near-zero total would make the loops below spin
  // forever (or build millions of sub-pixel segments) on the UI thread.
  if (pattern.isEmpty ||
      pattern.length.isOdd ||
      pattern.any((d) => !d.isFinite || d < 0)) {
    return dest;
  }
  final double total = pattern.fold(0.0, (a, b) => a + b);
  if (total < kMinDashPatternLength) return dest;

  for (final PathMetric metric in source.computeMetrics()) {
    double distance = phase.isFinite ? phase % total : 0.0;
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
