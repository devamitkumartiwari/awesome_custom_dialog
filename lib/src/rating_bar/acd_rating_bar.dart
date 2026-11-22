import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/acd_design_scope.dart';
import '../design/acd_design_tokens.dart';
import '../design/acd_strings.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../design/internal/acd_platform_support.dart';
import '../motion/acd_pop_animation.dart';
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
    this.filledIcon,
    this.halfIcon,
    this.emptyIcon,
    this.design,
    this.semanticLabel,
    this.starPoints = 5,
    this.starPointRounding = 0,
    this.starInnerRadiusRatio = 0.4,
    this.mouseCursor,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOut,
  }) : assert(itemCount > 0, 'itemCount must be positive'),
       assert(
         ratingPrecision == null || ratingPrecision > 0,
         'ratingPrecision must be positive',
       ),
       assert(minRating >= 0, 'minRating must not be negative'),
       assert(
         maxRating == null || maxRating >= minRating,
         'maxRating must be >= minRating',
       );

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
  final IconData? filledIcon;

  /// Half-item icon, used only in classic (non-[ratingPrecision]) half-star
  /// mode when [itemIconStyle] is [ACDRatingIconStyle.glyph].
  final IconData? halfIcon;

  /// Empty-item icon, used when [itemIconStyle] is
  /// [ACDRatingIconStyle.glyph].
  final IconData? emptyIcon;

  /// Material (default) / Cupertino / adaptive — see [ACDDesign]. Picks the
  /// default star glyphs and colors (iOS: SF-style stars, system yellow).
  final ACDDesign? design;

  /// What this control is for, read by screen readers before its value
  /// (e.g. "Notifications", "Rate this app"). Without it, only the value
  /// is announced.
  final String? semanticLabel;

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
  // One key per star, for rect-based hit-testing.
  List<GlobalKey> _itemKeys = const [];

  List<GlobalKey> _keysFor(int count) {
    if (_itemKeys.length != count) {
      _itemKeys = List<GlobalKey>.generate(count, (_) => GlobalKey());
    }
    return _itemKeys;
  }

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

  /// The rating currently *drawn* (hover/drag preview or committed). Stars
  /// listen to it individually, so a preview sweep never rebuilds the bar —
  /// only the stars whose fill actually changes.
  late final ValueNotifier<double> _display = ValueNotifier<double>(
    _effectiveRating,
  );

  void _syncDisplay() => _display.value = _effectiveRating;

  double get _resolvedMaxRating =>
      widget.maxRating ?? widget.itemCount.toDouble();

  /// [ACDRatingBar.minRating], never above the resolved max — so a
  /// misconfigured pair (or an `itemCount` lowered below `minRating`) can't
  /// make `clamp` throw in release builds.
  double get _resolvedMinRating =>
      math.min(math.max(0.0, widget.minRating), _resolvedMaxRating);

  double _clampRating(double value) => value.isNaN
      ? _resolvedMinRating
      : value.clamp(_resolvedMinRating, _resolvedMaxRating);

  /// Removes binary floating-point noise (0.1 * 3 == 0.30000000000000004)
  /// so committed values sit exactly on the step grid.
  static double _clean(double v) => (v * 1e9).roundToDouble() / 1e9;

  @override
  void didUpdateWidget(covariant ACDRatingBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A lowered itemCount/maxRating must not leave the uncontrolled rating
    // above the new ceiling (screen readers would read "7 of 5").
    if (widget.rating == null) {
      final double clamped = _clampRating(_internalRating);
      // The display notifier is re-synced post-frame by _buildBar.
      if (clamped != _internalRating) _internalRating = clamped;
    }
  }

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
    _display.dispose();
    _popController.dispose();
    super.dispose();
  }

  TextDirection _resolvedDirection(BuildContext context) =>
      widget.textDirection ?? Directionality.of(context);

  double _quantize(double raw) {
    final double step = _step;
    final double clamped = raw.clamp(0.0, widget.itemCount.toDouble());
    if (clamped <= 0) return 0;
    // The epsilon keeps an on-grid value (e.g. 0.3 / 0.1 = 3.0000000000000004)
    // from ceiling up a whole extra step.
    return _clean((clamped / step - 1e-9).ceil() * step);
  }

  /// Maps a pointer to a rating using each star's *actual* rect, so
  /// [ACDRatingBar.itemSpacing], [ACDRatingBar.itemPadding], separators and
  /// wrapped runs are all honoured (the old math divided the whole row
  /// evenly, which drifted as soon as any spacing was set).
  double? _ratingFromGlobal(Offset global) {
    final List<Rect> rects = <Rect>[];
    for (final GlobalKey key in _itemKeys) {
      final RenderObject? ro = key.currentContext?.findRenderObject();
      if (ro is! RenderBox || !ro.hasSize) return null;
      rects.add(ro.localToGlobal(Offset.zero) & ro.size);
    }
    if (rects.isEmpty) return null;

    final bool horizontal = widget.direction == Axis.horizontal;
    final bool rtl =
        horizontal && _resolvedDirection(context) == TextDirection.rtl;
    double crossDistance(Rect r) {
      final double p = horizontal ? global.dy : global.dx;
      final double lo = horizontal ? r.top : r.left;
      final double hi = horizontal ? r.bottom : r.right;
      return p < lo ? lo - p : (p > hi ? p - hi : 0);
    }

    // The run (line of a wrapped bar) closest to the pointer.
    double best = double.infinity;
    for (final Rect r in rects) {
      best = math.min(best, crossDistance(r));
    }

    double? raw;
    for (int i = 0; i < rects.length; i++) {
      final Rect r = rects[i];
      if (crossDistance(r) - best > 0.5) continue;
      final double extent = horizontal ? r.width : r.height;
      final double offset = horizontal
          ? (rtl ? r.right - global.dx : global.dx - r.left)
          : global.dy - r.top;
      if (raw == null && offset < 0) {
        raw = i.toDouble(); // before this run's first star
        break;
      }
      if (offset >= 0) raw = i + (offset / extent).clamp(0.0, 1.0);
    }
    if (raw == null) return null;
    return _clampRating(_quantize(raw));
  }

  void _commit(double value) {
    final double clamped = _clampRating(_clean(value));
    final double old = _committedRating;
    if (widget.rating == null) {
      setState(() => _internalRating = clamped);
    }
    if (widget.popAnimationOnChange && clamped != old) {
      _playPop(old, clamped);
    }
    if (clamped != old) {
      if (_design.isCupertino) ACDHaptics.selection(context);
      widget.onRatingUpdate?.call(clamped);
    }
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
    double? newRating = _ratingFromGlobal(details.globalPosition);
    if (newRating == null) return;
    if (widget.clearOnReTap && newRating == _committedRating) {
      newRating = 0;
    }
    _commit(newRating);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_dragAllowed) return;
    final double? newRating = _ratingFromGlobal(details.globalPosition);
    if (newRating == null) return;
    if (widget.updateOnDrag) {
      _commit(newRating);
    } else {
      _dragPreviewRating = newRating;
      _syncDisplay();
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_dragAllowed) return;
    if (!widget.updateOnDrag && _dragPreviewRating != null) {
      _commit(_dragPreviewRating!);
    }
    _dragPreviewRating = null;
    _syncDisplay();
  }

  void _handleHover(PointerHoverEvent event) {
    if (!widget.enableHoverPreview) return;
    final double? value = _ratingFromGlobal(event.position);
    if (value == null || value == _hoverValue) return;
    _hoverValue = value;
    _syncDisplay();
  }

  void _handleHoverExit(PointerExitEvent event) {
    if (!widget.enableHoverPreview) return;
    _hoverValue = null;
    _syncDisplay();
  }

  Color _resolvedFilledColor(BuildContext context) =>
      widget.filledColor ??
      (_design.isCupertino
          ? CupertinoDynamicColor.resolve(CupertinoColors.systemYellow, context)
          : Colors.amber);

  Color _resolvedUnratedColor(BuildContext context) =>
      widget.unratedColor ??
      (_design.isCupertino
          ? ACDDesignTokens.of(context, _design).track
          : Theme.of(context).colorScheme.surfaceContainerHighest);

  double get _step {
    final double? precision = widget.ratingPrecision;
    if (precision != null && precision.isFinite && precision > 0) {
      return precision;
    }
    return widget.allowHalfRating ? 0.5 : 1.0;
  }

  void _nudge(int direction) {
    // Snap to the step grid first so repeated nudges never drift off it.
    final double onGrid = (_committedRating / _step).roundToDouble() * _step;
    _commit(onGrid + direction * _step);
  }

  // Arrow keys adjust the rating (reading-direction aware horizontally).
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final bool rtl = _resolvedDirection(context) == TextDirection.rtl;
    final LogicalKeyboardKey key = event.logicalKey;
    int? dir;
    if (key == LogicalKeyboardKey.arrowUp) dir = 1;
    if (key == LogicalKeyboardKey.arrowDown) dir = -1;
    if (key == LogicalKeyboardKey.arrowRight) dir = rtl ? -1 : 1;
    if (key == LogicalKeyboardKey.arrowLeft) dir = rtl ? 1 : -1;
    if (dir == null) return KeyEventResult.ignored;
    _nudge(dir);
    return KeyEventResult.handled;
  }

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
        widget.halfIcon ?? ACDIcon.starHalf.of(_design),
        size: widget.itemSize,
        color: widget.halfColor ?? filled,
      );
    }

    final Widget background =
        widget.itemIconStyle == ACDRatingIconStyle.vectorStar
        ? _starShape(unrated)
        : Icon(
            widget.emptyIcon ?? ACDIcon.starOutline.of(_design),
            size: widget.itemSize,
            color: unrated,
          );

    Widget foreground = widget.itemIconStyle == ACDRatingIconStyle.vectorStar
        ? _starShape(filled)
        : Icon(
            widget.filledIcon ?? ACDIcon.star.of(_design),
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
      key: _itemKeys[index],
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

  // Resolved once per build; read by the item/color helpers.
  ACDResolvedDesign _design = ACDResolvedDesign.material;

  @override
  Widget build(BuildContext context) {
    _design = ACDDesign.resolve(context, widget.design);
    final Widget bar = _buildBar(context);
    final ACDStrings strings = ACDDesignScope.stringsOf(context);
    final double max = _resolvedMaxRating;
    final double min = _resolvedMinRating;
    final int maxItems = widget.itemCount;
    String label(double r) => strings.ratingLabel(r, maxItems);
    final double current = _clampRating(_committedRating);
    // A slider-like control for screen readers: value + increase/decrease.
    return Semantics(
      label: widget.semanticLabel,
      slider: _interactive,
      value: label(current),
      increasedValue: _interactive && current < max
          ? label(_clampRating(current + _step))
          : null,
      decreasedValue: _interactive && current > min
          ? label(_clampRating(current - _step))
          : null,
      onIncrease: _interactive && current < max ? () => _nudge(1) : null,
      onDecrease: _interactive && current > min ? () => _nudge(-1) : null,
      child: ExcludeSemantics(
        child: _interactive ? Focus(onKeyEvent: _onKey, child: bar) : bar,
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    // Committed changes arrive through a normal rebuild; keep the shared
    // notifier in step (post-frame: never notify listeners during build).
    if (_display.value != _effectiveRating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncDisplay();
      });
    }
    final double effectiveRating = _effectiveRating;
    _keysFor(widget.itemCount);
    final List<Widget> children = [];
    for (int i = 0; i < widget.itemCount; i++) {
      if (i > 0 && widget.separatorBuilder != null) {
        children.add(widget.separatorBuilder!(context, i));
      }
      children.add(
        _ACDStarSlot(
          index: i,
          rating: _display,
          initialRating: effectiveRating,
          builder: (context, rating) => _buildItem(context, i, rating),
        ),
      );
    }

    final Widget row = Wrap(
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
        // 48 dp / 44 pt touch band across the bar's cross axis, so small
        // stars stay easy to hit (taps above/below map to the nearest run).
        child: ConstrainedBox(
          constraints: widget.direction == Axis.horizontal
              ? BoxConstraints(minHeight: acdMinTapTarget(_design))
              : BoxConstraints(minWidth: acdMinTapTarget(_design)),
          child: Center(widthFactor: 1, heightFactor: 1, child: row),
        ),
      ),
    );
  }
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

