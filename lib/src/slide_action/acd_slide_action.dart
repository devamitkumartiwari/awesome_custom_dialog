import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/physics.dart';

import '../design/internal/acd_physics.dart';

import '../design/acd_design.dart';
import '../design/acd_design_tokens.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../design/internal/acd_platform_support.dart';
import 'acd_slide_action_controller.dart';
import 'acd_slide_action_direction.dart';
import 'acd_slide_action_shape.dart';
import 'acd_slide_action_status.dart';

/// Builds a piece of an [ACDSlideAction] given the current drag [progress]
/// (`0.0`–`1.0`, signed towards the active drag direction) and [status].
typedef ACDSlideActionBuilder = Widget Function(
  BuildContext context,
  double progress,
  ACDSlideActionStatus status,
);

/// A "slide/swipe to confirm" action bar — a dependency-free, fully
/// customizable widget for requiring a deliberate drag gesture before an
/// action fires.
///
/// Drag the thumb past [dismissThreshold] to fire [onConfirm]. Pair with an
/// [ACDSlideActionController] to drive the loading/success feedback for an
/// async action:
///
/// ```dart
/// final controller = ACDSlideActionController();
/// ACDSlideAction(
///   controller: controller,
///   label: 'Slide to confirm',
///   onConfirm: () async {
///     controller.loading();
///     final ok = await submit();
///     ok ? controller.success() : controller.reset();
///   },
/// );
/// ```
///
/// For a ready-made, polished look with no styling required, use
/// [ACDSlideAction.swipeButton] instead.
class ACDSlideAction extends StatefulWidget {
  /// Creates an [ACDSlideAction].
  const ACDSlideAction({
    super.key,
    required this.onConfirm,
    this.controller,
    this.shape = ACDSlideActionShape.rectangle,
    this.direction = ACDSlideActionDirection.startToEnd,
    this.height = 56,
    this.width,
    this.stretchToFill = true,
    this.borderRadius,
    this.dismissThreshold = 0.85,
    this.snapBackDuration = const Duration(milliseconds: 300),
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOut,
    this.design,
    this.enabled = true,
    this.thumbColor,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.thumbSize,
    this.thumbPadding = 4.0,
    this.thumbBorderRadius,
    this.thumbIcon,
    this.thumbWidget,
    this.thumbGradient,
    this.activeThumbGradient,
    this.inactiveThumbGradient,
    this.trackColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.trackGradient,
    this.activeTrackGradient,
    this.inactiveTrackGradient,
    this.trackPadding = EdgeInsets.zero,
    this.blurTrack = false,
    this.elevation = 2.0,
    this.elevationThumb,
    this.elevationTrack,
    this.boxShadow,
    this.label,
    this.labelWidget,
    this.labelTextStyle,
    this.shimmerOnLabel = false,
    this.shimmerColor,
    this.showWaveTrail = false,
    this.waveColor,
    this.successIcon = Icons.check,
    this.successColor,
    this.loadingWidget,
    this.hapticFeedbackOnSuccess = true,
    this.autoResetAfter,
    this.onSlideChanged,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.outerBackgroundBuilder,
  }) : assert(
         dismissThreshold > 0 && dismissThreshold <= 1,
         'dismissThreshold must be within (0, 1]',
       );

