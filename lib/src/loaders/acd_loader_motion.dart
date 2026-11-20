import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';

import '../design/acd_design.dart';
import '../design/acd_design_scope.dart';
import '../design/internal/acd_platform_support.dart';

/// How a percent loader draws its active (filled) track.
enum ACDLoaderStyle {
  /// A plain bar/ring — the classic look (default).
  flat,

  /// Material 3 Expressive: the active track is a gently moving sine wave
  /// (static under reduce motion).
  wavy,
}

// ── Internal widgets used by the linear / circular indicators ────────────────

/// Paints a linear loader that needs its own clock: indeterminate (a sweeping
/// segment) and/or [ACDLoaderStyle.wavy]. One controller, repainting only
/// this layer (`CustomPaint(repaint:)` + `RepaintBoundary`).
class ACDLinearLoaderMotion extends StatefulWidget {
  const ACDLinearLoaderMotion({
    super.key,
    required this.size,
    required this.trackColor,
    required this.progressColor,
    required this.radius,
    required this.indeterminate,
    required this.wavy,
    required this.progress,
    required this.rtl,
    required this.design,
  });

  final Size size;
  final Color trackColor;
  final Color progressColor;
  final Radius? radius;
  final bool indeterminate;
  final bool wavy;
  final double progress;
  final bool rtl;
  final ACDDesign? design;

  @override
  State<ACDLinearLoaderMotion> createState() => _ACDLinearLoaderMotionState();
}

class _ACDLinearLoaderMotionState extends State<ACDLinearLoaderMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant ACDLinearLoaderMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    // Indeterminate must keep moving to mean anything; a wave alone is
    // decoration and freezes under reduce motion.
    final bool run =
        widget.indeterminate || (widget.wavy && !acdReduceMotion(context));
    final Duration period = widget.indeterminate
        ? Duration(milliseconds: acdReduceMotion(context) ? 2400 : 1600)
        : const Duration(milliseconds: 1000);
    if (_clock.duration != period) _clock.duration = period;
    if (run && !_clock.isAnimating) {
      _clock.repeat();
    } else if (!run && _clock.isAnimating) {
      _clock.stop();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget painted = RepaintBoundary(
      child: CustomPaint(
        size: widget.size,
        painter: _ACDLinearMotionPainter(
          clock: _clock,
          trackColor: widget.trackColor,
          progressColor: widget.progressColor,
          radius: widget.radius,
          indeterminate: widget.indeterminate,
          wavy: widget.wavy,
          progress: widget.progress,
          rtl: widget.rtl,
        ),
      ),
    );
    if (!widget.indeterminate) return painted;
    return Semantics(
      label: ACDDesignScope.stringsOf(context).loading,
      child: painted,
    );
  }
}

class _ACDLinearMotionPainter extends CustomPainter {
  _ACDLinearMotionPainter({
    required this.clock,
    required this.trackColor,
    required this.progressColor,
    required this.radius,
    required this.indeterminate,
    required this.wavy,
    required this.progress,
    required this.rtl,
  }) : super(repaint: clock);

  final Animation<double> clock;
  final Color trackColor;
  final Color progressColor;
  final Radius? radius;
  final bool indeterminate;
  final bool wavy;
  final double progress;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Radius r = radius ?? Radius.zero;

    // Track (full width).
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, r),
      Paint()..color = trackColor,
    );

    // Active span along the bar, in logical (start→end) units.
    double from;
    double to;
    if (indeterminate) {
      // A segment sweeping across with an eased head and tail.
      final double t = clock.value;
      to = Curves.easeInOut.transform(t.clamp(0.0, 1.0)) * 1.4;
      from = Curves.easeIn.transform(t.clamp(0.0, 1.0)) * 1.4 - 0.4;
      from = from.clamp(0.0, 1.0) * w;
      to = to.clamp(0.0, 1.0) * w;
    } else {
      from = 0;
      to = progress.clamp(0.0, 1.0) * w;
    }
    if (to - from <= 0) return;
    if (rtl) {
      final double a = w - to;
      final double b = w - from;
      from = a;
      to = b;
    }

    final Paint active = Paint()..color = progressColor;
    if (!wavy) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(from, 0, to, h), r),
        active,
      );
      return;
    }

    // Wavy: a stroked sine path, kept inside the bar's height.
    final double amplitude = math.min(3.0, h / 4);
    final double stroke = math.max(2.0, h - 2 * amplitude);
    const double wavelength = 40;
    final double phase = clock.value * 2 * math.pi;
    final Path path = Path();
    for (double x = from; x <= to; x += 1) {
      final double y =
          h / 2 + amplitude * math.sin(2 * math.pi * x / wavelength - phase);
      if (x == from) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      active
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ACDLinearMotionPainter old) =>
      old.trackColor != trackColor ||
      old.progressColor != progressColor ||
      old.radius != radius ||
      old.indeterminate != indeterminate ||
      old.wavy != wavy ||
      old.progress != progress ||
      old.rtl != rtl;
}

