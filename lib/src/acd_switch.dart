import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import 'acd_state_fill.dart';
import 'acd_switch_shape.dart';

/// Builds a piece of an [ACDSwitch] given the current [progress] (`0.0`–`1.0`
/// towards "on"), its committed [value], and whether it's [enabled].
typedef ACDSwitchBuilder = Widget Function(
  BuildContext context,
  double progress,
  bool value,
  bool enabled,
);

/// A fully customizable, dependency-free toggle switch.
///
/// Works controlled (Checkbox-style, via [value]/[onChanged]), uncontrolled
/// (via [initialValue]), or driven by an external [controller]:
///
/// ```dart
/// ACDSwitch(
///   initialValue: true,
///   activeTrackColor: Colors.green,
///   onChanged: (value) => debugPrint('now $value'),
/// )
/// ```
///
/// For ready-made platform looks with no styling required, use
/// [ACDSwitch.material] or [ACDSwitch.ios].
class ACDSwitch extends StatefulWidget {
  /// Creates an [ACDSwitch].
  const ACDSwitch({
    super.key,
    this.value,
    this.initialValue = false,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.dragEnabled = true,
    this.disabledOpacity = 0.5,
    this.shape = ACDSwitchShape.pill,
    this.width = 52,
    this.height = 32,
    this.thumbSize,
    this.thumbPadding = const EdgeInsets.all(2),
    this.borderRadius,
    this.thumbBorderRadius,
    this.trackColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.disabledColor,
    this.trackGradient,
    this.activeTrackGradient,
    this.inactiveTrackGradient,
    this.thumbColor,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.disabledThumbColor,
    this.thumbGradient,
    this.activeThumbGradient,
    this.inactiveThumbGradient,
    this.borderColor,
    this.activeBorderColor,
    this.inactiveBorderColor,
    this.disabledBorderColor,
    this.borderWidth = 0,
    this.thumbBorderColor,
    this.activeThumbBorderColor,
    this.inactiveThumbBorderColor,
    this.thumbBorderWidth = 0,
    this.elevation = 0,
    this.elevationThumb,
    this.elevationTrack,
    this.boxShadow,
    this.thumbIcon,
    this.activeThumbIcon,
    this.inactiveThumbIcon,
    this.thumbWidget,
    this.thumbBuilder,
    this.trackBuilder,
    this.trackShapeBorder,
    this.thumbShapeBorder,
    this.mouseCursor,
    this.activeChild,
    this.inactiveChild,
    this.activeText,
    this.inactiveText,
    this.showOnOff = false,
    this.textStyle,
    this.activeTextStyle,
    this.inactiveTextStyle,
    this.textAlignment = AlignmentDirectional.center,
    this.activeImage,
    this.inactiveImage,
    this.imageFit = BoxFit.contain,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOut,
  });

  /// A ready-made Material-style preset — no styling required.
  ///
  /// Every base-constructor param is still available; this preset just
  /// supplies opinionated defaults for a curated subset.
  const ACDSwitch.material({
    Key? key,
    bool? value,
    bool initialValue = false,
    ValueNotifier<bool>? controller,
    ValueChanged<bool>? onChanged,
    bool enabled = true,
    Color activeColor = const Color(0xFF2962FF),
    Color inactiveColor = const Color(0xFFE0E0E0),
  }) : this(
         key: key,
         value: value,
         initialValue: initialValue,
         controller: controller,
         onChanged: onChanged,
         enabled: enabled,
         activeTrackColor: activeColor,
         inactiveTrackColor: inactiveColor,
         thumbColor: Colors.white,
         elevationThumb: 1,
       );

