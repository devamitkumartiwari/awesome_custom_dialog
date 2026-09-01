import 'package:flutter/material.dart';

import '../core/acd_animation.dart';
import '../core/acd_content_type.dart';
import '../core/acd_gravity.dart';
import 'acd_toast_close_button_mode.dart';
import 'acd_toast_overflow_policy.dart';
import 'acd_toast_style.dart';

/// Fully replaces a toast's card, bypassing every other appearance field on
/// [ACDToastConfig]. Call `dismiss()` to close the toast from inside your
/// widget (e.g. from a custom action button).
typedef ACDToastCardBuilder = Widget Function(
  BuildContext context,
  ACDToastConfig config,
  VoidCallback dismiss,
);

/// Every customizable aspect of a toast, resolved from `ACDDialog.toast()`'s
/// parameters against `ACDToastManager.defaults` (if set) and this class's
/// [fallback] instance (today's literal, backward-compatible defaults).
///
/// Every field is nullable so [resolve] can layer a per-call config over a
/// global-default config over [fallback] — matching `ACDPinTheme`'s
/// shortcuts-plus-`decoration`-escape-hatch, `copyWith`/`resolve` shape
/// (`lib/src/pin_field/acd_pin_theme.dart`). [message] is the one field
/// that's never defaulted from a base config — it's this toast's content.
@immutable
final class ACDToastConfig {
  /// Creates an [ACDToastConfig].
  const ACDToastConfig({
    this.message = '',
    this.id,
    this.gravity,
    this.contentType,
    this.style,
    this.icon,
    this.showIcon,
    this.animatedIcon,
    this.backgroundColor,
    this.textColor,
    this.backgroundGradient,
    this.borderColor,
    this.borderWidth,
    this.border,
    this.shape,
    this.borderRadius,
    this.cornerRadius,
    this.boxShadow,
    this.decoration,
    this.fontSize,
    this.fontFamily,
    this.textStyle,
    this.contentPadding,
    this.margin,
    this.stackSpacing,
    this.width,
    this.height,
    this.constraints,
    this.maxVisible,
    this.overflowPolicy,
    this.dedupeById,
    this.cancelPrevious,
    this.animation,
    this.animatedFunc,
    this.exitAnimation,
    this.exitAnimatedFunc,
    this.duration,
    this.autoDismissAfter,
    this.showDelay,
    this.showProgressBar,
    this.progressBarAtTop,
    this.pauseOnHover,
    this.dragToDismiss,
    this.dismissOnTap,
    this.closeButtonMode,
    this.closeIcon,
    this.blockBackgroundInteraction,
    this.useRootNavigator,
    this.actions,
    this.customBuilder,
    this.onTap,
    this.onCloseButtonTap,
    this.onAutoDismiss,
    this.onShown,
    this.onDismissed,
  });

  // ── Content ──────────────────────────────────────────────────────────────
  /// The toast's message text. Never inherited from a base config.
  final String message;

  /// Identifies this toast for `ACDToastManager.findById`/`dismissById`.
  /// Auto-generated if left `null`.
  final String? id;

  // ── Type / style ─────────────────────────────────────────────────────────
  /// Where this toast docks and stacks. Falls back to `ACDGravity.bottom`.
  final ACDGravity? gravity;

  /// Picks a default color/icon preset (success/failure/warning/help).
  final ACDContentType? contentType;

  /// Which decoration variant to use. Falls back to [ACDToastStyle.filled].
  final ACDToastStyle? style;

  /// Overrides [contentType]'s icon.
  final IconData? icon;

  /// Whether to show an icon at all. Falls back to `true`.
  final bool? showIcon;

  /// Wraps the icon in a subtle repeating scale pulse. Falls back to
  /// `false`.
  final bool? animatedIcon;

  // ── Colors / shape ───────────────────────────────────────────────────────
  /// Base fill/border color (exact resolution depends on [style]). Falls
  /// back to a dark translucent default, or [contentType]'s color when set.
  final Color? backgroundColor;

  /// Message (and icon, when not overridden) color. Falls back to white.
  final Color? textColor;

  /// Gradient fill, overriding [backgroundColor]/[style]'s fill when set.
  final Gradient? backgroundGradient;