  /// A ready-made, polished preset — a moderately-rounded track, a raised
  /// square-ish thumb, and distinct active/inactive track and thumb colors —
  /// with no styling required.
  ///
  /// ```dart
  /// ACDSlideAction.swipeButton(
  ///   label: 'Swipe to pay',
  ///   onConfirm: () => debugPrint('Paid'),
  /// )
  /// ```
  ///
  /// Every parameter here also exists on the base [ACDSlideAction]
  /// constructor; this preset just supplies ready-made defaults for a
  /// subset of them. Drop down to the base constructor
  /// directly for anything not exposed here (shape, direction, gradients,
  /// wave trail, shimmer, custom builders, and so on).
  const ACDSlideAction.swipeButton({
    Key? key,
    required VoidCallback onConfirm,
    ACDSlideActionController? controller,
    double height = 52,
    double? width,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
    Color inactiveTrackColor = const Color(0xFFEDEDED),
    Color activeTrackColor = const Color(0xFFE0E0E0),
    Color inactiveThumbColor = const Color(0xFF2962FF),
    Color activeThumbColor = const Color(0xFF1E4BD8),
    double thumbPadding = 4,
    EdgeInsets trackPadding = EdgeInsets.zero,
    double elevationThumb = 2,
    double elevationTrack = 0,
    IconData thumbIcon = Icons.arrow_forward,
    String? label,
    TextStyle? labelTextStyle,
    bool enabled = true,
    Duration? autoResetAfter,
  }) : this(
         key: key,
         onConfirm: onConfirm,
         controller: controller,
         height: height,
         width: width,
         stretchToFill: width == null,
         borderRadius: borderRadius,
         inactiveTrackColor: inactiveTrackColor,
         activeTrackColor: activeTrackColor,
         inactiveThumbColor: inactiveThumbColor,
         activeThumbColor: activeThumbColor,
         thumbPadding: thumbPadding,
         trackPadding: trackPadding,
         elevationThumb: elevationThumb,
         elevationTrack: elevationTrack,
         thumbIcon: thumbIcon,
         label: label,
         labelTextStyle: labelTextStyle,
         enabled: enabled,
         autoResetAfter: autoResetAfter,
       );

  /// Fired once a drag crosses [dismissThreshold] and is released. Typically
  /// drives [controller] through `loading()`/`success()`/`reset()`.
  final VoidCallback onConfirm;

  /// Material (default) / Cupertino / adaptive — see [ACDDesign]. Affects
  /// the default track color and the loading spinner.
  final ACDDesign? design;

  /// Drives the post-confirm lifecycle from outside the widget. Owned and
  /// disposed internally when left null.
  final ACDSlideActionController? controller;

  /// The default thumb/track shape (ignored when [thumbWidget] and a
  /// [foregroundBuilder] together fully replace the default visuals).
  final ACDSlideActionShape shape;

  /// The direction(s) the thumb can be dragged to confirm.
  final ACDSlideActionDirection direction;

  /// The bar's height.
  final double height;

  /// A fixed width. When null, see [stretchToFill].
  final double? width;

  /// When [width] is null and this is true (the default), the bar fills the
  /// available width. When false, it falls back to a fixed intrinsic width.
  final bool stretchToFill;

  /// Corner rounding for the default track/thumb. Defaults to fully rounded
  /// (pill shape) when null.
  final BorderRadius? borderRadius;

  /// Fraction (0, 1] of the track the thumb must cross, on release, to
  /// confirm instead of snapping back.
  final double dismissThreshold;

  /// Duration of the snap-back animation when released below
  /// [dismissThreshold].
  final Duration snapBackDuration;

  /// Duration of programmatic transitions: confirm-glide, loading/success
  /// feedback, and reset.
  final Duration animationDuration;

  /// Curve used for [animationDuration]-driven transitions.
  final Curve animationCurve;

  /// Disables dragging and greys out the bar when false.
  final bool enabled;

  /// The default thumb's color, while idle and not being dragged. Ignored
  /// once dragging starts if [activeThumbColor] is set.
  final Color? thumbColor;

  /// The default thumb's color while being actively dragged (`status ==
  /// ACDSlideActionStatus.dragging`). Falls back to [thumbColor] when null —
  /// set both to get distinct active/inactive thumb colors.
  final Color? activeThumbColor;

  /// The default thumb's color while idle (not being dragged). Falls back to
  /// [thumbColor] when null.
  final Color? inactiveThumbColor;

  /// The default thumb's diameter/side length. Defaults to [height] minus
  /// `thumbPadding * 2`.
  final double? thumbSize;

  /// Inset between the thumb and the track's top/bottom edge, used to derive
  /// [thumbSize] when it isn't set explicitly. Defaults to 4.
  final double thumbPadding;

  /// Corner rounding for the default thumb, when [shape] is
  /// [ACDSlideActionShape.rectangle]. Defaults to matching the track's own
  /// rounding (see [borderRadius]) — a full pill by default — rather than a
  /// fixed fraction of [thumbSize], so the thumb reads as part of the same
  /// shape as the track instead of a plain rounded square.
  final BorderRadius? thumbBorderRadius;

  /// Icon shown on the default thumb while idle/dragging.
  final IconData? thumbIcon;