  /// A ready-made iOS-style preset (native `UISwitch` proportions and
  /// colors) — no styling required.
  const ACDSwitch.ios({
    Key? key,
    bool? value,
    bool initialValue = false,
    ValueNotifier<bool>? controller,
    ValueChanged<bool>? onChanged,
    bool enabled = true,
  }) : this(
         key: key,
         value: value,
         initialValue: initialValue,
         controller: controller,
         onChanged: onChanged,
         enabled: enabled,
         width: 51,
         height: 31,
         activeTrackColor: const Color(0xFF34C759),
         inactiveTrackColor: const Color(0xFFE9E9EA),
         thumbColor: Colors.white,
         elevationThumb: 2,
         dragEnabled: true,
       );

  /// Controlled value — when non-null, this widget is fully controlled
  /// (Checkbox-style): every rebuild's [value] is authoritative and nothing
  /// is cached internally. Highest precedence after [controller].
  final bool? value;

  /// Uncontrolled seed, used only when both [controller] and [value] are
  /// `null`. Seeded exactly once — never re-read on rebuild.
  final bool initialValue;

  /// Highest-precedence external value source. When supplied, this widget
  /// listens to it and never owns its own value.
  final ValueNotifier<bool>? controller;

  /// Fires once per user-driven value change (tap, or a completed drag that
  /// crosses the 50% mark).
  final ValueChanged<bool>? onChanged;

  /// Disables all gestures and applies [disabledColor]/[disabledOpacity]
  /// when `false`.
  final bool enabled;

  /// Enables native-style swipe-to-toggle. A plain tap always toggles
  /// regardless of this flag.
  final bool dragEnabled;

  /// Opacity applied to the whole switch when [enabled] is `false`.
  final double disabledOpacity;

  /// The default track/thumb shape, ignored once [trackShapeBorder]/
  /// [thumbShapeBorder]/[trackBuilder]/[thumbBuilder] take over.
  final ACDSwitchShape shape;

  /// Overall width.
  final double width;

  /// Overall height.
  final double height;

  /// Overrides the derived thumb diameter (`height - thumbPadding.vertical`
  /// by default).
  final double? thumbSize;

  /// Inset between the thumb and the track's edge.
  final EdgeInsets thumbPadding;

  /// Track corner radius, used only when [shape] is
  /// [ACDSwitchShape.roundedRectangle].
  final BorderRadius? borderRadius;

  /// Thumb corner radius, used only when [shape] is
  /// [ACDSwitchShape.roundedRectangle]. Defaults to matching [borderRadius].
  final BorderRadius? thumbBorderRadius;

  /// The default track's color, ignored once a more specific color/gradient
  /// applies.
  final Color? trackColor;

  /// Track color while on. Falls back to [trackColor], then a theme color.
  final Color? activeTrackColor;

  /// Track color while off. Falls back to [trackColor], then a theme color.
  final Color? inactiveTrackColor;

  /// Track (and thumb, unless [disabledThumbColor] is set) color while
  /// [enabled] is `false`.
  final Color? disabledColor;

  /// Track gradient, overriding [trackColor]-derived colors when set.
  final Gradient? trackGradient;

  /// Track gradient while on. Falls back to [trackGradient].
  final Gradient? activeTrackGradient;

  /// Track gradient while off. Falls back to [trackGradient].
  final Gradient? inactiveTrackGradient;

  /// The default thumb's color.
  final Color? thumbColor;

  /// Thumb color while on. Falls back to [thumbColor].
  final Color? activeThumbColor;

  /// Thumb color while off. Falls back to [thumbColor].
  final Color? inactiveThumbColor;

  /// Thumb color while [enabled] is `false`. Falls back to [disabledColor].
  final Color? disabledThumbColor;

  /// Thumb gradient, overriding [thumbColor]-derived colors when set.
  final Gradient? thumbGradient;

  /// Thumb gradient while on. Falls back to [thumbGradient].
  final Gradient? activeThumbGradient;

  /// Thumb gradient while off. Falls back to [thumbGradient].
  final Gradient? inactiveThumbGradient;

  /// Track border color.
  final Color? borderColor;

