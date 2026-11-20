import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/acd_design_scope.dart';
import '../design/acd_design_tokens.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../design/internal/acd_platform_support.dart';
import 'acd_dialog.dart';

/// Adds `acdProgress()`, `acdDivider()`, `acdImage()`, and
/// `acdTextField()` to [ACDDialog] for common content widgets.
///
/// Each renders per the dialog's [ACDDialog.design] (resolved when the
/// dialog builds, so it doesn't matter whether `design` is set before or
/// after these are chained).
extension ACDDialogWidgets on ACDDialog {
  /// Adds a loading spinner (Material circular indicator, or iOS activity
  /// indicator). Returns this dialog for chaining.
  ACDDialog acdProgress({
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? valueColor,
    double? strokeWidth,
  }) {
    return widget(
      Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Builder(
          builder: (context) {
            final String label = ACDDesignScope.stringsOf(context).loading;
            return switch (resolveDesign(context)) {
              ACDResolvedDesign.material => CircularProgressIndicator(
                strokeWidth: strokeWidth ?? 4.0,
                backgroundColor: backgroundColor,
                semanticsLabel: label,
                valueColor: valueColor != null
                    ? AlwaysStoppedAnimation<Color>(valueColor)
                    : null,
              ),
              ACDResolvedDesign.cupertino => Semantics(
                label: label,
                child: CupertinoActivityIndicator(color: valueColor),
              ),
            };
          },
        ),
      ),
    );
  }

  /// Adds a horizontal divider line (Material divider, or iOS hairline
  /// separator). Returns this dialog for chaining.
  ACDDialog acdDivider({
    Color? color,
    double? height,
    double? thickness,
    EdgeInsets? padding,
  }) {
    return widget(
      Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Builder(
          builder: (context) {
            final ACDResolvedDesign design = resolveDesign(context);
            if (!design.isCupertino) {
              return Divider(
                color: color ?? Colors.grey[300],
                height: height ?? 1.0,
                thickness: thickness,
              );
            }
            return SizedBox(
              height: height ?? 1.0,
              child: Center(
                child: Container(
                  height: thickness ?? 0.5,
                  color: color ?? ACDDesignTokens.of(context, design).separator,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Adds an asset or network image, either [assetPath] or [imageProvider]
  /// is required. Pass [semanticLabel] to describe it to screen readers
  /// (omit it for purely decorative images). Returns this dialog for
  /// chaining.
  ACDDialog acdImage({
    String? assetPath,
    ImageProvider? imageProvider,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    EdgeInsets? padding,
    double borderRadius = 0.0,
    String? semanticLabel,
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
            semanticLabel: semanticLabel,
            excludeFromSemantics: semanticLabel == null,
          ),
        ),
      ),
    );
  }

  /// Adds a text input field (Material outlined field, or iOS rounded
  /// field). Pass [validator] to enable inline validation (optional — omit
  /// it for a plain field), and [fieldKey] if you need to trigger
  /// validation manually, e.g. from a submit button's `onTap` via
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
    final AutovalidateMode? effectiveAutovalidate =
        autovalidateMode ??
        (validator != null ? AutovalidateMode.onUserInteraction : null);
    return widget(
      Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Builder(
          builder: (context) {
            final ACDResolvedDesign design = resolveDesign(context);
            if (!design.isCupertino) {
              return acdEnsureMaterial(
                context,
                TextFormField(
                  key: fieldKey,
                  controller: controller,
                  maxLines: maxLines,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  onChanged: onChanged,
                  onFieldSubmitted: onSubmitted,
                  style: style,
                  validator: validator,
                  autovalidateMode: effectiveAutovalidate,
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
              );
            }
            // Cupertino: same FormField validation contract (fieldKey,
            // validator, autovalidateMode), rendered as an iOS field.
            return FormField<String>(
              key: fieldKey,
              initialValue: controller?.text ?? '',
              validator: validator,
              autovalidateMode: effectiveAutovalidate,
              builder: (state) => ACDAdaptiveTextField(
                design: design,
                controller: controller,
                maxLines: maxLines,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                style: style,
                onChanged: (value) {
                  state.didChange(value);
                  onChanged?.call(value);
                },
                onSubmitted: onSubmitted,
                decoration: InputDecoration(
                  hintText: hint ?? label,
                  prefixIcon: prefixIcon,
                  suffixIcon: suffixIcon,
                  errorText: state.errorText,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
