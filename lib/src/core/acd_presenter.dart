// The constructor below intentionally exposes friendly public parameter
// names (context, child, gravity, ...) that don't match the private,
// underscore-prefixed backing fields they populate — initializing formals
// (this._context) would force the public parameter name itself to carry
// the underscore, which isn't a good public API.
// ignore_for_file: prefer_initializing_formals

import 'package:material_ui/material_ui.dart';

import '../design/internal/acd_platform_support.dart';
import 'acd_gravity.dart';
import 'acd_predictive_back.dart';

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

  // Cupertino design: default to the iOS alert entrance (scale 1.1→1.0 +
  // fade) when no other animation applies.
  final bool _cupertinoTransition;

  // Pop control (Android predictive back / system back).
  final bool _canPop;
  final PopInvokedWithResultCallback<Object?>? _onPopInvoked;

  // The iOS entrance curve, created once per route (a CurvedAnimation made
  // inside the transition builder would leak a listener every rebuild).
  CurvedAnimation? _cupertinoCurve;

  /// The route this presenter pushed — kept so the owning dialog can remove
  /// exactly *its own* route on dismiss, rather than popping whatever
  /// happens to be on top of the navigator.
  late final RawDialogRoute<void> route;

  /// Builds and immediately shows a `showGeneralDialog`-style dialog.
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
    bool cupertinoTransition = false,
    bool canPop = true,
    PopInvokedWithResultCallback<Object?>? onPopInvoked,
  }) : _cupertinoTransition = cupertinoTransition,
       _canPop = canPop,
       _onPopInvoked = onPopInvoked,
       _child = child,
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

    // Equivalent to showGeneralDialog (which pushes this same route type),
    // but keeps a reference to the route — see [route].
    final NavigatorState navigator = Navigator.of(
      _context,
      rootNavigator: _useRootNavigator, // BUG-03 fix
    );
    route = RawDialogRoute<void>(
      barrierColor: _barrierColor,
      barrierDismissible: _barrierDismissible,
      barrierLabel: _barrierLabel,
      transitionDuration: _duration,
      transitionBuilder: _buildTransition,
      pageBuilder: (BuildContext buildContext, _, _) {
        // Keep the dialog clear of the on-screen keyboard (e.g. a dialog
        // with acdTextField), and name the route for screen readers.
        Widget content = Semantics(
          namesRoute: true,
          label: _barrierLabel,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(buildContext).bottom,
            ),
            // Android predictive back: shrink/nudge while swiping (Material
            // design only — iOS has no back gesture for alerts).
            child: ACDPredictiveBackDialog(
              enabled: !_cupertinoTransition,
              child: _child,
            ),
          ),
        );
        if (!_canPop || _onPopInvoked != null) {
          content = PopScope<Object?>(
            canPop: _canPop,
            onPopInvokedWithResult: _onPopInvoked,
            child: content,
          );
        }
        // FEAT-12: overlay a full-screen tap detector when onBarrierTap is set
        if (_onBarrierTap != null) {
          return Stack(
            children: [
              Semantics(
                button: true,
                label: _barrierLabel,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _onBarrierTap();
                    // maybePop (not pop) so a PopScope veto — canPop: false
                    // / onPopInvoked — is respected, like a system back.
                    if (route.isCurrent) {
                      route.navigator?.maybePop();
                    } else {
                      close();
                    }
                  },
                  child: const SizedBox.expand(),
                ),
              ),
              content,
            ],
          );
        }
        return content;
      },
    );
    navigator.push(route);
    // After the exit transition (not at pop time, which is mid-exit).
    route.completed.whenComplete(() {
      _cupertinoCurve?.dispose();
      _cupertinoCurve = null;
    });
  }

  /// Removes [route] if it's still on the navigator — popping it when it's
  /// the top route (so its exit transition plays), or removing it in place
  /// when something else has since been pushed above it.
  void close() {
    if (!route.isActive) return;
    if (route.isCurrent) {
      route.navigator?.pop();
    } else {
      route.navigator?.removeRoute(route);
    }
  }

  Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Custom animation wins
    if (_animatedFunc != null) {
      return _animatedFunc(child, animation) as Widget;
    }

    // Reduce motion: no movement — a plain cross-fade.
    if (acdReduceMotion(context)) {
      return FadeTransition(opacity: animation, child: child);
    }

    // No gravity animation requested
    if (!_gravityAnimationEnable) {
      if (!_cupertinoTransition) return child;
      final Animation<double> curved = _cupertinoCurve ??= CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: animation.status == AnimationStatus.reverse
            ? child
            : ScaleTransition(
                scale: Tween<double>(begin: 1.1, end: 1.0).animate(curved),
                child: child,
              ),
      );
    }

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
