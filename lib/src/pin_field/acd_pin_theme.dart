import 'package:flutter/material.dart';

/// Visual style for one [ACDPinField] cell. Supply a different [ACDPinTheme]
/// per state ([ACDPinField.focusedPinTheme], [ACDPinField.submittedPinTheme],
/// etc.); every field left `null` falls back to the same field on
/// [ACDPinField.pinTheme] (the default theme).
///
/// Direct shortcuts ([color]/[gradient]/[borderColor]/[borderWidth]/
/// [borderRadius]/[shape]/[boxShadow]) cover the common cases without
/// building a [BoxDecoration] by hand — matching the rest of this package's
/// widgets. For anything beyond what they express (an asymmetric border, a
/// background image, a blend mode...), set [decoration] instead; it fully
/// replaces the cell's decoration and the shortcuts above are ignored.
@immutable
final class ACDPinTheme {
  /// Creates an [ACDPinTheme].
  const ACDPinTheme({
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.constraints,
    this.color,
    this.gradient,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.shape,
    this.boxShadow,
    this.decoration,
    this.textStyle,
  });

  /// Cell width. Falls back to `48.0` if this is the default theme and left
  /// unset.
  final double? width;

  /// Cell height. Falls back to `52.0` if this is the default theme and
  /// left unset.
  final double? height;

  /// Space around the cell.
  final EdgeInsetsGeometry? margin;

  /// Space between the cell's decoration and its content.
  final EdgeInsetsGeometry? padding;

  /// Overrides [width]/[height] when set.
  final BoxConstraints? constraints;

  /// Cell background fill, ignored when [gradient] is set. Ignored
  /// entirely when [decoration] is supplied.
  final Color? color;

  /// Cell background gradient, overriding [color].
  final Gradient? gradient;

  /// Cell border color. No border is drawn when `null`.
  final Color? borderColor;

  /// Width of [borderColor]'s border. Falls back to `1.0`.
  final double? borderWidth;

  /// Cell corner radius. Ignored when [shape] is [BoxShape.circle].
  final BorderRadius? borderRadius;

  /// Rectangle (the default) or a fully circular cell.
  final BoxShape? shape;

  /// Drop shadow behind the cell.
  final List<BoxShadow>? boxShadow;

  /// Escape hatch: fully replaces the cell's decoration — [color]/
  /// [gradient]/[borderColor]/[borderWidth]/[borderRadius]/[shape]/
  /// [boxShadow] above are ignored once this is set.
  final BoxDecoration? decoration;

  /// Digit/obscure-glyph text style.
  final TextStyle? textStyle;

  /// The actual [BoxDecoration] to paint — [decoration] verbatim if set,
  /// otherwise built from [color]/[gradient]/[borderColor]/[borderWidth]/
  /// [borderRadius]/[shape]/[boxShadow]. `null` when none of those are set
  /// either (nothing to paint).
  BoxDecoration? resolveDecoration() {
    if (decoration != null) return decoration;
    if (color == null &&
        gradient == null &&
        borderColor == null &&
        borderRadius == null &&
        shape == null &&
        boxShadow == null) {
      return null;
    }
    final BoxShape effectiveShape = shape ?? BoxShape.rectangle;
    return BoxDecoration(
      color: gradient == null ? color : null,
      gradient: gradient,
      shape: effectiveShape,
      borderRadius: effectiveShape == BoxShape.circle ? null : borderRadius,
      border: borderColor == null
          ? null
          : Border.all(color: borderColor!, width: borderWidth ?? 1.0),
      boxShadow: boxShadow,
    );
  }

  /// Returns a copy with the given fields replaced.
  ACDPinTheme copyWith({
    double? width,
    double? height,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    BoxConstraints? constraints,
    Color? color,
    Gradient? gradient,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    BoxShape? shape,
    List<BoxShadow>? boxShadow,
    BoxDecoration? decoration,
    TextStyle? textStyle,
  }) {
    return ACDPinTheme(
      width: width ?? this.width,
      height: height ?? this.height,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      constraints: constraints ?? this.constraints,
      color: color ?? this.color,
      gradient: gradient ?? this.gradient,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      shape: shape ?? this.shape,
      boxShadow: boxShadow ?? this.boxShadow,
      decoration: decoration ?? this.decoration,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  /// Merges [overlay]'s non-null fields on top of `base`'s — used to layer
  /// a state-specific theme (e.g. `focusedPinTheme`) over the default
  /// [ACDPinField.pinTheme]. Each field is resolved independently, so an
  /// overlay that only sets [borderColor] still inherits `base`'s [color]/
  /// [shape]/etc.
  static ACDPinTheme resolve(ACDPinTheme base, ACDPinTheme? overlay) {
    if (overlay == null) return base;
    return ACDPinTheme(
      width: overlay.width ?? base.width,
      height: overlay.height ?? base.height,
      margin: overlay.margin ?? base.margin,
      padding: overlay.padding ?? base.padding,
      constraints: overlay.constraints ?? base.constraints,
      color: overlay.color ?? base.color,
      gradient: overlay.gradient ?? base.gradient,
      borderColor: overlay.borderColor ?? base.borderColor,
      borderWidth: overlay.borderWidth ?? base.borderWidth,
      borderRadius: overlay.borderRadius ?? base.borderRadius,
      shape: overlay.shape ?? base.shape,
      boxShadow: overlay.boxShadow ?? base.boxShadow,
      decoration: overlay.decoration ?? base.decoration,
      textStyle: base.textStyle?.merge(overlay.textStyle) ?? overlay.textStyle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ACDPinTheme &&
          width == other.width &&
          height == other.height &&
          margin == other.margin &&
          padding == other.padding &&
          constraints == other.constraints &&
          color == other.color &&
          gradient == other.gradient &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth &&
          borderRadius == other.borderRadius &&
          shape == other.shape &&
          boxShadow == other.boxShadow &&
          decoration == other.decoration &&
          textStyle == other.textStyle);

  @override
  int get hashCode => Object.hash(
    Object.hash(width, height, margin, padding, constraints),
    Object.hash(color, gradient, borderColor, borderWidth),
    Object.hash(borderRadius, shape, boxShadow, decoration),
    textStyle,
  );
}
