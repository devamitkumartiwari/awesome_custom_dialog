import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../dashed/acd_dash_path.dart';
import '../design/acd_design.dart';
import '../design/acd_design_scope.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../design/internal/acd_platform_support.dart';
import 'acd_stepper_design.dart';
import 'acd_step_shape.dart';
import 'acd_step_status.dart';
import 'acd_stepper_title_placement.dart';

/// Builds a fully custom step marker for [ACDStepper], given the step's
/// [index] and its [ACDStepStatus].
typedef ACDStepBuilder = Widget Function(
  BuildContext context,
  int index,
  ACDStepStatus status,
);

/// A compact, dependency-free step-progress indicator.
///
/// ```dart
/// ACDStepper(
///   steps: const ['Cart', 'Address', 'Payment', 'Done'],
///   activeStep: 1,
///   onStepReached: (i) => setState(() => activeStep = i),
/// )
/// ```
///
/// Use `direction: Axis.vertical` for a timeline layout instead of a
/// horizontal wizard bar. For a "Minimal Dots" look, combine
/// `stepShape: ACDStepShape.circle`, a small `stepRadius`, and
/// `showTitle: false`.
///
/// [showLoadingAnimation] shows a plain [CircularProgressIndicator] on the
/// active step, keeping this package dependency-free.
class ACDStepper extends StatelessWidget {
  /// Creates an [ACDStepper].
  ACDStepper({
    super.key,
    required this.steps,
    this.activeStep = 0,
    this.direction = Axis.horizontal,
    this.onStepReached,
    this.steppingEnabled = true,
    this.stepShape = ACDStepShape.circle,
    this.stepRadius = 20,
    this.stepBorderRadius = 8,
    this.borderThickness = 2,
    this.customStep,
    this.finishedStepBackgroundColor,
    this.activeStepBackgroundColor,
    this.upcomingStepBackgroundColor,
    this.finishedStepTextColor,
    this.activeStepTextColor,
    this.upcomingStepTextColor,
    this.finishedStepIconColor,
    this.activeStepIconColor,
    this.upcomingStepIconColor,
    this.finishedStepGradient,
    this.activeStepGradient,
    this.upcomingStepGradient,
    this.markerElevation = 0,
    this.markerBoxShadow,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.showTitle = true,
    this.titleStyle,
    this.verticalTitlePlacement = ACDStepperTitlePlacement.side,
    this.verticalAlignment = CrossAxisAlignment.start,
    this.lineThickness = 2,
    this.dashed = false,
    this.dashLength = 4,
    this.dashGap = 3,
    this.finishedLineColor,
    this.unfinishedLineColor,
    this.showLoadingAnimation = false,
    this.design,
  }) : assert(steps.isNotEmpty, 'steps must not be empty');

  /// Titles for each step, in order. Also determines the step count.
  final List<String> steps;

  /// Index of the current step (0-based). Steps before this are
  /// [ACDStepStatus.finished], this one is [ACDStepStatus.active], later
  /// ones are [ACDStepStatus.upcoming].
  final int activeStep;

  /// Horizontal wizard bar vs. vertical timeline.
  final Axis direction;

  /// Fired when a step marker is tapped, with its index. Fires regardless of
  /// [steppingEnabled] so callers can validate before advancing.
  final ValueChanged<int>? onStepReached;

  /// When false, tapping a step never visually changes which step looks
  /// active from within this widget alone — the caller decides whether to
  /// update [activeStep] inside [onStepReached].
  final bool steppingEnabled;

  /// Default marker shape, ignored when [customStep] is supplied.
  final ACDStepShape stepShape;

  /// Default marker radius (circle) or half-height (rounded rectangle).
  final double stepRadius;

  /// Corner rounding for [ACDStepShape.roundedRectangle] markers.
  final double stepBorderRadius;

  /// Border width around the default marker.
  final double borderThickness;

  /// Fully replaces a step's marker. Receives the step index and its
  /// [ACDStepStatus].
  final ACDStepBuilder? customStep;

  /// Background color for finished markers.
  final Color? finishedStepBackgroundColor;

  /// Background color for the active marker.
  final Color? activeStepBackgroundColor;

  /// Background color for upcoming markers.
  final Color? upcomingStepBackgroundColor;

  /// Title text color for finished steps.
  final Color? finishedStepTextColor;

  /// Title text color for the active step.
  final Color? activeStepTextColor;

  /// Title text color for upcoming steps.
  final Color? upcomingStepTextColor;

