import 'dart:math' as math;

import 'package:flutter/gestures.dart' show PointerExitEvent, PointerHoverEvent;
import 'package:flutter/material.dart';

import 'acd_pop_animation.dart';
import 'acd_rating_icon_style.dart';
import 'acd_rating_interaction_mode.dart';
import 'acd_rating_item_status.dart';

/// Builds one [ACDRatingBar] item given its [index], the continuous
/// [fillFraction] (`0`–`1`) it's currently filled to, and the convenience
/// [status] bucketing of that fraction.
typedef ACDRatingItemBuilder = Widget Function(
  BuildContext context,
  int index,
  double fillFraction,
  ACDRatingItemStatus status,
);

/// A fully customizable, dependency-free star (or any icon/shape) rating
/// bar, built to avoid the tap/drag-gesture and rebuild-state pitfalls
/// common to rating widgets by construction.
///
/// ```dart
/// ACDRatingBar(
///   initialRating: 3,
///   allowHalfRating: true,
///   onRatingUpdate: (value) => debugPrint('rated $value'),
/// )
/// ```
///
/// There is no separate read-only "indicator" widget — pass
/// `interactionMode: ACDRatingInteractionMode.none` instead.
class ACDRatingBar extends StatefulWidget {
  /// Creates an [ACDRatingBar].
  const ACDRatingBar({
    super.key,
    this.rating,
    this.initialRating = 0,
    this.onRatingUpdate,
    this.itemCount = 5,
    this.itemBuilder,
    this.itemSize = 32,
    this.itemSpacing = 0,
    this.itemPadding = EdgeInsets.zero,
    this.separatorBuilder,
    this.direction = Axis.horizontal,
    this.allowHalfRating = false,
    this.ratingPrecision,
    this.interactionMode = ACDRatingInteractionMode.tapAndDrag,
    this.clearOnReTap = false,
    this.enableHoverPreview = false,
    this.minRating = 0,
    this.maxRating,
    this.updateOnDrag = false,
    this.wrapAlignment = WrapAlignment.start,
    this.textDirection,
    this.filledColor,
    this.halfColor,
    this.unratedColor,
    this.filledGradient,
    this.unratedGradient,
    this.glowOnActive = false,
    this.glowColor,
    this.glowRadius = 8,
    this.popAnimationOnChange = true,
    this.itemIconStyle = ACDRatingIconStyle.glyph,
    this.filledIcon = Icons.star,
    this.halfIcon = Icons.star_half,
    this.emptyIcon = Icons.star_border,
    this.starPoints = 5,
    this.starPointRounding = 0,
    this.starInnerRadiusRatio = 0.4,
    this.mouseCursor,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOut,
  }) : assert(itemCount > 0, 'itemCount must be positive');

  /// Controlled rating — when non-null, this widget is fully controlled
  /// (Checkbox-style): every rebuild's [rating] is authoritative and
  /// nothing is cached internally.
  final double? rating;

  /// Uncontrolled seed, used only when [rating] is `null`. Seeded exactly
  /// once — never re-read on rebuild, structurally preventing the "initial
  /// rating doesn't persist across rebuilds" bug class.
  final double initialRating;

  /// Fires on every committed change (a completed tap/drag), and
  /// continuously during a drag when [updateOnDrag] is `true`.
  final ValueChanged<double>? onRatingUpdate;

  /// Number of items. Also the implicit rating ceiling unless [maxRating]
  /// overrides it.
  final int itemCount;

  /// Fully replaces the default per-item rendering.
  final ACDRatingItemBuilder? itemBuilder;

  /// Each item's width/height.
  final double itemSize;

  /// True whitespace between items (a layout gap, distinct from
  /// [itemPadding]'s tap-target growth).
  final double itemSpacing;

  /// Extra inset around each item, growing its tap target without adding a
  /// visual gap.
  final EdgeInsets itemPadding;

  /// Builds a custom separator widget between items.
  final IndexedWidgetBuilder? separatorBuilder;

  /// Horizontal row or vertical column.
  final Axis direction;

  /// Whether a tap/drag can land on a half-item boundary. Ignored when
  /// [ratingPrecision] is set.
  final bool allowHalfRating;

  /// Opt-in continuous rating step (e.g. `0.1`) for exact-fraction
  /// tap/drag ratings, overriding [allowHalfRating]'s whole/half stepping.
  final double? ratingPrecision;

  /// How this widget responds to user input.
  final ACDRatingInteractionMode interactionMode;

