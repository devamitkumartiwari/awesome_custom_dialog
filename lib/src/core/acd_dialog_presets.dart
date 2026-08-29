import 'package:flutter/material.dart';

import 'acd_dialog.dart';

/// Adds `success()`, `error()`, `warning()`, and `info()` to [ACDDialog] —
/// ready-made status dialogs with an icon, title, message, and OK button.
extension ACDDialogPresets on ACDDialog {
  /// A ready-made success dialog (green check icon). Returns this dialog
  /// for chaining.
  ACDDialog success({
    String title = 'Success',
    String? message,
    String buttonText = 'OK',
    VoidCallback? onTap,
    IconData? icon,
    Color? iconColor,
    double iconSize = 52,
    EdgeInsets? padding,
    Color? titleColor,
    double titleFontSize = 18,
    Color? messageColor,
    double messageFontSize = 14,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    TextStyle? buttonTextStyle,
  }) => _preset(
    icon: icon ?? Icons.check_circle_rounded,
    iconColor: iconColor ?? const Color(0xFF4CAF50),
    iconSize: iconSize,
    title: title,
    message: message,
    buttonText: buttonText,
    onTap: onTap,
    padding: padding,
    titleColor: titleColor,
    titleFontSize: titleFontSize,
    messageColor: messageColor,
    messageFontSize: messageFontSize,
    titleStyle: titleStyle,
    messageStyle: messageStyle,
    buttonTextStyle: buttonTextStyle,
  );

  /// A ready-made error dialog (red cancel icon). Returns this dialog for
  /// chaining.
  ACDDialog error({
    String title = 'Error',
    String? message,
    String buttonText = 'OK',
    VoidCallback? onTap,
    IconData? icon,
    Color? iconColor,
    double iconSize = 52,
    EdgeInsets? padding,
    Color? titleColor,
    double titleFontSize = 18,
    Color? messageColor,
    double messageFontSize = 14,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    TextStyle? buttonTextStyle,
  }) => _preset(
    icon: icon ?? Icons.cancel_rounded,
    iconColor: iconColor ?? const Color(0xFFF44336),
    iconSize: iconSize,
    title: title,
    message: message,
    buttonText: buttonText,
    onTap: onTap,
    padding: padding,
    titleColor: titleColor,
    titleFontSize: titleFontSize,
    messageColor: messageColor,
    messageFontSize: messageFontSize,
    titleStyle: titleStyle,
    messageStyle: messageStyle,
    buttonTextStyle: buttonTextStyle,
  );

  /// A ready-made warning dialog (orange warning icon). Returns this dialog
  /// for chaining.
  ACDDialog warning({
    String title = 'Warning',
    String? message,
    String buttonText = 'OK',
    VoidCallback? onTap,
    IconData? icon,
    Color? iconColor,
    double iconSize = 52,
    EdgeInsets? padding,
    Color? titleColor,
    double titleFontSize = 18,
    Color? messageColor,
    double messageFontSize = 14,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    TextStyle? buttonTextStyle,
  }) => _preset(
    icon: icon ?? Icons.warning_rounded,
    iconColor: iconColor ?? const Color(0xFFFF9800),
    iconSize: iconSize,
    title: title,
    message: message,
    buttonText: buttonText,
    onTap: onTap,
    padding: padding,
    titleColor: titleColor,
    titleFontSize: titleFontSize,
    messageColor: messageColor,
    messageFontSize: messageFontSize,
    titleStyle: titleStyle,
    messageStyle: messageStyle,
    buttonTextStyle: buttonTextStyle,
  );

  /// A ready-made info dialog (blue info icon). Returns this dialog for
  /// chaining.
  ACDDialog info({
    String title = 'Info',
    String? message,
    String buttonText = 'OK',
    VoidCallback? onTap,
    IconData? icon,
    Color? iconColor,
    double iconSize = 52,
    EdgeInsets? padding,
    Color? titleColor,
    double titleFontSize = 18,
    Color? messageColor,
    double messageFontSize = 14,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    TextStyle? buttonTextStyle,
  }) => _preset(
    icon: icon ?? Icons.info_rounded,
    iconColor: iconColor ?? const Color(0xFF2196F3),
    iconSize: iconSize,
    title: title,
    message: message,
    buttonText: buttonText,
    onTap: onTap,
    padding: padding,
    titleColor: titleColor,
    titleFontSize: titleFontSize,
    messageColor: messageColor,
    messageFontSize: messageFontSize,
    titleStyle: titleStyle,
    messageStyle: messageStyle,
    buttonTextStyle: buttonTextStyle,
  );

  ACDDialog _preset({
    required IconData icon,
    required Color iconColor,
    double iconSize = 52,
    required String title,
    String? message,
    required String buttonText,
    VoidCallback? onTap,
    EdgeInsets? padding,
    Color? titleColor,
    double titleFontSize = 18,
    Color? messageColor,
    double messageFontSize = 14,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    TextStyle? buttonTextStyle,
  }) {
    return widget(
      Padding(
        padding: padding ?? const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ).merge(titleStyle),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: messageFontSize,
                  color: messageColor ?? const Color(0xFF757575),
                ).merge(messageStyle),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  onTap?.call();
                  dismiss();
                },
                style: buttonTextStyle != null
                    ? TextButton.styleFrom(textStyle: buttonTextStyle)
                    : null,
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
