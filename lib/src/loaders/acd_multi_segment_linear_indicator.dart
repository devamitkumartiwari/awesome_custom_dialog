import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'acd_loader_paint.dart';
import 'acd_loader_segment.dart';
import 'acd_loader_stroke_cap.dart';

/// A row of independently-filled progress segments, each described by an
/// [ACDLoaderSegment].
///
/// ```dart
/// ACDMultiSegmentLinearIndicator(
///   segments: [
///     ACDLoaderSegment(key: 'download', percent: 0.6, color: Colors.blue),
///     ACDLoaderSegment(key: 'verify', percent: 0.2, color: Colors.orange),
///   ],
/// )
/// ```
///
/// [segments] is diffed by [ACDLoaderSegment.key] (falling back to index) on
/// every rebuild, so adding, removing, or reordering segments at runtime —
/// even mid-animation — is a plain, safe value update.
class ACDMultiSegmentLinearIndicator extends StatefulWidget {
  /// Creates an [ACDMultiSegmentLinearIndicator].
  const ACDMultiSegmentLinearIndicator({
    super.key,
    required this.segments,
    this.width,
    this.lineHeight = 8.0,
    this.barRadius,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.spacing = 4.0,
    this.backgroundColor,
    this.backgroundGradient,
    this.borderColor,
    this.borderWidth = 1.0,
    this.boxShadow,
    this.strokeCap = ACDLoaderStrokeCap.round,
    this.stripeEffect = false,
    this.stripeWidth = 10.0,
    this.stripeSpeed = 40.0,
    this.stripeColor = const Color(0x40FFFFFF),
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.linear,
    this.onAnimationEnd,
  });

  /// The segments to render, left to right.
  final List<ACDLoaderSegment> segments;

  /// Fixed total width. When `null`, fills the parent's available width.
  final double? width;

  /// Bar thickness, shared by every segment.
  final double lineHeight;

  /// Corner radius applied to each segment individually. Ignored when
  /// `null`.
  final Radius? barRadius;

  /// Padding around the whole row, inside [margin].
  final EdgeInsets padding;

  /// Space around the whole indicator, outside [padding].
  final EdgeInsets margin;

  /// Gap between adjacent segments.
  final double spacing;

  /// Default track color behind every segment's fill, overridable per
  /// segment via [ACDLoaderSegment.backgroundColor].
  final Color? backgroundColor;

  /// Default track gradient, overridable per segment via
  /// [ACDLoaderSegment.backgroundGradient].
  final Gradient? backgroundGradient;

  /// Default outline color drawn around each segment's fill, overridable
  /// per segment via [ACDLoaderSegment.borderColor].
  final Color? borderColor;

  /// Width of [borderColor]'s outline (or a segment's
  /// [ACDLoaderSegment.borderColor] outline).
  final double borderWidth;

  /// Drop shadow behind the whole row.
  final List<BoxShadow>? boxShadow;

  /// Default end-cap style, overridable per segment via
  /// [ACDLoaderSegment.strokeCap].
  final ACDLoaderStrokeCap strokeCap;

  /// Default marching-stripe overlay, overridable per segment via
  /// [ACDLoaderSegment.enableStripes].
  final bool stripeEffect;

  /// Width of each stripe band.
  final double stripeWidth;

  /// Stripe scroll speed, in logical pixels per second.
  final double stripeSpeed;

  /// Color of the marching stripe bands, painted over the fill.
  final Color stripeColor;

  /// Disables all animation when `false` — every value change snaps
  /// instantly.
  final bool animate;

  /// Duration of each segment's fill animation.
  final Duration animationDuration;

  /// Curve for [animationDuration].
  final Curve animationCurve;

  /// Fires once every segment's fill animation finishes.
  final VoidCallback? onAnimationEnd;

  @override
  State<ACDMultiSegmentLinearIndicator> createState() =>
      _ACDMultiSegmentLinearIndicatorState();
}

