import 'package:flutter/material.dart';

import 'acd_dialog.dart';
import 'acd_gravity.dart';

/// Adds `oneButton()`, `twoButton()`, and `threeButton()` to [ACDDialog]
/// for adding action button rows.
extension ACDDialogButtons on ACDDialog {
  /// Adds a row of two text buttons. Returns this dialog for chaining.
  ACDDialog twoButton({
    EdgeInsets? padding,
    ACDGravity? gravity,
    double? height,
    bool isClickAutoDismiss = true,
    bool withDivider = false,
    String? text1,
    Color? color1,
    double? fontSize1,
    FontWeight? fontWeight1,
    String? fontFamily1,
    VoidCallback? onTap1,
    EdgeInsets buttonPadding1 = EdgeInsets.zero,
    TextStyle? textStyle1,
    String? text2,
    Color? color2,
    double? fontSize2,
    FontWeight? fontWeight2,
    String? fontFamily2,
    VoidCallback? onTap2,
    EdgeInsets buttonPadding2 = EdgeInsets.zero,
    TextStyle? textStyle2,
  }) {
    return widget(
      SizedBox(
        height: height ?? 45.0,
        child: Row(
          mainAxisAlignment: acdRowAlignment(gravity),
          children: <Widget>[
            TextButton(
              onPressed: () {
                onTap1?.call();
                if (isClickAutoDismiss) dismiss();
              },
              style: TextButton.styleFrom(
                foregroundColor: color1 ?? Colors.black,
                padding: buttonPadding1,
                textStyle: TextStyle(
                  fontSize: fontSize1 ?? 18.0,
                  fontWeight: fontWeight1,
                  fontFamily: fontFamily1,
                ).merge(textStyle1),
              ),
              child: Text(text1 ?? ''),
            ),
            if (withDivider) const VerticalDivider(),
            TextButton(
              onPressed: () {
                onTap2?.call();
                if (isClickAutoDismiss) dismiss();
              },
              style: TextButton.styleFrom(
                foregroundColor: color2 ?? Colors.black,
                padding: buttonPadding2,
                textStyle: TextStyle(
                  fontSize: fontSize2 ?? 14.0,
                  fontWeight: fontWeight2,
                  fontFamily: fontFamily2,
                ).merge(textStyle2),
              ),
              child: Text(text2 ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  /// Adds a single, centered text button. Returns this dialog for chaining.
  ACDDialog oneButton({
    double? height,
    bool isClickAutoDismiss = true,
    String? text,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    String? fontFamily,
    VoidCallback? onTap,
    EdgeInsets buttonPadding = EdgeInsets.zero,
    TextStyle? textStyle,
  }) {
    return widget(
      SizedBox(
        height: height ?? 45.0,
        child: Center(
          child: TextButton(
            onPressed: () {
              onTap?.call();
              if (isClickAutoDismiss) dismiss();
            },
            style: TextButton.styleFrom(
              foregroundColor: color ?? Colors.black,
              padding: buttonPadding,
              textStyle: TextStyle(
                fontSize: fontSize ?? 18.0,
                fontWeight: fontWeight,
                fontFamily: fontFamily,
              ).merge(textStyle),
            ),
            child: Text(text ?? 'OK'),
          ),
        ),
      ),
    );
  }

  /// Adds a row of three text buttons, evenly spaced. Returns this dialog
  /// for chaining.
  ACDDialog threeButton({
    double? height,
    bool isClickAutoDismiss = true,
    String? text1,
    Color? color1,
    double? fontSize1,
    FontWeight? fontWeight1,
    String? fontFamily1,
    VoidCallback? onTap1,
    EdgeInsets buttonPadding1 = EdgeInsets.zero,
    TextStyle? textStyle1,
    String? text2,
    Color? color2,
    double? fontSize2,
    FontWeight? fontWeight2,
    String? fontFamily2,
    VoidCallback? onTap2,
    EdgeInsets buttonPadding2 = EdgeInsets.zero,
    TextStyle? textStyle2,
    String? text3,
    Color? color3,
    double? fontSize3,
    FontWeight? fontWeight3,
    String? fontFamily3,
    VoidCallback? onTap3,
    EdgeInsets buttonPadding3 = EdgeInsets.zero,
    TextStyle? textStyle3,
  }) {
    return widget(
      SizedBox(
        height: height ?? 45.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                onTap1?.call();
                if (isClickAutoDismiss) dismiss();
              },
              style: TextButton.styleFrom(
                foregroundColor: color1 ?? Colors.black,
                padding: buttonPadding1,
              ),
              child: Text(
                text1 ?? '',
                style: TextStyle(
                  fontSize: fontSize1 ?? 14.0,
                  fontWeight: fontWeight1,
                  fontFamily: fontFamily1,
                ).merge(textStyle1),
              ),
            ),
            const VerticalDivider(),
            TextButton(
              onPressed: () {
                onTap2?.call();
                if (isClickAutoDismiss) dismiss();
              },
              style: TextButton.styleFrom(
                foregroundColor: color2 ?? Colors.black,
                padding: buttonPadding2,
              ),
              child: Text(
                text2 ?? '',
                style: TextStyle(
                  fontSize: fontSize2 ?? 14.0,
                  fontWeight: fontWeight2,
                  fontFamily: fontFamily2,
                ).merge(textStyle2),
              ),
            ),
            const VerticalDivider(),
            TextButton(
              onPressed: () {
                onTap3?.call();
                if (isClickAutoDismiss) dismiss();
              },
              style: TextButton.styleFrom(
                foregroundColor: color3 ?? Colors.black,
                padding: buttonPadding3,
              ),
              child: Text(
                text3 ?? '',
                style: TextStyle(
                  fontSize: fontSize3 ?? 14.0,
                  fontWeight: fontWeight3,
                  fontFamily: fontFamily3,
                ).merge(textStyle3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