  /// Track border color while on. Falls back to [borderColor].
  final Color? activeBorderColor;

  /// Track border color while off. Falls back to [borderColor].
  final Color? inactiveBorderColor;

  /// Track border color while [enabled] is `false`.
  final Color? disabledBorderColor;

  /// Track border width. No border is painted when `0`.
  final double borderWidth;

  /// Thumb border color.
  final Color? thumbBorderColor;

  /// Thumb border color while on. Falls back to [thumbBorderColor].
  final Color? activeThumbBorderColor;

  /// Thumb border color while off. Falls back to [thumbBorderColor].
  final Color? inactiveThumbBorderColor;

  /// Thumb border width. No border is painted when `0`.
  final double thumbBorderWidth;

  /// Drop-shadow elevation shared by the default track and thumb when
  /// [elevationTrack]/[elevationThumb] aren't set. Ignored when [boxShadow]
  /// is supplied.
  final double elevation;

  /// Drop-shadow elevation for the default thumb specifically. Falls back
  /// to [elevation].
  final double? elevationThumb;

  /// Drop-shadow elevation for the default track specifically. Falls back
  /// to [elevation].
  final double? elevationTrack;

  /// Explicit shadow for the default track/thumb, overriding elevation.
  final List<BoxShadow>? boxShadow;

  /// Icon shown on the default thumb.
  final IconData? thumbIcon;

  /// Icon shown on the default thumb while on. Falls back to [thumbIcon].
  final IconData? activeThumbIcon;

  /// Icon shown on the default thumb while off. Falls back to [thumbIcon].
  final IconData? inactiveThumbIcon;

  /// Fully replaces the default thumb visuals with a static widget.
  final Widget? thumbWidget;

  /// Fully replaces the thumb, status-aware. Takes precedence over
  /// [thumbWidget].
  final ACDSwitchBuilder? thumbBuilder;

  /// Fully replaces the track, status-aware.
  final ACDSwitchBuilder? trackBuilder;

  /// Escape hatch below [trackBuilder]: any [ShapeBorder] (stadium,
  /// squircle, star...) for the default track, beyond what [borderRadius]
  /// alone can express.
  final ShapeBorder? trackShapeBorder;

  /// Escape hatch below [thumbBuilder]: any [ShapeBorder] for the default
  /// thumb.
  final ShapeBorder? thumbShapeBorder;

  /// Pointer cursor on desktop/web. Defaults to [SystemMouseCursors.click]
  /// when [enabled], [SystemMouseCursors.basic] otherwise.
  final MouseCursor? mouseCursor;

  /// Arbitrary track content while on. Takes precedence over [activeText].
  final Widget? activeChild;

  /// Arbitrary track content while off. Takes precedence over
  /// [inactiveText].
  final Widget? inactiveChild;

  /// Plain string track content while on, ignored when [activeChild] is set.
  final String? activeText;

  /// Plain string track content while off, ignored when [inactiveChild] is
  /// set.
  final String? inactiveText;

  /// When `true` and no text/child is otherwise supplied, falls back to
  /// built-in "On"/"Off" labels.
  final bool showOnOff;

  /// Text style shared by [activeText]/[inactiveText].
  final TextStyle? textStyle;

  /// Text style for [activeText]. Falls back to [textStyle].
  final TextStyle? activeTextStyle;

  /// Text style for [inactiveText]. Falls back to [textStyle].
  final TextStyle? inactiveTextStyle;

  /// Alignment of [activeChild]/[inactiveChild]/text within the track.
  final AlignmentGeometry textAlignment;

  /// Track background image while on.
  final ImageProvider? activeImage;

  /// Track background image while off.
  final ImageProvider? inactiveImage;

  /// How [activeImage]/[inactiveImage] fills the track.
  final BoxFit imageFit;

  /// Duration of the thumb glide and color/gradient cross-fade.
  final Duration animationDuration;

  /// Curve for [animationDuration]-driven transitions.
  final Curve animationCurve;

