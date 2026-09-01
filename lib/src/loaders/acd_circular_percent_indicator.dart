import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'acd_loader_arc_type.dart';
import 'acd_loader_direction.dart';
import 'acd_loader_fill_mode.dart';
import 'acd_loader_paint.dart';
import 'acd_loader_stroke_cap.dart';
import 'acd_percent_animation_mixin.dart';

/// A circular/arc progress ring — value fully controlled ([value]),
/// uncontrolled ([initialValue]), or driven by a [ValueNotifier]
/// ([controller]).
///
/// ```dart
/// ACDCircularPercentIndicator(
///   radius: 60,
///   initialValue: 0.7,
///   progressColor: Colors.green,
///   center: const Text('70%'),
/// )
/// ```
///
/// Set [fillMode] to [ACDLoaderFillMode.pie] for a filled slice instead of a
/// stroked ring, or [arcType] for a half-circle/reversed gauge shortcut.
class ACDCircularPercentIndicator extends StatefulWidget {
  /// Creates an [ACDCircularPercentIndicator].
  const ACDCircularPercentIndicator({
    super.key,
    this.value,
    this.initialValue = 0.0,
    this.controller,
    required this.radius,
    this.lineWidth = 5.0,
    this.backgroundWidth,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.progressColor,
    this.progressBorderColor,
    this.backgroundBorderColor,
    this.borderWidth = 1.0,
    this.circularGradient,
    this.backgroundGradient,
    this.arcBackgroundColor,
    this.boxShadow,
    this.strokeCap = ACDLoaderStrokeCap.butt,
    this.fillMode = ACDLoaderFillMode.ring,
    this.arcType,
    this.startAngle = -90.0,
    this.sweepAngle = 360.0,
    this.reverse = false,
    this.center,
    this.showPercentageText = false,
    this.percentageTextStyle,
    this.percentageFormatter,
    this.header,
    this.footer,
    this.enabled = true,
    this.disabledOpacity = 0.5,
    this.animate = true,
    this.animateFromInitial = false,
    this.animateFromLastPercent = true,
    this.restartAnimation = false,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.linear,
    this.direction = ACDLoaderDirection.forward,
    this.maskFilter,
    this.indicator,
    this.keepAlive = false,
    this.onAnimationEnd,
    this.onPercentChanged,
  });

  /// Controlled value — when non-null, authoritative on every rebuild.
  final double? value;

  /// Uncontrolled seed, used only when both [controller] and [value] are
  /// `null`.
  final double initialValue;

  /// Highest-precedence external value source.
  final ValueNotifier<double>? controller;

  /// Outer radius of the ring.
  final double radius;

  /// Stroke width of the progress ring ([ACDLoaderFillMode.ring] only).
  final double lineWidth;

  /// Independent stroke width for the background arc. Falls back to
  /// [lineWidth].
  final double? backgroundWidth;

  /// Padding around the ring (and [header]/[footer]), inside [margin].
  final EdgeInsets padding;

  /// Space around the whole indicator, outside [padding].
  final EdgeInsets margin;

  /// Track color behind the fill.
  final Color? backgroundColor;

  /// Fill color, ignored when [circularGradient] is set. Falls back to the
  /// ambient theme's `colorScheme.primary`.
  final Color? progressColor;

  /// Outline color drawn around the progress stroke/slice.
  final Color? progressBorderColor;

  /// Outline color drawn around the background stroke/slice.
  final Color? backgroundBorderColor;

  /// Width of [progressBorderColor]/[backgroundBorderColor]'s outline.
  final double borderWidth;

  /// Fill gradient, overriding [progressColor].
  final Gradient? circularGradient;

  /// Track gradient, overriding [backgroundColor].
  final Gradient? backgroundGradient;

  /// Overrides [backgroundColor] specifically for a partial ([sweepAngle] <
  /// 360) arc's background.
  final Color? arcBackgroundColor;

  /// Drop shadow behind the ring/pie.
  final List<BoxShadow>? boxShadow;

  /// End-cap style for the fill ([ACDLoaderFillMode.ring] only).
  final ACDLoaderStrokeCap strokeCap;

  /// Ring (stroked) or pie (filled slice) paint mode.
  final ACDLoaderFillMode fillMode;

  /// Convenience arc-extent preset, overriding [sweepAngle]/[reverse] when
  /// set. See [ACDLoaderArcType].
  final ACDLoaderArcType? arcType;

  /// Degrees clockwise from 3 o'clock where the arc starts. `-90` (the
  /// default) starts at 12 o'clock.
  final double startAngle;

