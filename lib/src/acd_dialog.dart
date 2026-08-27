import 'dart:async';

import 'package:flutter/material.dart';

import 'acd_animation.dart';
import 'acd_children.dart';
import 'acd_content_type.dart';
import 'acd_gravity.dart';
import 'acd_overlay_transition.dart';
import 'acd_presenter.dart';
import 'acd_snackbar_content.dart';
import 'acd_toast_length.dart';

/// A fluent, chainable builder for dialogs, toasts, and snackbars.
///
/// Typical usage:
/// ```dart
/// ACDDialog().build(context)
///   ..success(title: "Done!", message: "Saved successfully.")
///   ..show();
/// ```
/// Configure appearance/behaviour via the public fields below, add content
/// with the builder methods (`text()`, `oneButton()`, `listOfACDListTile()`,
/// the `success()`/`error()`/`warning()`/`info()` presets, etc. — most are
/// defined as extensions in sibling files), then call [show]. Use
/// [ACDDialog.toast] or [ACDDialog.snackbar] for the ready-made factories.
class ACDDialog {
  /// Creates an empty dialog. Chain [build] and content-adding methods, then
  /// call [show]. Explicit unnamed constructor required because a factory
  /// constructor is also declared below ([ACDDialog.toast]).
  ACDDialog();

  // ── Widget content ────────────────────────────────────────────────────────
  /// The content widgets added so far via [widget] and the builder methods.
  List<Widget> widgetList = [];

  // ── Context ───────────────────────────────────────────────────────────────
  static BuildContext? _context;

  /// The `BuildContext` this dialog will show in. Set via [build] or
  /// [ACDDialog.init].
  BuildContext? context;

  // ── Sizing ────────────────────────────────────────────────────────────────
  /// Fixed width for the dialog card, or `null` to size to content.
  double? width;

  /// Fixed height for the dialog card, or `null` to size to content.
  double? height;

  /// Additional layout constraints for the dialog card.
  BoxConstraints? constraints;

  // ── Animation ─────────────────────────────────────────────────────────────
  /// How long the show/dismiss transition takes.
  Duration duration = const Duration(milliseconds: 250);

  /// When `true`, slides the dialog in from the direction implied by
  /// [gravity] (used automatically by `.toast()`/`.snackbar()`).
  bool gravityAnimationEnable = false;

  /// A fully custom transition builder. Takes precedence over [animation]
  /// and [gravityAnimationEnable] when set.
  Function(Widget child, Animation<double> animation)? animatedFunc;

  /// Which built-in transition to use. Ignored if [animatedFunc] is set.
  ACDAnimation animation = ACDAnimation.none;

  // ── Positioning ───────────────────────────────────────────────────────────
  /// Where the dialog appears on screen.
  ACDGravity gravity = ACDGravity.center;

  /// Space between the dialog and the screen edges. Leave as
  /// `EdgeInsets.zero` to use a sensible default based on [gravity].
  EdgeInsets margin = EdgeInsets.zero;

  // ── Appearance ────────────────────────────────────────────────────────────
  /// Color of the scrim behind the dialog. Ignored in overlay-mode
  /// presentation (`.toast()`/`.snackbar()`).
  Color barrierColor = const Color.fromRGBO(0, 0, 0, 0.3);

  /// Fully custom background decoration, overriding [backgroundColor] and
  /// [borderRadius]/[cornerRadius].
  Decoration? decoration;

  /// Background color of the dialog card.
  Color backgroundColor = Colors.white;

  /// Uniform corner radius for the dialog card. For per-corner control (e.g.
  /// a side panel that should only round its exposed corners), use
  /// [cornerRadius] instead.
  double borderRadius = 0.0;

  /// Per-corner override — useful for edge-flush dialogs (e.g. a side panel
  /// sitting flush against the left edge only wants its right corners
  /// rounded). Takes precedence over the uniform [borderRadius] above when
  /// set.
  BorderRadius? cornerRadius;

  // ── Behaviour ─────────────────────────────────────────────────────────────
  /// Whether tapping outside the dialog dismisses it. Ignored in
  /// overlay-mode presentation.
  bool barrierDismissible = true;

  /// Whether to show on the root navigator (`true`) or the nearest one.
  bool useRootNavigator = true;

  /// Accessibility label read out for the barrier behind the dialog.
  String barrierLabel = 'Dialog';

  // ── New properties ────────────────────────────────────────────────────────
  /// If set, the dialog dismisses itself automatically after this duration.
  Duration? autoDismissAfter;

  /// Wraps the dialog in a `SafeArea` to avoid notches/system bars. Defaults
  /// to `true` automatically for top/bottom [gravity].
  bool respectSafeArea = false;