  /// Border color shortcut — ignored when [border] is set.
  final Color? borderColor;

  /// Border width shortcut, paired with [borderColor]. Falls back to `1.0`.
  final double? borderWidth;

  /// Full border override, replacing [borderColor]/[borderWidth] and
  /// [style]'s own border.
  final BorderSide? border;

  /// Escape hatch beyond [borderRadius]/[cornerRadius] — a full custom
  /// shape (pill, notched, etc.) for the card. When set, [boxShadow] still
  /// applies (drawn behind this shape), but [decoration] is ignored.
  final ShapeBorder? shape;

  /// Uniform corner radius. Ignored when [cornerRadius] or [shape] is set.
  /// Falls back to `24.0`.
  final double? borderRadius;

  /// Per-corner radius override, taking precedence over [borderRadius].
  /// Ignored when [shape] is set.
  final BorderRadius? cornerRadius;

  /// Drop shadow behind the card. Always rendered on the outermost layer so
  /// it's never clipped away by the card's own content-clipping (a
  /// `Material`/`ClipRRect` wrapper around the fill must never also clip
  /// this).
  final List<BoxShadow>? boxShadow;

  /// Full escape hatch: fully replaces the card's background decoration —
  /// every color/gradient/border/radius field above is ignored once this is
  /// set. Ignored when [shape] is set (shape takes precedence as the more
  /// specific override).
  final Decoration? decoration;

  // ── Text ─────────────────────────────────────────────────────────────────
  /// Message font size shortcut. Falls back to `14.0`.
  final double? fontSize;

  /// Message font family shortcut.
  final String? fontFamily;

  /// Full style control for the message, merged over [textColor]/[fontSize]/
  /// [fontFamily] and the default style.
  final TextStyle? textStyle;

  // ── Spacing ──────────────────────────────────────────────────────────────
  /// Inner padding around the card's content. Falls back to
  /// `EdgeInsets.symmetric(horizontal: 16, vertical: 10)`.
  final EdgeInsets? contentPadding;

  /// Outer inset from the screen edge. Falls back to a gravity-aware
  /// default via `acdResolveMarginForGravity`. Kept semantically distinct
  /// from [contentPadding] (inner spacing) and [stackSpacing] (gap between
  /// stacked toasts) — see the toast feature's design notes for why that
  /// distinction matters.
  final EdgeInsets? margin;

  /// Gap between multiple simultaneously visible toasts at the same
  /// position. Falls back to `8.0`.
  final double? stackSpacing;

  // ── Sizing ───────────────────────────────────────────────────────────────
  /// Fixed card width, or `null` to size to content/margin.
  final double? width;

  /// Fixed card height, or `null` to size to content.
  final double? height;

  /// Additional layout constraints — applies at any screen size, including
  /// tablets/desktop.
  final BoxConstraints? constraints;

  // ── Stacking ─────────────────────────────────────────────────────────────
  /// Maximum toasts visible at once at this toast's [gravity]. `null` means
  /// unlimited.
  final int? maxVisible;

  /// What happens to toasts beyond [maxVisible]. Falls back to
  /// [ACDToastOverflowPolicy.queue].
  final ACDToastOverflowPolicy? overflowPolicy;

  /// If a toast with the same [id] is already active, skip showing this one
  /// instead of stacking a duplicate. Falls back to `false`.
  final bool? dedupeById;

  /// Dismiss whichever toast this manager most recently showed before
  /// showing this one (the original single-toast behavior). Falls back to
  /// `true`.
  final bool? cancelPrevious;

  // ── Animation ────────────────────────────────────────────────────────────
  /// Entrance transition preset. Falls back to `ACDAnimation.slideUp`.
  final ACDAnimation? animation;

  /// Fully custom entrance transition, taking precedence over [animation].
  final Function(Widget, Animation<double>)? animatedFunc;

  /// Exit transition preset. Falls back to mirroring [animation].
  final ACDAnimation? exitAnimation;

  /// Fully custom exit transition, taking precedence over [exitAnimation].
  final Function(Widget, Animation<double>)? exitAnimatedFunc;

  /// How long the entrance/exit transition takes. Falls back to `250ms`.
  final Duration? duration;