  /// Degrees the arc spans. `360` (the default) is a full ring; smaller
  /// values draw a partial gauge. The background is always painted across
  /// this same extent.
  final double sweepAngle;

  /// Fills counter-clockwise instead of clockwise.
  final bool reverse;

  /// Content centered inside the ring. Takes precedence over
  /// [showPercentageText] when both are set.
  final Widget? center;

  /// Shows the live percent (e.g. `"70%"`) centered inside the ring when
  /// [center] isn't set. Its font size automatically scales with [radius]
  /// unless [percentageTextStyle] pins an explicit `fontSize`.
  final bool showPercentageText;

  /// Style for the [showPercentageText] label. A `null` `fontSize` still
  /// auto-scales with [radius].
  final TextStyle? percentageTextStyle;

  /// Formats the value shown by [showPercentageText]. Defaults to
  /// `'${(value * 100).round()}%'`.
  final String Function(double value)? percentageFormatter;

  /// Content above the ring.
  final Widget? header;

  /// Content below the ring.
  final Widget? footer;

  /// Disables and dims the indicator when `false`.
  final bool enabled;

  /// Opacity applied when [enabled] is `false`.
  final double disabledOpacity;

  /// Disables all animation when `false` — every value change snaps
  /// instantly.
  final bool animate;

  /// When `true`, the very first paint animates from `0` up to the seed
  /// value too, instead of snapping straight to it.
  final bool animateFromInitial;

  /// When `true` (the default), a value change animates from the *current*
  /// displayed value. When `false`, every change animates from `0`.
  final bool animateFromLastPercent;

  /// Toggle this (to any different value) to force-replay the fill
  /// animation from `0` to the current value on demand.
  final bool restartAnimation;

  /// Duration of the fill animation.
  final Duration animationDuration;

  /// Curve for [animationDuration].
  final Curve animationCurve;

  /// Fill direction, combined with [reverse]/[arcType].
  final ACDLoaderDirection direction;

  /// Optional blur applied to the fill/track paint (a glow effect).
  final MaskFilter? maskFilter;

  /// A marker widget painted at the current progress position along the
  /// arc.
  final Widget? indicator;

  /// Keeps this indicator's animation state alive when it's a descendant of
  /// a scrollable that would otherwise dispose it while scrolled off
  /// screen.
  final bool keepAlive;

  /// Fires once a fill animation finishes.
  final VoidCallback? onAnimationEnd;

  /// Fires with the live, currently-animated value on every animation
  /// frame — handy for driving an external "70%" label.
  final ValueChanged<double>? onPercentChanged;

  @override
  State<ACDCircularPercentIndicator> createState() =>
      _ACDCircularPercentIndicatorState();
}

