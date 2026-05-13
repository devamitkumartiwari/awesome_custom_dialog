import 'dart:async';

import 'package:flutter/material.dart';

// FEAT-08: built-in animation presets
enum ACDAnimation {
  none,
  fade,
  scale,
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  bounce,
  rotate,
}

// Dialog gravity positions
enum ACDGravity {
  left,
  top,
  bottom,
  right,
  center,
  rightTop,
  leftTop,
  rightBottom,
  leftBottom,
  spaceEvenly,
}

class ACDDialog {
  // Explicit unnamed constructor required because we also declare a factory constructor
  ACDDialog();

  // ── Widget content ────────────────────────────────────────────────────────
  List<Widget> widgetList = [];

  // ── Context ───────────────────────────────────────────────────────────────
  static BuildContext? _context;
  BuildContext? context;

  // ── Sizing ────────────────────────────────────────────────────────────────
  double? width;
  double? height;
  BoxConstraints? constraints;

  // ── Animation ─────────────────────────────────────────────────────────────
  Duration duration = const Duration(milliseconds: 250);
  bool gravityAnimationEnable = false;

  // IMP-01: typed; FEAT-08: preset enum
  Function(Widget child, Animation<double> animation)? animatedFunc;
  ACDAnimation animation = ACDAnimation.none;

  // ── Positioning ───────────────────────────────────────────────────────────
  ACDGravity gravity = ACDGravity.center;
  EdgeInsets margin = EdgeInsets.zero;

  // ── Appearance ────────────────────────────────────────────────────────────
  // IMP-05: replace deprecated withOpacity
  Color barrierColor = const Color.fromRGBO(0, 0, 0, 0.3);
  Decoration? decoration;
  Color backgroundColor = Colors.white;
  double borderRadius = 0.0;

  // ── Behaviour ─────────────────────────────────────────────────────────────
  bool barrierDismissible = true;
  bool useRootNavigator = true;

  // IMP-08: accessibility label for barrier
  String barrierLabel = 'Dialog';

  // ── New properties ────────────────────────────────────────────────────────
  Duration? autoDismissAfter; // FEAT-02
  bool respectSafeArea = false; // FEAT-11
  VoidCallback? onBarrierTap; // FEAT-12
  bool useTheme = false; // FEAT-10
  TextDirection textDirection = TextDirection.ltr; // FEAT-14

  // ── Callbacks ─────────────────────────────────────────────────────────────
  VoidCallback? showCallBack;
  VoidCallback? dismissCallBack;

  bool _isShowing = false;

  bool get isShowing => _isShowing;

  // ── Static helpers ────────────────────────────────────────────────────────

  static void init(BuildContext ctx) {
    _context = ctx;
  }

  // BUG-08: allow callers to clear stale static context
  static void clearContext() {
    _context = null;
  }

  // ── Builder API ───────────────────────────────────────────────────────────

  ACDDialog build([BuildContext? ctx]) {
    context = ctx ?? _context;
    return this;
  }

  ACDDialog widget(Widget child) {
    widgetList.add(child);
    return this;
  }

