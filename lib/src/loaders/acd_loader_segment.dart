import 'package:flutter/material.dart';

import 'acd_loader_stroke_cap.dart';

/// One segment of an [ACDMultiSegmentLinearIndicator] — an immutable value
/// type, so adding, removing, or reordering segments at runtime is a plain
/// list/value diff (see [ACDMultiSegmentLinearIndicator] for why this
/// matters).
///
/// ```dart
/// ACDMultiSegmentLinearIndicator(
///   segments: [
///     ACDLoaderSegment(key: 'download', percent: 0.4, color: Colors.blue),
///     ACDLoaderSegment(key: 'verify', percent: 0.2, color: Colors.orange),
///   ],
/// )
/// ```
@immutable
final class ACDLoaderSegment {
  /// Creates an [ACDLoaderSegment].
  const ACDLoaderSegment({
    this.key,
    required this.percent,
    this.color,
    this.gradient,
    this.backgroundColor,
    this.backgroundGradient,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.strokeCap,
    this.flex = 1.0,
    this.enableStripes = false,
    this.label,
  });

  /// Identity used to track this segment's animated progress across
  /// rebuilds, independent of its position in the list. Falls back to the
  /// segment's index when `null` — set an explicit [key] if segments can be
  /// reordered or inserted/removed at runtime.
  final Object? key;

  /// This segment's own fill, `0.0`–`1.0` (clamped), relative to its own
  /// slot — not a fraction of the whole bar.
  final double percent;

  /// This segment's fill color. Falls back to the ambient theme's primary
  /// color when both this and [gradient] are `null`.
  final Color? color;

  /// This segment's fill gradient, overriding [color] when set.
  final Gradient? gradient;

  /// Overrides [ACDMultiSegmentLinearIndicator.backgroundColor] for this
  /// segment's own track only.
  final Color? backgroundColor;

  /// Overrides [ACDMultiSegmentLinearIndicator.backgroundGradient] for this
  /// segment's own track only.
  final Gradient? backgroundGradient;

  /// Overrides [ACDMultiSegmentLinearIndicator.borderColor] for this
  /// segment only.
  final Color? borderColor;

  /// Overrides [ACDMultiSegmentLinearIndicator.borderWidth] for this
  /// segment only.
  final double? borderWidth;

  /// Overrides [ACDMultiSegmentLinearIndicator.barRadius] for this segment
  /// only.
  final Radius? borderRadius;

  /// Overrides [ACDMultiSegmentLinearIndicator.strokeCap] for this segment
  /// only.
  final ACDLoaderStrokeCap? strokeCap;

  /// Proportional width of this segment's slot relative to the other
  /// segments' [flex] values (`Expanded`-style).
  final double flex;

  /// Overrides [ACDMultiSegmentLinearIndicator.stripeEffect] for this
  /// segment only.
  final bool enableStripes;

  /// Optional caller-supplied label, not rendered by this widget directly —
  /// available to a custom `child`/tooltip built around it.
  final String? label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ACDLoaderSegment &&
          key == other.key &&
          percent == other.percent &&
          color == other.color &&
          gradient == other.gradient &&
          backgroundColor == other.backgroundColor &&
          backgroundGradient == other.backgroundGradient &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth &&
          borderRadius == other.borderRadius &&
          strokeCap == other.strokeCap &&
          flex == other.flex &&
          enableStripes == other.enableStripes &&
          label == other.label);

  @override
  int get hashCode => Object.hash(
    key,
    percent,
    color,
    gradient,
    Object.hash(backgroundColor, backgroundGradient, borderColor, borderWidth),
    borderRadius,
    strokeCap,
    flex,
    enableStripes,
    label,
  );
}
