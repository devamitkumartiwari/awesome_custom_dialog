import 'package:flutter/material.dart';

import 'acd_dash_path.dart';
import 'acd_dashed_border_shape.dart';

/// Wraps [child] with a dependency-free dashed/dotted border.
///
/// ```dart
/// ACDDashedBorder(
///   shape: ACDDashedBorderShape.roundedRect,
///   child: const Padding(padding: EdgeInsets.all(16), child: Text('Drop file here')),
/// )
/// ```
///
/// For [ACDDashedBorderShape.customPath], supply [customPathBuilder] to draw
/// an arbitrary outline sized to the child's laid-out [Size].
class ACDDashedBorder extends StatelessWidget {
  /// Creates an [ACDDashedBorder].
  const ACDDashedBorder({
    super.key,
    required this.child,
    this.shape = ACDDashedBorderShape.roundedRect,
    this.borderRadius = const Radius.circular(8),
    this.customPathBuilder,
    this.strokeWidth = 1.0,
    this.color = Colors.black,
    this.gradient,
    this.dashPattern = const [4, 3],
    this.roundedCaps = false,
    this.padding = const EdgeInsets.all(4),
  }) : assert(
         shape != ACDDashedBorderShape.customPath || customPathBuilder != null,
         'customPathBuilder is required when shape is ACDDashedBorderShape.customPath',
       );

  /// The widget this border wraps.
  final Widget child;

  /// The outline shape to paint.
  final ACDDashedBorderShape shape;

  /// Corner rounding, when [shape] is [ACDDashedBorderShape.roundedRect].
  final Radius borderRadius;

  /// Builds a custom outline `Path` sized to the painted [Size]. Required
  /// when [shape] is [ACDDashedBorderShape.customPath].
  final Path Function(Size size)? customPathBuilder;

  /// The border stroke width.
  final double strokeWidth;

  /// The border color. Ignored when [gradient] is set.
  final Color color;

  /// An optional gradient painted across the whole border, overriding
  /// [color].
  final Gradient? gradient;

  /// Alternating dash-length/gap-length pattern, e.g. `[4, 3]`.
  final List<double> dashPattern;

  /// Whether dash ends are rounded (`StrokeCap.round`) instead of square.
  final bool roundedCaps;

  /// Space between the painted border and [child].
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ACDDashedBorderPainter(
        shape: shape,
        borderRadius: borderRadius,
        customPathBuilder: customPathBuilder,
        strokeWidth: strokeWidth,
        color: color,
        gradient: gradient,
        dashPattern: dashPattern,
        roundedCaps: roundedCaps,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _ACDDashedBorderPainter extends CustomPainter {
  _ACDDashedBorderPainter({
    required this.shape,
    required this.borderRadius,
    required this.customPathBuilder,
    required this.strokeWidth,
    required this.color,
    required this.gradient,
    required this.dashPattern,
    required this.roundedCaps,
  });

  final ACDDashedBorderShape shape;
  final Radius borderRadius;
  final Path Function(Size size)? customPathBuilder;
  final double strokeWidth;
  final Color color;
  final Gradient? gradient;
  final List<double> dashPattern;
  final bool roundedCaps;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final Path shapePath;
    switch (shape) {
      case ACDDashedBorderShape.rect:
        shapePath = Path()..addRect(rect);
      case ACDDashedBorderShape.roundedRect:
        shapePath = Path()
          ..addRRect(RRect.fromRectAndRadius(rect, borderRadius));
      case ACDDashedBorderShape.oval:
        shapePath = Path()..addOval(rect);
      case ACDDashedBorderShape.circle:
        final double radius = (size.shortestSide) / 2 - strokeWidth / 2;
        shapePath = Path()
          ..addOval(Rect.fromCircle(center: rect.center, radius: radius));
      case ACDDashedBorderShape.customPath:
        shapePath = customPathBuilder!(size);
    }

    final Path dashed = acdDashPath(shapePath, pattern: dashPattern);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = roundedCaps ? StrokeCap.round : StrokeCap.butt
      ..shader = gradient?.createShader(rect)
      ..color = color;

    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant _ACDDashedBorderPainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.customPathBuilder != customPathBuilder ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.color != color ||
      oldDelegate.gradient != gradient ||
      oldDelegate.dashPattern != dashPattern ||
      oldDelegate.roundedCaps != roundedCaps;
}
