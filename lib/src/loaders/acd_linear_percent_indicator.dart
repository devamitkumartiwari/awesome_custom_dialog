import 'package:flutter/material.dart';

import 'acd_loader_direction.dart';
import 'acd_loader_paint.dart';
import 'acd_loader_stroke_cap.dart';
import 'acd_percent_animation_mixin.dart';

/// A horizontal progress bar — value fully controlled ([value]), uncontrolled
/// ([initialValue]), or driven by a [ValueNotifier] ([controller]).
///
/// ```dart
/// ACDLinearPercentIndicator(
///   initialValue: 0.4,
///   progressColor: Colors.blue,
///   center: const Text('40%'),
/// )
/// ```
///
/// No fixed [width] is required — by default the bar fills its parent's
/// available width and re-flows if that width changes; pass [width] for a
/// fixed size instead.
class ACDLinearPercentIndicator extends StatefulWidget {
  /// Creates an [ACDLinearPercentIndicator].
  const ACDLinearPercentIndicator({
    super.key,
    this.value,
    this.initialValue = 0.0,
    this.controller,
    this.width,
    this.lineHeight = 8.0,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.progressColor,
    this.progressBorderColor,
    this.backgroundBorderColor,
    this.borderWidth = 1.0,
    this.linearGradient,
    this.backgroundGradient,
    this.strokeCap = ACDLoaderStrokeCap.butt,
    this.barRadius,
    this.boxShadow,
    this.leading,
    this.trailing,
    this.center,
    this.showPercentageText = false,
    this.percentageTextStyle,
    this.percentageFormatter,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.isRTL = false,
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

  /// Fixed bar width. When `null` (the default), the bar fills its parent's
  /// available width via [LayoutBuilder] and re-flows on resize.
  final double? width;

  /// Bar thickness.
  final double lineHeight;

  /// Padding around the whole row (bar plus [leading]/[trailing]), inside
  /// [margin].
  final EdgeInsets padding;

  /// Space around the whole indicator, outside [padding].
  final EdgeInsets margin;

  /// Track color behind the fill.
  final Color? backgroundColor;

  /// Fill color, ignored when [linearGradient] is set. Falls back to the
  /// ambient theme's `colorScheme.primary`.
  final Color? progressColor;

  /// Stroke color drawn around the fill's edge.
  final Color? progressBorderColor;

  /// Stroke color drawn around the whole track's edge.
  final Color? backgroundBorderColor;

  /// Width of [progressBorderColor]/[backgroundBorderColor]'s stroke.
  final double borderWidth;

  /// Fill gradient, overriding [progressColor].
  final Gradient? linearGradient;

  /// Track gradient, overriding [backgroundColor].
  final Gradient? backgroundGradient;

  /// End-cap style for the fill.
  final ACDLoaderStrokeCap strokeCap;

  /// Corner radius for the bar (track and fill). Ignored when `null`.
  final Radius? barRadius;

  /// Drop shadow behind the whole bar.
  final List<BoxShadow>? boxShadow;

  /// Content before the bar.
  final Widget? leading;

  /// Content after the bar.
  final Widget? trailing;

  /// Content overlaid on top of the bar, centered. Takes precedence over
  /// [showPercentageText] when both are set.
  final Widget? center;

  /// Shows the live percent (e.g. `"42%"`) centered on the bar when
  /// [center] isn't set. Its font size automatically scales with
  /// [lineHeight] unless [percentageTextStyle] pins an explicit `fontSize`.
  final bool showPercentageText;

  /// Style for the [showPercentageText] label. A `null` `fontSize` still
  /// auto-scales with [lineHeight].
  final TextStyle? percentageTextStyle;

  /// Formats the value shown by [showPercentageText]. Defaults to
  /// `'${(value * 100).round()}%'`.
  final String Function(double value)? percentageFormatter;

  /// Alignment of [leading]/bar/[trailing] along the row.
  final MainAxisAlignment mainAxisAlignment;

  /// Cross-axis alignment of [leading]/bar/[trailing].
  final CrossAxisAlignment crossAxisAlignment;

  /// Fills from the right instead of the left, independent of ambient
  /// [Directionality] — combines with [direction] (both flipped cancels
  /// out).
  final bool isRTL;

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

  /// Fill direction.
  final ACDLoaderDirection direction;

  /// Optional blur applied to the fill/track paint (a glow effect).
  final MaskFilter? maskFilter;

  /// A marker widget painted at the current progress position along the
  /// bar.
  final Widget? indicator;

  /// Keeps this indicator's animation state alive when it's a descendant of
  /// a scrollable that would otherwise dispose it while scrolled off
  /// screen.
  final bool keepAlive;

  /// Fires once a fill animation finishes.
  final VoidCallback? onAnimationEnd;

  /// Fires with the live, currently-animated value on every animation
  /// frame — handy for driving an external "42%" label.
  final ValueChanged<double>? onPercentChanged;

  @override
  State<ACDLinearPercentIndicator> createState() =>
      _ACDLinearPercentIndicatorState();
}

class _ACDLinearPercentIndicatorState extends State<ACDLinearPercentIndicator>
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
  void didUpdateWidget(covariant ACDLinearPercentIndicator oldWidget) {
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
    final double autoFontSize = (widget.lineHeight * 1.5).clamp(10.0, 96.0);
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
    final bool rtlFill =
        widget.isRTL != (widget.direction == ACDLoaderDirection.reverse);
    // A caller can round corners either explicitly (`barRadius`) or via
    // `strokeCap: round/roundAll` alone, which defaults to a full pill —
    // `barRadius` always wins when both are set.
    final Radius? effectiveBarRadius =
        widget.barRadius ??
        (widget.strokeCap == ACDLoaderStrokeCap.round ||
                widget.strokeCap == ACDLoaderStrokeCap.roundAll
            ? Radius.circular(widget.lineHeight / 2)
            : null);
    final Widget? centerContent = _buildPercentageText();

    Widget bar(double width) {
      Widget painted = CustomPaint(
        size: Size(width, widget.lineHeight),
        painter: _ACDLinearPercentIndicatorPainter(
          progress: currentAnimatedPercent,
          rtlFill: rtlFill,
          backgroundColor: widget.backgroundColor ?? const Color(0xFFB8C7CB),
          progressColor:
              widget.progressColor ?? Theme.of(context).colorScheme.primary,
          progressBorderColor: widget.progressBorderColor,
          backgroundBorderColor: widget.backgroundBorderColor,
          borderWidth: widget.borderWidth,
          linearGradient: widget.linearGradient,
          backgroundGradient: widget.backgroundGradient,
          strokeCap: widget.strokeCap,
          barRadius: effectiveBarRadius,
          maskFilter: widget.maskFilter,
        ),
      );
      if (widget.boxShadow != null) {
        painted = DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: effectiveBarRadius == null
                ? null
                : BorderRadius.all(effectiveBarRadius),
            boxShadow: widget.boxShadow,
          ),
          child: painted,
        );
      }
      if (centerContent == null && widget.indicator == null) return painted;
      return SizedBox(
        width: width,
        height: widget.lineHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: painted),
            if (centerContent != null) Center(child: centerContent),
            if (widget.indicator != null)
              Positioned(
                left: rtlFill ? null : (width * currentAnimatedPercent) - 8,
                right: rtlFill ? (width * currentAnimatedPercent) - 8 : null,
                top: (widget.lineHeight / 2) - 8,
                child: widget.indicator!,
              ),
          ],
        ),
      );
    }

    final Widget row = Row(
      mainAxisSize: widget.width == null ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: [
        if (widget.leading != null) widget.leading!,
        if (widget.width != null)
          bar(widget.width!)
        else
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => bar(constraints.maxWidth),
            ),
          ),
        if (widget.trailing != null) widget.trailing!,
      ],
    );

    return Padding(
      padding: widget.margin,
      child: Padding(
        padding: widget.padding,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : widget.disabledOpacity,
          child: row,
        ),
      ),
    );
  }
}