  /// Fully replaces the default thumb visuals (icon/spinner/checkmark still
  /// swap automatically based on [ACDSlideActionStatus] unless
  /// [foregroundBuilder] is also supplied).
  final Widget? thumbWidget;

  /// Gradient fill for the default thumb, while idle and not being dragged.
  /// Ignored once dragging starts if [activeThumbGradient] is set. Falls
  /// back to [thumbColor]/[activeThumbColor]/[inactiveThumbColor] when null.
  final Gradient? thumbGradient;

  /// Gradient fill for the default thumb while being actively dragged.
  /// Falls back to [thumbGradient] when null.
  final Gradient? activeThumbGradient;

  /// Gradient fill for the default thumb while idle (not being dragged).
  /// Falls back to [thumbGradient] when null.
  final Gradient? inactiveThumbGradient;

  /// The default track's color, while idle and not being dragged. Ignored
  /// once dragging starts if [activeTrackColor] is set.
  final Color? trackColor;

  /// The default track's color while being actively dragged. Falls back to
  /// [trackColor] when null — set both to get distinct active/inactive
  /// track colors.
  final Color? activeTrackColor;

  /// The default track's color while idle (not being dragged). Falls back to
  /// [trackColor] when null.
  final Color? inactiveTrackColor;

  /// Gradient fill for the default track, while idle and not being dragged,
  /// overriding the track color. Ignored once dragging starts if
  /// [activeTrackGradient] is set.
  final Gradient? trackGradient;

  /// Gradient fill for the default track while being actively dragged.
  /// Falls back to [trackGradient] when null.
  final Gradient? activeTrackGradient;

  /// Gradient fill for the default track while idle (not being dragged).
  /// Falls back to [trackGradient] when null.
  final Gradient? inactiveTrackGradient;

  /// Insets the painted track inside the widget's own bounds. Defaults to
  /// no inset (the track fills the whole widget).
  final EdgeInsets trackPadding;

  /// Frosted-glass blur applied behind the track.
  final bool blurTrack;

  /// Drop-shadow elevation shared by the default track and thumb when
  /// [elevationTrack]/[elevationThumb] aren't set. Ignored when [boxShadow]
  /// is supplied.
  final double elevation;

  /// Drop-shadow elevation for the default thumb specifically. Falls back to
  /// [elevation] when null — set both [elevationThumb] and [elevationTrack]
  /// to shadow them independently.
  final double? elevationThumb;

  /// Drop-shadow elevation for the default track specifically. Falls back to
  /// [elevation] when null.
  final double? elevationTrack;

  /// Explicit shadow for the default track/thumb, overriding [elevation],
  /// [elevationThumb], and [elevationTrack].
  final List<BoxShadow>? boxShadow;

  /// Label text shown centered on the track. Ignored when [labelWidget] is
  /// supplied.
  final String? label;

  /// Fully replaces the default label widget.
  final Widget? labelWidget;

  /// Text style for [label].
  final TextStyle? labelTextStyle;

  /// Animates a shimmer sweep across the label.
  final bool shimmerOnLabel;

  /// Shimmer highlight color, when [shimmerOnLabel] is true.
  final Color? shimmerColor;

  /// Paints an animated trail behind the thumb as it's dragged.
  final bool showWaveTrail;

  /// Trail color, when [showWaveTrail] is true.
  final Color? waveColor;

  /// Icon the thumb morphs into on [ACDSlideActionStatus.success].
  final IconData successIcon;

  /// Track/thumb color while [ACDSlideActionStatus.success]. Defaults to
  /// [Colors.green].
  final Color? successColor;

  /// Widget shown on the thumb while [ACDSlideActionStatus.loading].
  /// Defaults to a small [CircularProgressIndicator].
  final Widget? loadingWidget;

  /// Whether to trigger a light haptic (honouring `ACDDesignScope.hapticsEnabled`) once
  /// [ACDSlideActionStatus.success] is reached.
  final bool hapticFeedbackOnSuccess;

  /// After a confirm, slides the thumb back and re-arms the action once
  /// this much time has passed (also resetting a [controller] that is in
  /// `loading`/`success`). `null` (the default) keeps it confirmed until
  /// [ACDSlideActionController.reset] is called — without a [controller]
  /// that means the action confirms exactly once.
  final Duration? autoResetAfter;

