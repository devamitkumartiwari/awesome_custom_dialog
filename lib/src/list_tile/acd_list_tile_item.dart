import 'package:flutter/material.dart';

// ── Data classes ──────────────────────────────────────────────────────────────

/// One row for `ACDDialog.listOfACDListTile()`.
class ACDListTileItem {
  /// Creates an [ACDListTileItem].
  const ACDListTileItem({
    this.padding,
    this.leading,
    this.trailing,
    this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.style,
  });

  /// Content padding for this row. Defaults to a sensible horizontal inset
  /// if unset.
  final EdgeInsets? padding;

  /// Widget shown before the text, e.g. an [Icon].
  final Widget? leading;

  /// Widget shown after the text.
  final Widget? trailing;

  /// The row's label.
  final String? text;

  /// Text color.
  final Color? color;

  /// Text size.
  final double? fontSize;

  /// Text weight.
  final FontWeight? fontWeight;

  /// Text font family.
  final String? fontFamily;

  /// Full style control, merged over [color]/[fontSize]/[fontWeight]/
  /// [fontFamily] above so any `TextStyle` property (letterSpacing,
  /// decoration, height, fontStyle, etc.) can be overridden while the rest
  /// keep their defaults.
  final TextStyle? style;
}
