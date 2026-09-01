import 'package:flutter/material.dart';

/// An optional root-level wrapper that gives toasts a dedicated `Overlay`
/// independent of the app's own navigation stack. Install it once via
/// `MaterialApp(builder: (context, child) => ACDToastLayer(child: child!))`.
///
/// Without this, toasts fall back to `Overlay.maybeOf(context, rootOverlay:
/// ...)` — the app's own root overlay — which works for most apps but can
/// fail from certain contexts (nested navigators, some state-management
/// context wrappers) and is subject to Flutter's `Overlay.of`
/// `LookupBoundary` enforcement changing across SDK versions. [ACDToastLayer]
/// sidesteps both: its `OverlayState` is exposed through a plain
/// `InheritedWidget` lookup, which `LookupBoundary` changes don't affect.
class ACDToastLayer extends StatefulWidget {
  /// Creates an [ACDToastLayer] wrapping [child].
  const ACDToastLayer({super.key, required this.child});

  /// The rest of the app.
  final Widget child;

  /// Returns the nearest [ACDToastLayer]'s `OverlayState`, or `null` if none
  /// is installed above [context].
  static OverlayState? maybeOf(BuildContext context) {
    final _ACDToastLayerScope? scope = context
        .dependOnInheritedWidgetOfExactType<_ACDToastLayerScope>();
    return scope?.overlayKey.currentState;
  }

  @override
  State<ACDToastLayer> createState() => _ACDToastLayerState();
}

class _ACDToastLayerState extends State<ACDToastLayer> {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();

  @override
  Widget build(BuildContext context) {
    return _ACDToastLayerScope(
      overlayKey: _overlayKey,
      child: Overlay(
        key: _overlayKey,
        initialEntries: [OverlayEntry(builder: (_) => widget.child)],
      ),
    );
  }
}

class _ACDToastLayerScope extends InheritedWidget {
  const _ACDToastLayerScope({required this.overlayKey, required super.child});

  final GlobalKey<OverlayState> overlayKey;

  @override
  bool updateShouldNotify(_ACDToastLayerScope oldWidget) =>
      overlayKey != oldWidget.overlayKey;
}