  // IMP-01: all parameters fully typed
  ACDDialog text({
    EdgeInsets? padding,
    String? text,
    Color? color,
    double? fontSize,
    Alignment? alignment,
    TextAlign? textAlign,
    int? maxLines,
    TextDirection? textDirection,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    String? fontFamily,
  }) {
    return widget(
      Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Align(
          alignment: alignment ?? Alignment.centerLeft,
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
            ),
          ),
        ),
      ),
    );
  }

  // IMP-04: gravity typed; BUG-06: onTap2 typed as VoidCallback?
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
    String? text2,
    Color? color2,
    double? fontSize2,
    FontWeight? fontWeight2,
    String? fontFamily2,
    VoidCallback? onTap2,
    EdgeInsets buttonPadding2 = EdgeInsets.zero,
  }) {
    return widget(
      SizedBox(
        height: height ?? 45.0,
        child: Row(
          mainAxisAlignment: _rowAlignment(gravity),
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
                ),
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
                ),
              ),
              child: Text(text2 ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  // FEAT-03: single button helper
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
              ),
            ),
            child: Text(text ?? 'OK'),
          ),
        ),
      ),
    );
  }

  // FEAT-04: three-button helper
  ACDDialog threeButton({
    double? height,
    bool isClickAutoDismiss = true,
    String? text1,
    Color? color1,
    double? fontSize1,
    VoidCallback? onTap1,
    String? text2,
    Color? color2,
    double? fontSize2,
    VoidCallback? onTap2,
    String? text3,
    Color? color3,
    double? fontSize3,
    VoidCallback? onTap3,
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
              ),
              child: Text(
                text1 ?? '',
                style: TextStyle(fontSize: fontSize1 ?? 14.0),
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
              ),
              child: Text(
                text2 ?? '',
                style: TextStyle(fontSize: fontSize2 ?? 14.0),
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
              ),
              child: Text(
                text3 ?? '',
                style: TextStyle(fontSize: fontSize3 ?? 14.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BUG-05: InkWell removed; IMP-03: physics + controller added
  ACDDialog listOfACDListTile({
    List<ACDListTileItem>? items,
    double? height,
    bool isClickAutoDismiss = true,
    Function(int)? onClickItemListener,
    ScrollPhysics? physics,
    ScrollController? controller,
  }) {
    return widget(
      SizedBox(
        height: height,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: physics,
          controller: controller,
          itemCount: items?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            return Material(
              color: Colors.white,
              child: ListTile(
                onTap: () {
                  onClickItemListener?.call(index);
                  if (isClickAutoDismiss) dismiss();
                },
                contentPadding: items?[index].padding ?? EdgeInsets.zero,
                leading: items?[index].leading,
                title: Text(
                  items?[index].text ?? '',
                  style: TextStyle(
                    color: items?[index].color,
                    fontSize: items?[index].fontSize,
                    fontWeight: items?[index].fontWeight,
                    fontFamily: items?[index].fontFamily,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // BUG-04: null guard on context; IMP-03: physics + controller
  ACDDialog listOfACDRadioButton({
    List<ACDRadioItem>? items,
    double? height,
    Color? color,
    Color? activeColor,
    int? initialValue,
    Function(int)? onClickItemListener,
    ScrollPhysics? physics,
    ScrollController? controller,
  }) {
    if (context == null) return this;
    final size = MediaQuery.of(context!).size;
    return widget(
      Container(
        height: height,
        constraints: BoxConstraints(
          minHeight: size.height * .1,
          minWidth: size.width * .1,
          maxHeight: size.height * .5,
        ),
        child: ACDRadioListTile(
          items: items,
          initialValue: initialValue,
          color: color,
          activeColor: activeColor,
          physics: physics,
          controller: controller,
          onChanged: onClickItemListener,
        ),
      ),
    );
  }

  // FEAT-07: checkbox multi-select list
  ACDDialog listOfACDCheckbox({
    List<ACDCheckboxItem>? items,
    double? height,
    Color? color,
    Color? activeColor,
    List<int>? initialValues,
    Function(List<int>)? onChanged,
    ScrollPhysics? physics,
    ScrollController? controller,
  }) {
    if (context == null) return this;
    final size = MediaQuery.of(context!).size;
    return widget(
      Container(
        height: height,
        constraints: BoxConstraints(
          minHeight: size.height * .1,
          minWidth: size.width * .1,
          maxHeight: size.height * .5,
        ),
        child: ACDCheckboxListTile(
          items: items,
          initialValues: initialValues,
          color: color,
          activeColor: activeColor,
          physics: physics,
          controller: controller,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // BUG-01: null-safe valueColor; IMP-01: typed parameters
  ACDDialog acdProgress({
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? valueColor,
    double? strokeWidth,
  }) {
    return widget(
      Padding(
        padding: padding ?? EdgeInsets.zero,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth ?? 4.0,
          backgroundColor: backgroundColor,
          valueColor: valueColor != null
              ? AlwaysStoppedAnimation<Color>(valueColor)
              : null,
        ),
      ),
    );
  }

  // BUG-07: default height fixed to 1.0; IMP-01: typed
  ACDDialog acdDivider({Color? color, double? height}) {
    return widget(
      Divider(color: color ?? Colors.grey[300], height: height ?? 1.0),
    );
  }

  // FEAT-06: image helper
  ACDDialog acdImage({
    String? assetPath,
    ImageProvider? imageProvider,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    EdgeInsets? padding,
  }) {
    assert(
      assetPath != null || imageProvider != null,
      'Provide either assetPath or imageProvider',
    );
    return widget(
      Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Image(
          image: imageProvider ?? AssetImage(assetPath!),
          width: width,
          height: height,
          fit: fit,
        ),
      ),
    );
  }

  // FEAT-05: text field inside dialog
  ACDDialog acdTextField({
    TextEditingController? controller,
    String? hint,
    String? label,
    int? maxLines = 1,
    Color? fillColor,
    Color? borderColor,
    EdgeInsets? padding,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return widget(
      Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            labelText: label,
            fillColor: fillColor,
            filled: fillColor != null,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor ?? Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  // FEAT-01: predefined success preset
  ACDDialog success({
    String title = 'Success',
    String? message,
    String buttonText = 'OK',
    VoidCallback? onTap,
  }) =>
      _preset(
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF4CAF50),
        title: title,
        message: message,
        buttonText: buttonText,
        onTap: onTap,
      );

  // FEAT-01: predefined error preset
  ACDDialog error({
    String title = 'Error',
    String? message,
    String buttonText = 'OK',
    VoidCallback? onTap,
  }) =>
      _preset(
        icon: Icons.cancel_rounded,
        iconColor: const Color(0xFFF44336),
        title: title,
        message: message,
        buttonText: buttonText,
        onTap: onTap,
      );

  // FEAT-01: predefined warning preset
  ACDDialog warning({
    String title = 'Warning',
    String? message,
    String buttonText = 'OK',
    VoidCallback? onTap,
  }) =>
      _preset(
        icon: Icons.warning_rounded,
        iconColor: const Color(0xFFFF9800),
        title: title,
        message: message,
        buttonText: buttonText,
        onTap: onTap,
      );

  // FEAT-01: predefined info preset
  ACDDialog info({
    String title = 'Info',
    String? message,
    String buttonText = 'OK',
    VoidCallback? onTap,
  }) =>
      _preset(
        icon: Icons.info_rounded,
        iconColor: const Color(0xFF2196F3),
        title: title,
        message: message,
        buttonText: buttonText,
        onTap: onTap,
      );

  ACDDialog _preset({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? message,
    required String buttonText,
    VoidCallback? onTap,
  }) {
    return widget(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 52),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
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
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FEAT-09: toast factory — call .show() after creation
  factory ACDDialog.toast({
    required BuildContext context,
    required String message,
    Duration showDuration = const Duration(seconds: 2),
    ACDGravity gravity = ACDGravity.bottom,
    Color backgroundColor = const Color(0xDD000000),
    Color textColor = Colors.white,
    double fontSize = 14.0,
    EdgeInsets margin = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 32,
    ),
  }) {
    return ACDDialog()
      ..build(context)
      ..barrierColor = Colors.transparent
      ..barrierDismissible = false
      ..gravity = gravity
      ..gravityAnimationEnable = true
      ..backgroundColor = backgroundColor
      ..borderRadius = 24.0
      ..autoDismissAfter = showDuration
      ..margin = margin
      ..widget(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            message,
            style: TextStyle(color: textColor, fontSize: fontSize),
            textAlign: TextAlign.center,
          ),
        ),
      );
  }

  // ── Show / Dismiss ────────────────────────────────────────────────────────

  void show([double? x, double? y]) {
    if (context == null) return;

    if (x != null && y != null) {
      gravity = ACDGravity.leftTop;
      margin = EdgeInsets.only(left: x, top: y);
    }

    // Resolve effective margin based on gravity if none provided
    EdgeInsets effectiveMargin = margin;
    if (effectiveMargin == EdgeInsets.zero) {
      switch (gravity) {
        case ACDGravity.top:
        case ACDGravity.leftTop:
        case ACDGravity.rightTop:
          effectiveMargin = const EdgeInsets.fromLTRB(24, 16, 24, 0);
          break;
        case ACDGravity.bottom:
        case ACDGravity.leftBottom:
        case ACDGravity.rightBottom:
          effectiveMargin = const EdgeInsets.fromLTRB(24, 0, 24, 16);
          break;
        default:
          effectiveMargin = const EdgeInsets.symmetric(horizontal: 24);
      }
    }

    // Resolve animation function: explicit > preset enum > gravity-based
    final Function(Widget, Animation<double>)? effectiveAnimFn = animatedFunc ??
        (animation != ACDAnimation.none ? _presetAnimFn(animation) : null);

    // IMP-10: use theme background when requested
    final Color effectiveBg = useTheme
        ? (Theme.of(context!).dialogTheme.backgroundColor ?? Colors.white)
        : backgroundColor;

    Widget dialogContent = Padding(
      padding: effectiveMargin,
      child: Column(
        textDirection: textDirection,
        mainAxisAlignment: _columnMainAxisAlignment(gravity),
        crossAxisAlignment: _columnCrossAxisAlignment(gravity),
        children: [
          Material(
            clipBehavior: Clip.antiAlias,
            type: MaterialType.transparency,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              width: width,
              height: height,
              decoration: decoration ??
                  BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    color: effectiveBg,
                  ),
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
          ),
        ],
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

    // FEAT-02: auto-dismiss timer
    if (autoDismissAfter != null) {
      Timer(autoDismissAfter!, () {
        if (_isShowing) dismiss();
      });
    }
  }

  void dismiss() {
    if (_isShowing) {
      Navigator.of(context!, rootNavigator: useRootNavigator).pop();
      _isShowing = false;
    }
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  // FEAT-08: map enum to animation function
  Function(Widget, Animation<double>) _presetAnimFn(ACDAnimation anim) {
    switch (anim) {
      case ACDAnimation.fade:
        return (child, anim) => FadeTransition(opacity: anim, child: child);

      case ACDAnimation.scale:
        return (child, anim) => ScaleTransition(
              scale: Tween(
                begin: 0.0,
                end: 1.0,
              ).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
              child: child,
            );

      case ACDAnimation.bounce:
        return (child, anim) => ScaleTransition(
              scale: Tween(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.bounceOut)),
              child: child,
            );

      case ACDAnimation.slideUp:
        return (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            );

      case ACDAnimation.slideDown:
        return (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            );

      case ACDAnimation.slideLeft:
        return (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            );

      case ACDAnimation.slideRight:
        return (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            );

      case ACDAnimation.rotate:
        return (child, anim) => RotationTransition(
              turns: Tween(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            );

      case ACDAnimation.none:
        return (child, anim) => child;
    }
  }

  MainAxisAlignment _columnMainAxisAlignment(ACDGravity g) {
    switch (g) {
      case ACDGravity.bottom:
      case ACDGravity.leftBottom:
      case ACDGravity.rightBottom:
        return MainAxisAlignment.end;
      case ACDGravity.top:
      case ACDGravity.leftTop:
      case ACDGravity.rightTop:
        return MainAxisAlignment.start;
      default:
        return MainAxisAlignment.center;
    }
  }

  CrossAxisAlignment _columnCrossAxisAlignment(ACDGravity g) {
    switch (g) {
      case ACDGravity.left:
      case ACDGravity.leftTop:
      case ACDGravity.leftBottom:
        return CrossAxisAlignment.start;
      case ACDGravity.right:
      case ACDGravity.rightTop:
      case ACDGravity.rightBottom:
        return CrossAxisAlignment.end;
      default:
        return CrossAxisAlignment.center;
    }
  }

  MainAxisAlignment _rowAlignment(ACDGravity? g) {
    switch (g) {
      case ACDGravity.left:
        return MainAxisAlignment.start;
      case ACDGravity.right:
        return MainAxisAlignment.end;
      case ACDGravity.spaceEvenly:
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.center;
    }
  }
}

// ── ACDChildren ──────────────────────────────────────────────────────────────

class ACDChildren extends StatefulWidget {
  final List<Widget> widgetList;

  // BUG-02: split into two explicit callbacks instead of a single bool callback
  final VoidCallback? onShown;
  final VoidCallback? onDismissed;

  const ACDChildren({
    super.key,
    this.widgetList = const [],
    this.onShown,
    this.onDismissed,
  });

  @override
  State<ACDChildren> createState() => _ACDChildrenState();
}

class _ACDChildrenState extends State<ACDChildren> {
  @override
  void initState() {
    super.initState();
    // BUG-02: defer callback to avoid setState-during-build framework error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onShown?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // IMP-07: wrap content, don't expand
      children: widget.widgetList,
    );
  }

  @override
  void dispose() {
    // BUG-09: always fires — covers barrier tap AND programmatic dismiss
    widget.onDismissed?.call();
    super.dispose();
  }
}

// ── ACD (internal presenter) ─────────────────────────────────────────────────

class ACD {
  final BuildContext _context;
  final Widget _child;
  final Duration _duration;
  Color _barrierColor;
  final bool _barrierDismissible;
  final ACDGravity? _gravity;
  final bool _gravityAnimationEnable;
  final Function(Widget, Animation<double>)? _animatedFunc;
  final bool _useRootNavigator; // BUG-03
  final String _barrierLabel; // IMP-08
  final VoidCallback? _onBarrierTap; // FEAT-12

  ACD({
    required Widget child,
    required BuildContext context,
    Duration duration = const Duration(milliseconds: 250),
    Color barrierColor = const Color.fromRGBO(0, 0, 0, 0.3),
    ACDGravity? gravity,
    bool gravityAnimationEnable = false,
    Function(Widget, Animation<double>)? animatedFunc,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
    String barrierLabel = 'Dialog',
    VoidCallback? onBarrierTap,
  })  : _child = child,
        _context = context,
        _gravity = gravity,
        _gravityAnimationEnable = gravityAnimationEnable,
        _duration = duration,
        _barrierColor = barrierColor,
        _animatedFunc = animatedFunc,
        // FEAT-12: when onBarrierTap is set, we manage dismissal ourselves
        _barrierDismissible = onBarrierTap != null ? false : barrierDismissible,
        _useRootNavigator = useRootNavigator,
        _barrierLabel = barrierLabel,
        _onBarrierTap = onBarrierTap {
    _show();
  }

  void _show() {
    // IMP-05: handle transparent barrier
    if (_barrierColor == Colors.transparent) {
      _barrierColor = const Color(0x00ffffff);
    }

    showGeneralDialog(
      context: _context,
      useRootNavigator: _useRootNavigator,
      // BUG-03 fix
      barrierColor: _barrierColor,
      barrierDismissible: _barrierDismissible,
      barrierLabel: _barrierLabel,
      transitionDuration: _duration,
      transitionBuilder: _buildTransition,
      pageBuilder: (BuildContext buildContext, _, __) {
        // FEAT-12: overlay a full-screen tap detector when onBarrierTap is set
        if (_onBarrierTap != null) {
          return Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _onBarrierTap!();
                  Navigator.of(
                    buildContext,
                    rootNavigator: _useRootNavigator,
                  ).pop();
                },
                child: const SizedBox.expand(),
              ),
              _child,
            ],
          );
        }
        return _child;
      },
    );
  }

  Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Custom animation wins
    if (_animatedFunc != null) {
      return _animatedFunc!(child, animation);
    }

    // No gravity animation requested
    if (!_gravityAnimationEnable) return child;

    Offset begin;
    switch (_gravity) {
      case ACDGravity.top:
      case ACDGravity.leftTop:
      case ACDGravity.rightTop:
        begin = const Offset(0.0, -1.0);
        break;
      case ACDGravity.left:
        begin = const Offset(-1.0, 0.0);
        break;
      case ACDGravity.right:
        begin = const Offset(1.0, 0.0);
        break;
      case ACDGravity.bottom:
      case ACDGravity.leftBottom:
      case ACDGravity.rightBottom:
        begin = const Offset(0.0, 1.0);
        break;
      default:
        return child;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}

// ── ACDDialogQueue ────────────────────────────────────────────────────────────
// FEAT-13: show dialogs one after another without overlapping

class ACDDialogQueue {
  ACDDialogQueue._();

  static final List<ACDDialog> _queue = [];
  static bool _active = false;

  static void enqueue(ACDDialog dialog) {
    _queue.add(dialog);
    if (!_active) _next();
  }

  static void clearQueue() {
    _queue.clear();
    _active = false;
  }

  static void _next() {
    if (_queue.isEmpty) {
      _active = false;
      return;
    }
    _active = true;
    final dialog = _queue.removeAt(0);
    final original = dialog.dismissCallBack;
    dialog.dismissCallBack = () {
      original?.call();
      // Use post frame callback to avoid "Navigator locked" error when showing next dialog in queue
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _next();
      });
    };
    dialog.show();
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class ACDListTileItem {
  // IMP-10: const constructor
  const ACDListTileItem({
    this.padding,
    this.leading,
    this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
  });

  final EdgeInsets? padding;
  final Widget? leading;
  final String? text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
}

class ACDRadioItem {
  // IMP-10: const constructor; BUG-10: added fontFamily
  const ACDRadioItem({
    this.padding,
    this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily, // BUG-10
    this.onTap,
  });

  final EdgeInsets? padding;
  final String? text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily; // BUG-10
  final Function(int)? onTap;
}

// FEAT-07: data class for checkbox list
class ACDCheckboxItem {
  const ACDCheckboxItem({
    this.padding,
    this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
  });

  final EdgeInsets? padding;
  final String? text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
}

// ── ACDRadioListTile ──────────────────────────────────────────────────────────

class ACDRadioListTile extends StatefulWidget {
  const ACDRadioListTile({
    super.key,
    required this.items,
    this.initialValue,
    this.color,
    this.activeColor,
    this.physics,
    this.controller,
    this.onChanged,
  });

  final List<ACDRadioItem>? items;
  final int? initialValue;
  final Color? color;
  final Color? activeColor;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final Function(int)? onChanged;

  @override
  State<ACDRadioListTile> createState() => _ACDRadioListTileState();
}

class _ACDRadioListTileState extends State<ACDRadioListTile> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue ?? -1;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: widget.physics,
      controller: widget.controller,
      itemCount: widget.items?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        final item = widget.items![index];
        return Material(
          color: widget.color,
          child: RadioListTile<int>(
            title: Text(
              item.text ?? '',
              style: TextStyle(
                fontSize: item.fontSize ?? 14,
                fontWeight: item.fontWeight ?? FontWeight.normal,
                fontFamily: item.fontFamily,
                color: item.color ?? Colors.black,
              ),
            ),
            value: index,
            groupValue: _selected,
            activeColor: widget.activeColor,
            onChanged: (int? value) {
              if (value == null) return;
              setState(() => _selected = value);
              widget.onChanged?.call(value);
              widget.items?[value].onTap?.call(value);
            },
          ),
        );
      },
    );
  }
}

// ── ACDCheckboxListTile ───────────────────────────────────────────────────────

class ACDCheckboxListTile extends StatefulWidget {
  const ACDCheckboxListTile({
    super.key,
    required this.items,
    this.initialValues,
    this.color,
    this.activeColor,
    this.physics,
    this.controller,
    this.onChanged,
  });

  final List<ACDCheckboxItem>? items;
  final List<int>? initialValues;
  final Color? color;
  final Color? activeColor;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final Function(List<int>)? onChanged;

  @override
  State<ACDCheckboxListTile> createState() => _ACDCheckboxListTileState();
}

class _ACDCheckboxListTileState extends State<ACDCheckboxListTile> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<int>.from(widget.initialValues ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: widget.physics,
      controller: widget.controller,
      itemCount: widget.items?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        final item = widget.items![index];
        return Material(
          color: widget.color,
          child: CheckboxListTile(
            title: Text(
              item.text ?? '',
              style: TextStyle(
                fontSize: item.fontSize ?? 14,
                fontWeight: item.fontWeight ?? FontWeight.normal,
                fontFamily: item.fontFamily,
                color: item.color ?? Colors.black,
              ),
            ),
            value: _selected.contains(index),
            activeColor: widget.activeColor,
            checkColor: Colors.white,
            contentPadding: item.padding ?? EdgeInsets.zero,
            onChanged: (bool? checked) {
              setState(() {
                if (checked == true) {
                  _selected.add(index);
                } else {
                  _selected.remove(index);
                }
              });
              widget.onChanged?.call(_selected.toList()..sort());
            },
          ),
        );
      },
    );
  }
}