class _ACDLinearPercentIndicatorPainter extends CustomPainter {
  _ACDLinearPercentIndicatorPainter({
    required this.progress,
    required this.rtlFill,
    required this.backgroundColor,
    required this.strokeCap,
    required this.borderWidth,
    this.progressColor,
    this.progressBorderColor,
    this.backgroundBorderColor,
    this.linearGradient,
    this.backgroundGradient,
    this.barRadius,
    this.maskFilter,
  });

  final double progress;
  final bool rtlFill;
  final Color backgroundColor;
  final Color? progressColor;
  final Color? progressBorderColor;
  final Color? backgroundBorderColor;
  final double borderWidth;
  final Gradient? linearGradient;
  final Gradient? backgroundGradient;
  final ACDLoaderStrokeCap strokeCap;
  final Radius? barRadius;
  final MaskFilter? maskFilter;

  bool get _rounded => barRadius != null && barRadius != Radius.zero;

  void _strokeRect(Canvas canvas, Rect rect, Color color) {
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = color;
    if (_rounded) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, barRadius!), borderPaint);
    } else {
      canvas.drawRect(rect, borderPaint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect fullRect = Offset.zero & size;
    acdDrawLoaderBar(
      canvas,
      fullRect,
      acdLoaderFillPaint(
        shaderRect: fullRect,
        color: backgroundColor,
        gradient: backgroundGradient,
        maskFilter: maskFilter,
      ),
      strokeCap: strokeCap,
      radius: barRadius,
    );
    if (backgroundBorderColor != null) {
      _strokeRect(canvas, fullRect, backgroundBorderColor!);
    }

    if (progress <= 0) return;
    final double fillWidth = size.width * progress;
    final Rect fillRect = rtlFill
        ? Rect.fromLTWH(size.width - fillWidth, 0, fillWidth, size.height)
        : Rect.fromLTWH(0, 0, fillWidth, size.height);
    acdDrawLoaderBar(
      canvas,
      fillRect,
      acdLoaderFillPaint(
        shaderRect: fullRect,
        color: progressColor,
        gradient: linearGradient,
        maskFilter: maskFilter,
      ),
      strokeCap: strokeCap,
      radius: barRadius,
    );
    if (progressBorderColor != null) {
      _strokeRect(canvas, fillRect, progressBorderColor!);
    }
  }

  @override
  bool shouldRepaint(covariant _ACDLinearPercentIndicatorPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        rtlFill != oldDelegate.rtlFill ||
        backgroundColor != oldDelegate.backgroundColor ||
        progressColor != oldDelegate.progressColor ||
        progressBorderColor != oldDelegate.progressBorderColor ||
        backgroundBorderColor != oldDelegate.backgroundBorderColor ||
        borderWidth != oldDelegate.borderWidth ||
        linearGradient != oldDelegate.linearGradient ||
        backgroundGradient != oldDelegate.backgroundGradient ||
        strokeCap != oldDelegate.strokeCap ||
        barRadius != oldDelegate.barRadius ||
        maskFilter != oldDelegate.maskFilter;
  }
}
