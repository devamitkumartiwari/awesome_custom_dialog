import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/acd_design_tokens.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../design/internal/acd_platform_support.dart';

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
    kind: _ACDPresetKind.success,
    icon: icon,
    iconColor: iconColor,
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
    kind: _ACDPresetKind.error,
    icon: icon,
    iconColor: iconColor,
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
    kind: _ACDPresetKind.warning,
    icon: icon,
    iconColor: iconColor,
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
    kind: _ACDPresetKind.info,
    icon: icon,
    iconColor: iconColor,
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
    required _ACDPresetKind kind,
    required IconData? icon,
    required Color? iconColor,
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
      _ACDPresetBody(
        dialog: this,
        kind: kind,
        icon: icon,
        iconColor: iconColor,
        iconSize: iconSize,
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: () {
          onTap?.call();
          dismiss();
        },
        padding: padding,
        titleColor: titleColor,
        titleFontSize: titleFontSize,
        messageColor: messageColor,
        messageFontSize: messageFontSize,
        titleStyle: titleStyle,
        messageStyle: messageStyle,
        buttonTextStyle: buttonTextStyle,
      ),
    );
  }
}

enum _ACDPresetKind {
  success(ACDIcon.success, Color(0xFF4CAF50), 'Success'),
  error(ACDIcon.error, Color(0xFFF44336), 'Error'),
  warning(ACDIcon.warning, Color(0xFFFF9800), 'Warning'),
  info(ACDIcon.info, Color(0xFF2196F3), 'Information');

  const _ACDPresetKind(this.icon, this.materialColor, this.semanticLabel);

  final ACDIcon icon;
  final Color materialColor;
  final String semanticLabel;

  Color cupertinoColor(ACDDesignTokens tokens) => switch (this) {
    _ACDPresetKind.success => tokens.success,
    _ACDPresetKind.error => tokens.error,
    _ACDPresetKind.warning => tokens.warning,
    _ACDPresetKind.info => tokens.info,
  };
}

class _ACDPresetBody extends StatefulWidget {
  const _ACDPresetBody({
    required this.dialog,
    required this.kind,
    required this.icon,
    required this.iconColor,
    required this.iconSize,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
    required this.padding,
    required this.titleColor,
    required this.titleFontSize,
    required this.messageColor,
    required this.messageFontSize,
    required this.titleStyle,
    required this.messageStyle,
    required this.buttonTextStyle,
  });

  final ACDDialog dialog;
  final _ACDPresetKind kind;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;
  final String title;
  final String? message;
  final String buttonText;
  final VoidCallback onPressed;
  final EdgeInsets? padding;
  final Color? titleColor;
  final double titleFontSize;
  final Color? messageColor;
  final double messageFontSize;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final TextStyle? buttonTextStyle;

  @override
  State<_ACDPresetBody> createState() => _ACDPresetBodyState();
}

class _ACDPresetBodyState extends State<_ACDPresetBody> {
  @override
  void initState() {
    super.initState();
    // One status haptic when the dialog appears (never on rebuilds).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (widget.kind) {
        case _ACDPresetKind.success:
          ACDHaptics.light(context);
        case _ACDPresetKind.error:
        case _ACDPresetKind.warning:
          ACDHaptics.heavy(context);
        case _ACDPresetKind.info:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ACDResolvedDesign design = widget.dialog.resolveDesign(context);
    final bool cupertino = design.isCupertino;
    // Material warning uses the contrast-safe token (the old #FF9800 was
    // ~2.2:1 on a light surface); the other Material presets keep their hue.
    final bool needsTokens = cupertino || widget.kind == _ACDPresetKind.warning;
    final ACDDesignTokens? tokens = needsTokens
        ? ACDDesignTokens.of(context, design)
        : null;
    final Color iconColor =
        widget.iconColor ??
        (tokens == null
            ? widget.kind.materialColor
            : widget.kind.cupertinoColor(tokens));

    final Widget button = switch (design) {
      ACDResolvedDesign.material => acdEnsureMaterial(
        context,
        TextButton(
          onPressed: widget.onPressed,
          style: widget.buttonTextStyle != null
              ? TextButton.styleFrom(textStyle: widget.buttonTextStyle)
              : null,
          child: Text(widget.buttonText),
        ),
      ),
      // iOS alert: a single bold default action above a hairline.
      ACDResolvedDesign.cupertino => DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens!.separator, width: 0.5)),
        ),
        child: CupertinoButton(
          onPressed: widget.onPressed,
          minimumSize: const Size(44, 44),
          child: Text(
            widget.buttonText,
            style: const TextStyle(fontWeight: FontWeight.w600)
                .merge(widget.buttonTextStyle)
                .copyWith(color: tokens.primary),
          ),
        ),
      ),
    };

    return Padding(
      padding:
          widget.padding ??
          (cupertino
              ? const EdgeInsets.fromLTRB(16, 20, 16, 0)
              : const EdgeInsets.fromLTRB(20, 24, 20, 16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon ?? widget.kind.icon.of(design),
            color: iconColor,
            size: widget.iconSize,
            semanticLabel: widget.kind.semanticLabel,
          ),
          const SizedBox(height: 14),
          Semantics(
            header: true,
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: cupertino ? 17 : widget.titleFontSize,
                fontWeight: cupertino ? FontWeight.w600 : FontWeight.bold,
                color: widget.titleColor ?? tokens?.onSurface,
              ).merge(widget.titleStyle),
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: cupertino ? 13 : widget.messageFontSize,
                color:
                    widget.messageColor ??
                    tokens?.onSurface ??
                    const Color(0xFF757575),
              ).merge(widget.messageStyle),
            ),
          ],
          SizedBox(height: cupertino ? 16 : 20),
          SizedBox(width: double.infinity, child: button),
        ],
      ),
    );
  }
}
