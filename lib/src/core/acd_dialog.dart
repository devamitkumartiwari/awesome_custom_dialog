import 'dart:async';
import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/acd_design_scope.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../design/internal/acd_platform_support.dart';
import 'acd_animation.dart';
import 'acd_children.dart';
import 'acd_content_type.dart';
import 'acd_gravity.dart';
import 'acd_overlay_transition.dart';
import 'acd_presenter.dart';
import '../motion/acd_stagger_options.dart';
import '../toast/toast.dart';
import '../toast_snackbar/acd_snackbar_content.dart';

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
  ///
  /// [design] picks Material (default), Cupertino, or adaptive rendering
  /// for the dialog card, its buttons, lists and fields — see [ACDDesign].
  ACDDialog({this.design});

  /// Material (default) / Cupertino / adaptive — see [ACDDesign]. Applies to
  /// the card and to every builder method's content (buttons, lists, text
  /// fields, progress). `null` defers to the nearest [ACDDesignScope].
  ACDDesign? design;

  /// Resolves [design] against [context] (scope, platform).
  ACDResolvedDesign resolveDesign(BuildContext context) =>
      ACDDesign.resolve(context, design);

  // ── Result ────────────────────────────────────────────────────────────────
  Completer<Object?>? _result;
  Object? _pendingResult;

  /// Sets the value [showForResult] completes with when this dialog is
  /// dismissed. `ACDAction`s set it automatically from their `value`; call
  /// it yourself from custom content, then [dismiss].
  void setResult(Object? value) => _pendingResult = value;

  void _completeResult(Object? fallback) {
    final Completer<Object?>? c = _result;
    _result = null;
    final Object? value = _pendingResult ?? fallback;
    _pendingResult = null;
    if (c != null && !c.isCompleted) c.complete(value);
  }

  /// Like [show], but returns a future that completes when the dialog is
  /// dismissed — with the chosen `ACDAction.value` (or the value passed to
  /// [setResult]), or `null` when dismissed any other way (barrier tap,
  /// back button, auto-dismiss).
  ///
  /// ```dart
  /// final bool? delete = await ACDDialog(design: ACDDesign.adaptive)
  ///     .build(context)
  ///     .text(text: 'Delete this photo?')
  ///     .actions(const [
  ///       ACDAction(label: 'Cancel', role: ACDActionRole.cancel),
  ///       ACDAction(label: 'Delete', role: ACDActionRole.destructive,
  ///           value: true),
  ///     ])
  ///     .showForResult<bool>();
  /// ```
  Future<T?> showForResult<T>([double? x, double? y]) {
    _completeResult(null); // settle any previous showing
    final Completer<Object?> completer = Completer<Object?>();
    _result = completer;
    show(x, y);
    if (context == null) _completeResult(null);
    return completer.future.then((Object? v) => v is T ? v : null);
  }

  // ── Widget content ────────────────────────────────────────────────────────
  /// The content widgets added so far via [widget] and the builder methods.
  List<Widget> widgetList = [];

  /// When set, every top-level content widget added so far (`.text()`,
  /// `.oneButton()`, `listOfACDListTile()`, etc. — in whatever order they
  /// were chained) plays a staggered entrance, and a staggered exit right
  /// before the dialog is actually removed from the tree. `null` (the
  /// default) keeps today's unanimated `Column` behavior.
  ACDStaggerOptions? contentStagger;

  // Drives ACDChildren's per-item entrance/exit when contentStagger is set —
  // flipped to false by dismiss() so the exit plays before actual removal.
  final ValueNotifier<bool> _contentVisible = ValueNotifier<bool>(true);

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

  /// Fully custom background decoration, overriding [backgroundColor],
  /// [backgroundGradient], [backgroundImage], [shape], and
  /// [borderRadius]/[cornerRadius]'s fill (though [shape]/[borderRadius]
  /// still determine child-clipping).
  Decoration? decoration;

  /// Background color of the dialog card. Ignored when [backgroundGradient]
  /// or [decoration] is set. `null` (the default) means white for Material
  /// and the iOS translucent alert surface (with background blur) for
  /// Cupertino.
  Color? backgroundColor;

  /// Gradient fill, overriding [backgroundColor]. Ignored when [decoration]
  /// is set.
  Gradient? backgroundGradient;

  /// Background image/texture, layered over [backgroundColor]/
  /// [backgroundGradient]. Ignored when [decoration] is set.
  DecorationImage? backgroundImage;

  /// Uniform corner radius for the dialog card. For per-corner control (e.g.
  /// a side panel that should only round its exposed corners), use
  /// [cornerRadius] instead.
  double borderRadius = 0.0;

  /// Per-corner override — useful for edge-flush dialogs (e.g. a side panel
  /// sitting flush against the left edge only wants its right corners
  /// rounded). Takes precedence over the uniform [borderRadius] above when
  /// set.
  BorderRadius? cornerRadius;

  /// Escape hatch beyond [borderRadius]/[cornerRadius] — a full custom
  /// shape (pill, notched, cut corners, etc.) for the card. When set,
  /// [boxShadow]/[elevation] still apply (drawn behind this shape), but
  /// [decoration] is ignored — mirrors `ACDToastConfig.shape`.
  ShapeBorder? shape;

  /// Drop-shadow elevation for the dialog card. Ignored when [boxShadow] is
  /// set.
  double elevation = 0;

  /// Color of the elevation-driven drop shadow. Falls back to a translucent
  /// black (matching every other widget's default elevation shadow in this
  /// package) when unset. Ignored when [boxShadow] is set.
  Color? shadowColor;

  /// Explicit shadow for the dialog card, overriding [elevation]/
  /// [shadowColor]. Always rendered on the outermost, unclipped layer so
  /// it's never clipped away by the card's own content-clipping.
  List<BoxShadow>? boxShadow;

  // ── Behaviour ─────────────────────────────────────────────────────────────
  /// Whether tapping outside the dialog dismisses it. Ignored in
  /// overlay-mode presentation.
  bool barrierDismissible = true;

  /// Whether to show on the root navigator (`true`) or the nearest one.
  bool useRootNavigator = true;

  /// Accessibility label read out for the barrier behind the dialog.
  String barrierLabel = 'Dialog';

  /// Whether system back (Android back button / predictive back gesture,
  /// Esc) may close the dialog. `false` keeps it open — pair with
  /// [onPopInvoked] to e.g. confirm discarding changes first.
  bool canPop = true;

  /// Called whenever a pop is attempted — `didPop` is `false` when
  /// [canPop] blocked it.
  PopInvokedWithResultCallback<Object?>? onPopInvoked;

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

  TextDirection? _textDirectionOverride;

  /// Text direction for the dialog's content, gravity-based positioning,
  /// margin, and slide animations. Defaults to the ambient `Directionality`
  /// (so RTL apps get correctly-mirrored gravity/margin/animation without
  /// any extra wiring) — set explicitly (e.g. `..textDirection =
  /// TextDirection.rtl`) to override that for this dialog specifically.
  TextDirection get textDirection =>
      _textDirectionOverride ??
      (context != null ? Directionality.maybeOf(context!) : null) ??
      TextDirection.ltr;

  set textDirection(TextDirection value) => _textDirectionOverride = value;

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

  // The modal-path presenter (owns the pushed route), so dismiss() removes
  // this dialog's own route rather than popping whatever is on top.
  ACD? _presenter;

  // Pending autoDismissAfter timer — cancelled on dismiss/re-show so a stale
  // timer from a previous showing can never close a later one.
  Timer? _autoDismissTimer;

  // ── Toast-mode presentation ──────────────────────────────────────────────
  // Used by .toast(): delegates presentation/stacking/lifecycle entirely to
  // ACDToastManager instead of the plain overlay path above, so multiple
  // toasts can stack, animate out, show a progress bar, etc. See
  // lib/src/toast/.
  bool _toastMode = false;
  ACDToastConfig? _toastConfig;
  ACDToastController? _toastController;

  /// For a dialog made with [ACDDialog.toast] / [ACDDialog.snackbar]-style
  /// toasts: completes once the toast is gone, with why it closed. `null`
  /// until [show] has been called (and for non-toast dialogs).
  Future<ACDToastDismissReason>? get toastClosed => _toastController?.closed;

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

  /// Dismisses every currently showing/queued toast. For finer-grained
  /// control (dismiss by id, one position only, oldest/newest only), use
  /// `ACDToastManager` directly.
  static void cancelToast() {
    ACDToastManager.dismissAll();
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

  /// Creates a toast message — call [show] on the result to display it.
  /// Presented via `ACDToastManager` (a non-blocking overlay by default, so
  /// it never intercepts taps on the rest of your app — set [blockTouches]
  /// to restore the old modal-blocking presentation), which also handles
  /// stacking multiple simultaneous toasts, exit animations, a progress
  /// bar, pause-on-hover, and drag-to-dismiss. Every parameter here is
  /// optional and defaults to this factory's original, backward-compatible
  /// behavior — see `ACDToastConfig`/`ACDToastManager` for the full
  /// customization surface (styles, shapes, colors, stacking, callbacks)
  /// and management API (dismiss by id, dismiss all, find by id).
  factory ACDDialog.toast({
    required BuildContext context,
    required String message,
    // Material (default) / Cupertino / adaptive — see ACDDesign.
    ACDDesign? design,
    // Nullable so precedence between showDuration and length is
    // unambiguous — explicit showDuration always wins, length is a
    // convenience shortcut, and omitting both keeps the original 2-second
    // default. Pass Duration.zero for a sticky toast that only dismisses
    // manually/via a close button/tap.
    Duration? showDuration,
    ACDToastLength? length,
    ACDGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    String? fontFamily,
    TextStyle? textStyle,
    double? borderRadius,
    BorderRadius? cornerRadius,
    EdgeInsets? contentPadding,
    EdgeInsets? margin,
    bool? cancelPrevious,
    @Deprecated('Use closeButtonMode instead.') bool showCloseButton = false,
    IconData? closeIcon,
    bool? dismissOnTap,
    // Fixes a pre-existing bug where the transparent barrier still fully
    // hit-tests the screen (showGeneralDialog's ModalBarrier is always
    // opaque to hit-testing, regardless of barrierColor/barrierDismissible).
    // Defaulting to overlay-mode makes the toast never block touches, like
    // a native platform toast. Set true only to restore the old
    // modal-blocking presentation.
    bool blockTouches = false,
    // ── New: type/style ────────────────────────────────────────────────
    String? id,
    ACDContentType? contentType,
    ACDToastStyle? style,
    IconData? icon,
    bool? showIcon,
    bool? animatedIcon,
    // ── New: position/stacking ─────────────────────────────────────────
    int? maxVisible,
    ACDToastOverflowPolicy? overflowPolicy,
    bool? dedupeById,
    double? stackSpacing,
    Duration? showDelay,
    bool? useRootNavigator,
    // ── New: animation ──────────────────────────────────────────────────
    ACDAnimation? animation,
    Function(Widget, Animation<double>)? animatedFunc,
    ACDAnimation? exitAnimation,
    Function(Widget, Animation<double>)? exitAnimatedFunc,
    // ── New: timing/progress ────────────────────────────────────────────
    bool? showProgressBar,
    bool? progressBarAtTop,
    bool? pauseOnHover,
    // ── New: interaction ─────────────────────────────────────────────────
    bool? dragToDismiss,
    ACDToastCloseButtonMode? closeButtonMode,
    bool? blockBackgroundInteraction,
    List<Widget>? actions,
    // ── New: appearance ──────────────────────────────────────────────────
    Gradient? backgroundGradient,
    Color? borderColor,
    double? borderWidth,
    BorderSide? border,
    ShapeBorder? shape,
    List<BoxShadow>? boxShadow,
    Decoration? decoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
    ACDToastCardBuilder? customBuilder,
    // ── New: callbacks ───────────────────────────────────────────────────
    VoidCallback? onTap,
    VoidCallback? onCloseButtonTap,
    VoidCallback? onAutoDismiss,
    VoidCallback? onShown,
  }) {
    final Duration? effectiveDuration = showDuration == Duration.zero
        ? Duration.zero
        : (showDuration ?? length?.duration);

    final ACDToastConfig config = ACDToastConfig(
      message: message,
      id: id,
      gravity: gravity,
      contentType: contentType,
      style: style,
      icon: icon,
      showIcon: showIcon,
      animatedIcon: animatedIcon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      backgroundGradient: backgroundGradient,
      borderColor: borderColor,
      borderWidth: borderWidth,
      border: border,
      shape: shape,
      borderRadius: borderRadius,
      cornerRadius: cornerRadius,
      boxShadow: boxShadow,
      decoration: decoration,
      fontSize: fontSize,
      fontFamily: fontFamily,
      textStyle: textStyle,
      contentPadding: contentPadding,
      margin: margin,
      stackSpacing: stackSpacing,
      width: width,
      height: height,
      constraints: constraints,
      maxVisible: maxVisible,
      overflowPolicy: overflowPolicy,
      dedupeById: dedupeById,
      cancelPrevious: cancelPrevious,
      animation: animation,
      animatedFunc: animatedFunc,
      exitAnimation: exitAnimation,
      exitAnimatedFunc: exitAnimatedFunc,
      autoDismissAfter: effectiveDuration,
      showDelay: showDelay,
      showProgressBar: showProgressBar,
      progressBarAtTop: progressBarAtTop,
      pauseOnHover: pauseOnHover,
      dragToDismiss: dragToDismiss,
      dismissOnTap: dismissOnTap,
      closeButtonMode:
          closeButtonMode ??
          // ignore: deprecated_member_use_from_same_package
          (showCloseButton ? ACDToastCloseButtonMode.always : null),
      closeIcon: closeIcon,
      blockBackgroundInteraction:
          blockBackgroundInteraction ?? (blockTouches ? true : null),
      useRootNavigator: useRootNavigator,
      actions: actions,
      customBuilder: customBuilder,
      onTap: onTap,
      onCloseButtonTap: onCloseButtonTap,
      onAutoDismiss: onAutoDismiss,
      onShown: onShown,
      design: design,
    );

    return ACDDialog(design: design)
      ..build(context)
      .._toastMode = true
      .._toastConfig = config;
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
    // Material (default) / Cupertino / adaptive — see ACDDesign.
    ACDDesign? design,
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
    final dialog = ACDDialog(design: design)
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
        design: design,
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
    _contentVisible.value = true;

    if (_toastMode) {
      // Route the toast's own lifecycle into this dialog's callbacks, so
      // dismissCallBack/showCallBack (and therefore ACDDialogQueue, which
      // advances on dismissCallBack) work for toasts too — previously a
      // queued toast never fired dismissCallBack and stalled the queue.
      final ACDToastConfig config = _toastConfig!;
      _toastController = ACDToastManager.show(
        context!,
        config.copyWith(
          onShown: () {
            config.onShown?.call();
            showCallBack?.call();
          },
          onDismissed: () {
            config.onDismissed?.call();
            _isShowing = false;
            _completeResult(null);
            dismissCallBack?.call();
          },
        ),
      );
      _isShowing = true;
      return;
    }

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
    final Function(Widget, Animation<double>)? effectiveAnimFn = _resolveAnimFn(
      acdReduceMotion(context!),
    );

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

    _presenter = ACD(
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
      barrierLabel: barrierLabel == 'Dialog'
          ? ACDDesignScope.stringsOf(context!).dialogLabel
          : barrierLabel,
      // IMP-08
      onBarrierTap: onBarrierTap, // FEAT-12
      textDirection: textDirection,
      cupertinoTransition: resolveDesign(context!).isCupertino,
      canPop: canPop,
      onPopInvoked: onPopInvoked,
    );

    _scheduleAutoDismiss();
  }

  /// Closes the dialog if it's currently showing. Does nothing otherwise.
  /// When [contentStagger] is set, first plays its staggered exit and waits
  /// for it to finish before actually removing the dialog — existing
  /// callers that don't await the returned `Future` are unaffected (`void`
  /// call sites/`VoidCallback` assignments remain valid).
  Future<void> dismiss() async {
    if (_toastMode) {
      _toastController?.requestDismiss();
      _isShowing = false;
      return;
    }
    // _isShowing only flips true after the first frame (ACDChildren.onShown),
    // so also treat a still-active route/overlay entry as "showing" — a
    // dismiss() issued right after show() must still close the dialog.
    final bool presented =
        (_presenter?.route.isActive ?? false) || _overlayEntry != null;
    if (!_isShowing && !presented) return;
    _isShowing = false;
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;

    final ACDStaggerOptions? options = contentStagger;
    if (options != null && widgetList.isNotEmpty) {
      _contentVisible.value = false;
      await Future<void>.delayed(
        options.startDelay +
            options.interval * (widgetList.length - 1) +
            options.itemDuration,
      );
      if (context == null || !context!.mounted) return;
    }

    if (_overlayEntry != null) {
      // FEAT-15/FEAT-16: overlay-mode teardown
      _overlayEntry!.remove();
      _overlayEntry = null;
    } else {
      _presenter?.close();
      _presenter = null;
    }
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  EdgeInsets _resolveMargin() =>
      acdResolveMarginForGravity(gravity, margin, textDirection);

  // Resolve animation function: explicit > preset enum > none
  // Under reduce motion, built-in presets are dropped (the presenter then
  // fades); an explicit animatedFunc is the caller's choice and is kept.
  Function(Widget, Animation<double>)? _resolveAnimFn(bool reduceMotion) {
    if (animatedFunc == null && reduceMotion) return null;
    return animatedFunc ??
        (animation != ACDAnimation.none
            ? acdPresetAnimFn(animation, textDirection)
            : null);
  }

  // The card is built lazily inside the presented route, so the design (and
  // dark-mode tokens) resolve against the route's own context.
  Widget _buildContentCard() => Builder(builder: _buildContentCardIn);

  Widget _buildContentCardIn(BuildContext context) {
    final ACDResolvedDesign resolved = resolveDesign(context);
    final bool cupertino = resolved.isCupertino;
    // iOS alert surface: translucent + blurred, resolved for brightness.
    final bool blurSurface =
        cupertino &&
        !useTheme &&
        backgroundColor == null &&
        backgroundGradient == null &&
        decoration == null;
    // IMP-10: use theme background when requested
    final Color effectiveBg = useTheme
        ? (Theme.of(context).dialogTheme.backgroundColor ?? Colors.white)
        : backgroundColor ??
              (cupertino
                  ? CupertinoDynamicColor.resolve(
                      const CupertinoDynamicColor.withBrightness(
                        color: Color(0xCCF2F2F2),
                        darkColor: Color(0xBF1E1E1E),
                      ),
                      context,
                    )
                  : Colors.white);
    final BorderRadius effectiveRadius =
        cornerRadius ?? BorderRadius.circular(borderRadius);

    final Widget content = ACDChildren(
      widgetList: widgetList,
      staggerOptions: contentStagger,
      visible: _contentVisible,
      onShown: () {
        _isShowing = true;
        showCallBack?.call();
      },
      onDismissed: () {
        _isShowing = false;
        _completeResult(null);
        dismissCallBack?.call();
      },
    );

    // ShapeDecoration subsumes BoxDecoration's rectangle-only borderRadius,
    // so a custom shape (pill, notched, etc.) can carry the same
    // color/gradient/image fill as the default rounded-rect case — unlike
    // ACDToastConfig.shape, which is limited to a flat color fill.
    // decoration remains a full escape hatch overriding all of the above.
    Widget body = Container(
      width: width,
      height: height,
      decoration:
          decoration ??
          ShapeDecoration(
            shape:
                shape ?? RoundedRectangleBorder(borderRadius: effectiveRadius),
            // ShapeDecoration (unlike BoxDecoration) forbids setting both
            // color and gradient at once — gradient wins when set.
            color: backgroundGradient == null ? effectiveBg : null,
            gradient: backgroundGradient,
            image: backgroundImage,
          ),
      constraints: constraints ?? const BoxConstraints(),
      child: content,
    );
    if (blurSurface) {
      // The clip below bounds the blur to the card's shape.
      body = BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: body,
      );
    }
    // Material: transparent Material (ink + text style), as before.
    // Cupertino: clip + Cupertino text style, no Material ancestor.
    final Widget card = ACDAdaptiveSurface(
      design: resolved,
      clipBehavior: Clip.antiAlias,
      shape: shape,
      borderRadius: shape == null ? effectiveRadius : null,
      child: body,
    );

    // Shadow always on the outermost, unclipped layer — a clip wrapper
    // around the fill/shape (above) must never also clip this away.
    final List<BoxShadow>? effectiveShadow =
        boxShadow ??
        (elevation > 0
            ? [
                BoxShadow(
                  color: shadowColor ?? Colors.black.withValues(alpha: 0.2),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation / 2),
                ),
              ]
            : null);
    if (effectiveShadow == null) return card;
    return Container(
      decoration: BoxDecoration(boxShadow: effectiveShadow),
      child: card,
    );
  }

  void _scheduleAutoDismiss() {
    // FEAT-02: auto-dismiss timer
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    if (autoDismissAfter != null) {
      _autoDismissTimer = Timer(autoDismissAfter!, () {
        _autoDismissTimer = null;
        dismiss();
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
    final Function(Widget, Animation<double>)? effectiveAnimFn = _resolveAnimFn(
      acdReduceMotion(context!),
    );

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
        alignment: acdGravityToAlignment(gravity, textDirection),
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