  /// Called when the user taps outside the dialog. When set, this replaces
  /// the default dismiss-on-barrier-tap behavior — call [dismiss] yourself
  /// if you still want it to close.
  VoidCallback? onBarrierTap;

  /// When `true`, uses `Theme.of(context).dialogTheme`'s background color
  /// instead of [backgroundColor].
  bool useTheme = false;

  /// Text direction for the dialog's content column — set to
  /// `TextDirection.rtl` for right-to-left layouts.
  TextDirection textDirection = TextDirection.ltr;

  // ── Callbacks ─────────────────────────────────────────────────────────────
  /// Called once the dialog has finished appearing.
  VoidCallback? showCallBack;

  /// Called once the dialog has finished disappearing (whether dismissed
  /// programmatically or via the barrier).
  VoidCallback? dismissCallBack;

  bool _isShowing = false;

  /// Whether the dialog is currently visible.
  bool get isShowing => _isShowing;

  // ── Overlay-mode presentation (FEAT-15/FEAT-16) ─────────────────────────────
  // Used by .toast() (by default) and .snackbar(): presents via a plain
  // Overlay entry instead of showGeneralDialog, so the rest of the screen
  // stays tappable (showGeneralDialog's ModalBarrier is always fully
  // hit-tested, regardless of barrierColor/barrierDismissible). barrierColor,
  // barrierDismissible and onBarrierTap are inert while this is true — there
  // is no barrier in overlay mode.
  bool _overlayMode = false;
  OverlayEntry? _overlayEntry;

  // ── Static helpers ────────────────────────────────────────────────────────

  /// Stores a default `BuildContext` so later `ACDDialog().build()` calls
  /// (without an explicit context) and the [ACDDialog.toast]/
  /// [ACDDialog.snackbar] factories can use it automatically. Call once
  /// near the top of your widget tree, e.g. in your home screen's `build()`.
  static void init(BuildContext ctx) {
    _context = ctx;
  }

  /// Clears the context stored by [init], to avoid holding a reference to a
  /// disposed widget.
  static void clearContext() {
    _context = null;
  }

  static ACDDialog? _activeToast;

  /// Dismisses the currently showing toast (if any) — equivalent to
  /// `Fluttertoast.cancel()`.
  static void cancelToast() {
    _activeToast?.dismiss();
    _activeToast = null;
  }

  // ── Builder API ───────────────────────────────────────────────────────────

  /// Sets the context this dialog will show in, defaulting to the one
  /// stored by [ACDDialog.init] if [ctx] is omitted. Returns this dialog for
  /// chaining.
  ACDDialog build([BuildContext? ctx]) {
    context = ctx ?? _context;
    return this;
  }

  /// Appends an arbitrary widget to the dialog's content. Returns this
  /// dialog for chaining. Most content is added via the more specific
  /// builder methods (`text()`, `oneButton()`, etc.) instead.
  ACDDialog widget(Widget child) {
    widgetList.add(child);
    return this;
  }