class _ACDMultiSegmentLinearIndicatorState
    extends State<ACDMultiSegmentLinearIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _fillController = AnimationController(
    vsync: this,
  )..addStatusListener(_onFillStatus);
  AnimationController? _stripeController;

  /// The most recently painted value per segment key — updated every
  /// animation frame, so the *next* animation always begins from here
  /// (never from a stale/hardcoded `0`).
  final Map<Object, double> _displayed = {};
  Map<Object, double> _animBegin = {};
  Map<Object, double> _animEnd = {};

  Object _keyFor(int index, ACDLoaderSegment segment) => segment.key ?? index;

  bool get _anySegmentStripes =>
      widget.stripeEffect || widget.segments.any((s) => s.enableStripes);

  @override
  void initState() {
    super.initState();
    _fillController.addListener(_onFillTick);
    for (int i = 0; i < widget.segments.length; i++) {
      _displayed[_keyFor(i, widget.segments[i])] = widget.animate
          ? 0.0
          : widget.segments[i].percent.clamp(0.0, 1.0);
    }
    if (widget.animate) _animateTo(widget.segments);
    _syncStripeController();
  }

  @override
  void didUpdateWidget(covariant ACDMultiSegmentLinearIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Set<Object> currentKeys = {
      for (int i = 0; i < widget.segments.length; i++)
        _keyFor(i, widget.segments[i]),
    };
    _displayed.removeWhere((key, _) => !currentKeys.contains(key));

    if (widget.animate && widget.animationDuration != Duration.zero) {
      _animateTo(widget.segments);
    } else {
      for (int i = 0; i < widget.segments.length; i++) {
        _displayed[_keyFor(i, widget.segments[i])] = widget.segments[i].percent
            .clamp(0.0, 1.0);
      }
      _animBegin = {};
      _animEnd = {};
      _fillController.stop();
    }
    _syncStripeController();
  }

  @override
  void dispose() {
    _fillController.dispose();
    _stripeController?.dispose();
    super.dispose();
  }

  void _syncStripeController() {
    if (_anySegmentStripes && _stripeController == null) {
      _stripeController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      )..repeat();
    } else if (!_anySegmentStripes && _stripeController != null) {
      _stripeController!.dispose();
      _stripeController = null;
    }
  }

  void _onFillStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) widget.onAnimationEnd?.call();
  }

  void _onFillTick() {
    if (_animEnd.isEmpty) return;
    final double t = widget.animationCurve.transform(_fillController.value);
    for (final Object key in _animEnd.keys) {
      final double begin = _animBegin[key] ?? 0.0;
      final double end = _animEnd[key]!;
      _displayed[key] = lerpDouble(begin, end, t) ?? end;
    }
  }

  void _animateTo(List<ACDLoaderSegment> segments) {
    // Capture the live (possibly mid-animation) value per key as the new
    // animation's begin — this is what keeps a rapid, repeated value change
    // from visibly snapping back to 0 before animating again.
    _animBegin = Map.of(_displayed);
    _animEnd = {
      for (int i = 0; i < segments.length; i++)
        _keyFor(i, segments[i]): segments[i].percent.clamp(0.0, 1.0),
    };
    for (final Object key in _animEnd.keys) {
      _animBegin.putIfAbsent(key, () => 0.0);
    }
    _fillController
      ..duration = widget.animationDuration
      ..value = 0;
    _fillController.forward();
  }

  double _valueFor(Object key, double fallback) => _displayed[key] ?? fallback;

  Widget _buildSegment(int i) {
    final ACDLoaderSegment segment = widget.segments[i];
    final ACDLoaderStrokeCap effectiveStrokeCap =
        segment.strokeCap ?? widget.strokeCap;
    // A segment can round its corners either explicitly (`borderRadius`/
    // `barRadius`) or via `strokeCap: round/roundAll` alone, which defaults
    // to a full pill — an explicit radius always wins when both are set.
    final Radius? effectiveBarRadius =
        segment.borderRadius ??
        widget.barRadius ??
        (effectiveStrokeCap == ACDLoaderStrokeCap.round ||
                effectiveStrokeCap == ACDLoaderStrokeCap.roundAll
            ? Radius.circular(widget.lineHeight / 2)
            : null);

    return Expanded(
      flex: (segment.flex * 1000).round(),
      child: SizedBox(
        height: widget.lineHeight,
        child: CustomPaint(
          painter: _ACDMultiSegmentPainter(
            progress: _valueFor(
              _keyFor(i, segment),
              segment.percent.clamp(0.0, 1.0),
            ),
            color: segment.color,
            gradient: segment.gradient,
            backgroundColor:
                segment.backgroundColor ??
                widget.backgroundColor ??
                const Color(0xFFB8C7CB),
            backgroundGradient:
                segment.backgroundGradient ?? widget.backgroundGradient,
            borderColor: segment.borderColor ?? widget.borderColor,
            borderWidth: segment.borderWidth ?? widget.borderWidth,
            strokeCap: effectiveStrokeCap,
            barRadius: effectiveBarRadius,
            stripes: segment.enableStripes || widget.stripeEffect,
            stripeWidth: widget.stripeWidth,
            stripeColor: widget.stripeColor,
            stripeOffset: (_stripeController?.value ?? 0) * widget.stripeSpeed,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: widget.padding,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _fillController,
          if (_stripeController != null) _stripeController!,
        ]),
        builder: (context, _) {
          final Widget row = Row(
            mainAxisSize: widget.width == null
                ? MainAxisSize.max
                : MainAxisSize.min,
            children: [
              for (int i = 0; i < widget.segments.length; i++) ...[
                if (i > 0) SizedBox(width: widget.spacing),
                _buildSegment(i),
              ],
            ],
          );
          return widget.width == null
              ? row
              : SizedBox(width: widget.width, child: row);
        },
      ),
    );
    if (widget.boxShadow != null) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: widget.barRadius == null
              ? null
              : BorderRadius.all(widget.barRadius!),
          boxShadow: widget.boxShadow,
        ),
        child: content,
      );
    }
    return Padding(padding: widget.margin, child: content);
  }
}

