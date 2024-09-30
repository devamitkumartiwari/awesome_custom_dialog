import 'package:flutter/material.dart';
import 'awesome_custom_dialog_widget.dart';



class ACDDialog {

  ///
  /// Dialog properties
  ///
  // All widget inside dialog
  List<Widget> widgetList = [];
  // Dialog context
  static BuildContext? _context;
  // Dialog context build context
  BuildContext? context;

  // Dialog width
  double? width;
  // Dialog height
  double? height;
  // Animation duration on dialog show and hide
  Duration duration = const Duration(milliseconds: 250);
  // Dialog show location
  ACDGravity gravity = ACDGravity.center;
  // Default animation at location where dialog visible
  bool gravityAnimationEnable = false;
  // Dialog background color in outer space
  Color barrierColor = Colors.black.withOpacity(.3);
  // Dialog constraints using box constraints
  BoxConstraints? constraints;
  // Dialog window animation
  Function(Widget child, Animation<double> animation)? animatedFunc;
  // Closing dialogs
  bool barrierDismissible = true;
  // Dialog margim
  EdgeInsets margin = const EdgeInsets.all(0.0);
  // For nested navigators (=>true (Push uses the context of the current layout) =>false (Push uses the context of a nested root layout))
  bool useRootNavigator = true;
  // Dialog decoration
  Decoration? decoration;
  // Dialog back ground color
  Color backgroundColor = Colors.white;
  // Dialog corner radius
  double borderRadius = 0.0;
  // Display callback
  Function()? showCallBack;
  // Disappearing callbacks
  Function()? dismissCallBack;
  // checking for current dialog visibility
  get isShowing => _isShowing;
  bool _isShowing = false;
  ///
  ///
  ///
  ///



  static void init(BuildContext ctx) {
    _context = ctx;
  }

  ACDDialog build([BuildContext? ctx]) {
    if (ctx == null && _context != null) {
      context = _context;
      return this;
    }
    context = ctx;
    return this;
  }

  ACDDialog widget(Widget child) {
    widgetList.add(child);
    return this;
  }