  /// Creates a small, auto-dismissing toast message — call [show] on the
  /// result to display it. Presented via a non-blocking overlay by default,
  /// so it never intercepts taps on the rest of your app (set [blockTouches]
  /// to restore the old modal-blocking presentation).
  factory ACDDialog.toast({
    required BuildContext context,
    required String message,
    // FEAT-15: nullable so precedence between showDuration and length is
    // unambiguous — explicit showDuration always wins, length is the
    // Fluttertoast-style convenience, and omitting both keeps the original
    // 2-second default.
    Duration? showDuration,
    ACDToastLength? length, // FEAT-15: Toast.LENGTH_SHORT/LENGTH_LONG parity
    ACDGravity gravity = ACDGravity.bottom,
    Color backgroundColor = const Color(0xDD000000),
    Color textColor = Colors.white,
    double fontSize = 14.0,
    String? fontFamily, // FEAT-15: fontAsset parity
    TextStyle? textStyle,
    double borderRadius = 24.0,
    EdgeInsets contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
    EdgeInsets margin = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 32,
    ),
    bool cancelPrevious = true, // FEAT-15: Fluttertoast.cancel()-first parity
    bool showCloseButton = false, // FEAT-15: webShowClose parity
    IconData closeIcon = Icons.close_rounded,
    bool dismissOnTap = false, // FEAT-15: FToast(isDismissible:) parity
    // FEAT-15: fixes a pre-existing bug where the transparent barrier still
    // fully hit-tests the screen (showGeneralDialog's ModalBarrier is always
    // opaque to hit-testing, regardless of barrierColor/barrierDismissible).
    // Defaulting to overlay-mode makes the toast never block touches,
    // matching real Android Toast / FToast(ignorePointer: true) behavior.
    // Set true only to restore the old modal-blocking presentation.
    bool blockTouches = false,
  }) {
    if (cancelPrevious) cancelToast();

    final Duration effectiveDuration =
        showDuration ?? length?.duration ?? const Duration(seconds: 2);

    final dialog = ACDDialog()
      ..build(context)
      .._overlayMode = !blockTouches
      ..barrierColor = Colors.transparent
      ..barrierDismissible = false
      ..gravity = gravity
      ..gravityAnimationEnable = true
      ..backgroundColor = backgroundColor
      ..borderRadius = borderRadius
      ..autoDismissAfter = effectiveDuration
      ..margin = margin;

    final Widget messageWidget = Text(
      message,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontFamily: fontFamily,
      ).merge(textStyle),
      textAlign: TextAlign.center,
    );

    Widget content = showCloseButton
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: messageWidget),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: dialog.dismiss,
                child: Icon(closeIcon, color: textColor, size: 16),
              ),
            ],
          )
        : messageWidget;

    if (dismissOnTap) {
      content = GestureDetector(onTap: dialog.dismiss, child: content);
    }

    dialog.widget(Padding(padding: contentPadding, child: content));

    // FEAT-15: track + chain dismissCallBack so cancelToast()/a subsequent
    // .toast() call can find and dismiss this one (same capture pattern
    // ACDDialogQueue._next() uses).
    _activeToast = dialog;
    final VoidCallback? userDismiss = dialog.dismissCallBack;
    dialog.dismissCallBack = () {
      userDismiss?.call();
      if (identical(_activeToast, dialog)) _activeToast = null;
    };

    return dialog;
  }

  /// Creates a colorful success/failure/warning/help snackbar banner — call
  /// [show] on the result to display it, for apps that don't want to manage
  /// `ScaffoldMessenger` themselves. Presented via the same non-blocking
  /// overlay as [ACDDialog.toast]. The underlying `ACDSnackbarContent`
  /// widget remains independently usable inside a real
  /// `SnackBar`/`ScaffoldMessenger`/`MaterialBanner` too.
  factory ACDDialog.snackbar({
    required BuildContext context,
    required String title,
    required String message,
    ACDContentType contentType = ACDContentType.success,
    Color? color,
    Gradient? gradient,
    IconData? icon,
    TextStyle? titleTextStyle,
    double? titleFontSize,
    FontWeight? titleFontWeight,
    String? titleFontFamily,
    TextStyle? messageTextStyle,
    double? messageFontSize,
    FontWeight? messageFontWeight,
    String? messageFontFamily,
    double borderRadius = 20.0,
    EdgeInsets? padding,
    bool inMaterialBanner = false,
    Duration autoDismissAfter = const Duration(seconds: 3),
    EdgeInsets margin = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
    VoidCallback? onClose,
    double elevation = 0,
    List<BoxShadow>? boxShadow,
  }) {
    final dialog = ACDDialog()
      ..build(context)
      .._overlayMode = true
      ..gravity = ACDGravity.bottom
      ..gravityAnimationEnable = true
      ..animation = ACDAnimation.slideUp
      ..backgroundColor = Colors.transparent
      ..borderRadius = 0
      ..width = double.infinity
      ..margin = margin
      ..autoDismissAfter = autoDismissAfter;

    dialog.widget(
      ACDSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
        color: color,
        gradient: gradient,
        icon: icon,
        titleTextStyle: titleTextStyle,
        titleFontSize: titleFontSize,
        titleFontWeight: titleFontWeight,
        titleFontFamily: titleFontFamily,
        messageTextStyle: messageTextStyle,
        messageFontSize: messageFontSize,
        messageFontWeight: messageFontWeight,
        messageFontFamily: messageFontFamily,
        borderRadius: borderRadius,
        padding: padding,
        inMaterialBanner: inMaterialBanner,
        elevation: elevation,
        boxShadow: boxShadow,
        // FEAT-16: default close action dismisses this overlay dialog, not a
        // ScaffoldMessenger — there isn't one involved in this code path.
        onClose: onClose ?? dialog.dismiss,
      ),
    );

    return dialog;
  }

  // ── Show / Dismiss ────────────────────────────────────────────────────────

  /// Displays the dialog. Requires [context] to be set (via [build] or
  /// [ACDDialog.init]) — does nothing otherwise. Pass [x]/[y] to position the
  /// dialog at exact screen coordinates instead of using [gravity].
  void show([double? x, double? y]) {
    if (context == null) return;

    // FEAT-15/FEAT-16: overlay-mode presentation (never blocks touches)
    if (_overlayMode) {
      _showViaOverlay();
      return;
    }

    if (x != null && y != null) {
      gravity = ACDGravity.leftTop;
      margin = EdgeInsets.only(left: x, top: y);
    }

    final EdgeInsets effectiveMargin = _resolveMargin();
    final Function(Widget, Animation<double>)? effectiveAnimFn =
        _resolveAnimFn();

    Widget dialogContent = Padding(
      padding: effectiveMargin,
      child: Column(
        textDirection: textDirection,
        mainAxisAlignment: acdColumnMainAxisAlignment(gravity),
        crossAxisAlignment: acdColumnCrossAxisAlignment(gravity),
        children: [_buildContentCard()],
      ),
    );

    // Default respectSafeArea to true for top/bottom if not explicitly set
    bool effectiveRespectSafeArea = respectSafeArea;
    if (gravity == ACDGravity.top || gravity == ACDGravity.bottom) {
      effectiveRespectSafeArea = true;
    }

    if (effectiveRespectSafeArea) {
      dialogContent = SafeArea(child: dialogContent);
    }

    ACD(
      child: dialogContent,
      context: context!,
      gravity: gravity,
      gravityAnimationEnable: gravityAnimationEnable,
      barrierColor: barrierColor,
      animatedFunc: effectiveAnimFn,
      barrierDismissible: barrierDismissible,
      duration: duration,
      useRootNavigator: useRootNavigator,
      // BUG-03 fix
      barrierLabel: barrierLabel,
      // IMP-08
      onBarrierTap: onBarrierTap, // FEAT-12
    );

    _scheduleAutoDismiss();
  }

  /// Closes the dialog if it's currently showing. Does nothing otherwise.
  void dismiss() {
    if (_isShowing) {
      if (_overlayEntry != null) {
        // FEAT-15/FEAT-16: overlay-mode teardown
        _overlayEntry!.remove();
        _overlayEntry = null;
      } else {
        Navigator.of(context!, rootNavigator: useRootNavigator).pop();
      }
      _isShowing = false;
    }
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  EdgeInsets _resolveMargin() => acdResolveMarginForGravity(gravity, margin);

  // Resolve animation function: explicit > preset enum > none
  Function(Widget, Animation<double>)? _resolveAnimFn() {
    return animatedFunc ??
        (animation != ACDAnimation.none ? acdPresetAnimFn(animation) : null);
  }

  Widget _buildContentCard() {
    // IMP-10: use theme background when requested
    final Color effectiveBg = useTheme
        ? (Theme.of(context!).dialogTheme.backgroundColor ?? Colors.white)
        : backgroundColor;
    final BorderRadius effectiveRadius =
        cornerRadius ?? BorderRadius.circular(borderRadius);

    return Material(
      clipBehavior: Clip.antiAlias,
      type: MaterialType.transparency,
      borderRadius: effectiveRadius,
      child: Container(
        width: width,
        height: height,
        decoration:
            decoration ??
            BoxDecoration(borderRadius: effectiveRadius, color: effectiveBg),
        constraints: constraints ?? const BoxConstraints(),
        child: ACDChildren(
          widgetList: widgetList,
          onShown: () {
            _isShowing = true;
            showCallBack?.call();
          },
          onDismissed: () {
            _isShowing = false;
            dismissCallBack?.call();
          },
        ),
      ),
    );
  }

  void _scheduleAutoDismiss() {
    // FEAT-02: auto-dismiss timer
    if (autoDismissAfter != null) {
      Timer(autoDismissAfter!, () {
        if (_isShowing) dismiss();
      });
    }
  }

  // FEAT-15/FEAT-16: presents via a plain Overlay entry (Align + Padding, no
  // full-screen hit-testable widget) instead of showGeneralDialog, so taps
  // outside the card fall through to the app underneath. See _overlayMode.
  void _showViaOverlay() {
    final OverlayState overlayState = Overlay.of(
      context!,
      rootOverlay: useRootNavigator,
    );
    final EdgeInsets effectiveMargin = _resolveMargin();
    final Function(Widget, Animation<double>)? effectiveAnimFn =
        _resolveAnimFn();

    final bool topSafe =
        gravity == ACDGravity.top ||
        gravity == ACDGravity.leftTop ||
        gravity == ACDGravity.rightTop;
    final bool bottomSafe =
        gravity == ACDGravity.bottom ||
        gravity == ACDGravity.leftBottom ||
        gravity == ACDGravity.rightBottom;

    final OverlayEntry entry = OverlayEntry(
      builder: (_) => Align(
        alignment: acdGravityToAlignment(gravity),
        child: Padding(
          padding: effectiveMargin,
          child: SafeArea(
            top: topSafe,
            bottom: bottomSafe,
            left: false,
            right: false,
            child: ACDOverlayTransition(
              duration: duration,
              animatedFunc: effectiveAnimFn,
              child: _buildContentCard(),
            ),
          ),
        ),
      ),
    );

    _overlayEntry = entry;
    overlayState.insert(entry);

    _scheduleAutoDismiss();
  }
}
