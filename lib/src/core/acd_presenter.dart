// The constructor below intentionally exposes friendly public parameter
// names (context, child, gravity, ...) that don't match the private,
// underscore-prefixed backing fields they populate — initializing formals
// (this._context) would force the public parameter name itself to carry
// the underscore, which isn't a good public API.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter/material.dart';

import 'acd_gravity.dart';

// ── ACD (internal presenter) ─────────────────────────────────────────────────

/// Internal `showGeneralDialog` presenter used by `ACDDialog.show()` for
/// its (non-overlay-mode) presentation path. Not normally constructed
/// directly — use [ACDDialog] instead.
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
  final TextDirection _textDirection;

  /// Builds and immediately shows a `showGeneralDialog`-based dialog.
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
    TextDirection textDirection = TextDirection.ltr,
  }) : _child = child,
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
       _onBarrierTap = onBarrierTap,
       _textDirection = textDirection {
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
      pageBuilder: (BuildContext buildContext, _, _) {
        // FEAT-12: overlay a full-screen tap detector when onBarrierTap is set
        if (_onBarrierTap != null) {
          return Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _onBarrierTap();
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
      return _animatedFunc(child, animation);
    }

    // No gravity animation requested
    if (!_gravityAnimationEnable) return child;

    final ACDGravity? resolvedGravity = _gravity == null
        ? null
        : acdResolveGravityForDirection(_gravity, _textDirection);

    Offset begin;
    switch (resolvedGravity) {
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