  // ── Timing ───────────────────────────────────────────────────────────────
  /// Auto-dismiss after this long. `null` inherits from a base config (see
  /// [resolve]) and ultimately falls back to `2` seconds; pass
  /// `Duration.zero` explicitly to make the toast sticky (stays until
  /// dismissed manually) — `null` can't mean that here since it's reserved
  /// for "inherit," but `Duration.zero` isn't a value any real timer needs.
  final Duration? autoDismissAfter;

  /// Delay before this toast appears at all (it stays [ACDToastQueued]
  /// until then). Falls back to `Duration.zero`.
  final Duration? showDelay;

  /// Shows a countdown progress bar tracking [autoDismissAfter]. Falls back
  /// to `false`.
  final bool? showProgressBar;

  /// Progress bar above the content instead of below. Falls back to
  /// `false`.
  final bool? progressBarAtTop;

  /// Pauses the auto-dismiss timer (and progress bar) while the pointer
  /// hovers the toast — a no-op on touch-only platforms, where no hover
  /// event ever fires. Falls back to `false`.
  final bool? pauseOnHover;

  // ── Interaction ──────────────────────────────────────────────────────────
  /// Lets the user swipe the toast away. Falls back to `false`.
  final bool? dragToDismiss;

  /// Dismisses the toast when tapped anywhere on its body. Falls back to
  /// `false`.
  final bool? dismissOnTap;

  /// Close-button visibility rule. Falls back to
  /// [ACDToastCloseButtonMode.never].
  final ACDToastCloseButtonMode? closeButtonMode;

  /// Icon for the close button. Falls back to `Icons.close_rounded`.
  final IconData? closeIcon;

  /// Whether this toast blocks touches on the rest of the screen, overriding
  /// any global default set via `ACDToastManager.defaults`. `null` defers to
  /// that global default (itself falling back to `false`).
  final bool? blockBackgroundInteraction;

  /// Shows on the root navigator's overlay (`true`) or the nearest one.
  /// Falls back to `true`.
  final bool? useRootNavigator;

  /// An optional trailing row of action widgets (e.g. buttons).
  final List<Widget>? actions;

  /// Fully replaces the toast's card — every other appearance field above
  /// is ignored once this is set.
  final ACDToastCardBuilder? customBuilder;

  // ── Callbacks ────────────────────────────────────────────────────────────
  /// Called when the toast body is tapped.
  final VoidCallback? onTap;

  /// Called when the close button is tapped.
  final VoidCallback? onCloseButtonTap;

  /// Called only when this toast dismisses itself via its auto-dismiss
  /// timer (not on a manual/tap/drag dismiss).
  final VoidCallback? onAutoDismiss;

  /// Called once this toast has finished its entrance transition.
  final VoidCallback? onShown;

  /// Called once this toast has finished disappearing, for any reason.
  final VoidCallback? onDismissed;

  /// Literal, backward-compatible defaults — matches the values
  /// `ACDDialog.toast()` used before this config existed, so a call site
  /// that sets none of the new parameters resolves to exactly the same
  /// output as before.
  static const ACDToastConfig fallback = ACDToastConfig(
    gravity: ACDGravity.bottom,
    style: ACDToastStyle.filled,
    showIcon: true,
    animatedIcon: false,
    backgroundColor: Color(0xDD000000),
    textColor: Colors.white,
    borderWidth: 1.0,
    borderRadius: 24.0,
    fontSize: 14.0,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    margin: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    stackSpacing: 8.0,
    overflowPolicy: ACDToastOverflowPolicy.queue,
    dedupeById: false,
    cancelPrevious: true,
    animation: ACDAnimation.slideUp,
    duration: Duration(milliseconds: 250),
    autoDismissAfter: Duration(seconds: 2),
    showDelay: Duration.zero,
    showProgressBar: false,
    progressBarAtTop: false,
    pauseOnHover: false,
    dragToDismiss: false,
    dismissOnTap: false,
    closeButtonMode: ACDToastCloseButtonMode.never,
    closeIcon: Icons.close_rounded,
    blockBackgroundInteraction: false,
    useRootNavigator: true,
  );

