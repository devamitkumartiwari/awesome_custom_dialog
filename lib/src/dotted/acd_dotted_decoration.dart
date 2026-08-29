import 'package:flutter/material.dart';

import '../dashed/acd_dash_path.dart';
import 'acd_dotted_line_position.dart';
import 'acd_dotted_shape.dart';

/// A dashed/dotted [Decoration] — as simple to use as [BoxDecoration], and
/// fully dependency-free.
///
/// ```dart
/// Container(
///   decoration: const ACDDottedDecoration(shape: ACDDottedShape.box),
///   child: const Padding(padding: EdgeInsets.all(12), child: Text('Hi')),
/// )
/// ```
class ACDDottedDecoration extends Decoration {
  /// Creates an [ACDDottedDecoration].
  const ACDDottedDecoration({
    this.shape = ACDDottedShape.box,
    this.linePosition = ACDDottedLinePosition.bottom,
    this.borderRadius = BorderRadius.zero,
    this.color = Colors.grey,
    this.gradient,
    this.strokeWidth = 1.0,
    this.dashPattern = const [3, 2],
    this.roundedCaps = false,
  });

  /// The outline shape to paint.
  final ACDDottedShape shape;

  /// Which edge to draw along, when [shape] is [ACDDottedShape.line].
  final ACDDottedLinePosition linePosition;

  /// Corner rounding, when [shape] is [ACDDottedShape.box].
  final BorderRadius borderRadius;

  /// The dash color. Ignored when [gradient] is set.
  final Color color;

  /// An optional gradient painted across the whole shape, overriding
  /// [color].
  final Gradient? gradient;

  /// The dash stroke width.
  final double strokeWidth;

  /// Alternating dash-length/gap-length pattern, e.g. `[3, 2]`.
  final List<double> dashPattern;

  /// Whether dash ends are rounded (`StrokeCap.round`) instead of square —
  /// what actually makes a dash pattern read as "dots" rather than tiny
  /// rectangles.
  final bool roundedCaps;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _ACDDottedBoxPainter(this, onChanged);
}

class _ACDDottedBoxPainter extends BoxPainter {
  _ACDDottedBoxPainter(this.decoration, VoidCallback? onChanged)
    : super(onChanged);

  final ACDDottedDecoration decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Size size = configuration.size!;
    final Rect rect = offset & size;

    final Path shapePath;
    switch (decoration.shape) {
      case ACDDottedShape.box:
        shapePath = Path()..addRRect(decoration.borderRadius.toRRect(rect));
      case ACDDottedShape.oval:
        shapePath = Path()..addOval(rect);
      case ACDDottedShape.line:
        shapePath = Path();
        switch (decoration.linePosition) {
          case ACDDottedLinePosition.top:
            shapePath.moveTo(rect.left, rect.top);
            shapePath.lineTo(rect.right, rect.top);
          case ACDDottedLinePosition.bottom:
            shapePath.moveTo(rect.left, rect.bottom);
            shapePath.lineTo(rect.right, rect.bottom);
          case ACDDottedLinePosition.left:
            shapePath.moveTo(rect.left, rect.top);
            shapePath.lineTo(rect.left, rect.bottom);
          case ACDDottedLinePosition.right:
            shapePath.moveTo(rect.right, rect.top);
            shapePath.lineTo(rect.right, rect.bottom);
        }
    }

    final Path dashed = acdDashPath(shapePath, pattern: decoration.dashPattern);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = decoration.strokeWidth
      ..strokeCap = decoration.roundedCaps ? StrokeCap.round : StrokeCap.butt
      ..shader = decoration.gradient?.createShader(rect)
      ..color = decoration.color;

    canvas.drawPath(dashed, paint);
  }
}
