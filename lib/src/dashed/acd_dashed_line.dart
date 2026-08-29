import 'package:flutter/material.dart';

import 'acd_dash_path.dart';

/// A dependency-free dashed/dotted line.
///
/// ```dart
/// ACDDashedLine(length: 200) // horizontal, default dash/gap of 4px
/// ACDDashedLine(axis: Axis.vertical, length: 100, dashLength: 6, gapLength: 3)
/// ```
///
/// When [length] is null, the line fills the available space along [axis]
/// (its parent must provide a bounded constraint in that direction).
class ACDDashedLine extends StatelessWidget {
  /// Creates an [ACDDashedLine].
  const ACDDashedLine({
    super.key,
    this.axis = Axis.horizontal,
    this.length,
    this.thickness = 1.0,
    this.dashLength = 4.0,
    this.gapLength = 4.0,
    this.color = Colors.black,
    this.gradient,
    this.roundedCaps = false,
    this.useRepaintBoundary = true,
  });

  /// Whether the line runs horizontally or vertically.
  final Axis axis;

  /// The line's length along [axis]. Null fills the available space.
  final double? length;

  /// The line's thickness across [axis].
  final double thickness;

  /// Length, in logical pixels, of each dash.
  final double dashLength;

  /// Length, in logical pixels, of the gap between dashes.
  final double gapLength;

  /// The dash color. Ignored when [gradient] is set.
  final Color color;

  /// An optional gradient painted across the whole line, overriding [color].
  final Gradient? gradient;

  /// Whether dash ends are rounded (`StrokeCap.round`) instead of square.
  final bool roundedCaps;

  /// Wraps the line in a [RepaintBoundary] so a frequently-rebuilding parent
  /// doesn't force this line to repaint too. Defaults to true.
  final bool useRepaintBoundary;

  @override
  Widget build(BuildContext context) {
    final Widget painted = CustomPaint(
      painter: _ACDDashedLinePainter(
        axis: axis,
        thickness: thickness,
        dashLength: dashLength,
        gapLength: gapLength,
        color: color,
        gradient: gradient,
        roundedCaps: roundedCaps,
      ),
    );

    final Widget line = SizedBox(
      width: axis == Axis.horizontal ? (length ?? double.infinity) : thickness,
      height: axis == Axis.horizontal ? thickness : (length ?? double.infinity),
      child: painted,
    );

    return useRepaintBoundary ? RepaintBoundary(child: line) : line;
  }
}

class _ACDDashedLinePainter extends CustomPainter {
  _ACDDashedLinePainter({
    required this.axis,
    required this.thickness,
    required this.dashLength,
    required this.gapLength,
    required this.color,
    required this.gradient,
    required this.roundedCaps,
  });

  final Axis axis;
  final double thickness;
  final double dashLength;
  final double gapLength;
  final Color color;
  final Gradient? gradient;
  final bool roundedCaps;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset start = Offset.zero;
    final Offset end = axis == Axis.horizontal
        ? Offset(size.width, 0)
        : Offset(0, size.height);

    final Path straight = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
    final Path dashed = acdDashPath(straight, pattern: [dashLength, gapLength]);

    final Rect bounds = Offset.zero & size;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = roundedCaps ? StrokeCap.round : StrokeCap.butt
      ..shader = gradient?.createShader(bounds)
      ..color = color;

    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant _ACDDashedLinePainter oldDelegate) =>
      oldDelegate.axis != axis ||
      oldDelegate.thickness != thickness ||
      oldDelegate.dashLength != dashLength ||
      oldDelegate.gapLength != gapLength ||
      oldDelegate.color != color ||
      oldDelegate.gradient != gradient ||
      oldDelegate.roundedCaps != roundedCaps;
}
