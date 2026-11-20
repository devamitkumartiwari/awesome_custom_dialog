import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../design/acd_action.dart';
import '../design/acd_design.dart';
import '../design/acd_design_tokens.dart';
import '../design/internal/acd_platform_support.dart';

import 'acd_dialog.dart';
import 'acd_gravity.dart';

/// Adds `oneButton()`, `twoButton()`, and `threeButton()` to [ACDDialog]
/// for adding action button rows.
extension ACDDialogButtons on ACDDialog {
  /// Adds design-native action buttons from role-tagged [ACDAction]s —
  /// Material 3 filled/text buttons, or iOS dialog actions (bold primary,
  /// red destructive, hairline separators; stacked vertically when there
  /// are more than two). Pair with [ACDDialog.showForResult] to await the
  /// chosen action's `value`. Returns this dialog for chaining.
  ACDDialog actions(List<ACDAction> actions, {EdgeInsets? padding}) =>
      widget(_ACDActionsBar(dialog: this, actions: actions, padding: padding));

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
          dialog: this,
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
        if (withDivider) _ACDActionDivider(dialog: this),
        _acdButton(
          dialog: this,
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
        flexible: false,
        dialog: this,
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
          dialog: this,
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
        _ACDActionDivider(dialog: this),
        _acdButton(
          dialog: this,
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
        _ACDActionDivider(dialog: this),
        _acdButton(
          dialog: this,
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
/// per-slot inline. Wrapped in [Flexible] so long labels (or large text
/// scaling) wrap instead of overflowing the row.
Widget _acdButton({
  bool flexible = true,
  required ACDDialog dialog,
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
  final Widget button = _ACDDialogButton(
    dialog: dialog,
    onPressed: onPressed,
    text: text,
    color: color,
    fontSize: fontSize,
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
  );
  return flexible ? Flexible(child: button) : button;
}

class _ACDDialogButton extends StatelessWidget {
  const _ACDDialogButton({
    required this.dialog,
    required this.onPressed,
    required this.text,
    required this.color,
    required this.fontSize,
    required this.fontWeight,
    required this.fontFamily,
    required this.textStyle,
    required this.buttonPadding,
    required this.backgroundColor,
    required this.borderRadius,
    required this.elevation,
    required this.boxShadow,
    required this.icon,
    required this.gradient,
  });

  final ACDDialog dialog;
  final VoidCallback onPressed;
  final String text;
  final Color? color;
  final double fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final TextStyle? textStyle;
  final EdgeInsets? buttonPadding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double? elevation;
  final List<BoxShadow>? boxShadow;
  final IconData? icon;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final ACDResolvedDesign design = dialog.resolveDesign(context);
    final ACDDesignTokens? tokens = design.isCupertino
        ? ACDDesignTokens.of(context, design)
        : null;
    final TextStyle mergedTextStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: fontFamily,
      // Material keeps its original black default; iOS actions default to
      // the accent (system blue), like CupertinoDialogAction.
      color: color ?? tokens?.primary ?? Colors.black,
    ).merge(textStyle);

    final Widget label = icon == null
        ? Text(text, style: mergedTextStyle, textAlign: TextAlign.center)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: mergedTextStyle.fontSize,
                color: mergedTextStyle.color,
              ),
              const SizedBox(width: 8),
              Flexible(child: Text(text, style: mergedTextStyle)),
            ],
          );

    // A filled/gradient/shadowed button needs real breathing room around
    // its label or it reads as a cramped sticker rather than a button — but
    // a plain flat text button (the original, pre-styling look) is still
    // meant to sit flush with no padding by default, so only the "filled"
    // look gets a non-zero default.
    final bool filled =
        backgroundColor != null || gradient != null || boxShadow != null;
    final EdgeInsets effectivePadding =
        buttonPadding ??
        (filled
            ? const EdgeInsets.symmetric(horizontal: 22, vertical: 14)
            : (design.isCupertino
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                  : EdgeInsets.zero));

    final Widget button = switch (design) {
      ACDResolvedDesign.material => acdEnsureMaterial(
        context,
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: color ?? Colors.black,
            backgroundColor: gradient == null
                ? backgroundColor
                : Colors.transparent,
            padding: effectivePadding,
            minimumSize: filled ? const Size(64, 44) : null,
            elevation: boxShadow == null ? elevation : null,
            shadowColor: boxShadow == null ? null : Colors.transparent,
            shape: borderRadius == null
                ? null
                : RoundedRectangleBorder(borderRadius: borderRadius!),
          ),
          child: label,
        ),
      ),
      // iOS dialog action: 44pt minimum target, press-dim feedback, no
      // ripple; fill/radius honoured when the caller styles the button.
      ACDResolvedDesign.cupertino => CupertinoButton(
        onPressed: onPressed,
        padding: effectivePadding,
        minimumSize: const Size(44, 44),
        color: gradient == null ? backgroundColor : null,
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(8)),
        child: label,
      ),
    };

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
}

