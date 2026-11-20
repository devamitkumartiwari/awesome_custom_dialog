import 'dart:math' as math;
import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/acd_design_scope.dart';
import '../design/acd_design_tokens.dart';
import '../design/internal/acd_platform_support.dart';
import 'acd_pin_animation_type.dart';
import 'acd_pin_error_animation.dart';
import 'acd_pin_field_state.dart';
import 'acd_pin_theme.dart';
import 'acd_pin_theme_resolve.dart';

/// Builds the separator shown after cell [index] (`0`-based), or `null` for
/// none.
typedef ACDPinSeparatorBuilder = Widget? Function(int index);

/// Fully replaces a filled cell's content (in place of the digit/obscure
/// glyph) at [index].
typedef ACDPinObscureBuilder = Widget Function(BuildContext context, int index);

/// Fully replaces cell [index]'s rendering, bypassing [ACDPinField.pinTheme]
/// entirely. [char] is that cell's current character, or `''` when empty.
typedef ACDPinCellBuilder = Widget Function(
  BuildContext context,
  int index,
  ACDPinCellState state,
  String char,
);

/// Builds the error widget shown below the field.
typedef ACDPinErrorBuilder = Widget Function(String? errorText, String pin);

/// The vibration played on [ACDPinField.hapticFeedbackType] when the user
/// types.
enum ACDHapticFeedbackType {
  /// No vibration.
  disabled,

  /// [HapticFeedback.lightImpact].
  lightImpact,

  /// [HapticFeedback.mediumImpact].
  mediumImpact,

  /// [HapticFeedback.heavyImpact].
  heavyImpact,

  /// [HapticFeedback.selectionClick].
  selectionClick,

  /// [HapticFeedback.vibrate].
  vibrate,
}