class _ACDCircularPercentIndicatorState
    extends State<ACDCircularPercentIndicator>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin,
        ACDPercentAnimationMixin {
  double get _effectiveValue =>
      (widget.controller?.value ?? widget.value ?? widget.initialValue).clamp(
        0.0,
        1.0,
      );

  @override
  bool get wantKeepAlive => widget.keepAlive;

  ({double sweepAngle, bool reverse}) get _effectiveArc =>
      switch (widget.arcType) {
        null => (sweepAngle: widget.sweepAngle, reverse: widget.reverse),
        ACDLoaderArcType.full => (sweepAngle: 360, reverse: false),
        ACDLoaderArcType.half => (sweepAngle: 180, reverse: false),
        ACDLoaderArcType.fullReversed => (sweepAngle: 360, reverse: true),
      };

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerChanged);
    if (widget.animate && widget.animateFromInitial) {
      initPercentAnimation(0);
      WidgetsBinding.instance.addPostFrameCallback((_) => _animate());
    } else {
      initPercentAnimation(_effectiveValue);
    }
  }

  @override
  void didUpdateWidget(covariant ACDCircularPercentIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
    if (widget.restartAnimation != oldWidget.restartAnimation) {
      initPercentAnimation(0);
      _animate();
    } else if (widget.controller != oldWidget.controller ||
        (widget.controller == null && widget.value != oldWidget.value)) {
      _animate();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    disposePercentAnimation();
    super.dispose();
  }

  void _onControllerChanged() => _animate();

  Future<void> _animate() async {
    final double target = _effectiveValue;
    if (!widget.animateFromLastPercent) {
      initPercentAnimation(0);
    }
    await animateToPercent(
      target,
      duration: widget.animationDuration,
      curve: widget.animationCurve,
      animate: widget.animate,
      onTick: widget.onPercentChanged,
    );
    if (mounted && currentAnimatedPercent == target) {
      widget.onAnimationEnd?.call();
    }
  }

  Widget? _buildPercentageText() {
    if (widget.center != null) return widget.center;
    if (!widget.showPercentageText) return null;
    final String text =
        widget.percentageFormatter?.call(currentAnimatedPercent) ??
        '${(currentAnimatedPercent * 100).round()}%';
    final double autoFontSize = (widget.radius * 0.35).clamp(10.0, 96.0);
    return Text(
      text,
      style: (widget.percentageTextStyle ?? const TextStyle()).copyWith(
        fontSize: widget.percentageTextStyle?.fontSize ?? autoFontSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ({double sweepAngle, bool reverse}) arc = _effectiveArc;
    final bool reverseFill =
        arc.reverse != (widget.direction == ACDLoaderDirection.reverse);
    final double diameter = widget.radius * 2;
    final Widget? centerContent = _buildPercentageText();

    Widget ring = SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.boxShadow != null)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: widget.boxShadow,
                ),
              ),
            ),
          CustomPaint(
            size: Size(diameter, diameter),
            painter: _ACDCircularPercentIndicatorPainter(
              progress: currentAnimatedPercent,
              startAngleDeg: widget.startAngle,
              sweepAngleDeg: arc.sweepAngle,
              reverse: reverseFill,
              fillMode: widget.fillMode,
              backgroundColor:
                  widget.arcBackgroundColor ??
                  widget.backgroundColor ??
                  const Color(0xFFB8C7CB),
              progressColor:
                  widget.progressColor ?? Theme.of(context).colorScheme.primary,
              progressBorderColor: widget.progressBorderColor,
              backgroundBorderColor: widget.backgroundBorderColor,
              borderWidth: widget.borderWidth,
              circularGradient: widget.circularGradient,
              backgroundGradient: widget.backgroundGradient,
              strokeCap: widget.strokeCap,
              lineWidth: widget.lineWidth,
              backgroundWidth: widget.backgroundWidth ?? widget.lineWidth,
              maskFilter: widget.maskFilter,
            ),
          ),
          if (centerContent != null) centerContent,
          if (widget.indicator != null)
            _ArcIndicatorPosition(
              radius: widget.radius,
              startAngleDeg: widget.startAngle,
              sweepAngleDeg: arc.sweepAngle,
              progress: currentAnimatedPercent,
              reverse: reverseFill,
              child: widget.indicator!,
            ),
        ],
      ),
    );

    if (widget.header != null || widget.footer != null) {
      ring = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.header != null) widget.header!,
          ring,
          if (widget.footer != null) widget.footer!,
        ],
      );
    }

    return Padding(
      padding: widget.margin,
      child: Padding(
        padding: widget.padding,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : widget.disabledOpacity,
          child: ring,
        ),
      ),
    );
  }
}

class _ArcIndicatorPosition extends StatelessWidget {
  const _ArcIndicatorPosition({
    required this.radius,
    required this.startAngleDeg,
    required this.sweepAngleDeg,
    required this.progress,
    required this.reverse,
    required this.child,
  });

  final double radius;
  final double startAngleDeg;
  final double sweepAngleDeg;
  final double progress;
  final bool reverse;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final (double startRad, double sweepRad) = acdLoaderArc(
      percent: progress,
      startAngleDeg: startAngleDeg,
      sweepAngleDeg: sweepAngleDeg,
      reverse: reverse,
    );
    final double angle = startRad + sweepRad;
    final Offset offset = Offset(math.cos(angle), math.sin(angle)) * radius;
    return Transform.translate(offset: offset, child: child);
  }
}

class _ACDCircularPercentIndicatorPainter extends CustomPainter {
  _ACDCircularPercentIndicatorPainter({
    required this.progress,
    required this.startAngleDeg,
    required this.sweepAngleDeg,
    required this.reverse,
    required this.fillMode,
    required this.backgroundColor,
    required this.strokeCap,
    required this.lineWidth,
    required this.backgroundWidth,
    required this.borderWidth,
    this.progressColor,
    this.progressBorderColor,
    this.backgroundBorderColor,
    this.circularGradient,
    this.backgroundGradient,
    this.maskFilter,
  });

  final double progress;
  final double startAngleDeg;
  final double sweepAngleDeg;
  final bool reverse;
  final ACDLoaderFillMode fillMode;
  final Color backgroundColor;
  final Color? progressColor;
  final Color? progressBorderColor;
  final Color? backgroundBorderColor;
  final double borderWidth;
  final Gradient? circularGradient;
  final Gradient? backgroundGradient;
  final ACDLoaderStrokeCap strokeCap;
  final double lineWidth;
  final double backgroundWidth;
  final MaskFilter? maskFilter;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double maxLineWidth = math.max(lineWidth, backgroundWidth);
    final double ringRadius =
        (math.min(size.width, size.height) - maxLineWidth) / 2;
    final Rect ringRect = Rect.fromCircle(center: center, radius: ringRadius);
    final Rect shaderRect = Offset.zero & size;

