import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'acd_dialog.dart';

// ── ACDDialogQueue ────────────────────────────────────────────────────────────
// FEAT-13: show dialogs one after another without overlapping

/// Shows a series of [ACDDialog]s (including toasts) one after another,
/// without overlapping — each one shows only after the previous is
/// dismissed.
///
/// The queue waits on each showing via [ACDDialog.showAndWait], so it never
/// touches a dialog's own `dismissCallBack`, and it keeps going if a dialog
/// can't be shown (no context, unmounted context, no Navigator) or throws.
class ACDDialogQueue {
  ACDDialogQueue._();

  static final List<ACDDialog> _queue = [];
  static ACDDialog? _current;

  /// Whether a queued dialog is currently showing.
  static bool get isShowing => _current != null;

  /// How many dialogs are waiting behind the one currently showing.
  static int get pendingCount => _queue.length;

  /// Adds [dialog] to the queue. If nothing is currently showing, it (or
  /// whatever's ahead of it) starts showing immediately.
  static void enqueue(ACDDialog dialog) {
    _queue.add(dialog);
    if (_current == null) _next();
  }

  /// Removes [dialog] from the waiting queue, if it's still waiting.
  /// Returns whether it was removed. Does not dismiss a dialog that's
  /// already showing — call `dialog.dismiss()` for that.
  static bool remove(ACDDialog dialog) => _queue.remove(dialog);

  /// Removes every dialog still waiting in the queue. Does not dismiss a
  /// dialog that's already showing; the queue simply stops after it.
  static void clearQueue() => _queue.clear();

  /// Drops every waiting dialog and forgets the showing one, without
  /// dismissing anything. For tests: call it in `tearDown` so one test's
  /// queue can't leak into the next.
  @visibleForTesting
  static void reset() {
    _queue.clear();
    _current = null;
  }

  static void _next() {
    while (_queue.isNotEmpty) {
      final ACDDialog dialog = _queue.removeAt(0);
      _current = dialog;
      final Future<void> ended;
      try {
        ended = dialog.showAndWait();
      } catch (error, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'awesome_custom_dialog',
            context: ErrorDescription('while showing a queued ACDDialog'),
          ),
        );
        continue; // skip it; never stall the queue
      }
      // Completes asynchronously (after the route/entry is fully gone), so
      // the next show never runs while the navigator is locked.
      ended.whenComplete(() {
        if (!identical(_current, dialog)) return; // reset() in between
        _current = null;
        _next();
      });
      return;
    }
    _current = null;
  }
}
