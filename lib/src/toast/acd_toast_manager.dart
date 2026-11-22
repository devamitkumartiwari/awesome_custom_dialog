import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../core/acd_gravity.dart';
import 'acd_toast_config.dart';
import 'acd_toast_controller.dart';
import 'acd_toast_dismiss_reason.dart';
import 'acd_toast_layer.dart';
import 'acd_toast_lifecycle.dart';
import 'acd_toast_stack.dart';

/// Static registry that stacks, resolves overlays for, and manages every
/// active toast. `ACDDialog.toast()` delegates to [show]; use the other
/// static methods for management beyond a single call site (dismiss by id,
/// dismiss all, introspection, global defaults).
class ACDToastManager {
  ACDToastManager._();

  // Stacks are keyed by overlay *and* position: a toast shown under a
  // different Overlay (an ACDToastLayer, a nested Navigator, a new test
  // app) gets its own stack there instead of joining one that overlay
  // doesn't draw.
  static final Map<_StackKey, ValueNotifier<List<ACDToastController>>> _stacks =
      {};
  static final Map<_StackKey, OverlayEntry> _entries = {};
  static final Map<String, ACDToastController> _byId = {};
  static int _counter = 0;
  static ACDToastController? _lastShown;
  static _ACDToastLifecycleObserver? _observer;

  /// Global default configuration, layered under every per-call config and
  /// over [ACDToastConfig.fallback]. `null` (the default) means only
  /// [ACDToastConfig.fallback] applies.
  static ACDToastConfig? defaults;

  /// Sets [defaults].
  static void setDefaults(ACDToastConfig config) => defaults = config;

  /// Clears [defaults], reverting to [ACDToastConfig.fallback] alone.
  static void clearDefaults() => defaults = null;

  /// Resolves [perCall] against [defaults] and [ACDToastConfig.fallback],
  /// applies `cancelPrevious`/`dedupeById`, resolves an overlay (via
  /// [ACDToastLayer] first, then `Overlay.maybeOf`), and registers the
  /// resulting [ACDToastController] with its position's stack — lazily
  /// creating that stack's `OverlayEntry` if this is the first toast there.
  static ACDToastController show(BuildContext context, ACDToastConfig perCall) {
    final ACDToastConfig config = ACDToastConfig.resolve(
      ACDToastConfig.resolve(ACDToastConfig.fallback, defaults),
      perCall,
    );
    final ACDGravity position = config.gravity ?? ACDGravity.bottom;
    final String id = config.id ?? _nextId();

    final ACDToastController? existing = _byId[id];
    if ((config.dedupeById ?? false) &&
        existing != null &&
        !existing.isDismissing) {
      // The caller's dismiss wiring (ACDDialog's onDismissed → queue,
      // showForResult, dismissCallBack) must still run when the toast it
      // was deduplicated into closes.
      final VoidCallback? onDismissed = config.onDismissed;
      if (onDismissed != null) {
        unawaited(existing.closed.then((_) => onDismissed()));
      }
      return existing;
    }

    if ((config.cancelPrevious ?? true) &&
        _lastShown != null &&
        !_lastShown!.isDismissing) {
      _lastShown!.requestDismiss(
        immediate: true,
        reason: ACDToastDismissReason.replaced,
      );
    }

    final OverlayState? overlay = _resolveOverlay(context, config);
    if (overlay == null) {
      throw FlutterError(
        'ACDDialog.toast()/.snackbar() could not find an Overlay.\n'
        'Wrap your MaterialApp with `builder: (context, child) => '
        'ACDToastLayer(child: child!)`, or ensure the context passed to '
        '.toast()/.build() sits under a Navigator/MaterialApp.',
      );
    }

    final ACDToastController controller = ACDToastController(
      id: id,
      config: config,
    );
    _byId[id] = controller;
    _lastShown = controller;
    _observer ??= _ACDToastLifecycleObserver()..attach();

    final _StackKey key = (overlay, position);
    controller.onChanged = () => _onControllerChanged(key, controller);

    void addToList() {
      if (controller.isDismissing) return; // dismissed during its showDelay
      if (!overlay.mounted) {
        // The overlay went away during showDelay: nothing can show this.
        controller.dispose();
        return;
      }
      // Resolved now, not when show() ran: during a showDelay the stack
      // that existed then may have emptied and been disposed.
      final ValueNotifier<List<ACDToastController>> list = _stacks.putIfAbsent(
        key,
        () => ValueNotifier<List<ACDToastController>>(<ACDToastController>[]),
      );
      list.value = List.of(list.value)..add(controller);
      _entries.putIfAbsent(key, () {
        final OverlayEntry entry = OverlayEntry(
          builder: (_) => ACDToastStack(position: position, listenable: list),
        );
        overlay.insert(entry);
        return entry;
      });
    }

    final Duration delay = config.showDelay ?? Duration.zero;
    if (delay == Duration.zero) {
      addToList();
    } else {
      Timer(delay, addToList);
    }

    return controller;
  }