  @override
  State<ACDSwitch> createState() => _ACDSwitchState();
}

class _ACDSwitchState extends State<ACDSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late bool _internalValue = widget.value ?? widget.initialValue;
  late double _thumbProgress = _effectiveValue ? 1.0 : 0.0;
  bool _dragging = false;
  double _dragProgress = 0;

  bool get _effectiveValue =>
      widget.controller?.value ?? widget.value ?? _internalValue;

  bool get _interactive => widget.enabled;

  double get _thumbDiameter =>
      widget.thumbSize ?? (widget.height - widget.thumbPadding.vertical);

  double get _travelExtent =>
      (widget.width - widget.thumbPadding.horizontal - _thumbDiameter).clamp(
        1.0,
        double.infinity,
      );

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant ACDSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
    if (widget.controller == null &&
        widget.value != null &&
        widget.value != oldWidget.value &&
        !_dragging) {
      unawaited(_animateTo(widget.value! ? 1.0 : 0.0));
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _animController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!_dragging) {
      unawaited(_animateTo(_effectiveValue ? 1.0 : 0.0));
    }
  }

  Future<void> _animateTo(double target) async {
    if (!mounted) return;
    final double begin = _thumbProgress;
    if (begin == target) return;
    _animController
      ..duration = widget.animationDuration
      ..value = 0;
    final Animation<double> anim = Tween<double>(begin: begin, end: target)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: widget.animationCurve,
          ),
        );
    void listener() {
      if (mounted) setState(() => _thumbProgress = anim.value);
    }

    anim.addListener(listener);
    await _animController.forward();
    anim.removeListener(listener);
  }

  void _commit(bool newValue) {
    final bool changed = newValue != _effectiveValue;
    if (widget.controller != null) {
      widget.controller!.value = newValue;
    } else if (widget.value == null) {
      setState(() => _internalValue = newValue);
      unawaited(_animateTo(newValue ? 1.0 : 0.0));
    } else {
      // Fully controlled without a separate controller: don't fight the
      // parent — snap back to the last committed value and wait for
      // `didUpdateWidget` to animate once the parent supplies a new `value`.
      unawaited(_animateTo(_effectiveValue ? 1.0 : 0.0));
    }
    if (changed) widget.onChanged?.call(newValue);
  }

  void _onTap() {
    if (!_interactive) return;
    _commit(!_effectiveValue);
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (!_interactive || !widget.dragEnabled) return;
    _animController.stop();
    setState(() {
      _dragging = true;
      _dragProgress = _effectiveValue ? 1.0 : 0.0;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_dragging) return;
    double delta = details.delta.dx / _travelExtent;
    if (Directionality.of(context) == TextDirection.rtl) delta = -delta;
    setState(() => _dragProgress = (_dragProgress + delta).clamp(0.0, 1.0));
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_dragging) return;
    final bool newValue = _dragProgress >= 0.5;
    setState(() => _dragging = false);
    _commit(newValue);
  }

  Color _resolveTrackColor(BuildContext context, {required bool active}) {
    final ({Color? color, Gradient? gradient}) fill = acdResolveStateFill(
      active: active,
      enabled: widget.enabled,
      color: widget.trackColor,
      activeColor: widget.activeTrackColor,
      inactiveColor: widget.inactiveTrackColor,
      disabledColor: widget.disabledColor,
    );
    if (fill.color != null) return fill.color!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    if (!widget.enabled) return scheme.onSurface.withValues(alpha: 0.12);
    return active ? scheme.primary : scheme.surfaceContainerHighest;
  }

  Gradient? _resolveTrackGradient({required bool active}) {
    if (!widget.enabled) return null;
    final ({Color? color, Gradient? gradient}) fill = acdResolveStateFill(
      active: active,
      color: widget.trackColor,
      gradient: widget.trackGradient,
      activeGradient: widget.activeTrackGradient,
      inactiveGradient: widget.inactiveTrackGradient,
    );
    return fill.gradient;
  }

  Color _resolveThumbColor(BuildContext context, {required bool active}) {
    final ({Color? color, Gradient? gradient}) fill = acdResolveStateFill(
      active: active,
      enabled: widget.enabled,
      color: widget.thumbColor,
      activeColor: widget.activeThumbColor,
      inactiveColor: widget.inactiveThumbColor,
      disabledColor: widget.disabledThumbColor ?? widget.disabledColor,
    );
    return fill.color ?? Colors.white;
  }

  Gradient? _resolveThumbGradient({required bool active}) {
    if (!widget.enabled) return null;
    final ({Color? color, Gradient? gradient}) fill = acdResolveStateFill(
      active: active,
      color: widget.thumbColor,
      gradient: widget.thumbGradient,
      activeGradient: widget.activeThumbGradient,
      inactiveGradient: widget.inactiveThumbGradient,
    );
    return fill.gradient;
  }

  Color? _resolveBorderColor({required bool active}) {
    final ({Color? color, Gradient? gradient}) fill = acdResolveStateFill(
      active: active,
      enabled: widget.enabled,
      color: widget.borderColor,
      activeColor: widget.activeBorderColor,
      inactiveColor: widget.inactiveBorderColor,
      disabledColor: widget.disabledBorderColor,
    );
    return fill.color;
  }

  Color? _resolveThumbBorderColor({required bool active}) {
    final ({Color? color, Gradient? gradient}) fill = acdResolveStateFill(
      active: active,
      enabled: widget.enabled,
      color: widget.thumbBorderColor,
      activeColor: widget.activeThumbBorderColor,
      inactiveColor: widget.inactiveThumbBorderColor,
    );
    return fill.color;
  }

  List<BoxShadow>? _shadow(double? specific) {
    if (widget.boxShadow != null) return widget.boxShadow;
    final double elevation = specific ?? widget.elevation;
    if (elevation <= 0) return null;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation / 2),
      ),
    ];
  }

  Widget? _buildContent() {
    final bool active = _effectiveValue;
    Widget? child = active ? widget.activeChild : widget.inactiveChild;
    if (child != null) return child;
    String? text = active ? widget.activeText : widget.inactiveText;
    text ??= widget.showOnOff ? (active ? 'On' : 'Off') : null;
    if (text == null) return null;
    final TextStyle? style =
        (active ? widget.activeTextStyle : widget.inactiveTextStyle) ??
        widget.textStyle;
    return Text(
      text,
      style:
          style ??
          const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildThumb(BuildContext context, double progress, bool active) {
    if (widget.thumbBuilder != null) {
      return widget.thumbBuilder!(context, progress, active, widget.enabled);
    }
    final double diameter = _thumbDiameter;
    if (widget.thumbWidget != null) {
      return SizedBox(
        width: diameter,
        height: diameter,
        child: widget.thumbWidget,
      );
    }

    final Color inactiveColor = _resolveThumbColor(context, active: false);
    final Color activeColor = _resolveThumbColor(context, active: true);
    final Gradient? gradient = progress >= 0.5
        ? _resolveThumbGradient(active: true)
        : _resolveThumbGradient(active: false);
    final Color? borderColor = progress >= 0.5
        ? _resolveThumbBorderColor(active: true)
        : _resolveThumbBorderColor(active: false);
    final IconData? icon = active
        ? (widget.activeThumbIcon ?? widget.thumbIcon)
        : (widget.inactiveThumbIcon ?? widget.thumbIcon);

    final ShapeBorder shape =
        widget.thumbShapeBorder ??
        (widget.shape == ACDSwitchShape.pill
            ? CircleBorder(
                side: widget.thumbBorderWidth > 0 && borderColor != null
                    ? BorderSide(
                        color: borderColor,
                        width: widget.thumbBorderWidth,
                      )
                    : BorderSide.none,
              )
            : RoundedRectangleBorder(
                borderRadius:
                    widget.thumbBorderRadius ?? BorderRadius.circular(6),
                side: widget.thumbBorderWidth > 0 && borderColor != null
                    ? BorderSide(
                        color: borderColor,
                        width: widget.thumbBorderWidth,
                      )
                    : BorderSide.none,
              ));

    return Container(
      width: diameter,
      height: diameter,
      decoration: ShapeDecoration(
        color: gradient == null
            ? Color.lerp(inactiveColor, activeColor, progress)
            : null,
        gradient: gradient,
        shape: shape,
        shadows: _shadow(widget.elevationThumb),
      ),
      alignment: Alignment.center,
      child: icon == null
          ? null
          : Icon(icon, size: diameter * 0.55, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool active = _effectiveValue;
    final double progress = _dragging ? _dragProgress : _thumbProgress;

    final BorderRadius trackRadius = widget.shape == ACDSwitchShape.pill
        ? BorderRadius.circular(widget.height / 2)
        : (widget.borderRadius ?? BorderRadius.circular(8));

    final Color inactiveTrackColor = _resolveTrackColor(context, active: false);
    final Color activeTrackColor = _resolveTrackColor(context, active: true);
    final Gradient? trackGradient = progress >= 0.5
        ? _resolveTrackGradient(active: true)
        : _resolveTrackGradient(active: false);
    final Color? trackBorderColor = progress >= 0.5
        ? _resolveBorderColor(active: true)
        : _resolveBorderColor(active: false);

    final ShapeBorder trackShape =
        widget.trackShapeBorder ??
        RoundedRectangleBorder(
          borderRadius: trackRadius,
          side: widget.borderWidth > 0 && trackBorderColor != null
              ? BorderSide(color: trackBorderColor, width: widget.borderWidth)
              : BorderSide.none,
        );

    final Widget track =
        widget.trackBuilder?.call(context, progress, active, widget.enabled) ??
        DecoratedBox(
          decoration: ShapeDecoration(
            color: trackGradient == null
                ? Color.lerp(inactiveTrackColor, activeTrackColor, progress)
                : null,
            gradient: trackGradient,
            shape: trackShape,
            shadows: _shadow(widget.elevationTrack),
          ),
        );

    final ImageProvider? image = active
        ? widget.activeImage
        : widget.inactiveImage;
    final Widget? content = _buildContent();
    final MouseCursor cursor =
        widget.mouseCursor ??
        (widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic);

    final Widget stack = Stack(
      children: [
        Positioned.fill(child: track),
        if (image != null)
          Positioned.fill(
            child: ClipPath(
              clipper: ShapeBorderClipper(shape: trackShape),
              child: Image(image: image, fit: widget.imageFit),
            ),
          ),
        if (content != null)
          Positioned.fill(
            child: Align(alignment: widget.textAlignment, child: content),
          ),
        Positioned.fill(
          child: Padding(
            padding: widget.thumbPadding,
            child: Align(
              alignment: AlignmentDirectional.lerp(
                AlignmentDirectional.centerStart,
                AlignmentDirectional.centerEnd,
                progress,
              )!,
              child: _buildThumb(context, progress, active),
            ),
          ),
        ),
      ],
    );

    return Opacity(
      opacity: widget.enabled ? 1.0 : widget.disabledOpacity,
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _interactive ? _onTap : null,
          onHorizontalDragStart: (_interactive && widget.dragEnabled)
              ? _onHorizontalDragStart
              : null,
          onHorizontalDragUpdate: (_interactive && widget.dragEnabled)
              ? _onHorizontalDragUpdate
              : null,
          onHorizontalDragEnd: (_interactive && widget.dragEnabled)
              ? _onHorizontalDragEnd
              : null,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: stack,
          ),
        ),
      ),
    );
  }
}