/// The circular counterpart: indeterminate (Material: a rotating, breathing
/// arc; Cupertino: the iOS activity indicator) and/or a wavy ring.
class ACDCircularLoaderMotion extends StatefulWidget {
  const ACDCircularLoaderMotion({
    super.key,
    required this.diameter,
    required this.lineWidth,
    required this.trackColor,
    required this.progressColor,
    required this.indeterminate,
    required this.wavy,
    required this.progress,
    required this.reverse,
    required this.design,
  });

  final double diameter;
  final double lineWidth;
  final Color trackColor;
  final Color progressColor;
  final bool indeterminate;
  final bool wavy;
  final double progress;
  final bool reverse;
  final ACDDesign? design;

  @override
  State<ACDCircularLoaderMotion> createState() =>
      _ACDCircularLoaderMotionState();
}

class _ACDCircularLoaderMotionState extends State<ACDCircularLoaderMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this);

  bool get _cupertinoSpinner =>
      widget.indeterminate &&
      ACDDesign.resolve(context, widget.design).isCupertino;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant ACDCircularLoaderMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final bool run =
        !_cupertinoSpinner &&
        (widget.indeterminate || (widget.wavy && !acdReduceMotion(context)));
    final Duration period = widget.indeterminate
        ? const Duration(milliseconds: 1400)
        : const Duration(milliseconds: 1200);
    if (_clock.duration != period) _clock.duration = period;
    if (run && !_clock.isAnimating) {
      _clock.repeat();
    } else if (!run && _clock.isAnimating) {
      _clock.stop();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String loading = ACDDesignScope.stringsOf(context).loading;
    if (_cupertinoSpinner) {
      return Semantics(
        label: loading,
        child: SizedBox.square(
          dimension: widget.diameter,
          child: Center(
            child: CupertinoActivityIndicator(
              radius: widget.diameter / 2 * 0.6,
              color: widget.progressColor,
            ),
          ),
        ),
      );
    }
    final Widget painted = RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.diameter),
        painter: _ACDCircularMotionPainter(
          clock: _clock,
          lineWidth: widget.lineWidth,
          trackColor: widget.trackColor,
          progressColor: widget.progressColor,
          indeterminate: widget.indeterminate,
          wavy: widget.wavy,
          progress: widget.progress,
          reverse: widget.reverse,
        ),
      ),
    );
    if (!widget.indeterminate) return painted;
    return Semantics(label: loading, child: painted);
  }
}

class _ACDCircularMotionPainter extends CustomPainter {
  _ACDCircularMotionPainter({
    required this.clock,
    required this.lineWidth,
    required this.trackColor,
    required this.progressColor,
    required this.indeterminate,
    required this.wavy,
    required this.progress,
    required this.reverse,
  }) : super(repaint: clock);

  final Animation<double> clock;
  final double lineWidth;
  final Color trackColor;
  final Color progressColor;
  final bool indeterminate;
  final bool wavy;
  final double progress;
  final bool reverse;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double amplitude = wavy ? math.min(2.0, lineWidth / 2) : 0;
    final double radius =
        (math.min(size.width, size.height) - lineWidth) / 2 - amplitude;
    if (radius <= 0) return;

    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth,
    );

    double start;
    double sweep;
    if (indeterminate) {
      final double t = clock.value;
      // Rotate a full turn per cycle while the arc grows and shrinks.
      sweep = (0.1 + 0.65 * math.sin(t * math.pi)) * 2 * math.pi;
      start = -math.pi / 2 + t * 2 * math.pi * 1.5;
    } else {
      start = -math.pi / 2;
      sweep = progress.clamp(0.0, 1.0) * 2 * math.pi;
    }
    if (sweep <= 0) return;
    if (reverse) {
      start = start - sweep;
    }

    final Paint active = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;
    if (!wavy) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: radius),
        start,
        sweep,
        false,
        active,
      );
      return;
    }
    // Wavy ring: the radius oscillates around the arc.
    const int waves = 10;
    final double phase = clock.value * 2 * math.pi;
    final Path path = Path();
    final int steps = math.max(8, (sweep * radius / 2).round());
    for (int i = 0; i <= steps; i++) {
      final double a = start + sweep * i / steps;
      final double rr = radius + amplitude * math.sin(waves * a - phase);
      final Offset p = c + Offset(math.cos(a) * rr, math.sin(a) * rr);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, active);
  }

  @override
  bool shouldRepaint(covariant _ACDCircularMotionPainter old) =>
      old.lineWidth != lineWidth ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor ||
      old.indeterminate != indeterminate ||
      old.wavy != wavy ||
      old.progress != progress ||
      old.reverse != reverse;
}