  /// Check-icon color on finished markers.
  final Color? finishedStepIconColor;

  /// Icon color on the active marker.
  final Color? activeStepIconColor;

  /// Icon color on upcoming markers.
  final Color? upcomingStepIconColor;

  /// Gradient background for finished markers, overriding
  /// [finishedStepBackgroundColor] when set.
  final Gradient? finishedStepGradient;

  /// Gradient background for the active marker, overriding
  /// [activeStepBackgroundColor] when set.
  final Gradient? activeStepGradient;

  /// Gradient background for upcoming markers, overriding
  /// [upcomingStepBackgroundColor] when set.
  final Gradient? upcomingStepGradient;

  /// Drop-shadow elevation for the default marker. Ignored when
  /// [markerBoxShadow] is supplied.
  final double markerElevation;

  /// Explicit shadow for the default marker, overriding [markerElevation].
  final List<BoxShadow>? markerBoxShadow;

  /// Duration of the implicit transition when a marker's status changes
  /// (e.g. `activeStep` moving forward).
  final Duration animationDuration;

  /// Curve for [animationDuration]-driven transitions.
  final Curve animationCurve;

  /// Shows each step's title below (horizontal) or beside/below (vertical,
  /// see [verticalTitlePlacement]) its marker.
  final bool showTitle;

  /// Text style for step titles.
  final TextStyle? titleStyle;

  /// Where titles sit relative to markers when [direction] is
  /// `Axis.vertical`.
  final ACDStepperTitlePlacement verticalTitlePlacement;

  /// Cross-axis alignment of marker vs. title when [direction] is
  /// `Axis.vertical` and [verticalTitlePlacement] is
  /// [ACDStepperTitlePlacement.side].
  final CrossAxisAlignment verticalAlignment;

  /// Connector line thickness.
  final double lineThickness;

  /// Dashes the connector line instead of drawing it solid.
  final bool dashed;

  /// Dash length, when [dashed] is true.
  final double dashLength;

  /// Gap length, when [dashed] is true.
  final double dashGap;

  /// Connector line color for segments before [activeStep].
  final Color? finishedLineColor;

  /// Connector line color for segments at or after [activeStep].
  final Color? unfinishedLineColor;

  /// Overlays a [CircularProgressIndicator] on the active marker instead of
  /// its usual content.
  final bool showLoadingAnimation;

  /// Material (default) / Cupertino / adaptive — see [ACDDesign]. Cupertino
  /// maps default colors to iOS system colors, uses an activity indicator
  /// and press-dim (no ripple) on tappable markers.
  final ACDDesign? design;

  ACDStepStatus _statusFor(int index) {
    if (index < activeStep) return ACDStepStatus.finished;
    if (index == activeStep) return ACDStepStatus.active;
    return ACDStepStatus.upcoming;
  }

  Color? _backgroundFor(ACDStepStatus status) => switch (status) {
    ACDStepStatus.finished => finishedStepBackgroundColor,
    ACDStepStatus.active => activeStepBackgroundColor,
    ACDStepStatus.upcoming => upcomingStepBackgroundColor,
  };

  Color? _textColorFor(ACDStepStatus status) => switch (status) {
    ACDStepStatus.finished => finishedStepTextColor,
    ACDStepStatus.active => activeStepTextColor,
    ACDStepStatus.upcoming => upcomingStepTextColor,
  };

  Color? _iconColorFor(ACDStepStatus status) => switch (status) {
    ACDStepStatus.finished => finishedStepIconColor,
    ACDStepStatus.active => activeStepIconColor,
    ACDStepStatus.upcoming => upcomingStepIconColor,
  };