  /// Fires continuously during a drag with the signed progress
  /// (`-1.0`–`1.0`).
  final ValueChanged<double>? onSlideChanged;

  /// Fully replaces the thumb.
  final ACDSlideActionBuilder? foregroundBuilder;

  /// Fully replaces the label/content layer, in front of the track but
  /// behind the thumb.
  final ACDSlideActionBuilder? backgroundBuilder;

  /// Fully replaces the outer track background.
  final ACDSlideActionBuilder? outerBackgroundBuilder;

  @override
  State<ACDSlideAction> createState() => _ACDSlideActionState();
}

class _ACDSlideActionState extends State<ACDSlideAction>
    with TickerProviderStateMixin {
  /// The thumb offset in pixels from its resting position (unbounded:
  /// positive towards the end for [ACDSlideActionDirection.startToEnd]/
  /// `dual`, negative towards the start for `endToStart`). Drags write it
  /// directly, programmatic moves animate it and releases spring it — only
  /// the [AnimatedBuilder] subtree repaints, never this State's build.
  late final AnimationController _extent;
  AnimationController? _shimmerController;
  ACDSlideActionController? _ownedController;

  /// The thumb offset, clamped to the track (a released spring may briefly
  /// overshoot the controller value; the thumb never leaves the track).
  double get _dragExtent {
    final double v = _extent.value;
    return v.clamp(-_trackExtent, _trackExtent);
  }

  /// Max drag distance in pixels, recomputed each build from layout.
  double _trackExtent = 1.0;

  /// Whether the user currently has a finger/pointer down on the bar —
  /// drives [ACDSlideAction.activeThumbColor]/[ACDSlideAction.activeTrackColor].
  bool _dragging = false;

  /// Set once [ACDSlideAction.onConfirm] fires; blocks a second confirm
  /// (a tiny drag at the end, or the screen-reader/keyboard activate) until
  /// the controller is reset or [ACDSlideAction.autoResetAfter] elapses.
  bool _confirmed = false;
  Timer? _autoResetTimer;

  /// The last laid-out travel, to re-snap a confirmed thumb when it changes
  /// (first layout, rotation, resize).
  double? _laidOutExtent;

  ACDSlideActionController get _controller =>
      widget.controller ?? (_ownedController ??= ACDSlideActionController());

  @override
  void initState() {
    super.initState();
    _extent = AnimationController.unbounded(vsync: this);
    _controller.addListener(_onControllerChanged);
    if (widget.shimmerOnLabel) {
      _shimmerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      )..repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ACDSlideAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownedController)?.removeListener(
        _onControllerChanged,
      );
      _controller.addListener(_onControllerChanged);
    }
    if (widget.shimmerOnLabel && _shimmerController == null) {
      _shimmerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      )..repeat();
    } else if (!widget.shimmerOnLabel && _shimmerController != null) {
      _shimmerController!.dispose();
      _shimmerController = null;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _extent.dispose();
    _shimmerController?.dispose();
    _ownedController?.dispose();
    _autoResetTimer?.cancel();
    super.dispose();
  }

  bool get _rtl => Directionality.of(context) == TextDirection.rtl;

  double get _progress => _trackExtent == 0
      ? 0
      : (_dragExtent.abs() / _trackExtent).clamp(0.0, 1.0);

  void _onControllerChanged() {
    switch (_controller.status) {
      case ACDSlideActionStatus.loading:
        unawaited(_animateTo(_confirmedExtent(), widget.animationDuration));
      case ACDSlideActionStatus.success:
        unawaited(
          _animateTo(_confirmedExtent(), widget.animationDuration).then((
            completed,
          ) {
            if (completed && mounted && widget.hapticFeedbackOnSuccess) {
              ACDHaptics.light(context);
            }
          }),
        );
      case ACDSlideActionStatus.idle:
        _confirmed = false;
        _autoResetTimer?.cancel();
        unawaited(_animateTo(0, widget.animationDuration));
      case ACDSlideActionStatus.dragging:
        break;
    }
    setState(() {});
  }

  double _confirmedExtent() {
    if (widget.direction == ACDSlideActionDirection.endToStart) {
      return -_trackExtent;
    }
    return _trackExtent;
  }

  /// Returns `true` when the motion ran to completion (or there was nothing
  /// to animate), `false` when it was superseded/cancelled — so callers
  /// never fire follow-up effects (e.g. [ACDSlideAction.onConfirm]) for an
  /// interrupted animation. Instant under reduce motion.
  Future<bool> _animateTo(double target, Duration duration) async {
    if (!mounted) return false;
    if (_extent.value == target) return true;
    if (acdReduceMotion(context)) {
      _extent.value = target;
      return true;
    }
    try {
      await _extent
          .animateTo(target, duration: duration, curve: widget.animationCurve)
          .orCancel;
      return mounted;
    } on TickerCanceled {
      // Superseded by a newer run, a drag, or dispose.
      return false;
    }
  }

  /// Springs the thumb to [target] carrying the release [velocity] (px/s).
  /// Same completion contract as [_animateTo].
  Future<bool> _springTo(double target, double velocity) async {
    if (!mounted) return false;
    if (acdReduceMotion(context)) {
      _extent.value = target;
      return true;
    }
    try {
      await _extent
          .animateWith(
            SpringSimulation(
              acdThumbSpring,
              _extent.value,
              target,
              velocity,
              tolerance: const Tolerance(distance: 0.5, velocity: 5),
            ),
          )
          .orCancel;
      _extent.value = target; // land exactly, whatever the tolerance
      return mounted;
    } on TickerCanceled {
      return false;
    }
  }

  void _fireConfirm() {
    if (_confirmed) return;
    _confirmed = true;
    widget.onConfirm();
    final Duration? after = widget.autoResetAfter;
    if (after == null) return;
    _autoResetTimer?.cancel();
    _autoResetTimer = Timer(after, () {
      if (!mounted) return;
      if (_controller.status == ACDSlideActionStatus.idle) {
        setState(() => _confirmed = false);
        unawaited(_animateTo(0, widget.animationDuration));
      } else {
        _controller.reset(); // listener re-arms and slides back
      }
    });
  }

  bool get _interactive =>
      widget.enabled &&
      !_confirmed &&
      (_controller.status == ACDSlideActionStatus.idle ||
          _controller.status == ACDSlideActionStatus.dragging);

  void _onDragStart(DragStartDetails details) {
    if (!_interactive) return;
    _extent.stop();
    _extent.value = _dragExtent; // drop any spring overshoot
    setState(() => _dragging = true);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_interactive) return;
    double delta = details.delta.dx;
    if (_rtl) delta = -delta;
    final bool wasPast = _progress >= widget.dismissThreshold;
    final double next = _extent.value + delta;
    // No setState: the AnimatedBuilder repaints from the controller.
    _extent.value = switch (widget.direction) {
      ACDSlideActionDirection.startToEnd => next.clamp(0.0, _trackExtent),
      ACDSlideActionDirection.endToStart => next.clamp(-_trackExtent, 0.0),
      ACDSlideActionDirection.dual => next.clamp(-_trackExtent, _trackExtent),
    };
    // A tick when the release point would now confirm (and when it no
    // longer would) — tells the user without looking.
    if (wasPast != (_progress >= widget.dismissThreshold)) {
      ACDHaptics.selection(context);
    }
    widget.onSlideChanged?.call(
      _trackExtent == 0 ? 0 : _dragExtent / _trackExtent,
    );
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    setState(() => _dragging = false);
    if (!_interactive) return;
    double velocity = details.primaryVelocity ?? 0;
    if (_rtl) velocity = -velocity;
    final double sign = _dragExtent == 0
        ? (widget.direction == ACDSlideActionDirection.endToStart ? -1 : 1)
        : _dragExtent.sign;
    // Velocity towards the confirm end, in tracks per second.
    final double towards = _trackExtent == 0
        ? 0
        : velocity * sign / _trackExtent;
    // Confirm past the threshold, or on a decisive flick from > 30 %.
    final bool confirm =
        _progress >= widget.dismissThreshold ||
        (towards > 2.0 && _progress > 0.3);
    if (confirm) {
      final bool completed = await _springTo(
        sign * _trackExtent,
        // Carry a flick that points the right way; ignore a reversed one.
        velocity * sign > 0 ? velocity : 0,
      );
      if (completed) _fireConfirm();
    } else if (velocity == 0) {
      await _animateTo(0, widget.snapBackDuration);
    } else {
      await _springTo(0, velocity);
    }
  }

  Future<void> _confirmWithoutDrag() async {
    if (!_interactive || _trackExtent == 0) return;
    final bool completed = await _animateTo(
      _confirmedExtent(),
      widget.animationDuration,
    );
    if (completed) _fireConfirm();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The label shimmer loops forever — exactly what reduce motion opts out
    // of.
    final AnimationController? shimmer = _shimmerController;
    if (shimmer == null) return;
    if (acdReduceMotion(context)) {
      shimmer.stop();
    } else if (!shimmer.isAnimating) {
      shimmer.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ACDSlideActionStatus status = _controller.status;
    final ACDResolvedDesign design = ACDDesign.resolve(context, widget.design);
    final ACDDesignTokens tokens = ACDDesignTokens.of(context, design);
    final BorderRadius radius =
        widget.borderRadius ?? BorderRadius.circular(widget.height / 2);
    final Color baseTrackColor = _dragging
        ? (widget.activeTrackColor ?? widget.trackColor ?? tokens.primary)
        : (widget.inactiveTrackColor ?? widget.trackColor ?? tokens.primary);
    final Color effectiveTrackColor = status == ACDSlideActionStatus.success
        ? (widget.successColor ??
              (design.isCupertino ? tokens.success : Colors.green))
        : baseTrackColor;
    final Gradient? baseTrackGradient = _dragging
        ? (widget.activeTrackGradient ?? widget.trackGradient)
        : (widget.inactiveTrackGradient ?? widget.trackGradient);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double requested =
            widget.width ??
            (widget.stretchToFill ? constraints.maxWidth : 280.0);
        // Inside a Row/horizontal list `maxWidth` is unbounded; a
        // SizedBox(width: infinity) would throw, so fall back to the
        // intrinsic default instead.
        final double totalWidth = requested.isFinite ? requested : 280.0;
        final double insetWidth = totalWidth - widget.trackPadding.horizontal;
        final double insetHeight = widget.height - widget.trackPadding.vertical;
        final double thumbSize =
            widget.thumbSize ?? insetHeight - widget.thumbPadding * 2;
        final double fullTravel = (insetWidth - thumbSize - 8).clamp(
          1.0,
          double.infinity,
        );
        // `dual` starts centred, so each side only has half the travel.
        _trackExtent = widget.direction == ACDSlideActionDirection.dual
            ? math.max(1.0, fullTravel / 2)
            : fullTravel;
        if (_laidOutExtent != _trackExtent) {
          _laidOutExtent = _trackExtent;
          // A status set before the first layout (or a resize) animated to
          // a stale extent: land a confirmed thumb on the real end.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _dragging || _extent.isAnimating) return;
            final bool atEnd =
                _confirmed ||
                _controller.status == ACDSlideActionStatus.loading ||
                _controller.status == ACDSlideActionStatus.success;
            if (atEnd) _extent.value = _confirmedExtent();
          });
        }

        // Only this subtree follows the thumb frame-by-frame.
        final Widget content = AnimatedBuilder(
          animation: _extent,
          builder: (context, _) {
            Widget track =
                widget.outerBackgroundBuilder?.call(
                  context,
                  _dragExtent,
                  status,
                ) ??
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: baseTrackGradient == null
                        ? effectiveTrackColor
                        : null,
                    gradient: status == ACDSlideActionStatus.success
                        ? null
                        : baseTrackGradient,
                    borderRadius: radius,
                    boxShadow:
                        widget.boxShadow ??
                        (() {
                          final double trackElevation =
                              widget.elevationTrack ?? widget.elevation;
                          return trackElevation > 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: trackElevation * 2,
                                    offset: Offset(0, trackElevation / 2),
                                  ),
                                ]
                              : null;
                        })(),
                  ),
                );

            if (widget.blurTrack) {
              track = ClipRRect(
                borderRadius: radius,
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: track,
                ),
              );
            }

            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: track),
                if (widget.showWaveTrail)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ACDWaveTrailPainter(
                        dragExtent: _dragExtent,
                        trackExtent: _trackExtent,
                        thumbSize: thumbSize,
                        rtl: _rtl,
                        direction: widget.direction,
                        color:
                            widget.waveColor ??
                            Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Center(
                    child:
                        widget.backgroundBuilder?.call(
                          context,
                          _dragExtent,
                          status,
                        ) ??
                        _buildLabel(context),
                  ),
                ),
                _buildThumb(
                  context,
                  status,
                  thumbSize,
                  radius,
                  insetWidth,
                  insetHeight,
                ),
              ],
            );
          },
        );

        // Screen-reader / keyboard users can't drag: expose a button whose
        // activation plays the confirm slide and then fires onConfirm.
        return Semantics(
          button: true,
          enabled: _interactive,
          label: widget.label,
          // The visible label text would otherwise be announced twice.
          excludeSemantics: widget.label != null,
          onTap: _interactive ? _confirmWithoutDrag : null,
          child: FocusableActionDetector(
            enabled: _interactive,
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  _confirmWithoutDrag();
                  return null;
                },
              ),
            },
            child: Opacity(
              opacity: widget.enabled ? 1.0 : 0.5,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: _onDragStart,
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: (d) => unawaited(_onDragEnd(d)),
                child: SizedBox(
                  height: widget.height,
                  width: totalWidth,
                  child: Padding(padding: widget.trackPadding, child: content),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(BuildContext context) {
    if (widget.labelWidget != null) return widget.labelWidget!;
    if (widget.label == null) return const SizedBox.shrink();
    final TextStyle style =
        widget.labelTextStyle ??
        const TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
    final Text text = Text(widget.label!, style: style);
    if (!widget.shimmerOnLabel || _shimmerController == null) return text;
    // The shimmer repaints every frame: keep it off the track's layer.
    return RepaintBoundary(child: _shimmer(style, text));
  }

  Widget _shimmer(TextStyle style, Text text) {
    return AnimatedBuilder(
      animation: _shimmerController!,
      builder: (context, child) {
        final double t = _shimmerController!.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                style.color ?? Colors.white,
                widget.shimmerColor ?? Colors.white,
                style.color ?? Colors.white,
              ],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment(-1.0 - 2 * t, 0),
              end: Alignment(1.0 - 2 * t + 2, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: text,
    );
  }

  Widget _buildThumb(
    BuildContext context,
    ACDSlideActionStatus status,
    double thumbSize,
    BorderRadius trackRadius,
    double insetWidth,
    double insetHeight,
  ) {
    Widget thumbChild;
    if (widget.foregroundBuilder != null) {
      thumbChild = widget.foregroundBuilder!(context, _dragExtent, status);
    } else {
      thumbChild = _defaultThumb(status, thumbSize, trackRadius);
    }

    final Widget positioned;
    switch (widget.direction) {
      case ACDSlideActionDirection.startToEnd:
        positioned = PositionedDirectional(
          start: 4 + _dragExtent,
          top: (insetHeight - thumbSize) / 2,
          child: thumbChild,
        );
      case ACDSlideActionDirection.endToStart:
        positioned = PositionedDirectional(
          end: 4 - _dragExtent,
          top: (insetHeight - thumbSize) / 2,
          child: thumbChild,
        );
      case ACDSlideActionDirection.dual:
        // Directional: _dragExtent is in reading direction (the drag delta
        // is negated under RTL), so `start` keeps the thumb under the finger.
        positioned = PositionedDirectional(
          start: insetWidth / 2 - thumbSize / 2 + _dragExtent,
          top: (insetHeight - thumbSize) / 2,
          child: thumbChild,
        );
    }
    return positioned;
  }

  Widget _defaultThumb(
    ACDSlideActionStatus status,
    double thumbSize,
    BorderRadius trackRadius,
  ) {
    if (widget.thumbWidget != null && widget.foregroundBuilder == null) {
      return SizedBox(
        width: thumbSize,
        height: thumbSize,
        child: widget.thumbWidget,
      );
    }

    final Color baseThumbColor = _dragging
        ? (widget.activeThumbColor ?? widget.thumbColor ?? Colors.white)
        : (widget.inactiveThumbColor ?? widget.thumbColor ?? Colors.white);
    final Color color = status == ACDSlideActionStatus.success
        ? (widget.successColor ?? Colors.green)
        : baseThumbColor;
    final Gradient? baseThumbGradient = _dragging
        ? (widget.activeThumbGradient ?? widget.thumbGradient)
        : (widget.inactiveThumbGradient ?? widget.thumbGradient);

    Widget icon;
    switch (status) {
      case ACDSlideActionStatus.loading:
        icon =
            widget.loadingWidget ??
            SizedBox(
              width: thumbSize * 0.5,
              height: thumbSize * 0.5,
              child: ACDAdaptiveProgress(
                design: ACDDesign.resolve(context, widget.design),
                strokeWidth: 2,
              ),
            );
      case ACDSlideActionStatus.success:
        icon = Icon(
          widget.successIcon,
          color: Colors.white,
          size: thumbSize * 0.55,
        );
      case ACDSlideActionStatus.idle:
      case ACDSlideActionStatus.dragging:
        icon = widget.thumbIcon == null
            ? const SizedBox.shrink()
            : Transform.flip(
                // BUG FIX: the thumb's position/drag direction already
                // mirror under RTL, but a directional glyph like the
                // default arrow_forward kept pointing physically right —
                // flip it to match, same technique ACDSnackbarContent
                // already uses for its splash graphic.
                flipX: Directionality.of(context) == TextDirection.rtl,
                child: Icon(
                  widget.thumbIcon,
                  size: thumbSize * 0.55,
                  color:
                      ThemeData.estimateBrightnessForColor(color) ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              );
    }

    final BoxDecoration decoration = BoxDecoration(
      color: baseThumbGradient == null ? color : null,
      gradient: status == ACDSlideActionStatus.success
          ? null
          : baseThumbGradient,
      shape: widget.shape == ACDSlideActionShape.circle
          ? BoxShape.circle
          : BoxShape.rectangle,
      borderRadius: widget.shape == ACDSlideActionShape.circle
          ? null
          : (widget.thumbBorderRadius ?? trackRadius),
      boxShadow:
          widget.boxShadow ??
          (() {
            final double thumbElevation =
                widget.elevationThumb ?? widget.elevation;
            return thumbElevation > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: thumbElevation * 2,
                      offset: Offset(0, thumbElevation / 2),
                    ),
                  ]
                : null;
          })(),
    );

    return Container(
      width: thumbSize,
      height: thumbSize,
      decoration: decoration,
      alignment: Alignment.center,
      child: icon,
    );
  }
}

class _ACDWaveTrailPainter extends CustomPainter {
  _ACDWaveTrailPainter({
    required this.dragExtent,
    required this.trackExtent,
    required this.thumbSize,
    required this.rtl,
    required this.direction,
    required this.color,
  });

  final double dragExtent;
  final double trackExtent;
  final double thumbSize;
  final bool rtl;
  final ACDSlideActionDirection direction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (dragExtent == 0) return;
    final double midY = size.height / 2;
    // The thumb's resting centre in reading direction, then mirrored to a
    // physical x under RTL (the thumb uses directional positioning).
    final double logicalStart = switch (direction) {
      ACDSlideActionDirection.startToEnd => thumbSize / 2 + 4,
      ACDSlideActionDirection.endToStart => size.width - thumbSize / 2 - 4,
      ACDSlideActionDirection.dual => size.width / 2,
    };
    final double startX = rtl ? size.width - logicalStart : logicalStart;
    final double endX = startX + (rtl ? -dragExtent : dragExtent);

    final Path path = Path()..moveTo(startX, midY);
    const double waveLength = 14;
    final double distance = endX - startX;
    final int steps = (distance.abs() / waveLength).ceil().clamp(1, 200);
    final double stepX = distance / steps;
    for (int i = 0; i < steps; i++) {
      final double x1 = startX + stepX * (i + 0.5);
      final double y1 = midY + (i.isEven ? -4.0 : 4.0);
      final double x2 = startX + stepX * (i + 1);
      path.quadraticBezierTo(x1, y1, x2, midY);
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ACDWaveTrailPainter oldDelegate) =>
      oldDelegate.dragExtent != dragExtent ||
      oldDelegate.trackExtent != trackExtent ||
      oldDelegate.thumbSize != thumbSize ||
      oldDelegate.rtl != rtl ||
      oldDelegate.direction != direction ||
      oldDelegate.color != color;
}