/// A PIN/OTP input field — [length] boxes filled from one real (invisible)
/// [TextField], so every bit of text editing, selection, IME, and autofill
/// behavior is Flutter's own, well-tested code; the boxes are a pure
/// presentation layer painted from that field's live text and selection.
///
/// ```dart
/// ACDPinField(
///   length: 6,
///   onCompleted: (pin) => debugPrint('Entered $pin'),
///   validator: (pin) => pin != null && pin.length == 6 ? null : 'Enter all 6 digits',
/// )
/// ```
///
/// Wraps a [FormField], so it drops straight into a [Form] with `validator`/
/// `onSaved`/`autovalidateMode` like any other field.
class ACDPinField extends FormField<String> {
  /// Creates an [ACDPinField].
  ACDPinField({
    super.key,
    required int length,
    TextEditingController? controller,
    FocusNode? focusNode,
    super.initialValue,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onCompleted,
    ValueChanged<String>? onSubmitted,
    super.validator,
    super.onSaved,
    super.enabled = true,
    AutovalidateMode? autovalidateMode,
    super.forceErrorText,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
    ACDPinTheme pinTheme = const ACDPinTheme(width: 48.0, height: 52.0),
    ACDPinTheme? focusedPinTheme,
    ACDPinTheme? submittedPinTheme,
    ACDPinTheme? followingPinTheme,
    ACDPinTheme? errorPinTheme,
    ACDPinTheme? disabledPinTheme,
    double disabledOpacity = 0.5,
    Widget? preFilledWidget,
    ACDPinCellBuilder? cellBuilder,
    ACDPinSeparatorBuilder? separatorBuilder,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    AlignmentGeometry pinContentAlignment = Alignment.center,
    ACDPinAnimationType pinAnimationType = ACDPinAnimationType.scale,
    Offset? slideTransitionBeginOffset,
    Duration animationDuration = const Duration(milliseconds: 150),
    Curve animationCurve = Curves.easeOut,
    bool obscureText = false,
    String obscureCharacter = '•',
    ACDPinObscureBuilder? obscuringWidgetBuilder,
    Duration? obscureRevealDuration,
    Widget? cursor,
    Color? cursorColor,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    bool showCursor = true,
    bool enableCursorAnimation = true,
    TextInputType keyboardType = TextInputType.number,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    bool autofocus = false,
    bool readOnly = false,
    bool enableInteractiveSelection = true,
    bool enableSuggestions = true,
    bool enableIMEPersonalizedLearning = true,
    Brightness? keyboardAppearance,
    MouseCursor? mouseCursor,
    EdgeInsets scrollPadding = const EdgeInsets.all(20),
    String? restorationId,
    EditableTextContextMenuBuilder? contextMenuBuilder,
    bool toolbarEnabled = true,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    TapRegionCallback? onTapOutside,
    TapRegionUpCallback? onTapUpOutside,
    ValueChanged<String>? onClipboardFound,
    ACDHapticFeedbackType hapticFeedbackType = ACDHapticFeedbackType.disabled,
    bool closeKeyboardWhenCompleted = true,
    bool autoUnfocusOnCompleted = true,
    ACDPinErrorBuilder? errorBuilder,
    TextStyle? errorTextStyle,
    bool showErrorWhenFocused = false,
    bool enableAutofill = true,
    Iterable<String>? autofillHints,
    bool wrap = false,
    double wrapSpacing = 8,
    double wrapRunSpacing = 8,
    // Digit-entry order is deliberately independent of the ambient
    // Directionality by default: conventional PIN/OTP UX keeps digits
    // left-to-right even in RTL apps (Arabic/Hebrew banking apps included).
    // Pass TextDirection.rtl explicitly to opt into mirrored cell order.
    TextDirection textDirection = TextDirection.ltr,
    // Material (default) / Cupertino / adaptive — see ACDDesign.
    ACDDesign? design,
    // How the cells react when an error appears (default: a short shake,
    // skipped under reduce motion).
    ACDPinErrorAnimation errorAnimation = ACDPinErrorAnimation.shake,
    // Clears the entered digits when an error appears, so the user can
    // retype straight away.
    bool clearOnError = false,
  }) : assert(length > 0, 'length must be greater than 0'),
       assert(
         initialValue == null || initialValue.length <= length,
         'initialValue must not be longer than length',
       ),
       super(
         autovalidateMode:
             autovalidateMode ??
             (validator != null
                 ? AutovalidateMode.onUserInteraction
                 : AutovalidateMode.disabled),
         builder: (FormFieldState<String> field) {
           return _ACDPinFieldRenderer(
             field: field,
             length: length,
             controller: controller,
             focusNode: focusNode,
             onChanged: onChanged,
             onCompleted: onCompleted,
             onSubmitted: onSubmitted,
             enabled: enabled,
             padding: padding,
             margin: margin,
             pinTheme: pinTheme,
             focusedPinTheme: focusedPinTheme,
             submittedPinTheme: submittedPinTheme,
             followingPinTheme: followingPinTheme,
             errorPinTheme: errorPinTheme,
             disabledPinTheme: disabledPinTheme,
             disabledOpacity: disabledOpacity,
             preFilledWidget: preFilledWidget,
             cellBuilder: cellBuilder,
             separatorBuilder: separatorBuilder,
             mainAxisAlignment: mainAxisAlignment,
             crossAxisAlignment: crossAxisAlignment,
             pinContentAlignment: pinContentAlignment,
             pinAnimationType: pinAnimationType,
             slideTransitionBeginOffset:
                 slideTransitionBeginOffset ?? const Offset(0, 0.3),
             animationDuration: animationDuration,
             animationCurve: animationCurve,
             obscureText: obscureText,
             obscureCharacter: obscureCharacter,
             obscuringWidgetBuilder: obscuringWidgetBuilder,
             obscureRevealDuration: obscureRevealDuration,
             cursor: cursor,
             cursorColor: cursorColor,
             cursorWidth: cursorWidth,
             cursorHeight: cursorHeight,
             cursorRadius: cursorRadius,
             showCursor: showCursor,
             enableCursorAnimation: enableCursorAnimation,
             keyboardType: keyboardType,
             textInputAction: textInputAction,
             textCapitalization: textCapitalization,
             inputFormatters: inputFormatters,
             autofocus: autofocus,
             readOnly: readOnly,
             enableInteractiveSelection: enableInteractiveSelection,
             enableSuggestions: enableSuggestions,
             enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
             keyboardAppearance: keyboardAppearance,
             mouseCursor: mouseCursor,
             scrollPadding: scrollPadding,
             restorationId: restorationId,
             contextMenuBuilder: contextMenuBuilder,
             toolbarEnabled: toolbarEnabled,
             onTap: onTap,
             onLongPress: onLongPress,
             onTapOutside: onTapOutside,
             onTapUpOutside: onTapUpOutside,
             onClipboardFound: onClipboardFound,
             hapticFeedbackType: hapticFeedbackType,
             closeKeyboardWhenCompleted: closeKeyboardWhenCompleted,
             autoUnfocusOnCompleted: autoUnfocusOnCompleted,
             errorBuilder: errorBuilder,
             errorTextStyle: errorTextStyle,
             showErrorWhenFocused: showErrorWhenFocused,
             enableAutofill: enableAutofill,
             autofillHints: autofillHints ?? const [AutofillHints.oneTimeCode],
             wrap: wrap,
             wrapSpacing: wrapSpacing,
             wrapRunSpacing: wrapRunSpacing,
             textDirection: textDirection,
             design: design,
             errorAnimation: errorAnimation,
             clearOnError: clearOnError,
           );
         },
       );
}