  Gradient? _gradientFor(ACDStepStatus status) => switch (status) {
    ACDStepStatus.finished => finishedStepGradient,
    ACDStepStatus.active => activeStepGradient,
    ACDStepStatus.upcoming => upcomingStepGradient,
  };

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = acdStepperScheme(
      context,
      ACDDesign.resolve(context, design),
    );
    return direction == Axis.horizontal
        ? _buildHorizontal(context, scheme)
        : _buildVertical(context, scheme);
  }

  Widget _buildHorizontal(BuildContext context, ColorScheme scheme) {
    final markerRow = <Widget>[];
    final titleRow = <Widget>[];
    final double slot = stepRadius * 2 + 16;

    for (int i = 0; i < steps.length; i++) {
      final ACDStepStatus status = _statusFor(i);
      markerRow.add(
        SizedBox(
          width: slot,
          child: Center(child: _marker(context, i, status, scheme)),
        ),
      );
      if (showTitle) {
        titleRow.add(
          SizedBox(
            width: slot,
            child: Text(
              steps[i],
              textAlign: TextAlign.center,
              style: (titleStyle ?? const TextStyle()).merge(
                TextStyle(color: _textColorFor(status)),
              ),
            ),
          ),
        );
      }
      if (i != steps.length - 1) {
        markerRow.add(Expanded(child: _line(context, i, Axis.horizontal)));
        if (showTitle) titleRow.add(const Expanded(child: SizedBox.shrink()));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: markerRow),
        if (showTitle) ...[const SizedBox(height: 4), Row(children: titleRow)],
      ],
    );
  }

  Widget _buildVertical(BuildContext context, ColorScheme scheme) {
    final children = <Widget>[];
    for (int i = 0; i < steps.length; i++) {
      final ACDStepStatus status = _statusFor(i);
      final bool isLast = i == steps.length - 1;
      final Widget marker = _marker(context, i, status, scheme);
      final Widget? title = showTitle
          ? Text(
              steps[i],
              style: (titleStyle ?? const TextStyle()).merge(
                TextStyle(color: _textColorFor(status)),
              ),
            )
          : null;

      if (verticalTitlePlacement == ACDStepperTitlePlacement.below) {
        children.add(
          Column(
            crossAxisAlignment: verticalAlignment,
            children: [
              marker,
              if (title != null) ...[const SizedBox(height: 4), title],
            ],
          ),
        );
        if (!isLast) {
          children.add(
            SizedBox(
              height: 24,
              width: lineThickness,
              child: _line(context, i, Axis.vertical),
            ),
          );
        }
      } else if (customStep != null) {
        // A custom marker has an unknown size: measure the row intrinsically.
        children.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: verticalAlignment,
              children: [
                Column(
                  children: [
                    marker,
                    if (!isLast)
                      Expanded(child: _line(context, i, Axis.vertical)),
                  ],
                ),
                const SizedBox(width: 12),
                if (title != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: title,
                    ),
                  ),
              ],
            ),
          ),
        );
      } else {
        // Built-in markers have a known extent, so the row lays out in a
        // single pass (no IntrinsicHeight): the title sets the height and
        // the marker + connector are positioned against it.
        final double extent = _markerExtent(context);
        children.add(
          Stack(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(start: extent + 12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: extent),
                  child: title == null
                      ? const SizedBox(width: double.infinity)
                      : Align(
                          alignment: switch (verticalAlignment) {
                            CrossAxisAlignment.center =>
                              AlignmentDirectional.centerStart,
                            CrossAxisAlignment.end =>
                              AlignmentDirectional.bottomStart,
                            _ => AlignmentDirectional.topStart,
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: title,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                PositionedDirectional(
                  start: extent / 2,
                  width: 0,
                  top: extent,
                  bottom: 0,
                  child: _line(context, i, Axis.vertical),
                ),
              PositionedDirectional(
                start: 0,
                top: 0,
                width: extent,
                height: extent,
                child: Center(child: marker),
              ),
            ],
          ),
        );
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  /// The laid-out size of a built-in marker: its diameter, grown to the
  /// 48 dp / 44 pt tap target when markers are tappable.
  double _markerExtent(BuildContext context) {
    final double diameter = stepRadius * 2;
    if (onStepReached == null) return diameter;
    return math.max(
      diameter,
      acdMinTapTarget(ACDDesign.resolve(context, design)),
    );
  }

  Widget _marker(
    BuildContext context,
    int index,
    ACDStepStatus status,
    ColorScheme scheme,
  ) {
    if (customStep != null) {
      return GestureDetector(
        onTap: onStepReached == null ? null : () => onStepReached!(index),
        child: customStep!(context, index, status),
      );
    }

    final Color background =
        _backgroundFor(status) ??
        switch (status) {
          ACDStepStatus.finished => scheme.primary,
          ACDStepStatus.active => scheme.primary,
          ACDStepStatus.upcoming => scheme.surfaceContainerHighest,
        };
    final Color iconColor =
        _iconColorFor(status) ??
        (status == ACDStepStatus.upcoming
            ? scheme.onSurfaceVariant
            : scheme.onPrimary);

    Widget content;
    if (showLoadingAnimation && status == ACDStepStatus.active) {
      content = SizedBox(
        width: stepRadius,
        height: stepRadius,
        child: ACDAdaptiveProgress(
          design: ACDDesign.resolve(context, design),
          strokeWidth: 2,
          color: iconColor,
        ),
      );
    } else if (status == ACDStepStatus.finished) {
      content = Icon(
        ACDIcon.check.of(ACDDesign.resolve(context, design)),
        color: iconColor,
        size: stepRadius,
      );
    } else {
      content = Text(
        '${index + 1}',
        style: TextStyle(color: iconColor, fontWeight: FontWeight.w600),
      );
    }

    final Gradient? gradient = _gradientFor(status);
    final BoxDecoration decoration = BoxDecoration(
      color: gradient == null ? background : null,
      gradient: gradient,
      shape: stepShape == ACDStepShape.circle
          ? BoxShape.circle
          : BoxShape.rectangle,
      borderRadius: stepShape == ACDStepShape.circle
          ? null
          : BorderRadius.circular(stepBorderRadius),
      border: borderThickness > 0
          ? Border.all(color: background, width: borderThickness)
          : null,
      boxShadow:
          markerBoxShadow ??
          (markerElevation > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: markerElevation * 2,
                    offset: Offset(0, markerElevation / 2),
                  ),
                ]
              : null),
    );

    final Widget box = AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      width: stepRadius * 2,
      height: stepRadius * 2,
      decoration: decoration,
      alignment: Alignment.center,
      child: content,
    );

    final ACDResolvedDesign resolved = ACDDesign.resolve(context, design);
    final VoidCallback? onTap = onStepReached == null
        ? null
        : () => onStepReached!(index);
    // "Step 2 of 5, completed" for screen readers (the visible number/check
    // alone doesn't convey position or state).
    Widget labelled(Widget child) => Semantics(
      label: ACDDesignScope.stringsOf(context)
          .stepLabel(index, steps.length, status.name),
      button: onTap != null,
      selected: status == ACDStepStatus.active,
      // The inner gesture's own tap action is excluded below, so expose it
      // here.
      onTap: onTap,
      excludeSemantics: true,
      child: child,
    );
    // Tappable markers get a 48 dp / 44 pt hit area (and semantics rect);
    // display-only markers keep their exact size.
    final Widget target = onTap == null
        ? box
        : ACDTapTargetBox(design: resolved, child: box);
    if (resolved.isCupertino) {
      return labelled(
        ACDAdaptiveTappable(design: resolved, onTap: onTap, child: target),
      );
    }
    return labelled(
      acdEnsureMaterial(
        context,
        InkWell(
          onTap: onTap,
          customBorder: stepShape == ACDStepShape.circle
              ? const CircleBorder()
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(stepBorderRadius),
                ),
          child: target,
        ),
      ),
    );
  }

  Widget _line(BuildContext context, int index, Axis axis) {
    final bool isFinished = index < activeStep;
    final Color color =
        (isFinished ? finishedLineColor : unfinishedLineColor) ??
        (isFinished
            ? acdStepperScheme(
                context,
                ACDDesign.resolve(context, design),
              ).primary
            : acdStepperScheme(
                context,
                ACDDesign.resolve(context, design),
              ).outlineVariant);
    return CustomPaint(
      painter: _ACDStepperLinePainter(
        axis: axis,
        thickness: lineThickness,
        color: color,
        dashed: dashed,
        dashLength: dashLength,
        dashGap: dashGap,
      ),
    );
  }
}

class _ACDStepperLinePainter extends CustomPainter {
  _ACDStepperLinePainter({
    required this.axis,
    required this.thickness,
    required this.color,
    required this.dashed,
    required this.dashLength,
    required this.dashGap,
  });

  final Axis axis;
  final double thickness;
  final Color color;
  final bool dashed;
  final double dashLength;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset start = axis == Axis.horizontal
        ? Offset(0, size.height / 2)
        : Offset(size.width / 2, 0);
    final Offset end = axis == Axis.horizontal
        ? Offset(size.width, size.height / 2)
        : Offset(size.width / 2, size.height);

    Path path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
    if (dashed) {
      path = acdDashPath(path, pattern: [dashLength, dashGap]);
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _ACDStepperLinePainter oldDelegate) =>
      oldDelegate.axis != axis ||
      oldDelegate.thickness != thickness ||
      oldDelegate.color != color ||
      oldDelegate.dashed != dashed ||
      oldDelegate.dashLength != dashLength ||
      oldDelegate.dashGap != dashGap;
}
