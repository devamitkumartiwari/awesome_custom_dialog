// Internal Material/Cupertino building blocks shared by every feature.
//
// Rule for every adapter here: the Material branch returns exactly the
// widget the package used before design support existed, so the default
// (Material) rendering is unchanged. Adapters are const-constructible
// StatelessWidgets (or a minimal StatefulWidget where press state is
// inherently stateful) and take an already-resolved design, so callers
// resolve once per build and pass it down — no per-row lookups.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../acd_cupertino_field_style.dart';
import '../acd_design.dart';
import 'acd_platform_support.dart';

// ── Icons ─────────────────────────────────────────────────────────────────────

/// Semantic icons with a native glyph per design.
enum ACDIcon {
  check,
  close,
  search,
  clear,
  chevronDown,
  arrowForward,
  info,
  warning,
  error,
  success,
  question,
  star,
  starHalf,
  starOutline,
  favorite;

  /// The glyph for [design].
  IconData of(ACDResolvedDesign design) =>
      design.isCupertino ? _cupertino : _material;

  IconData get _material => switch (this) {
    ACDIcon.check => Icons.check,
    ACDIcon.close => Icons.close_rounded,
    ACDIcon.search => Icons.search,
    ACDIcon.clear => Icons.clear,
    ACDIcon.chevronDown => Icons.arrow_drop_down,
    ACDIcon.arrowForward => Icons.arrow_forward,
    ACDIcon.info => Icons.info_rounded,
    ACDIcon.warning => Icons.warning_rounded,
    ACDIcon.error => Icons.cancel_rounded,
    ACDIcon.success => Icons.check_circle_rounded,
    ACDIcon.question => Icons.question_mark_rounded,
    ACDIcon.star => Icons.star,
    ACDIcon.starHalf => Icons.star_half,
    ACDIcon.starOutline => Icons.star_border,
    ACDIcon.favorite => Icons.favorite,
  };

  IconData get _cupertino => switch (this) {
    ACDIcon.check => CupertinoIcons.check_mark,
    ACDIcon.close => CupertinoIcons.xmark,
    ACDIcon.search => CupertinoIcons.search,
    ACDIcon.clear => CupertinoIcons.clear_thick_circled,
    ACDIcon.chevronDown => CupertinoIcons.chevron_down,
    ACDIcon.arrowForward => CupertinoIcons.arrow_right,
    ACDIcon.info => CupertinoIcons.info_circle_fill,
    ACDIcon.warning => CupertinoIcons.exclamationmark_triangle_fill,
    ACDIcon.error => CupertinoIcons.xmark_circle_fill,
    ACDIcon.success => CupertinoIcons.checkmark_circle_fill,
    ACDIcon.question => CupertinoIcons.question_circle_fill,
    ACDIcon.star => CupertinoIcons.star_fill,
    ACDIcon.starHalf => CupertinoIcons.star_lefthalf_fill,
    ACDIcon.starOutline => CupertinoIcons.star,
    ACDIcon.favorite => CupertinoIcons.heart_fill,
  };
}

// ── Progress ──────────────────────────────────────────────────────────────────

/// Indeterminate spinner: `CircularProgressIndicator` | `CupertinoActivityIndicator`.
class ACDAdaptiveProgress extends StatelessWidget {
  const ACDAdaptiveProgress({
    super.key,
    required this.design,
    this.size,
    this.strokeWidth,
    this.color,
    this.semanticsLabel,
  });

  final ACDResolvedDesign design;
  final double? size;
  final double? strokeWidth;
  final Color? color;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final Widget indicator = switch (design) {
      ACDResolvedDesign.material => CircularProgressIndicator(
        strokeWidth: strokeWidth ?? 4.0,
        color: color,
        semanticsLabel: semanticsLabel,
      ),
      ACDResolvedDesign.cupertino => Semantics(
        label: semanticsLabel,
        child: CupertinoActivityIndicator(
          color: color,
          radius: size == null ? 10 : size! / 2,
        ),
      ),
    };
    // The spinner animates forever — isolate its repaints.
    final Widget bounded = RepaintBoundary(child: indicator);
    return size == null
        ? bounded
        : SizedBox(width: size, height: size, child: bounded);
  }
}

// ── Minimum tap target ────────────────────────────────────────────────────────

/// Minimum interactive size: 48 dp (Material guideline) | 44 pt (iOS HIG).
double acdMinTapTarget(ACDResolvedDesign design) =>
    design.isCupertino ? 44.0 : kMinInteractiveDimension;

/// Grows [child]'s hit area (not its drawn size) to [acdMinTapTarget],
/// centring the glyph inside. Wrap the *gesture* widget's child with this so
/// the whole box is tappable.
class ACDTapTargetBox extends StatelessWidget {
  const ACDTapTargetBox({super.key, required this.design, required this.child});

  final ACDResolvedDesign design;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double min = acdMinTapTarget(design);
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: min, minHeight: min),
      child: Center(widthFactor: 1, heightFactor: 1, child: child),
    );
  }
}

// ── Tappable ──────────────────────────────────────────────────────────────────

