import 'package:flutter/material.dart';

import '../dashed/acd_dash_path.dart';
import 'acd_step_status.dart';

/// One row's worth of data for [ACDStepperListView].
class ACDStepperItemData<T> {
  /// Creates an [ACDStepperItemData].
  const ACDStepperItemData({required this.id, required this.data, this.status});

  /// A stable identifier for this row (e.g. for `Key`s or lookups).
  final Object id;

  /// The row's payload, passed to [ACDStepperListView]'s builders.
  final T data;

  /// Overrides this row's [ACDStepStatus] independent of its position in the
  /// list. When null, the default avatar just uses the row's index.
  final ACDStepStatus? status;
}

/// Connector-line styling for [ACDStepperListView], shared across every row
/// rather than repeated as a flat parameter block on the main widget.
class ACDStepperThemeData {
  /// Creates an [ACDStepperThemeData].
  const ACDStepperThemeData({
    this.lineColor,
    this.lineWidth = 2,
    this.dashed = false,
    this.dashLength = 4,
    this.dashGap = 3,
  });

  /// Connector line color. Defaults to the theme's `outlineVariant`.
  final Color? lineColor;

  /// Connector line thickness.
  final double lineWidth;

  /// Dashes the connector line instead of drawing it solid.
  final bool dashed;

  /// Dash length, when [dashed] is true.
  final double dashLength;

  /// Gap length, when [dashed] is true.
  final double dashGap;
}

/// Builds one row's avatar/label/content for [ACDStepperListView].
typedef ACDStepperRowBuilder<T> = Widget Function(
  BuildContext context,
  ACDStepperItemData<T> item,
  int index,
);

/// A dependency-free, scrollable vertical timeline list — avatar/marker +
/// connector line + content per row.
///
/// Distinct from [ACDStepper]: this is for an arbitrarily long, scrollable
/// list of entries (e.g. order-tracking history), not a small fixed-count
/// wizard progress bar.
///
/// ```dart
/// ACDStepperListView<String>(
///   items: [
///     const ACDStepperItemData(id: 1, data: 'Order placed'),
///     const ACDStepperItemData(id: 2, data: 'Shipped'),
///   ],
///   contentBuilder: (context, item, index) => Text(item.data),
/// )
/// ```
///
/// Sorting isn't a feature of this widget — sort [items] yourself before
/// passing them in.
class ACDStepperListView<T> extends StatelessWidget {
  /// Creates an [ACDStepperListView].
  const ACDStepperListView({
    super.key,
    required this.items,
    required this.contentBuilder,
    this.avatarBuilder,
    this.labelBuilder,
    this.theme = const ACDStepperThemeData(),
    this.showLineOnLast = false,
    this.avatarSize = 32,
    this.avatarColor,
    this.avatarGradient,
    this.avatarElevation = 0,
    this.avatarBoxShadow,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.physics,
    this.shrinkWrap = false,
    this.controller,
  });

  /// The rows to render, top to bottom.
  final List<ACDStepperItemData<T>> items;

  /// Builds a row's main content. Required.
  final ACDStepperRowBuilder<T> contentBuilder;

  /// Builds a row's avatar/marker. Defaults to a numbered [CircleAvatar].
  final ACDStepperRowBuilder<T>? avatarBuilder;

  /// Builds an optional label shown above a row's content.
  final ACDStepperRowBuilder<T>? labelBuilder;

  /// Connector-line styling, shared across every row.
  final ACDStepperThemeData theme;

  /// Whether the last row still draws a trailing connector line below its
  /// avatar.
  final bool showLineOnLast;

  /// Default avatar's diameter.
  final double avatarSize;

  /// Default avatar's background color.
  final Color? avatarColor;

  /// Gradient background for the default avatar, overriding [avatarColor]
  /// when set.
  final Gradient? avatarGradient;

  /// Drop-shadow elevation for the default avatar. Ignored when
  /// [avatarBoxShadow] is supplied.
  final double avatarElevation;

  /// Explicit shadow for the default avatar, overriding [avatarElevation].
  final List<BoxShadow>? avatarBoxShadow;

  /// Duration of the implicit transition when a row's [ACDStepperItemData.status]
  /// changes.
  final Duration animationDuration;

  /// Curve for [animationDuration]-driven transitions.
  final Curve animationCurve;

  /// Passed through to the inner `ListView.builder`.
  final ScrollPhysics? physics;

  /// Passed through to the inner `ListView.builder`.
  final bool shrinkWrap;

  /// Passed through to the inner `ListView.builder`.
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: physics,
      shrinkWrap: shrinkWrap,
      controller: controller,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final ACDStepperItemData<T> item = items[index];
        final bool isLast = index == items.length - 1;
        final Widget avatar =
            avatarBuilder?.call(context, item, index) ??
            _defaultAvatar(context, item, index);
        final Widget? label = labelBuilder?.call(context, item, index);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: avatarSize,
                    height: avatarSize,
                    child: avatar,
                  ),
                  if (!isLast || showLineOnLast)
                    Expanded(
                      child: CustomPaint(
                        painter: _ACDStepperListLinePainter(
                          color:
                              theme.lineColor ??
                              Theme.of(context).colorScheme.outlineVariant,
                          width: theme.lineWidth,
                          dashed: theme.dashed,
                          dashLength: theme.dashLength,
                          dashGap: theme.dashGap,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (label != null) label,
                      contentBuilder(context, item, index),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _defaultAvatar(
    BuildContext context,
    ACDStepperItemData<T> item,
    int index,
  ) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color background = avatarColor ?? scheme.primary;
    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      width: avatarSize,
      height: avatarSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: avatarGradient == null ? background : null,
        gradient: avatarGradient,
        shape: BoxShape.circle,
        boxShadow:
            avatarBoxShadow ??
            (avatarElevation > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: avatarElevation * 2,
                      offset: Offset(0, avatarElevation / 2),
                    ),
                  ]
                : null),
      ),
      child: Text(
        '${index + 1}',
        style: TextStyle(
          color: scheme.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ACDStepperListLinePainter extends CustomPainter {
  _ACDStepperListLinePainter({
    required this.color,
    required this.width,
    required this.dashed,
    required this.dashLength,
    required this.dashGap,
  });

  final Color color;
  final double width;
  final bool dashed;
  final double dashLength;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2, size.height);
    if (dashed) {
      path = acdDashPath(path, pattern: [dashLength, dashGap]);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _ACDStepperListLinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.width != width ||
      oldDelegate.dashed != dashed ||
      oldDelegate.dashLength != dashLength ||
      oldDelegate.dashGap != dashGap;
}