  /// When `true`, tapping the item that already represents the current
  /// top rating clears the rating to `0` instead of leaving it unchanged.
  final bool clearOnReTap;

  /// Strictly opt-in mouse-hover preview. When `false` (the default), no
  /// hover value tracking happens at all — hovering can never itself change
  /// [rating]/fire [onRatingUpdate], only an actual tap/drag commit can.
  final bool enableHoverPreview;

  /// Floor beneath which a commit can't push the rating.
  final double minRating;

  /// Ceiling a commit can't push the rating past. Defaults to [itemCount].
  final double? maxRating;

  /// When `true`, [onRatingUpdate] fires continuously as a drag moves, not
  /// only once the drag ends.
  final bool updateOnDrag;

  /// Alignment of items when the row/column wraps because it doesn't fit
  /// the available extent.
  final WrapAlignment wrapAlignment;

  /// Explicit RTL override for hit-testing and fill direction. Defaults to
  /// the ambient `Directionality`.
  final TextDirection? textDirection;

  /// Default-renderer filled-item color.
  final Color? filledColor;

  /// Default-renderer half-item glyph color (only used for a discrete
  /// [halfIcon] swap — see [halfIcon]). Falls back to [filledColor].
  final Color? halfColor;

  /// Default-renderer empty-item color. `null` derives a theme grey rather
  /// than a hardcoded literal.
  final Color? unratedColor;

  /// Gradient for the filled portion, overriding [filledColor].
  final Gradient? filledGradient;

  /// Gradient for the unrated portion, overriding [unratedColor].
  final Gradient? unratedGradient;

  /// Paints a glow behind the item at the current rating boundary.
  final bool glowOnActive;

  /// Glow color. Defaults to the resolved filled color.
  final Color? glowColor;

  /// Glow blur radius.
  final double glowRadius;

  /// Plays a brief scale "pop" on items whose fill state changes.
  final bool popAnimationOnChange;

  /// How the default (non-`itemBuilder`) item renders.
  final ACDRatingIconStyle itemIconStyle;

  /// Filled-item icon, used when [itemIconStyle] is
  /// [ACDRatingIconStyle.glyph].
  final IconData filledIcon;

  /// Half-item icon, used only in classic (non-[ratingPrecision]) half-star
  /// mode when [itemIconStyle] is [ACDRatingIconStyle.glyph].
  final IconData halfIcon;

  /// Empty-item icon, used when [itemIconStyle] is
  /// [ACDRatingIconStyle.glyph].
  final IconData emptyIcon;

  /// Star point count, used only when [itemIconStyle] is
  /// [ACDRatingIconStyle.vectorStar].
  final int starPoints;

  /// Star point rounding (`0`–`1`), used only when [itemIconStyle] is
  /// [ACDRatingIconStyle.vectorStar].
  final double starPointRounding;

  /// Star inner-radius ratio, used only when [itemIconStyle] is
  /// [ACDRatingIconStyle.vectorStar].
  final double starInnerRadiusRatio;

  /// Pointer cursor on desktop/web. Defaults to [SystemMouseCursors.click]
  /// when interactive, [SystemMouseCursors.basic] otherwise.
  final MouseCursor? mouseCursor;

  /// Duration of the pop animation and any implicit transitions.
  final Duration animationDuration;

  /// Curve for [animationDuration]-driven transitions.
  final Curve animationCurve;

  @override
  State<ACDRatingBar> createState() => _ACDRatingBarState();
}