    final (double backgroundStart, double backgroundSweep) = acdLoaderArc(
      percent: 1.0,
      startAngleDeg: startAngleDeg,
      sweepAngleDeg: sweepAngleDeg,
      reverse: reverse,
    );

    switch (fillMode) {
      case ACDLoaderFillMode.ring:
        if (backgroundBorderColor != null) {
          canvas.drawArc(
            ringRect,
            backgroundStart,
            backgroundSweep,
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = acdCircularStrokeCap(strokeCap)
              ..strokeWidth = backgroundWidth + borderWidth * 2
              ..color = backgroundBorderColor!,
          );
        }
        canvas.drawArc(
          ringRect,
          backgroundStart,
          backgroundSweep,
          false,
          acdLoaderStrokePaint(
            strokeWidth: backgroundWidth,
            strokeCap: strokeCap,
            shaderRect: shaderRect,
            color: backgroundColor,
            gradient: backgroundGradient,
            maskFilter: maskFilter,
          ),
        );
        if (progress <= 0) return;
        final (double start, double sweep) = acdLoaderArc(
          percent: progress,
          startAngleDeg: startAngleDeg,
          sweepAngleDeg: sweepAngleDeg,
          reverse: reverse,
        );
        if (progressBorderColor != null) {
          canvas.drawArc(
            ringRect,
            start,
            sweep,
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = acdCircularStrokeCap(strokeCap)
              ..strokeWidth = lineWidth + borderWidth * 2
              ..color = progressBorderColor!,
          );
        }
        canvas.drawArc(
          ringRect,
          start,
          sweep,
          false,
          acdLoaderStrokePaint(
            strokeWidth: lineWidth,
            strokeCap: strokeCap,
            shaderRect: shaderRect,
            color: progressColor,
            gradient: circularGradient,
            maskFilter: maskFilter,
          ),
        );
      case ACDLoaderFillMode.pie:
        final Path backgroundPath = Path()
          ..moveTo(center.dx, center.dy)
          ..arcTo(ringRect, backgroundStart, backgroundSweep, false)
          ..close();
        canvas.drawPath(
          backgroundPath,
          acdLoaderFillPaint(
            shaderRect: shaderRect,
            color: backgroundColor,
            gradient: backgroundGradient,
            maskFilter: maskFilter,
          ),
        );
        if (backgroundBorderColor != null) {
          canvas.drawPath(
            backgroundPath,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = borderWidth
              ..color = backgroundBorderColor!,
          );
        }
        if (progress <= 0) return;
        final (double start, double sweep) = acdLoaderArc(
          percent: progress,
          startAngleDeg: startAngleDeg,
          sweepAngleDeg: sweepAngleDeg,
          reverse: reverse,
        );
        final Path progressPath = Path()
          ..moveTo(center.dx, center.dy)
          ..arcTo(ringRect, start, sweep, false)
          ..close();
        canvas.drawPath(
          progressPath,
          acdLoaderFillPaint(
            shaderRect: shaderRect,
            color: progressColor,
            gradient: circularGradient,
            maskFilter: maskFilter,
          ),
        );
        if (progressBorderColor != null) {
          canvas.drawPath(
            progressPath,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = borderWidth
              ..color = progressBorderColor!,
          );
        }
    }
  }

  @override
  bool shouldRepaint(
    covariant _ACDCircularPercentIndicatorPainter oldDelegate,
  ) {
    return progress != oldDelegate.progress ||
        progressBorderColor != oldDelegate.progressBorderColor ||
        backgroundBorderColor != oldDelegate.backgroundBorderColor ||
        borderWidth != oldDelegate.borderWidth ||
        startAngleDeg != oldDelegate.startAngleDeg ||
        sweepAngleDeg != oldDelegate.sweepAngleDeg ||
        reverse != oldDelegate.reverse ||
        fillMode != oldDelegate.fillMode ||
        backgroundColor != oldDelegate.backgroundColor ||
        progressColor != oldDelegate.progressColor ||
        circularGradient != oldDelegate.circularGradient ||
        backgroundGradient != oldDelegate.backgroundGradient ||
        strokeCap != oldDelegate.strokeCap ||
        lineWidth != oldDelegate.lineWidth ||
        backgroundWidth != oldDelegate.backgroundWidth ||
        maskFilter != oldDelegate.maskFilter;
  }
}