/// A tappable region: `InkWell` ripple | iOS pressed-opacity feedback.
class ACDAdaptiveTappable extends StatefulWidget {
  const ACDAdaptiveTappable({
    super.key,
    required this.design,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
  });

  final ACDResolvedDesign design;
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final MouseCursor? mouseCursor;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<ACDAdaptiveTappable> createState() => _ACDAdaptiveTappableState();
}

class _ACDAdaptiveTappableState extends State<ACDAdaptiveTappable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.design == ACDResolvedDesign.material) {
      return acdEnsureMaterial(
        context,
        InkWell(
          onTap: widget.onTap,
          borderRadius: widget.borderRadius,
          mouseCursor: widget.mouseCursor,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          child: widget.child,
        ),
      );
    }
    final bool enabled = widget.onTap != null;
    // Cupertino: no ripple. Pressed state dims content (iOS convention);
    // keyboard activation via FocusableActionDetector.
    return FocusableActionDetector(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: enabled,
      mouseCursor:
          widget.mouseCursor ??
          (enabled ? SystemMouseCursors.click : MouseCursor.defer),
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onTap?.call();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTap: widget.onTap,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.4 : 1.0,
          duration: _pressed
              ? Duration.zero
              : const Duration(milliseconds: 150),
          child: widget.child,
        ),
      ),
    );
  }
}

// ── Surface ───────────────────────────────────────────────────────────────────

/// A clipped surface that gives descendant text a proper default style.
///
/// Material: `Material(type: transparency)` (as before). Cupertino: a clip
/// plus the Cupertino text style — no Material ancestor, so nothing
/// Material-only is pulled into a Cupertino tree.
class ACDAdaptiveSurface extends StatelessWidget {
  const ACDAdaptiveSurface({
    super.key,
    required this.design,
    required this.child,
    this.shape,
    this.borderRadius,
    this.color,
    this.clipBehavior = Clip.antiAlias,
  });

  final ACDResolvedDesign design;
  final Widget child;
  final ShapeBorder? shape;
  final BorderRadius? borderRadius;
  final Color? color;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    switch (design) {
      case ACDResolvedDesign.material:
        return Material(
          type: color == null ? MaterialType.transparency : MaterialType.canvas,
          color: color,
          shape: shape,
          borderRadius: shape == null ? borderRadius : null,
          clipBehavior: clipBehavior,
          child: child,
        );
      case ACDResolvedDesign.cupertino:
        final ShapeBorder effectiveShape =
            shape ??
            RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.zero,
            );
        Widget content = DefaultTextStyle(
          style: CupertinoTheme.of(context).textTheme.textStyle,
          child: child,
        );
        if (color != null) {
          content = DecoratedBox(
            decoration: ShapeDecoration(shape: effectiveShape, color: color),
            child: content,
          );
        }
        if (clipBehavior == Clip.none) return content;
        return ClipPath(
          clipper: ShapeBorderClipper(
            shape: effectiveShape,
            textDirection: Directionality.maybeOf(context),
          ),
          clipBehavior: clipBehavior,
          child: content,
        );
    }
  }
}

// ── List tile ─────────────────────────────────────────────────────────────────

/// A list row: `ListTile` | `CupertinoListTile`.
class ACDAdaptiveListTile extends StatelessWidget {
  const ACDAdaptiveListTile({
    super.key,
    required this.design,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.enabled = true,
    this.backgroundColor,
    this.contentPadding,
    this.dense,
  });

  final ACDResolvedDesign design;
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final bool enabled;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool? dense;

  @override
  Widget build(BuildContext context) {
    switch (design) {
      case ACDResolvedDesign.material:
        return acdEnsureMaterial(
          context,
          Material(
            color: backgroundColor ?? Colors.transparent,
            child: ListTile(
              title: title,
              subtitle: subtitle,
              leading: leading,
              trailing: trailing,
              onTap: enabled ? onTap : null,
              enabled: enabled,
              selected: selected,
              contentPadding: contentPadding,
              dense: dense,
            ),
          ),
        );
      case ACDResolvedDesign.cupertino:
        return Semantics(
          selected: selected,
          button: onTap != null,
          enabled: enabled,
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: CupertinoListTile(
              title: title,
              subtitle: subtitle,
              leading: leading,
              trailing: trailing,
              onTap: enabled ? onTap : null,
              backgroundColor: backgroundColor,
              padding: contentPadding,
            ),
          ),
        );
    }
  }
}

// ── Toggles ───────────────────────────────────────────────────────────────────

/// A checkbox: `Checkbox` | `CupertinoCheckbox`.
class ACDAdaptiveCheckbox extends StatelessWidget {
  const ACDAdaptiveCheckbox({
    super.key,
    required this.design,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.checkColor,
  });

  final ACDResolvedDesign design;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Color? activeColor;
  final Color? checkColor;

  @override
  Widget build(BuildContext context) => switch (design) {
    ACDResolvedDesign.material => acdEnsureMaterial(
      context,
      Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        checkColor: checkColor,
      ),
    ),
    ACDResolvedDesign.cupertino => CupertinoCheckbox(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      checkColor: checkColor,
    ),
  };
}

