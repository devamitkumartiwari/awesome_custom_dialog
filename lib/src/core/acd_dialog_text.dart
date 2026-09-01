import 'package:flutter/material.dart';

import 'acd_dialog.dart';

/// Adds `text()` to [ACDDialog] for adding a styled line of text.
extension ACDDialogText on ACDDialog {
  /// Adds a styled [Text] to the dialog. Returns this dialog for chaining.
  ACDDialog text({
    EdgeInsets? padding,
    String? text,
    Color? color,
    double? fontSize,
    AlignmentGeometry? alignment,
    TextAlign? textAlign,
    int? maxLines,
    TextDirection? textDirection,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    String? fontFamily,
    // Full style control (letterSpacing, height, decoration, fontStyle,
    // shadows, etc.) — merged over the params above, which stay as quick
    // shortcuts and remain the defaults when style is omitted or leaves a
    // property unset.
    TextStyle? style,
  }) {
    return widget(
      Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Align(
          // AlignmentDirectional resolves against ambient Directionality,
          // so plain-LTR usage is unchanged while RTL apps get the text
          // starting on the correct visual side without extra wiring.
          alignment: alignment ?? AlignmentDirectional.centerStart,
          child: Text(
            text ?? '',
            textAlign: textAlign,
            maxLines: maxLines,
            textDirection: textDirection,
            overflow: overflow,
            style: TextStyle(
              color: color ?? Colors.black,
              fontSize: fontSize ?? 14.0,
              fontWeight: fontWeight,
              fontFamily: fontFamily,
            ).merge(style),
          ),
        ),
      ),
    );
  }
}