class _ACDPinFieldRenderer extends StatefulWidget {
  const _ACDPinFieldRenderer({
    required this.field,
    required this.length,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onCompleted,
    required this.onSubmitted,
    required this.enabled,
    required this.padding,
    required this.margin,
    required this.pinTheme,
    required this.focusedPinTheme,
    required this.submittedPinTheme,
    required this.followingPinTheme,
    required this.errorPinTheme,
    required this.disabledPinTheme,
    required this.disabledOpacity,
    required this.preFilledWidget,
    required this.cellBuilder,
    required this.separatorBuilder,
    required this.mainAxisAlignment,
    required this.crossAxisAlignment,
    required this.pinContentAlignment,
    required this.pinAnimationType,
    required this.slideTransitionBeginOffset,
    required this.animationDuration,
    required this.animationCurve,
    required this.obscureText,
    required this.obscureCharacter,
    required this.obscuringWidgetBuilder,
    required this.obscureRevealDuration,
    required this.cursor,
    required this.cursorColor,
    required this.cursorWidth,
    required this.cursorHeight,
    required this.cursorRadius,
    required this.showCursor,
    required this.enableCursorAnimation,
    required this.keyboardType,
    required this.textInputAction,
    required this.textCapitalization,
    required this.inputFormatters,
    required this.autofocus,
    required this.readOnly,
    required this.enableInteractiveSelection,
    required this.enableSuggestions,
    required this.enableIMEPersonalizedLearning,
    required this.keyboardAppearance,
    required this.mouseCursor,
    required this.scrollPadding,
    required this.restorationId,
    required this.contextMenuBuilder,
    required this.toolbarEnabled,
    required this.onTap,
    required this.onLongPress,
    required this.onTapOutside,
    required this.onTapUpOutside,
    required this.onClipboardFound,
    required this.hapticFeedbackType,
    required this.closeKeyboardWhenCompleted,
    required this.autoUnfocusOnCompleted,
    required this.errorBuilder,
    required this.errorTextStyle,
    required this.showErrorWhenFocused,
    required this.enableAutofill,
    required this.autofillHints,
    required this.wrap,
    required this.wrapSpacing,
    required this.wrapRunSpacing,
    required this.textDirection,
    required this.design,
    required this.errorAnimation,
    required this.clearOnError,
  });

  final ACDDesign? design;
  final ACDPinErrorAnimation errorAnimation;
  final bool clearOnError;