// ── Text field ────────────────────────────────────────────────────────────────

/// A text field: `TextField` (with [decoration]) | `CupertinoTextField`
/// (with [decoration] mapped to placeholder/prefix/suffix and
/// [cupertinoStyle] applied), plus error/helper text below on iOS.
class ACDAdaptiveTextField extends StatelessWidget {
  const ACDAdaptiveTextField({
    super.key,
    required this.design,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.cupertinoStyle,
    this.search = false,
    this.style,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.inputFormatters,
    this.enabled,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.autofillHints,
    this.restorationId,
  });

  final ACDResolvedDesign design;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration decoration;
  final ACDCupertinoFieldStyle? cupertinoStyle;

  /// Render as a search field (iOS: `CupertinoSearchTextField` styling).
  final bool search;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final GestureTapCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final bool readOnly;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextAlign textAlign;
  final Iterable<String>? autofillHints;
  final String? restorationId;

  @override
  Widget build(BuildContext context) {
    if (design == ACDResolvedDesign.material) {
      return acdEnsureMaterial(
        context,
        TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: decoration,
          style: style,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onTap: onTap,
          onTapOutside: onTapOutside,
          inputFormatters: inputFormatters,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: autofocus,
          obscureText: obscureText,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          textAlign: textAlign,
          autofillHints: autofillHints,
          restorationId: restorationId,
        ),
      );
    }

    final ACDCupertinoFieldStyle? cs = cupertinoStyle;
    final String? placeholder =
        cs?.placeholder ?? decoration.hintText ?? decoration.labelText;
    final bool isEnabled = enabled ?? decoration.enabled;
    Widget field;
    if (search) {
      field = CupertinoSearchTextField(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        placeholderStyle: cs?.placeholderStyle,
        style: cs?.style ?? style,
        decoration: cs?.decoration,
        padding:
            cs?.padding ?? const EdgeInsetsDirectional.fromSTEB(5.5, 8, 5.5, 8),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        enabled: isEnabled,
        autofocus: autofocus,
        autocorrect: autocorrect,
        enableIMEPersonalizedLearning: true,
      );
    } else {
      field = CupertinoTextField(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        placeholderStyle:
            cs?.placeholderStyle ??
            const TextStyle(color: CupertinoColors.placeholderText),
        prefix: cs?.prefix ?? _padIcon(decoration.prefixIcon, start: true),
        suffix: cs?.suffix ?? _padIcon(decoration.suffixIcon, start: false),
        decoration:
            cs?.decoration ??
            BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.tertiarySystemFill,
                context,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: decoration.errorText != null
                  ? Border.all(
                      color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemRed,
                        context,
                      ),
                    )
                  : null,
            ),
        padding: cs?.padding ?? const EdgeInsets.all(12),
        style: cs?.style ?? style,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        onTapOutside: onTapOutside,
        inputFormatters: inputFormatters,
        enabled: isEnabled,
        readOnly: readOnly,
        autofocus: autofocus,
        obscureText: obscureText,
        autocorrect: autocorrect,
        enableSuggestions: enableSuggestions,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        textAlign: textAlign,
        autofillHints: autofillHints,
        restorationId: restorationId,
      );
    }

    final String? below = decoration.errorText ?? decoration.helperText;
    if (below == null) return field;
    final bool isError = decoration.errorText != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field,
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 12, top: 6),
          child: Semantics(
            liveRegion: isError,
            child: Text(
              below,
              style: TextStyle(
                fontSize: 13,
                color: CupertinoDynamicColor.resolve(
                  isError
                      ? CupertinoColors.systemRed
                      : CupertinoColors.secondaryLabel,
                  context,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget? _padIcon(Widget? icon, {required bool start}) {
    if (icon == null) return null;
    return Padding(
      padding: start
          ? const EdgeInsetsDirectional.only(start: 8)
          : const EdgeInsetsDirectional.only(end: 8),
      child: IconTheme.merge(
        data: const IconThemeData(
          size: 20,
          color: CupertinoColors.secondaryLabel,
        ),
        child: icon,
      ),
    );
  }
}

// ── Popup surface ─────────────────────────────────────────────────────────────

/// An elevated popup panel (autocomplete results, menus): Material card |
/// iOS blurred popup surface.
class ACDAdaptivePopupSurface extends StatelessWidget {
  const ACDAdaptivePopupSurface({
    super.key,
    required this.design,
    required this.child,
    this.color,
    this.elevation = 4,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  final ACDResolvedDesign design;
  final Widget child;
  final Color? color;
  final double elevation;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    switch (design) {
      case ACDResolvedDesign.material:
        return acdEnsureMaterial(
          context,
          Material(
            elevation: elevation,
            color: color,
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        );
      case ACDResolvedDesign.cupertino:
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: color == null
                ? CupertinoPopupSurface(
                    child: DefaultTextStyle(
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                      child: child,
                    ),
                  )
                : ColoredBox(
                    color: color!,
                    child: DefaultTextStyle(
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                      child: child,
                    ),
                  ),
          ),
        );
    }
  }
}