  static void _onControllerChanged(
    _StackKey key,
    ACDToastController controller,
  ) {
    final bool disposed = controller.state is ACDToastDisposed;
    // Only unregister the id if it still points at *this* toast — a newer
    // toast may have reused the id while this one was exiting.
    if (disposed && identical(_byId[controller.id], controller)) {
      _byId.remove(controller.id);
    }
    if (disposed && identical(_lastShown, controller)) _lastShown = null;
    final ValueNotifier<List<ACDToastController>>? list = _stacks[key];
    if (list == null) {
      // Disposed before ever joining a stack (e.g. during its showDelay).
      if (disposed && _byId.isEmpty) {
        _observer?.detach();
        _observer = null;
      }
      return;
    }
    if (disposed) {
      list.value = list.value.where((c) => c != controller).toList();
      if (list.value.isEmpty) {
        final OverlayEntry? entry = _entries.remove(key);
        // Remove even if the entry hasn't built yet (shown and dismissed in
        // the same frame) — but never touch an overlay that's gone.
        if (entry != null && key.$1.mounted) entry.remove();
        _stacks.remove(key)?.dispose();
      }
      if (_byId.isEmpty) {
        _observer?.detach();
        _observer = null;
      }
    } else {
      list.value = List.of(list.value);
    }
  }

  static OverlayState? _resolveOverlay(
    BuildContext context,
    ACDToastConfig config,
  ) {
    final OverlayState? layer = ACDToastLayer.maybeOf(context);
    if (layer != null) return layer;
    return Overlay.maybeOf(
      context,
      rootOverlay: config.useRootNavigator ?? true,
    );
  }

  static String _nextId() => 'acd_toast_${_counter++}';

  /// Tears down every toast immediately and resets all static state
  /// ([defaults], ids, stacks). For tests: call it in `tearDown` so a
  /// toast from one test can't leak into the next.
  @visibleForTesting
  static void resetForTest() {
    for (final ACDToastController c in _byId.values.toList()) {
      c.dispose();
    }
    for (final MapEntry<_StackKey, OverlayEntry> e in _entries.entries) {
      if (e.key.$1.mounted) e.value.remove();
    }
    _entries.clear();
    for (final ValueNotifier<List<ACDToastController>> n in _stacks.values) {
      n.dispose();
    }
    _stacks.clear();
    _byId.clear();
    _lastShown = null;
    _observer?.detach();
    _observer = null;
    _counter = 0;
    defaults = null;
  }

  /// Dismisses every toast, optionally scoped to [position] — including
  /// ones still waiting on a `showDelay` or queued behind `maxVisible`
  /// (both are tracked in the registry from the moment [show] is called,
  /// not only once actually inserted into the overlay).
  static void dismissAll({ACDGravity? position}) {
    for (final ACDToastController controller in _byId.values.toList()) {
      if (position == null || controller.config.gravity == position) {
        controller.requestDismiss(immediate: true);
      }
    }
  }

  /// Dismisses the toast with [id], if one is active.
  static void dismissById(String id) => _byId[id]?.requestDismiss();

  /// Dismisses the oldest active toast at [position] (or, if omitted, the
  /// oldest at every position).
  static void dismissFirst({ACDGravity? position}) =>
      _dismissEnd(position, first: true);

  /// Dismisses the newest active toast at [position] (or, if omitted, the
  /// newest at every position).
  static void dismissLast({ACDGravity? position}) =>
      _dismissEnd(position, first: false);

  static void _dismissEnd(ACDGravity? position, {required bool first}) {
    for (final MapEntry<_StackKey, ValueNotifier<List<ACDToastController>>>
        stack
        in _stacks.entries.toList()) {
      if (position != null && stack.key.$2 != position) continue;
      final List<ACDToastController> list = stack.value.value;
      final Iterable<ACDToastController> candidates =
          (first ? list : list.reversed).where((c) => !c.isDismissing);
      if (candidates.isNotEmpty) candidates.first.requestDismiss();
    }
  }

  /// Finds the active toast with [id], or `null` if none is active.
  static ACDToastController? findById(String id) => _byId[id];

  /// Every currently-active toast (queued, inserted, or showing), optionally
  /// scoped to [position].
  static List<ACDToastController> activeToasts({ACDGravity? position}) => _byId
      .values
      .where((c) => position == null || c.config.gravity == position)
      .toList(growable: false);

  /// How many toasts are currently active, optionally scoped to [position].
  static int activeCount({ACDGravity? position}) =>
      activeToasts(position: position).length;
}

/// One stack per (overlay, position).
typedef _StackKey = (OverlayState, ACDGravity);

/// Pauses/resumes every active toast's auto-dismiss timer when the app
/// leaves/returns to the foreground, so a backgrounded app doesn't silently
/// burn through toast durations while nothing is visible.
class _ACDToastLifecycleObserver with WidgetsBindingObserver {
  void attach() => WidgetsBinding.instance.addObserver(this);

  void detach() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final Iterable<ACDToastController> all = ACDToastManager._byId.values;
    if (state == AppLifecycleState.resumed) {
      for (final ACDToastController c in all) {
        c.resume();
      }
    } else {
      for (final ACDToastController c in all) {
        c.pause();
      }
    }
  }
}