  final FormFieldState<String> field;
  final int length;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final ACDPinTheme pinTheme;
  final ACDPinTheme? focusedPinTheme;
  final ACDPinTheme? submittedPinTheme;
  final ACDPinTheme? followingPinTheme;
  final ACDPinTheme? errorPinTheme;
  final ACDPinTheme? disabledPinTheme;
  final double disabledOpacity;
  final Widget? preFilledWidget;
  final ACDPinCellBuilder? cellBuilder;
  final ACDPinSeparatorBuilder? separatorBuilder;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final AlignmentGeometry pinContentAlignment;
  final ACDPinAnimationType pinAnimationType;
  final Offset slideTransitionBeginOffset;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool obscureText;
  final String obscureCharacter;
  final ACDPinObscureBuilder? obscuringWidgetBuilder;
  final Duration? obscureRevealDuration;
  final Widget? cursor;
  final Color? cursorColor;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final bool showCursor;
  final bool enableCursorAnimation;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final bool readOnly;
  final bool enableInteractiveSelection;
  final bool enableSuggestions;
  final bool enableIMEPersonalizedLearning;
  final Brightness? keyboardAppearance;
  final MouseCursor? mouseCursor;
  final EdgeInsets scrollPadding;
  final String? restorationId;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final bool toolbarEnabled;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final TapRegionCallback? onTapOutside;
  final TapRegionUpCallback? onTapUpOutside;
  final ValueChanged<String>? onClipboardFound;
  final ACDHapticFeedbackType hapticFeedbackType;
  final bool closeKeyboardWhenCompleted;
  final bool autoUnfocusOnCompleted;
  final ACDPinErrorBuilder? errorBuilder;
  final TextStyle? errorTextStyle;
  final bool showErrorWhenFocused;
  final bool enableAutofill;
  final Iterable<String> autofillHints;
  final bool wrap;
  final double wrapSpacing;
  final double wrapRunSpacing;
  final TextDirection textDirection;

  @override
  State<_ACDPinFieldRenderer> createState() => _ACDPinFieldRendererState();
}

