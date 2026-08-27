import 'package:flutter/material.dart';

import 'acd_dialog.dart';

/// Adds `acdProgress()`, `acdDivider()`, `acdImage()`, and
/// `acdTextField()` to [ACDDialog] for common content widgets.
extension ACDDialogWidgets on ACDDialog {
  /// Adds a circular loading spinner. Returns this dialog for chaining.
  ACDDialog acdProgress({
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? valueColor,
    double? strokeWidth,
  }) {
    return widget(
      Padding(
        padding: padding ?? EdgeInsets.zero,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth ?? 4.0,
          backgroundColor: backgroundColor,
          valueColor: valueColor != null
              ? AlwaysStoppedAnimation<Color>(valueColor)
              : null,
        ),
      ),
    );
  }

  /// Adds a horizontal divider line. Returns this dialog for chaining.
  ACDDialog acdDivider({
    Color? color,
    double? height,
    double? thickness,
    EdgeInsets? padding,
  }) {
    return widget(
      Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Divider(
          color: color ?? Colors.grey[300],
          height: height ?? 1.0,
          thickness: thickness,
        ),
      ),
    );
  }

  /// Adds an asset or network image, either [assetPath] or [imageProvider]
  /// is required. Returns this dialog for chaining.
  ACDDialog acdImage({
    String? assetPath,
    ImageProvider? imageProvider,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    EdgeInsets? padding,
    double borderRadius = 0.0,
  }) {
    assert(
      assetPath != null || imageProvider != null,
      'Provide either assetPath or imageProvider',
    );
    return widget(
      Padding(
        padding: padding ?? EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image(
            image: imageProvider ?? AssetImage(assetPath!),
            width: width,
            height: height,
            fit: fit,
          ),
        ),
      ),
    );
  }

  /// Adds a text input field. Pass [validator] to enable inline validation
  /// (optional — omit it for a plain field), and [fieldKey] if you need to
  /// trigger validation manually, e.g. from a submit button's `onTap` via
  /// `fieldKey.currentState?.validate()`. Returns this dialog for chaining.
  ACDDialog acdTextField({
    TextEditingController? controller,
    String? hint,
    String? label,
    int? maxLines = 1,
    Color? fillColor,
    Color? borderColor,
    double borderRadius = 4.0,
    EdgeInsets? padding,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextStyle? style,
    TextStyle? hintStyle,
    TextStyle? labelStyle,
    // Optional — omit entirely for a plain field with no validation.
    // When set, the field self-validates as the user interacts with it
    // (no surrounding Form needed). Pass fieldKey if you also want to
    // trigger validation manually (e.g. from a submit button's onTap via
    // fieldKey.currentState?.validate()).
    FormFieldValidator<String>? validator,
    AutovalidateMode? autovalidateMode,
    GlobalKey<FormFieldState<String>>? fieldKey,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return widget(
      Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextFormField(
          key: fieldKey,
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          style: style,
          validator: validator,
          autovalidateMode:
              autovalidateMode ??
              (validator != null ? AutovalidateMode.onUserInteraction : null),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: hintStyle,
            labelText: label,
            labelStyle: labelStyle,
            fillColor: fillColor,
            filled: fillColor != null,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: borderColor ?? Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