class _ACDRatingBarState extends State<ACDRatingBar>
    with SingleTickerProviderStateMixin {
  late double _internalRating = widget.initialRating;
  double? _dragPreviewRating;
  double? _hoverValue;
  Set<int> _poppingIndices = const {};
  final GlobalKey _rowKey = GlobalKey();

  late final AnimationController _popController = AnimationController(
    vsync: this,
    duration: acdPopAnimationDuration,
  );
  late final Animation<double> _popAnimation = _popController.drive(
    acdPopScaleTween(),
  );

  double get _committedRating => widget.rating ?? _internalRating;

  double get _effectiveRating =>
      _dragPreviewRating ?? _hoverValue ?? _committedRating;

  double get _resolvedMaxRating =>
      widget.maxRating ?? widget.itemCount.toDouble();

  bool get _tapAllowed =>
      widget.interactionMode == ACDRatingInteractionMode.tapAndDrag ||
      widget.interactionMode == ACDRatingInteractionMode.tapOnly;

  bool get _dragAllowed =>
      widget.interactionMode == ACDRatingInteractionMode.tapAndDrag ||
      widget.interactionMode == ACDRatingInteractionMode.dragOnly;

  bool get _interactive =>
      widget.interactionMode != ACDRatingInteractionMode.none;

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  TextDirection _resolvedDirection(BuildContext context) =>
      widget.textDirection ?? Directionality.of(context);

  double _quantize(double raw) {
    final double step =
        widget.ratingPrecision ?? (widget.allowHalfRating ? 0.5 : 1.0);
    final double clamped = raw.clamp(0.0, widget.itemCount.toDouble());
    if (clamped <= 0) return 0;
    return (clamped / step).ceil() * step;
  }

  double _ratingFromLocalPosition(Offset localPosition, Size size) {
    final bool rtl = _resolvedDirection(context) == TextDirection.rtl;
    double fraction = widget.direction == Axis.horizontal
        ? localPosition.dx / size.width
        : localPosition.dy / size.height;
    if (widget.direction == Axis.horizontal && rtl) fraction = 1 - fraction;
    fraction = fraction.clamp(0.0, 1.0);
    final double raw = _quantize(fraction * widget.itemCount);
    return raw.clamp(widget.minRating, _resolvedMaxRating);
  }

  void _commit(double value) {
    final double clamped = value.clamp(widget.minRating, _resolvedMaxRating);
    final double old = _committedRating;
    if (widget.rating == null) {
      setState(() => _internalRating = clamped);
    }
    if (widget.popAnimationOnChange && clamped != old) {
      _playPop(old, clamped);
    }
    if (clamped != old) widget.onRatingUpdate?.call(clamped);
  }

  void _playPop(double oldRating, double newRating) {
    final int lo = math
        .min(oldRating, newRating)
        .floor()
        .clamp(0, widget.itemCount - 1);
    final int hi = (math.max(oldRating, newRating).ceil() - 1).clamp(
      0,
      widget.itemCount - 1,
    );
    setState(() {
      _poppingIndices = {for (int i = lo; i <= hi; i++) i};
    });
    _popController.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _poppingIndices = const {});
    });
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_tapAllowed) return;
    final Offset? local = _globalToLocal(details.globalPosition);
    final Size? size = _currentSize();
    if (local == null || size == null) return;
    double newRating = _ratingFromLocalPosition(local, size);
    if (widget.clearOnReTap && newRating == _committedRating) {
      newRating = 0;
    }
    _commit(newRating);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_dragAllowed) return;
    final Offset? local = _globalToLocal(details.globalPosition);
    final Size? size = _currentSize();
    if (local == null || size == null) return;
    final double newRating = _ratingFromLocalPosition(local, size);
    if (widget.updateOnDrag) {
      _commit(newRating);
    } else {
      setState(() => _dragPreviewRating = newRating);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_dragAllowed) return;
    if (!widget.updateOnDrag && _dragPreviewRating != null) {
      _commit(_dragPreviewRating!);
    }
    setState(() => _dragPreviewRating = null);
  }

  void _handleHover(PointerHoverEvent event) {
    if (!widget.enableHoverPreview) return;
    final Offset? local = _globalToLocal(event.position);
    final Size? size = _currentSize();
    if (local == null || size == null) return;
    setState(() => _hoverValue = _ratingFromLocalPosition(local, size));
  }

  void _handleHoverExit(PointerExitEvent event) {
    if (!widget.enableHoverPreview) return;
    setState(() => _hoverValue = null);
  }

  Color _resolvedFilledColor(BuildContext context) =>
      widget.filledColor ?? Colors.amber;

  Color _resolvedUnratedColor(BuildContext context) =>
      widget.unratedColor ??
      Theme.of(context).colorScheme.surfaceContainerHighest;

  Widget _starShape(Color color) => Container(
    width: widget.itemSize,
    height: widget.itemSize,
    decoration: ShapeDecoration(
      color: color,
      shape: StarBorder(
        points: widget.starPoints.toDouble(),
        pointRounding: widget.starPointRounding,
        innerRadiusRatio: widget.starInnerRadiusRatio,
      ),
    ),
  );

  Widget _defaultItem(
    BuildContext context,
    double fillFraction,
    ACDRatingItemStatus status,
  ) {
    final Color filled = _resolvedFilledColor(context);
    final Color unrated = _resolvedUnratedColor(context);
    final bool rtl = _resolvedDirection(context) == TextDirection.rtl;

    final bool useHalfGlyph =
        widget.itemIconStyle == ACDRatingIconStyle.glyph &&
        widget.ratingPrecision == null &&
        status == ACDRatingItemStatus.half;
    if (useHalfGlyph) {
      return Icon(
        widget.halfIcon,
        size: widget.itemSize,
        color: widget.halfColor ?? filled,
      );
    }

    final Widget background =
        widget.itemIconStyle == ACDRatingIconStyle.vectorStar
        ? _starShape(unrated)
        : Icon(widget.emptyIcon, size: widget.itemSize, color: unrated);

    Widget foreground = widget.itemIconStyle == ACDRatingIconStyle.vectorStar
        ? _starShape(filled)
        : Icon(
            widget.filledIcon,
            size: widget.itemSize,
            color: widget.filledGradient == null ? filled : null,
          );
    if (widget.filledGradient != null) {
      foreground = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => widget.filledGradient!.createShader(bounds),
        child: foreground,
      );
    }

    return Stack(
      children: [
        background,
        ClipRect(
          clipper: _ACDFractionClipper(fraction: fillFraction, rtl: rtl),
          child: foreground,
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, int index, double effectiveRating) {
    final double fillFraction = (effectiveRating - index).clamp(0.0, 1.0);
    final ACDRatingItemStatus status = fillFraction <= 0
        ? ACDRatingItemStatus.empty
        : (fillFraction >= 1
              ? ACDRatingItemStatus.filled
              : ACDRatingItemStatus.half);

    Widget item =
        widget.itemBuilder?.call(context, index, fillFraction, status) ??
        _defaultItem(context, fillFraction, status);
    item = SizedBox(
      width: widget.itemSize,
      height: widget.itemSize,
      child: item,
    );

    if (widget.popAnimationOnChange && _poppingIndices.contains(index)) {
      item = AnimatedBuilder(
        animation: _popAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _popAnimation.value, child: child),
        child: item,
      );
    }

    if (widget.glowOnActive &&
        status != ACDRatingItemStatus.empty &&
        index == effectiveRating.ceil() - 1) {
      item = DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: (widget.glowColor ?? _resolvedFilledColor(context))
                  .withValues(alpha: 0.6),
              blurRadius: widget.glowRadius,
              spreadRadius: widget.glowRadius / 4,
            ),
          ],
        ),
        child: item,
      );
    }

    return Padding(padding: widget.itemPadding, child: item);
  }

  @override
  Widget build(BuildContext context) {
    final double effectiveRating = _effectiveRating;
    final List<Widget> children = [];
    for (int i = 0; i < widget.itemCount; i++) {
      if (i > 0 && widget.separatorBuilder != null) {
        children.add(widget.separatorBuilder!(context, i));
      }
      children.add(_buildItem(context, i, effectiveRating));
    }

    final Widget row = Wrap(
      key: _rowKey,
      direction: widget.direction,
      alignment: widget.wrapAlignment,
      spacing: widget.itemSpacing,
      runSpacing: widget.itemSpacing,
      children: children,
    );

    if (!_interactive) return row;

    final MouseCursor cursor = widget.mouseCursor ?? SystemMouseCursors.click;

    return MouseRegion(
      cursor: cursor,
      onHover: widget.enableHoverPreview ? _handleHover : null,
      onExit: widget.enableHoverPreview ? _handleHoverExit : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: _tapAllowed ? _handleTapUp : null,
        onPanUpdate: _dragAllowed ? _handlePanUpdate : null,
        onPanEnd: _dragAllowed ? _handlePanEnd : null,
        child: row,
      ),
    );
  }

  RenderBox? get _rowRenderBox {
    final RenderObject? renderObject = _rowKey.currentContext
        ?.findRenderObject();
    return renderObject is RenderBox && renderObject.hasSize
        ? renderObject
        : null;
  }

  Offset? _globalToLocal(Offset global) => _rowRenderBox?.globalToLocal(global);

  Size? _currentSize() => _rowRenderBox?.size;
}

class _ACDFractionClipper extends CustomClipper<Rect> {
  const _ACDFractionClipper({required this.fraction, required this.rtl});

  final double fraction;
  final bool rtl;

  @override
  Rect getClip(Size size) {
    final double w = size.width * fraction;
    return rtl
        ? Rect.fromLTWH(size.width - w, 0, w, size.height)
        : Rect.fromLTWH(0, 0, w, size.height);
  }

  @override
  bool shouldReclip(covariant _ACDFractionClipper oldClipper) =>
      oldClipper.fraction != fraction || oldClipper.rtl != rtl;
}