class _ACDPinFieldRendererState extends State<_ACDPinFieldRenderer>
    with TickerProviderStateMixin {
  TextEditingController? _ownedController;
  FocusNode? _ownedFocusNode;
  AnimationController? _cursorController;

  // Error shake: created on first use only.
  AnimationController? _shakeController;
  bool _hadError = false;
  final Map<int, Timer> _revealTimers = {};
  final Set<int> _revealedIndices = {};
  bool _completedFired = false;

  // Last text seen by _handleTextChanged — the controller also notifies on
  // selection/caret-only changes, which must not fire onChanged/haptics.
  String? _lastText;

  TextEditingController get _controller =>
      widget.controller ??
      (_ownedController ??= TextEditingController(
        text: widget.field.value ?? '',
      ));

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  bool get _isFull => _controller.text.length >= widget.length;

  @override
  void initState() {
    super.initState();
    _lastText = _controller.text;
    _controller.addListener(_handleTextChanged);
    _focusNode.addListener(_handleFocusChanged);
    if (widget.enableCursorAnimation && widget.showCursor) {
      _cursorController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
        value: 1,
      );
      // Started in didChangeDependencies once reduce-motion is readable.
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncCursorAnimation();
  }

  /// Blink the caret only while focused and when motion is allowed — an
  /// idle field must not schedule a frame every 500ms forever.
  void _syncCursorAnimation() {
    final AnimationController? c = _cursorController;
    if (c == null) return;
    final bool run = _focusNode.hasFocus && !acdReduceMotion(context);
    if (run && !c.isAnimating) {
      c.repeat(reverse: true);
    } else if (!run && c.isAnimating) {
      c
        ..stop()
        ..value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _ACDPinFieldRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleTextChanged);
      _ownedController?.removeListener(_handleTextChanged);
      _lastText = _controller.text;
      _controller.addListener(_handleTextChanged);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      _ownedFocusNode?.removeListener(_handleFocusChanged);
      _focusNode.addListener(_handleFocusChanged);
    }
    final bool wantsCursorAnim =
        widget.enableCursorAnimation && widget.showCursor;
    if (wantsCursorAnim && _cursorController == null) {
      _cursorController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
        value: 1,
      );
    } else if (!wantsCursorAnim && _cursorController != null) {
      _cursorController!.dispose();
      _cursorController = null;
    }
    _syncCursorAnimation();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _focusNode.removeListener(_handleFocusChanged);
    _ownedController?.dispose();
    _ownedFocusNode?.dispose();
    _cursorController?.dispose();
    _shakeController?.dispose();
    for (final Timer timer in _revealTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _handleTextChanged() {
    final String text = _controller.text;
    if (text == _lastText) {
      // Selection/caret-only change: just repaint the caret cell.
      setState(() {});
      return;
    }
    _lastText = text;
    widget.field.didChange(text);
    widget.onChanged?.call(text);
    _maybeScheduleReveal(text);

    final bool full = text.length >= widget.length;
    if (full && !_completedFired) {
      _completedFired = true;
      widget.onCompleted?.call(text);
      if (widget.autoUnfocusOnCompleted) {
        // Unfocusing also hides the on-screen keyboard.
        _focusNode.unfocus();
      } else if (widget.closeKeyboardWhenCompleted) {
        // Hide the keyboard only, keeping the field's visual focus state.
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      }
    } else if (!full) {
      _completedFired = false;
    }

    if (widget.hapticFeedbackType != ACDHapticFeedbackType.disabled) {
      _fireHaptic();
    }
    setState(() {});
  }

  void _fireHaptic() {
    switch (widget.hapticFeedbackType) {
      case ACDHapticFeedbackType.disabled:
        break;
      case ACDHapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
      case ACDHapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
      case ACDHapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
      case ACDHapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
      case ACDHapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
    }
  }

  void _maybeScheduleReveal(String text) {
    final Duration? revealDuration = widget.obscureRevealDuration;
    if (!widget.obscureText || revealDuration == null) return;
    final int lastIndex = text.length - 1;
    if (lastIndex < 0) return;
    _revealedIndices.add(lastIndex);
    _revealTimers[lastIndex]?.cancel();
    _revealTimers[lastIndex] = Timer(revealDuration, () {
      if (!mounted) return;
      setState(() => _revealedIndices.remove(lastIndex));
    });
  }

  void _handleFocusChanged() {
    _syncCursorAnimation();
    setState(() {});
    if (_focusNode.hasFocus) _maybeCheckClipboard();
  }

  Future<void> _maybeCheckClipboard() async {
    if (widget.onClipboardFound == null) return;
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String? text = data?.text?.trim();
    if (text != null && text.length == widget.length && mounted) {
      widget.onClipboardFound!(text);
    }
  }

  void _requestFocus() {
    if (!widget.enabled || widget.readOnly) return;
    _focusNode.requestFocus();
    widget.onTap?.call();
  }

  ACDPinCellState _stateFor(int index, int caretIndex, bool hasChar) {
    if (!widget.enabled) return const ACDPinCellDisabled();
    if (widget.field.hasError) return const ACDPinCellError();
    if (_isFull) return const ACDPinCellSubmitted();
    if (_focusNode.hasFocus && index == caretIndex) {
      return const ACDPinCellFocused();
    }
    if (hasChar) return const ACDPinCellFollowing();
    return const ACDPinCellDefault();
  }

  /// Default idle cell decoration when the caller supplies no theme
  /// decoration. Material light keeps the original outlined look; Material
  /// dark uses the scheme outline (the old fixed grey was near-invisible on
  /// dark surfaces); Cupertino uses iOS filled, rounded cells.
  BoxDecoration _defaultCellDecoration(
    ACDResolvedDesign design,
    ACDDesignTokens tokens,
  ) {
    if (design.isCupertino) {
      return BoxDecoration(
        color: tokens.track,
        borderRadius: BorderRadius.circular(10),
      );
    }
    return BoxDecoration(
      border: Border.all(
        color: tokens.brightness == Brightness.dark
            ? tokens.outline
            : const Color(0xFFB8C7CB),
      ),
      borderRadius: BorderRadius.circular(8),
    );
  }

  /// Reacts once when an error *appears* (validate / forceErrorText):
  /// shake (unless reduce motion), an error haptic on iOS, and optionally
  /// clear the digits. Runs post-frame — never animates during build.
  void _onErrorAppeared(ACDResolvedDesign design) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (design.isCupertino) ACDHaptics.heavy(context);
      if (widget.errorAnimation == ACDPinErrorAnimation.shake &&
          !acdReduceMotion(context)) {
        if (_shakeController == null) {
          // First shake: rebuild so the AnimatedBuilder subscribes to it.
          setState(() {
            _shakeController = AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 400),
            );
          });
        }
        _shakeController!.forward(from: 0);
      }
      if (widget.clearOnError && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Resolved once per build (not per cell).
    final ACDResolvedDesign design = ACDDesign.resolve(context, widget.design);
    final bool hasError = widget.field.hasError;
    if (hasError && !_hadError) _onErrorAppeared(design);
    _hadError = hasError;
    final ACDDesignTokens tokens = ACDDesignTokens.of(context, design);
    // Sensible out-of-the-box focus/error indication when the caller
    // supplies no focused/error theme — a focused cell must never look
    // identical to an idle one.
    final ACDPinTheme defaultFocusedTheme = ACDPinTheme(
      borderColor: tokens.primary,
      borderWidth: 2,
    );
    final ACDPinTheme defaultErrorTheme = ACDPinTheme(
      borderColor: tokens.error,
      borderWidth: 2,
    );
    final BoxDecoration defaultCellDecoration = _defaultCellDecoration(
      design,
      tokens,
    );
    final Color caretColor = widget.cursorColor ?? tokens.primary;

    final TextEditingValue value = _controller.value;
    final String text = value.text;
    final int caretIndex = value.selection.isValid
        ? value.selection.baseOffset.clamp(0, widget.length)
        : text.length;

    final List<Widget> children = [];
    for (int i = 0; i < widget.length; i++) {
      if (i > 0) {
        final Widget? separator = widget.separatorBuilder?.call(i);
        if (separator != null) children.add(separator);
      }
      final bool hasChar = i < text.length;
      final String char = hasChar ? text[i] : '';
      final ACDPinCellState state = _stateFor(i, caretIndex, hasChar);
      children.add(
        _ACDPinCell(
          key: ValueKey(i),
          index: i,
          char: char,
          state: state,
          showCaret:
              widget.showCursor &&
              widget.enabled &&
              _focusNode.hasFocus &&
              i == caretIndex,
          theme: acdResolvePinTheme(
            state,
            defaultTheme: widget.pinTheme,
            focusedTheme: widget.focusedPinTheme ?? defaultFocusedTheme,
            submittedTheme: widget.submittedPinTheme,
            followingTheme: widget.followingPinTheme,
            errorTheme: widget.errorPinTheme ?? defaultErrorTheme,
            disabledTheme: widget.disabledPinTheme,
          ),
          preFilledWidget: widget.preFilledWidget,
          cellBuilder: widget.cellBuilder,
          obscureText: widget.obscureText,
          obscureCharacter: widget.obscureCharacter,
          obscuringWidgetBuilder: widget.obscuringWidgetBuilder,
          revealed: !widget.obscureText || _revealedIndices.contains(i),
          pinContentAlignment: widget.pinContentAlignment,
          pinAnimationType: widget.pinAnimationType,
          slideTransitionBeginOffset: widget.slideTransitionBeginOffset,
          animationDuration: widget.animationDuration,
          animationCurve: widget.animationCurve,
          cursor: widget.cursor,
          cursorColor: caretColor,
          defaultDecoration: defaultCellDecoration,
          cursorWidth: widget.cursorWidth,
          cursorHeight: widget.cursorHeight,
          cursorRadius: widget.cursorRadius,
          cursorAnimation: _cursorController,
        ),
      );
    }

    // Digit-entry order is pinned to widget.textDirection (LTR by default)
    // regardless of the app's ambient Directionality — see the textDirection
    // doc comment on ACDPinField for why.
    final Widget cellsRow = Directionality(
      textDirection: widget.textDirection,
      child: widget.wrap
          ? Wrap(
              alignment: WrapAlignment.center,
              spacing: widget.wrapSpacing,
              runSpacing: widget.wrapRunSpacing,
              children: children,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: widget.mainAxisAlignment,
              crossAxisAlignment: widget.crossAxisAlignment,
              children: children,
            ),
    );

    // No wrapping GestureDetector: the real TextField below already handles
    // tap-to-focus (via its own `onTap`) and long-press-to-select natively.
    // Layering an opaque gesture detector on top of it would silently steal
    // those gestures before the TextField's own (well-tested) selection
    // handling ever saw them — exactly the kind of hand-rolled selection
    // logic this architecture exists to avoid.
    final EditableTextContextMenuBuilder? menuBuilder = widget.toolbarEnabled
        ? widget.contextMenuBuilder
        : (context, state) => const SizedBox.shrink();
    // Caller formatters run first; the field's own maxLength limiter
    // (appended after them) then truncates. Limiting first truncated pasted
    // codes like "123 456" before a digits-only formatter could strip the
    // space.
    final Widget hiddenField = switch (design) {
      ACDResolvedDesign.material => acdEnsureMaterial(
        context,
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          showCursor: false,
          obscureText: widget.obscureText,
          autocorrect: false,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          enableSuggestions: widget.enableSuggestions,
          enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
          cursorColor: Colors.transparent,
          style: const TextStyle(color: Colors.transparent, fontSize: 16),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          keyboardAppearance: widget.keyboardAppearance,
          mouseCursor: widget.mouseCursor,
          maxLength: widget.length,
          scrollPadding: widget.scrollPadding,
          restorationId: widget.restorationId,
          contextMenuBuilder: menuBuilder,
          onTap: _requestFocus,
          onTapOutside: widget.onTapOutside,
          onTapUpOutside: widget.onTapUpOutside,
          onSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          autofillHints: widget.enableAutofill ? widget.autofillHints : null,
        ),
      ),
      // iOS: a real CupertinoTextField — native paste menu and selection,
      // and no Material ancestor/localizations required.
      // cupertino_ui 1.1.7 types CupertinoTextField.onTapUpOutside as a
      // pointer-*down* callback, so deliver onTapUpOutside through a
      // TapRegion sharing the text field's group instead.
      ACDResolvedDesign.cupertino => TapRegion(
        groupId: EditableText,
        onTapUpOutside: widget.onTapUpOutside,
        child: CupertinoTextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          showCursor: false,
          obscureText: widget.obscureText,
          autocorrect: false,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          enableSuggestions: widget.enableSuggestions,
          enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
          cursorColor: const Color(0x00000000),
          style: const TextStyle(color: Color(0x00000000), fontSize: 16),
          decoration: null,
          padding: EdgeInsets.zero,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          keyboardAppearance: widget.keyboardAppearance,
          maxLength: widget.length,
          scrollPadding: widget.scrollPadding,
          restorationId: widget.restorationId,
          contextMenuBuilder: menuBuilder,
          onTap: _requestFocus,
          onTapOutside: widget.onTapOutside,
          onSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          autofillHints: widget.enableAutofill ? widget.autofillHints : null,
        ),
      ),
    };

    final Widget stack = Stack(
      alignment: Alignment.center,
      children: [
        // The visible cells are a pure presentation layer: excluded from
        // semantics so screen readers announce one labelled PIN field (and
        // never read obscured digits cell by cell).
        IgnorePointer(child: ExcludeSemantics(child: cellsRow)),
        Positioned.fill(
          child: Semantics(
            label: ACDDesignScope.stringsOf(context)
                .pinFieldLabel(text.length, widget.length),
            // Invisible, but must stay in the semantics tree — opacity 0
            // would otherwise drop the field for screen readers entirely.
            child: Opacity(
              opacity: 0.0,
              alwaysIncludeSemantics: true,
              child: hiddenField,
            ),
          ),
        ),
        // Translucent, not opaque: this still lets the pointer event reach
        // the real TextField underneath for its own native long-press-to-
        // select handling — it only adds `widget.onLongPress` as an extra
        // participant in the same gesture arena, rather than stealing the
        // gesture from it.
        if (widget.onLongPress != null)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPress: widget.onLongPress,
            ),
          ),
      ],
    );
    final bool showFieldError =
        widget.field.hasError &&
        (!widget.showErrorWhenFocused || !_focusNode.hasFocus);

    return Padding(
      padding: widget.margin,
      child: Padding(
        padding: widget.padding,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : widget.disabledOpacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Always the same wrapper (even before the first error), so
              // creating the shake controller never remounts the hidden
              // text field and drops focus.
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _shakeController ?? kAlwaysDismissedAnimation,
                  builder: (context, child) {
                    // 4 decaying oscillations of up to 8 px.
                    // Always a Transform (offset 0 at rest): switching the
                    // wrapper type mid-shake would remount the field too.
                    final double t = _shakeController?.value ?? 0;
                    final double dx =
                        math.sin(t * 4 * 2 * math.pi) * 8 * (1 - t);
                    return Transform.translate(
                      offset: Offset(dx, 0),
                      child: child,
                    );
                  },
                  child: stack,
                ),
              ),
              if (showFieldError)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child:
                      widget.errorBuilder?.call(widget.field.errorText, text) ??
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          widget.field.errorText ?? '',
                          style:
                              widget.errorTextStyle ??
                              TextStyle(color: tokens.error, fontSize: 12),
                        ),
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ACDPinCell extends StatelessWidget {
  const _ACDPinCell({
    required Key super.key,
    required this.index,
    required this.char,
    required this.state,
    required this.showCaret,
    required this.theme,
    required this.preFilledWidget,
    required this.cellBuilder,
    required this.obscureText,
    required this.obscureCharacter,
    required this.obscuringWidgetBuilder,
    required this.revealed,
    required this.pinContentAlignment,
    required this.pinAnimationType,
    required this.slideTransitionBeginOffset,
    required this.animationDuration,
    required this.animationCurve,
    required this.cursor,
    required this.cursorColor,
    required this.cursorWidth,
    required this.cursorHeight,
    required this.cursorRadius,
    required this.cursorAnimation,
    required this.defaultDecoration,
  });

  final int index;
  final String char;
  final ACDPinCellState state;
  final bool showCaret;
  final ACDPinTheme theme;
  final Widget? preFilledWidget;
  final ACDPinCellBuilder? cellBuilder;
  final bool obscureText;
  final String obscureCharacter;
  final ACDPinObscureBuilder? obscuringWidgetBuilder;
  final bool revealed;
  final AlignmentGeometry pinContentAlignment;
  final ACDPinAnimationType pinAnimationType;
  final Offset slideTransitionBeginOffset;
  final Duration animationDuration;
  final Curve animationCurve;
  final Widget? cursor;
  final Color? cursorColor;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Animation<double>? cursorAnimation;
  final BoxDecoration defaultDecoration;

  Widget _buildContent(BuildContext context) {
    if (char.isEmpty) return preFilledWidget ?? const SizedBox.shrink();
    if (obscureText && !revealed) {
      return obscuringWidgetBuilder?.call(context, index) ??
          Text(obscureCharacter, style: theme.textStyle);
    }
    return Text(char, style: theme.textStyle);
  }

  Widget _animatedEntry(BuildContext context) {
    final Widget content = KeyedSubtree(
      key: ValueKey('$index-$char-$revealed'),
      child: _buildContent(context),
    );
    return switch (pinAnimationType) {
      ACDPinAnimationType.none => content,
      ACDPinAnimationType.scale => AnimatedSwitcher(
        duration: animationDuration,
        switchInCurve: animationCurve,
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: content,
      ),
      ACDPinAnimationType.fade => AnimatedSwitcher(
        duration: animationDuration,
        switchInCurve: animationCurve,
        child: content,
      ),
      ACDPinAnimationType.slide => AnimatedSwitcher(
        duration: animationDuration,
        switchInCurve: animationCurve,
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: slideTransitionBeginOffset,
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
        child: content,
      ),
      ACDPinAnimationType.rotation => AnimatedSwitcher(
        duration: animationDuration,
        switchInCurve: animationCurve,
        transitionBuilder: (child, animation) =>
            RotationTransition(turns: animation, child: child),
        child: content,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (cellBuilder != null) {
      return cellBuilder!(context, index, state, char);
    }

    Widget content = Align(
      alignment: pinContentAlignment,
      child: _animatedEntry(context),
    );

    if (showCaret) {
      final Widget caret = Container(
        width: cursorWidth,
        height: cursorHeight ?? (theme.height ?? 52.0) * 0.5,
        decoration: BoxDecoration(
          color: cursorColor,
          borderRadius: cursorRadius != null
              ? BorderRadius.all(cursorRadius!)
              : null,
        ),
      );
      final Widget positionedCaret = cursor ?? caret;
      // Only overlay the blinking caret in an empty cell — a filled cell at
      // the caret position is shown via its `focused` theme instead, so the
      // caret bar never gets drawn on top of an existing digit.
      if (char.isEmpty) {
        content = Stack(
          alignment: Alignment.center,
          children: [
            content,
            cursorAnimation == null
                ? positionedCaret
                : FadeTransition(
                    opacity: cursorAnimation!,
                    child: positionedCaret,
                  ),
          ],
        );
      }
    }

    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      width: theme.width ?? 48.0,
      height: theme.height ?? 52.0,
      margin: theme.margin,
      padding: theme.padding,
      constraints: theme.constraints,
      decoration: theme.resolveDecoration() ?? defaultDecoration,
      alignment: Alignment.center,
      child: content,
    );
  }
}
