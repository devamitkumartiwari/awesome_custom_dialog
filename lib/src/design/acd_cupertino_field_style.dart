import 'package:material_ui/material_ui.dart';

/// Cupertino-only styling for awesome_custom_dialog text fields, used when a
/// field renders with `ACDDesign.cupertino`.
///
/// The field's existing Material `InputDecoration` still applies to the
/// Cupertino variant where it maps cleanly: `hintText` (or `labelText`)
/// becomes the placeholder, `prefixIcon`/`suffixIcon` become prefix/suffix,
/// `errorText`/`helperText` render below the field, and `enabled` is
/// honoured. Use this class for everything Cupertino-specific.
@immutable
class ACDCupertinoFieldStyle {
  /// Creates a Cupertino field style.
  const ACDCupertinoFieldStyle({
    this.decoration,
    this.padding,
    this.placeholder,
    this.placeholderStyle,
    this.style,
    this.prefix,
    this.suffix,
  });

  /// The field's box decoration. Defaults to an iOS rounded grey field.
  final BoxDecoration? decoration;

  /// Inner padding. Defaults to iOS standard padding.
  final EdgeInsetsGeometry? padding;

  /// Placeholder, overriding the `InputDecoration` hint/label.
  final String? placeholder;

  /// Placeholder text style.
  final TextStyle? placeholderStyle;

  /// Input text style.
  final TextStyle? style;

  /// Leading widget, overriding the `InputDecoration` prefix icon.
  final Widget? prefix;

  /// Trailing widget, overriding the `InputDecoration` suffix icon.
  final Widget? suffix;
}