class _ACDMultiSegmentPainter extends CustomPainter {
  _ACDMultiSegmentPainter({
    required this.progress,
    required this.backgroundColor,
    required this.strokeCap,
    required this.borderWidth,
    required this.stripes,
    required this.stripeWidth,
    required this.stripeColor,
    required this.stripeOffset,
    this.color,
    this.gradient,
    this.backgroundGradient,
    this.borderColor,
    this.barRadius,
  });

  final double progress;
  final Color? color;
  final Gradient? gradient;
  final Color backgroundColor;
  final Gradient? backgroundGradient;
  final Color? borderColor;
  final double borderWidth;
  final ACDLoaderStrokeCap strokeCap;
  final Radius? barRadius;
  final bool stripes;
  final double stripeWidth;
  final Color stripeColor;
  final double stripeOffset;

  bool get _rounded => barRadius != null && barRadius != Radius.zero;

  void _strokeRect(Canvas canvas, Rect rect) {
    if (borderColor == null) return;
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = borderColor!;
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
      ),
      strokeCap: strokeCap,
      radius: barRadius,
    );
    _strokeRect(canvas, fullRect);

    if (progress <= 0) return;
    final Rect fillRect = Rect.fromLTWH(
      0,
      0,
      size.width * progress,
      size.height,
    );

    canvas.save();
    if (_rounded) {
      canvas.clipRRect(RRect.fromRectAndRadius(fillRect, barRadius!));
    } else {
      canvas.clipRect(fillRect);
    }
    acdDrawLoaderBar(
      canvas,
      fillRect,
      acdLoaderFillPaint(
        shaderRect: fullRect,
        color: color ?? const Color(0xFF2962FF),
        gradient: gradient,
      ),
      strokeCap: strokeCap,
      radius: barRadius,
    );

    if (stripes) {
      final Paint stripePaint = Paint()..color = stripeColor;
      final double step = stripeWidth * 2;
      final double offset = stripeOffset % step;
      for (
        double x = -size.height - step + offset;
        x < size.width + size.height;
        x += step
      ) {
        final Path stripe = Path()
          ..moveTo(x, size.height)
          ..lineTo(x + size.height, 0)
          ..lineTo(x + size.height + stripeWidth, 0)
          ..lineTo(x + stripeWidth, size.height)
          ..close();
        canvas.drawPath(stripe, stripePaint);
      }
    }
    canvas.restore();
    _strokeRect(canvas, fillRect);
  }

  @override
  bool shouldRepaint(covariant _ACDMultiSegmentPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        gradient != oldDelegate.gradient ||
        backgroundColor != oldDelegate.backgroundColor ||
        backgroundGradient != oldDelegate.backgroundGradient ||
        borderColor != oldDelegate.borderColor ||
        borderWidth != oldDelegate.borderWidth ||
        strokeCap != oldDelegate.strokeCap ||
        barRadius != oldDelegate.barRadius ||
        stripes != oldDelegate.stripes ||
        stripeColor != oldDelegate.stripeColor ||
        stripeOffset != oldDelegate.stripeOffset;
  }
}
