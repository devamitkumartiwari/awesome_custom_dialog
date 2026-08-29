import 'package:flutter/material.dart';

import 'acd_dialog.dart';

// ── ACDDialogQueue ────────────────────────────────────────────────────────────
// FEAT-13: show dialogs one after another without overlapping

/// Shows a series of [ACDDialog]s (including toasts) one after another,
/// without overlapping — each one shows only after the previous is
/// dismissed.
class ACDDialogQueue {
  ACDDialogQueue._();

  static final List<ACDDialog> _queue = [];
  static bool _active = false;

  /// Adds [dialog] to the queue. If nothing is currently showing, it (or
  /// whatever's ahead of it) starts showing immediately.
  static void enqueue(ACDDialog dialog) {
    _queue.add(dialog);
    if (!_active) _next();
  }

  /// Removes every dialog still waiting in the queue. Does not dismiss a
  /// dialog that's already showing.
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