/// One star that rebuilds only when *its* appearance changes — its fill
/// fraction, or whether it's the top (glowing) star — as [rating] moves.
class _ACDStarSlot extends StatefulWidget {
  const _ACDStarSlot({
    required this.index,
    required this.rating,
    required this.initialRating,
    required this.builder,
  });

  final int index;
  final ValueListenable<double> rating;

  /// The rating the parent built with (authoritative for this build).
  final double initialRating;
  final Widget Function(BuildContext context, double rating) builder;

  @override
  State<_ACDStarSlot> createState() => _ACDStarSlotState();
}

class _ACDStarSlotState extends State<_ACDStarSlot> {
  late double _rating = widget.initialRating;

  (double, bool) _lookFor(double rating) {
    final double fill = (rating - widget.index).clamp(0.0, 1.0);
    return (fill, fill > 0 && widget.index == rating.ceil() - 1);
  }

  @override
  void initState() {
    super.initState();
    widget.rating.addListener(_onRating);
  }

  @override
  void didUpdateWidget(covariant _ACDStarSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rating != widget.rating) {
      oldWidget.rating.removeListener(_onRating);
      widget.rating.addListener(_onRating);
    }
    _rating = widget.initialRating;
  }

  @override
  void dispose() {
    widget.rating.removeListener(_onRating);
    super.dispose();
  }

  void _onRating() {
    final double next = widget.rating.value;
    if (_lookFor(next) == _lookFor(_rating)) {
      _rating = next;
      return;
    }
    setState(() => _rating = next);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _rating);
}
