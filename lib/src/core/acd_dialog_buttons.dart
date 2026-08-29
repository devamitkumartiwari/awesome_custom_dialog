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
    EdgeInsets? buttonPadding1,
    TextStyle? textStyle1,
    Color? backgroundColor1,
    BorderRadius? borderRadius1,
    double? elevation1,
    List<BoxShadow>? boxShadow1,
    IconData? icon1,
    Gradient? gradient1,
    String? text2,
    Color? color2,
    double? fontSize2,
    FontWeight? fontWeight2,
    String? fontFamily2,
    VoidCallback? onTap2,
    EdgeInsets? buttonPadding2,
    TextStyle? textStyle2,
    Color? backgroundColor2,
    BorderRadius? borderRadius2,
    double? elevation2,
    List<BoxShadow>? boxShadow2,
    IconData? icon2,
    Gradient? gradient2,
  }) {
    final Widget row = Row(
      mainAxisAlignment: acdRowAlignment(gravity),
      children: <Widget>[
        _acdButton(
          text: text1 ?? '',
          color: color1,
          fontSize: fontSize1 ?? 18.0,
          fontWeight: fontWeight1,
          fontFamily: fontFamily1,
          textStyle: textStyle1,
          buttonPadding: buttonPadding1,
          backgroundColor: backgroundColor1,
          borderRadius: borderRadius1,
          elevation: elevation1,
          boxShadow: boxShadow1,
          icon: icon1,
          gradient: gradient1,
          onPressed: () {
            onTap1?.call();
            if (isClickAutoDismiss) dismiss();
          },
        ),
        if (withDivider) const VerticalDivider(),
        _acdButton(
          text: text2 ?? '',
          color: color2,
          fontSize: fontSize2 ?? 14.0,
          fontWeight: fontWeight2,
          fontFamily: fontFamily2,
          textStyle: textStyle2,
          buttonPadding: buttonPadding2,
          backgroundColor: backgroundColor2,
          borderRadius: borderRadius2,
          elevation: elevation2,
          boxShadow: boxShadow2,
          icon: icon2,
          gradient: gradient2,
          onPressed: () {
            onTap2?.call();
            if (isClickAutoDismiss) dismiss();
          },
        ),
      ],
    );
    // Only force a fixed height when the caller explicitly asks for one —
    // a hardcoded default risks clipping a filled/padded button (see
    // _acdButton's smart-padding default) that's taller than the old
    // zero-padding flat-text-button look this default was tuned for.
    return widget(height == null ? row : SizedBox(height: height, child: row));
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
    EdgeInsets? buttonPadding,
    TextStyle? textStyle,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    double? elevation,
    List<BoxShadow>? boxShadow,
    IconData? icon,
    Gradient? gradient,
  }) {
    final Widget centered = Center(
      child: _acdButton(
        text: text ?? 'OK',
        color: color,
        fontSize: fontSize ?? 18.0,
        fontWeight: fontWeight,
        fontFamily: fontFamily,
        textStyle: textStyle,
        buttonPadding: buttonPadding,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        elevation: elevation,
        boxShadow: boxShadow,
        icon: icon,
        gradient: gradient,
        onPressed: () {
          onTap?.call();
          if (isClickAutoDismiss) dismiss();
        },
      ),
    );
    return widget(
      // Only force a fixed height when the caller explicitly asks for one —
      // see the matching comment in twoButton().
      height == null ? centered : SizedBox(height: height, child: centered),
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
    EdgeInsets? buttonPadding1,
    TextStyle? textStyle1,
    Color? backgroundColor1,
    BorderRadius? borderRadius1,
    double? elevation1,
    List<BoxShadow>? boxShadow1,
    IconData? icon1,
    Gradient? gradient1,
    String? text2,
    Color? color2,
    double? fontSize2,
    FontWeight? fontWeight2,
    String? fontFamily2,
    VoidCallback? onTap2,
    EdgeInsets? buttonPadding2,
    TextStyle? textStyle2,
    Color? backgroundColor2,
    BorderRadius? borderRadius2,
    double? elevation2,
    List<BoxShadow>? boxShadow2,
    IconData? icon2,
    Gradient? gradient2,
    String? text3,
    Color? color3,
    double? fontSize3,
    FontWeight? fontWeight3,
    String? fontFamily3,
    VoidCallback? onTap3,
    EdgeInsets? buttonPadding3,
    TextStyle? textStyle3,
    Color? backgroundColor3,
    BorderRadius? borderRadius3,
    double? elevation3,
    List<BoxShadow>? boxShadow3,
    IconData? icon3,
    Gradient? gradient3,
  }) {
    final Widget row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _acdButton(
          text: text1 ?? '',
          color: color1,
          fontSize: fontSize1 ?? 14.0,
          fontWeight: fontWeight1,
          fontFamily: fontFamily1,
          textStyle: textStyle1,
          buttonPadding: buttonPadding1,
          backgroundColor: backgroundColor1,
          borderRadius: borderRadius1,
          elevation: elevation1,
          boxShadow: boxShadow1,
          icon: icon1,
          gradient: gradient1,
          onPressed: () {
            onTap1?.call();
            if (isClickAutoDismiss) dismiss();
          },
        ),
        const VerticalDivider(),
        _acdButton(
          text: text2 ?? '',
          color: color2,
          fontSize: fontSize2 ?? 14.0,
          fontWeight: fontWeight2,
          fontFamily: fontFamily2,
          textStyle: textStyle2,
          buttonPadding: buttonPadding2,
          backgroundColor: backgroundColor2,
          borderRadius: borderRadius2,
          elevation: elevation2,
          boxShadow: boxShadow2,
          icon: icon2,
          gradient: gradient2,
          onPressed: () {
            onTap2?.call();
            if (isClickAutoDismiss) dismiss();
          },
        ),
        const VerticalDivider(),
        _acdButton(
          text: text3 ?? '',
          color: color3,
          fontSize: fontSize3 ?? 14.0,
          fontWeight: fontWeight3,
          fontFamily: fontFamily3,
          textStyle: textStyle3,
          buttonPadding: buttonPadding3,
          backgroundColor: backgroundColor3,
          borderRadius: borderRadius3,
          elevation: elevation3,
          boxShadow: boxShadow3,
          icon: icon3,
          gradient: gradient3,
          onPressed: () {
            onTap3?.call();
            if (isClickAutoDismiss) dismiss();
          },
        ),
      ],
    );
    // Only force a fixed height when the caller explicitly asks for one —
    // see the matching comment in twoButton().
    return widget(height == null ? row : SizedBox(height: height, child: row));
  }
}