  ACDDialog text(
      {padding,
        text,
        color,
        fontSize,
        alignment,
        textAlign,
        maxLines,
        textDirection,
        overflow,
        fontWeight,
        fontFamily}) {
    return widget(
      Padding(
        padding: padding ?? const EdgeInsets.all(0.0),
        child: Align(
          alignment: alignment ?? Alignment.centerLeft,
          child: Text(
            text ?? "",
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

  ACDDialog twoButton({
    padding,
    gravity,
    height,
    isClickAutoDismiss = true,
    withDivider = false,
    text1,
    color1,
    fontSize1,
    fontWeight1,
    fontFamily1,
    VoidCallback? onTap1,
    buttonPadding1 = const EdgeInsets.all(0.0),
    text2,
    color2,
    fontSize2,
    fontWeight2,
    fontFamily2,
    onTap2,
    buttonPadding2 = const EdgeInsets.all(0.0),
  }) {
    return widget(
      SizedBox(
        height: height ?? 45.0,
        child: Row(
          mainAxisAlignment: getRowMainAxisAlignment(gravity),
          children: <Widget>[
            TextButton(
              onPressed: () {
                if (onTap1 != null) onTap1();
                if (isClickAutoDismiss) {
                  dismiss();
                }
              },
              style: TextButton.styleFrom(
                  foregroundColor: color1 ?? Colors.black,
                  padding: buttonPadding1,
                  textStyle: TextStyle(
                    fontSize: fontSize1 ?? 18.0,
                    fontWeight: fontWeight1,
                    fontFamily: fontFamily1,
                  )),
              child: Text(
                text1 ?? "",
              ),
            ),
            Visibility(
              visible: withDivider,
              child: const VerticalDivider(),
            ),
            TextButton(
              onPressed: () {
                if (onTap2 != null) onTap2();
                if (isClickAutoDismiss) {
                  dismiss();
                }
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
              child: Text(
                text2 ?? "",
              ),
            )
          ],
        ),
      ),
    );
  }

  ACDDialog listOfACDListTile({
    List<ACDListTileItem>? items,
    double? height,
    isClickAutoDismiss = true,
    Function(int)? onClickItemListener,
  }) {
    return widget(
      SizedBox(
        height: height,
        child: ListView.builder(
          padding: const EdgeInsets.all(0.0),
          shrinkWrap: true,
          itemCount: items?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            return Material(
              color: Colors.white,
              child: InkWell(
                child: ListTile(
                  onTap: () {
                    if (onClickItemListener != null) {
                      onClickItemListener(index);
                    }
                    if (isClickAutoDismiss) {
                      dismiss();
                    }
                  },
                  contentPadding: items?[index].padding ?? const EdgeInsets.all(0.0),
                  leading: items?[index].leading,
                  title: Text(
                    items?[index].text ?? "",
                    style: TextStyle(
                      color: items?[index].color,
                      fontSize: items?[index].fontSize,
                      fontWeight: items?[index].fontWeight,
                      fontFamily: items?[index].fontFamily,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  ACDDialog listOfACDRadioButton({
    List<ACDRadioItem>? items,
    double? height,
    Color? color,
    Color? activeColor,
    int? initialValue,
    Function(int)? onClickItemListener,
  }) {
    Size size = MediaQuery.of(context!).size;
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
          onChanged: onClickItemListener,
        ),
      ),
    );
  }

  ACDDialog acdProgress(
      {padding, backgroundColor, valueColor, strokeWidth}) {
    return widget(Padding(
      padding: padding,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth ?? 4.0,
        backgroundColor: backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(valueColor),
      ),
    ));
  }

  ACDDialog acdDivider({color, height}) {
    return widget(
      Divider(
        color: color ?? Colors.grey[300],
        height: height ?? 0.1,
      ),
    );
  }

  // x co-ordinate
  // y co-ordinate
  void show([x, y]) {
    var mainAxisAlignment = getColumnMainAxisAlignment(gravity);
    var crossAxisAlignment = getColumnCrossAxisAlignment(gravity);
    if (x != null && y != null) {
      gravity = ACDGravity.leftTop;
      margin = EdgeInsets.only(left: x, top: y);
    }
    ACD(
      gravity: gravity,
      gravityAnimationEnable: gravityAnimationEnable,
      context: context!,
      barrierColor: barrierColor,
      animatedFunc: animatedFunc,
      barrierDismissible: barrierDismissible,
      duration: duration,
      child: Padding(
        padding: margin,
        child: Column(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: <Widget>[
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
                      color: backgroundColor,
                    ),
                constraints: constraints ?? const BoxConstraints(),
                child: ACDChildren(
                  widgetList: widgetList,
                  isShowingChange: (bool isShowingChange) {
                    if (isShowingChange) {
                      showCallBack?.call();
                    } else {
                      dismissCallBack?.call();
                    }
                    _isShowing = isShowingChange;
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void dismiss() {
    if (_isShowing) {
      Navigator.of(context!, rootNavigator: useRootNavigator).pop();
    }
  }

  getColumnMainAxisAlignment(acdGravity) {
    var mainAxisAlignment = MainAxisAlignment.start;
    switch (acdGravity) {
      case ACDGravity.bottom:
      case ACDGravity.leftBottom:
      case ACDGravity.rightBottom:
        mainAxisAlignment = MainAxisAlignment.end;
        break;
      case ACDGravity.top:
      case ACDGravity.leftTop:
      case ACDGravity.rightTop:
        mainAxisAlignment = MainAxisAlignment.start;
        break;
      case ACDGravity.left:
        mainAxisAlignment = MainAxisAlignment.center;
        break;
      case ACDGravity.right:
        mainAxisAlignment = MainAxisAlignment.center;
        break;
      case ACDGravity.center:
      default:
        mainAxisAlignment = MainAxisAlignment.center;
        break;
    }
    return mainAxisAlignment;
  }

  getColumnCrossAxisAlignment(acdGravity) {
    var crossAxisAlignment = CrossAxisAlignment.center;
    switch (acdGravity) {
      case ACDGravity.bottom:
        break;
      case ACDGravity.top:
        break;
      case ACDGravity.left:
      case ACDGravity.leftTop:
      case ACDGravity.leftBottom:
        crossAxisAlignment = CrossAxisAlignment.start;
        break;
      case ACDGravity.right:
      case ACDGravity.rightTop:
      case ACDGravity.rightBottom:
        crossAxisAlignment = CrossAxisAlignment.end;
        break;
      default:
        break;
    }
    return crossAxisAlignment;
  }

  getRowMainAxisAlignment(acdGravity) {
    var mainAxisAlignment = MainAxisAlignment.start;
    switch (acdGravity) {
      case ACDGravity.bottom:
        break;
      case ACDGravity.top:
        break;
      case ACDGravity.left:
        mainAxisAlignment = MainAxisAlignment.start;
        break;
      case ACDGravity.right:
        mainAxisAlignment = MainAxisAlignment.end;
        break;
      case ACDGravity.spaceEvenly:
        mainAxisAlignment = MainAxisAlignment.spaceEvenly;
        break;
      case ACDGravity.center:
      default:
        mainAxisAlignment = MainAxisAlignment.center;
        break;
    }
    return mainAxisAlignment;
  }
}

//Dialog as inline
class ACDChildren extends StatefulWidget {
  final List<Widget> widgetList;
  final Function(bool)? isShowingChange;

  const ACDChildren({super.key, this.widgetList = const [], this.isShowingChange});

  @override
  CustomDialogChildState createState() => CustomDialogChildState();
}

class CustomDialogChildState extends State<ACDChildren> {
  @override
  Widget build(BuildContext context) {
    if (widget.isShowingChange != null) {
      widget.isShowingChange!(true);
    }
    return Column(
      children: widget.widgetList,
    );
  }

  @override
  void dispose() {
    if (widget.isShowingChange != null) {
      widget.isShowingChange!(false);
    }
    super.dispose();
  }
}


class ACD {
  final BuildContext _context;
  final Widget _child;
  final Duration? _duration;
  Color? _barrierColor;
  final RouteTransitionsBuilder? _transitionsBuilder;
  final bool? _barrierDismissible;
  final ACDGravity? _gravity;
  final bool _gravityAnimationEnable;
  final Function? _animatedFunc;

  ACD({
    required Widget child,
    required BuildContext context,
    Duration? duration,
    Color? barrierColor,
    RouteTransitionsBuilder? transitionsBuilder,
    ACDGravity? gravity,
    bool gravityAnimationEnable = false,
    Function? animatedFunc,
    bool? barrierDismissible,
  })  : _child = child,
        _context = context,
        _gravity = gravity,
        _gravityAnimationEnable = gravityAnimationEnable,
        _duration = duration,
        _barrierColor = barrierColor,
        _animatedFunc = animatedFunc,
        _transitionsBuilder = transitionsBuilder,
        _barrierDismissible = barrierDismissible {
    show();
  }

  show() {
    if (_barrierColor == Colors.transparent) {
      _barrierColor = Colors.white.withOpacity(0.0);
    }

    showGeneralDialog(
      context: _context,
      barrierColor: _barrierColor ?? Colors.black.withOpacity(.3),
      barrierDismissible: _barrierDismissible ?? true,
      barrierLabel: "",
      transitionDuration: _duration ?? const Duration(milliseconds: 250),
      transitionBuilder: _transitionsBuilder ?? _buildMaterialDialogTransitions,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Builder(
          builder: (BuildContext context) {
            return _child;
          },
        );
      },
    );
  }

  Widget _buildMaterialDialogTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    Animation<Offset> custom;
    switch (_gravity) {
      case ACDGravity.top:
      case ACDGravity.leftTop:
      case ACDGravity.rightTop:
        custom = Tween<Offset>(
          begin: const Offset(0.0, -1.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation);
        break;
      case ACDGravity.left:
        custom = Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation);
        break;
      case ACDGravity.right:
        custom = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation);
        break;
      case ACDGravity.bottom:
      case ACDGravity.leftBottom:
      case ACDGravity.rightBottom:
        custom = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation);
        break;
      case ACDGravity.center:
      default:
        custom = Tween<Offset>(
          begin: const Offset(0.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation);
        break;
    }

    /// Custom animation
    if (_animatedFunc != null) {
      return _animatedFunc(child, animation);
    }

    /// No default animation required
    if (!_gravityAnimationEnable) {
      custom = Tween<Offset>(
        begin: const Offset(0.0, 0.0),
        end: const Offset(0.0, 0.0),
      ).animate(animation);
    }

    return SlideTransition(
      position: custom,
      child: child,
    );
  }
}

/// Dialog gravity
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
///
///
///
/// Dialog entity
class ACDListTileItem {
  ACDListTileItem({
    this.padding,
    this.leading,
    this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
  });

  EdgeInsets? padding;
  Widget? leading;
  String? text;
  Color? color;
  double? fontSize;
  FontWeight? fontWeight;
  String? fontFamily;
}

class ACDRadioItem {
  ACDRadioItem({
    this.padding,
    this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.onTap,
  });

  EdgeInsets? padding;
  String? text;
  Color? color;
  double? fontSize;
  FontWeight? fontWeight;
  Function(int)? onTap;
}