  /// Returns a copy with the given fields replaced.
  ACDToastConfig copyWith({
    String? message,
    String? id,
    ACDGravity? gravity,
    ACDContentType? contentType,
    ACDToastStyle? style,
    IconData? icon,
    bool? showIcon,
    bool? animatedIcon,
    Color? backgroundColor,
    Color? textColor,
    Gradient? backgroundGradient,
    Color? borderColor,
    double? borderWidth,
    BorderSide? border,
    ShapeBorder? shape,
    double? borderRadius,
    BorderRadius? cornerRadius,
    List<BoxShadow>? boxShadow,
    Decoration? decoration,
    double? fontSize,
    String? fontFamily,
    TextStyle? textStyle,
    EdgeInsets? contentPadding,
    EdgeInsets? margin,
    double? stackSpacing,
    double? width,
    double? height,
    BoxConstraints? constraints,
    int? maxVisible,
    ACDToastOverflowPolicy? overflowPolicy,
    bool? dedupeById,
    bool? cancelPrevious,
    ACDAnimation? animation,
    Function(Widget, Animation<double>)? animatedFunc,
    ACDAnimation? exitAnimation,
    Function(Widget, Animation<double>)? exitAnimatedFunc,
    Duration? duration,
    Duration? autoDismissAfter,
    Duration? showDelay,
    bool? showProgressBar,
    bool? progressBarAtTop,
    bool? pauseOnHover,
    bool? dragToDismiss,
    bool? dismissOnTap,
    ACDToastCloseButtonMode? closeButtonMode,
    IconData? closeIcon,
    bool? blockBackgroundInteraction,
    bool? useRootNavigator,
    List<Widget>? actions,
    ACDToastCardBuilder? customBuilder,
    VoidCallback? onTap,
    VoidCallback? onCloseButtonTap,
    VoidCallback? onAutoDismiss,
    VoidCallback? onShown,
    VoidCallback? onDismissed,
  }) {
    return ACDToastConfig(
      message: message ?? this.message,
      id: id ?? this.id,
      gravity: gravity ?? this.gravity,
      contentType: contentType ?? this.contentType,
      style: style ?? this.style,
      icon: icon ?? this.icon,
      showIcon: showIcon ?? this.showIcon,
      animatedIcon: animatedIcon ?? this.animatedIcon,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      border: border ?? this.border,
      shape: shape ?? this.shape,
      borderRadius: borderRadius ?? this.borderRadius,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      decoration: decoration ?? this.decoration,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      textStyle: textStyle ?? this.textStyle,
      contentPadding: contentPadding ?? this.contentPadding,
      margin: margin ?? this.margin,
      stackSpacing: stackSpacing ?? this.stackSpacing,
      width: width ?? this.width,
      height: height ?? this.height,
      constraints: constraints ?? this.constraints,
      maxVisible: maxVisible ?? this.maxVisible,
      overflowPolicy: overflowPolicy ?? this.overflowPolicy,
      dedupeById: dedupeById ?? this.dedupeById,
      cancelPrevious: cancelPrevious ?? this.cancelPrevious,
      animation: animation ?? this.animation,
      animatedFunc: animatedFunc ?? this.animatedFunc,
      exitAnimation: exitAnimation ?? this.exitAnimation,
      exitAnimatedFunc: exitAnimatedFunc ?? this.exitAnimatedFunc,
      duration: duration ?? this.duration,
      autoDismissAfter: autoDismissAfter ?? this.autoDismissAfter,
      showDelay: showDelay ?? this.showDelay,
      showProgressBar: showProgressBar ?? this.showProgressBar,
      progressBarAtTop: progressBarAtTop ?? this.progressBarAtTop,
      pauseOnHover: pauseOnHover ?? this.pauseOnHover,
      dragToDismiss: dragToDismiss ?? this.dragToDismiss,
      dismissOnTap: dismissOnTap ?? this.dismissOnTap,
      closeButtonMode: closeButtonMode ?? this.closeButtonMode,
      closeIcon: closeIcon ?? this.closeIcon,
      blockBackgroundInteraction:
          blockBackgroundInteraction ?? this.blockBackgroundInteraction,
      useRootNavigator: useRootNavigator ?? this.useRootNavigator,
      actions: actions ?? this.actions,
      customBuilder: customBuilder ?? this.customBuilder,
      onTap: onTap ?? this.onTap,
      onCloseButtonTap: onCloseButtonTap ?? this.onCloseButtonTap,
      onAutoDismiss: onAutoDismiss ?? this.onAutoDismiss,
      onShown: onShown ?? this.onShown,
      onDismissed: onDismissed ?? this.onDismissed,
    );
  }