/// Shared button builder for `oneButton`/`twoButton`/`threeButton` — keeps
/// the background/shape/elevation/icon/gradient customization added on top
/// of the original plain `TextButton` in one place instead of repeated
/// per-slot inline.
Widget _acdButton({
  required VoidCallback onPressed,
  required String text,
  required Color? color,
  required double fontSize,
  required FontWeight? fontWeight,
  required String? fontFamily,
  required TextStyle? textStyle,
  required EdgeInsets? buttonPadding,
  required Color? backgroundColor,
  required BorderRadius? borderRadius,
  required double? elevation,
  required List<BoxShadow>? boxShadow,
  required IconData? icon,
  required Gradient? gradient,
}) {
  final TextStyle mergedTextStyle = TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontFamily: fontFamily,
    color: color ?? Colors.black,
  ).merge(textStyle);

  final Widget label = icon == null
      ? Text(text, style: mergedTextStyle)
      : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: mergedTextStyle.fontSize,
              color: mergedTextStyle.color,
            ),
            const SizedBox(width: 8),
            Text(text, style: mergedTextStyle),
          ],
        );

  // A filled/gradient/shadowed button needs real breathing room around its
  // label or it reads as a cramped sticker rather than a button — but a
  // plain flat text button (the original, pre-styling look) is still meant
  // to sit flush with no padding by default, so only the "filled" look gets
  // a non-zero default.
  final bool filled =
      backgroundColor != null || gradient != null || boxShadow != null;
  final EdgeInsets effectivePadding =
      buttonPadding ??
      (filled
          ? const EdgeInsets.symmetric(horizontal: 22, vertical: 14)
          : EdgeInsets.zero);

  final TextButton button = TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: color ?? Colors.black,
      backgroundColor: gradient == null ? backgroundColor : Colors.transparent,
      padding: effectivePadding,
      minimumSize: filled ? const Size(64, 44) : null,
      elevation: boxShadow == null ? elevation : null,
      shadowColor: boxShadow == null ? null : Colors.transparent,
      shape: borderRadius == null
          ? null
          : RoundedRectangleBorder(borderRadius: borderRadius),
    ),
    child: label,
  );

  if (gradient == null && boxShadow == null) return button;

  return Container(
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
    ),
    child: button,
  );
}