/// Divider between action buttons: Material `VerticalDivider`, or an iOS
/// hairline separator.
class _ACDActionDivider extends StatelessWidget {
  const _ACDActionDivider({required this.dialog});

  final ACDDialog dialog;

  @override
  Widget build(BuildContext context) {
    final ACDResolvedDesign design = dialog.resolveDesign(context);
    if (!design.isCupertino) return const VerticalDivider();
    return Container(
      width: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: ACDDesignTokens.of(context, design).separator,
    );
  }
}

class _ACDActionsBar extends StatelessWidget {
  const _ACDActionsBar({
    required this.dialog,
    required this.actions,
    required this.padding,
  });

  final ACDDialog dialog;
  final List<ACDAction> actions;
  final EdgeInsets? padding;

  void _press(BuildContext context, ACDAction action) {
    action.onPressed?.call();
    if (action.role == ACDActionRole.destructive) {
      ACDHaptics.heavy(context);
    } else {
      ACDHaptics.selection(context);
    }
    if (action.dismissOnPressed) {
      dialog
        ..setResult(action.value)
        ..dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ACDResolvedDesign design = dialog.resolveDesign(context);
    final ACDDesignTokens tokens = ACDDesignTokens.of(context, design);
    return design.isCupertino
        ? _cupertino(context, tokens)
        : _material(context, tokens);
  }

  Widget _material(BuildContext context, ACDDesignTokens tokens) {
    Widget button(ACDAction a) {
      final VoidCallback? onPressed = a.enabled
          ? () => _press(context, a)
          : null;
      final Widget label = Text(a.label);
      return switch (a.role) {
        ACDActionRole.primary => FilledButton(
          onPressed: onPressed,
          child: label,
        ),
        ACDActionRole.destructive => TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(foregroundColor: tokens.error),
          child: label,
        ),
        ACDActionRole.normal ||
        ACDActionRole.cancel => TextButton(onPressed: onPressed, child: label),
      };
    }

    // Material 3: end-aligned; wraps onto a new line instead of
    // overflowing when labels are long or text is scaled up.
    return acdEnsureMaterial(
      context,
      Padding(
        padding: padding ?? const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: OverflowBar(
          alignment: MainAxisAlignment.end,
          spacing: 8,
          overflowAlignment: OverflowBarAlignment.end,
          overflowSpacing: 4,
          children: [for (final ACDAction a in actions) button(a)],
        ),
      ),
    );
  }

  Widget _cupertino(BuildContext context, ACDDesignTokens tokens) {
    final BorderSide hairline = BorderSide(color: tokens.separator, width: 0.5);
    // iOS alert action look (17pt, accent; bold primary; red destructive).
    // Built on CupertinoButton: CupertinoDialogAction only receives taps
    // inside a real CupertinoAlertDialog's action section.
    Widget action(ACDAction a) => CupertinoButton(
      onPressed: a.enabled ? () => _press(context, a) : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      minimumSize: const Size(44, 44),
      borderRadius: BorderRadius.zero,
      child: Text(
        a.label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 17,
          fontWeight: a.role == ACDActionRole.primary
              ? FontWeight.w600
              : FontWeight.w400,
          color: !a.enabled
              ? tokens.disabled
              : (a.role == ACDActionRole.destructive
                    ? tokens.error
                    : tokens.primary),
        ),
      ),
    );

    // iOS: two short actions sit side by side; anything else stacks.
    final bool sideBySide =
        actions.length <= 2 &&
        actions.every((a) => a.label.length <= 14) &&
        MediaQuery.textScalerOf(context).scale(17) <= 22;
    final Widget body = sideBySide
        // Side-by-side actions are single-line and equal height, so the
        // divider is just a start-edge hairline (no IntrinsicHeight pass).
        ? Row(
            children: [
              for (int i = 0; i < actions.length; i++)
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: i == 0
                          ? null
                          : BorderDirectional(start: hairline),
                    ),
                    child: action(actions[i]),
                  ),
                ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < actions.length; i++)
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: i == 0 ? null : Border(top: hairline),
                  ),
                  child: action(actions[i]),
                ),
            ],
          );
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: hairline)),
        child: body,
      ),
    );
  }
}