  /// Merges [overlay]'s non-null fields on top of `base`'s — used to layer
  /// a per-call config over a global-default config over [fallback]. Each
  /// field is resolved independently, so an overlay that only sets
  /// [backgroundColor] still inherits `base`'s [borderRadius]/[style]/etc.
  /// [message] always comes from [overlay] — it's never defaulted.
  static ACDToastConfig resolve(ACDToastConfig base, ACDToastConfig? overlay) {
    if (overlay == null) return base;
    return ACDToastConfig(
      message: overlay.message,
      id: overlay.id ?? base.id,
      gravity: overlay.gravity ?? base.gravity,
      contentType: overlay.contentType ?? base.contentType,
      style: overlay.style ?? base.style,
      icon: overlay.icon ?? base.icon,
      showIcon: overlay.showIcon ?? base.showIcon,
      animatedIcon: overlay.animatedIcon ?? base.animatedIcon,
      backgroundColor: overlay.backgroundColor ?? base.backgroundColor,
      textColor: overlay.textColor ?? base.textColor,
      backgroundGradient: overlay.backgroundGradient ?? base.backgroundGradient,
      borderColor: overlay.borderColor ?? base.borderColor,
      borderWidth: overlay.borderWidth ?? base.borderWidth,
      border: overlay.border ?? base.border,
      shape: overlay.shape ?? base.shape,
      borderRadius: overlay.borderRadius ?? base.borderRadius,
      cornerRadius: overlay.cornerRadius ?? base.cornerRadius,
      boxShadow: overlay.boxShadow ?? base.boxShadow,
      decoration: overlay.decoration ?? base.decoration,
      fontSize: overlay.fontSize ?? base.fontSize,
      fontFamily: overlay.fontFamily ?? base.fontFamily,
      textStyle: base.textStyle?.merge(overlay.textStyle) ?? overlay.textStyle,
      contentPadding: overlay.contentPadding ?? base.contentPadding,
      margin: overlay.margin ?? base.margin,
      stackSpacing: overlay.stackSpacing ?? base.stackSpacing,
      width: overlay.width ?? base.width,
      height: overlay.height ?? base.height,
      constraints: overlay.constraints ?? base.constraints,
      maxVisible: overlay.maxVisible ?? base.maxVisible,
      overflowPolicy: overlay.overflowPolicy ?? base.overflowPolicy,
      dedupeById: overlay.dedupeById ?? base.dedupeById,
      cancelPrevious: overlay.cancelPrevious ?? base.cancelPrevious,
      animation: overlay.animation ?? base.animation,
      animatedFunc: overlay.animatedFunc ?? base.animatedFunc,
      exitAnimation: overlay.exitAnimation ?? base.exitAnimation,
      exitAnimatedFunc: overlay.exitAnimatedFunc ?? base.exitAnimatedFunc,
      duration: overlay.duration ?? base.duration,
      autoDismissAfter: overlay.autoDismissAfter ?? base.autoDismissAfter,
      showDelay: overlay.showDelay ?? base.showDelay,
      showProgressBar: overlay.showProgressBar ?? base.showProgressBar,
      progressBarAtTop: overlay.progressBarAtTop ?? base.progressBarAtTop,
      pauseOnHover: overlay.pauseOnHover ?? base.pauseOnHover,
      dragToDismiss: overlay.dragToDismiss ?? base.dragToDismiss,
      dismissOnTap: overlay.dismissOnTap ?? base.dismissOnTap,
      closeButtonMode: overlay.closeButtonMode ?? base.closeButtonMode,
      closeIcon: overlay.closeIcon ?? base.closeIcon,
      blockBackgroundInteraction:
          overlay.blockBackgroundInteraction ?? base.blockBackgroundInteraction,
      useRootNavigator: overlay.useRootNavigator ?? base.useRootNavigator,
      actions: overlay.actions ?? base.actions,
      customBuilder: overlay.customBuilder ?? base.customBuilder,
      onTap: overlay.onTap ?? base.onTap,
      onCloseButtonTap: overlay.onCloseButtonTap ?? base.onCloseButtonTap,
      onAutoDismiss: overlay.onAutoDismiss ?? base.onAutoDismiss,
      onShown: overlay.onShown ?? base.onShown,
      onDismissed: overlay.onDismissed ?? base.onDismissed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ACDToastConfig &&
          message == other.message &&
          id == other.id &&
          gravity == other.gravity &&
          contentType == other.contentType &&
          style == other.style &&
          icon == other.icon &&
          showIcon == other.showIcon &&
          animatedIcon == other.animatedIcon &&
          backgroundColor == other.backgroundColor &&
          textColor == other.textColor &&
          backgroundGradient == other.backgroundGradient &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth &&
          border == other.border &&
          shape == other.shape &&
          borderRadius == other.borderRadius &&
          cornerRadius == other.cornerRadius &&
          boxShadow == other.boxShadow &&
          decoration == other.decoration &&
          fontSize == other.fontSize &&
          fontFamily == other.fontFamily &&
          textStyle == other.textStyle &&
          contentPadding == other.contentPadding &&
          margin == other.margin &&
          stackSpacing == other.stackSpacing &&
          width == other.width &&
          height == other.height &&
          constraints == other.constraints &&
          maxVisible == other.maxVisible &&
          overflowPolicy == other.overflowPolicy &&
          dedupeById == other.dedupeById &&
          cancelPrevious == other.cancelPrevious &&
          animation == other.animation &&
          animatedFunc == other.animatedFunc &&
          exitAnimation == other.exitAnimation &&
          exitAnimatedFunc == other.exitAnimatedFunc &&
          duration == other.duration &&
          autoDismissAfter == other.autoDismissAfter &&
          showDelay == other.showDelay &&
          showProgressBar == other.showProgressBar &&
          progressBarAtTop == other.progressBarAtTop &&
          pauseOnHover == other.pauseOnHover &&
          dragToDismiss == other.dragToDismiss &&
          dismissOnTap == other.dismissOnTap &&
          closeButtonMode == other.closeButtonMode &&
          closeIcon == other.closeIcon &&
          blockBackgroundInteraction == other.blockBackgroundInteraction &&
          useRootNavigator == other.useRootNavigator &&
          actions == other.actions &&
          customBuilder == other.customBuilder &&
          onTap == other.onTap &&
          onCloseButtonTap == other.onCloseButtonTap &&
          onAutoDismiss == other.onAutoDismiss &&
          onShown == other.onShown &&
          onDismissed == other.onDismissed);

  @override
  int get hashCode => Object.hash(
    Object.hash(message, id, gravity, contentType, style, icon),
    Object.hash(
      showIcon,
      animatedIcon,
      backgroundColor,
      textColor,
      backgroundGradient,
    ),
    Object.hash(
      borderColor,
      borderWidth,
      border,
      shape,
      borderRadius,
      cornerRadius,
    ),
    Object.hash(boxShadow, decoration, fontSize, fontFamily, textStyle),
    Object.hash(
      contentPadding,
      margin,
      stackSpacing,
      width,
      height,
      constraints,
    ),
    Object.hash(maxVisible, overflowPolicy, dedupeById, cancelPrevious),
    Object.hash(
      animation,
      animatedFunc,
      exitAnimation,
      exitAnimatedFunc,
      duration,
    ),
    Object.hash(
      autoDismissAfter,
      showDelay,
      showProgressBar,
      progressBarAtTop,
      pauseOnHover,
    ),
    Object.hash(dragToDismiss, dismissOnTap, closeButtonMode, closeIcon),
    Object.hash(
      blockBackgroundInteraction,
      useRootNavigator,
      actions,
      customBuilder,
    ),
    Object.hash(onTap, onCloseButtonTap, onAutoDismiss, onShown, onDismissed),
  );
}
