import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/acd_design_scope.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../toast/toast.dart';
import 'acd_content_type.dart';
import 'acd_dialog.dart';
import 'acd_dialog_text.dart';
import 'acd_dialog_widgets.dart';
import 'acd_gravity.dart';

/// Thrown into the future returned by `ACDDialog.loading` when the user
/// taps its Cancel button. The work itself keeps running — Dart futures
/// can't be cancelled — but the caller stops waiting for it.
class ACDLoadingCanceled implements Exception {
  /// Creates an [ACDLoadingCanceled].
  const ACDLoadingCanceled();

  @override
  String toString() => 'ACDLoadingCanceled: the user canceled the operation';
}

/// Shows a blocking progress dialog while [future] runs.
/// See `ACDDialog.loading`.
Future<T> acdShowLoading<T>({
  required BuildContext context,
  required Future<T> future,
  String? message,
  ACDDesign? design,
  Duration showAfter = Duration.zero,
  Duration minDisplay = const Duration(milliseconds: 500),
  bool cancelable = false,
  String? cancelLabel,
}) async {
  final Completer<T> outcome = Completer<T>();
  // Settle the outcome from the work, whatever happens to the dialog.
  future.then(
    (T value) {
      if (!outcome.isCompleted) outcome.complete(value);
    },
    onError: (Object error, StackTrace stack) {
      if (!outcome.isCompleted) outcome.completeError(error, stack);
    },
  );

  // Fast work never flashes a dialog: wait `showAfter` first.
  if (showAfter > Duration.zero) {
    // A cancellable timer (not Future.delayed): when the work wins the race
    // nothing is left pending.
    final Completer<void> gate = Completer<void>();
    final Timer timer = Timer(showAfter, () {
      if (!gate.isCompleted) gate.complete();
    });
    outcome.future.then((_) {}, onError: (Object _) {}).whenComplete(() {
      timer.cancel();
      if (!gate.isCompleted) gate.complete();
    });
    await gate.future;
    if (outcome.isCompleted) return outcome.future;
  }
  if (!context.mounted) return outcome.future;

  final ACDDialog dialog = ACDDialog(design: design).build(context)
    ..barrierDismissible = false
    ..canPop = false
    ..barrierLabel = message ?? 'Dialog'
    ..acdProgress(padding: const EdgeInsets.fromLTRB(24, 24, 24, 12));
  if (message != null) {
    dialog.text(
      text: message,
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
      alignment: Alignment.center,
      textAlign: TextAlign.center,
    );
  }
  if (cancelable) {
    dialog.widget(
      Builder(
        builder: (BuildContext ctx) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ACDAdaptiveTappable(
            design: ACDDesign.resolve(ctx, design),
            onTap: () {
              if (!outcome.isCompleted) {
                outcome.completeError(const ACDLoadingCanceled());
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                cancelLabel ?? ACDDesignScope.stringsOf(ctx).cancel,
                style: TextStyle(color: Theme.of(ctx).colorScheme.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  final Stopwatch shown = Stopwatch()..start();
  dialog.show();
  try {
    return await outcome.future;
  } finally {
    // Avoid a sub-frame flash: keep it up at least `minDisplay`.
    final Duration left = minDisplay - shown.elapsed;
    if (left > Duration.zero) await Future<void>.delayed(left);
    await dialog.dismiss();
  }
}

/// A toast that shows [loading] while [future] runs, then turns into a
/// success or error toast in place. See `ACDDialog.promiseToast`.
Future<T> acdPromiseToast<T>({
  required BuildContext context,
  required Future<T> future,
  required String loading,
  required String Function(T value) success,
  required String Function(Object error) error,
  ACDGravity? gravity,
  Duration resultDuration = const Duration(seconds: 3),
  ACDDesign? design,
}) async {
  final ACDToastController toast = ACDToastManager.show(
    context,
    ACDToastConfig(
      message: loading,
      gravity: gravity,
      design: design,
      autoDismissAfter: Duration.zero, // sticky while working
      showLoadingIndicator: true,
      cancelPrevious: false,
    ),
  );
  try {
    final T value = await future;
    toast.update(
      message: success(value),
      contentType: ACDContentType.success,
      showLoadingIndicator: false,
      autoDismissAfter: resultDuration,
    );
    return value;
  } catch (e) {
    toast.update(
      message: error(e),
      contentType: ACDContentType.failure,
      showLoadingIndicator: false,
      autoDismissAfter: resultDuration,
    );
    rethrow;
  }
}

/// A toast with an Undo action; completes with whether it was undone.
/// See `ACDDialog.undoToast`.
Future<bool> acdUndoToast({
  required BuildContext context,
  required String message,
  String? undoLabel,
  VoidCallback? onUndo,
  Duration duration = const Duration(seconds: 5),
  ACDGravity? gravity,
  bool showProgressBar = true,
  ACDDesign? design,
}) async {
  bool undone = false;
  late final ACDToastController toast;
  toast = ACDToastManager.show(
    context,
    ACDToastConfig(
      message: message,
      gravity: gravity,
      design: design,
      autoDismissAfter: duration,
      showProgressBar: showProgressBar,
      cancelPrevious: false,
      actions: [
        Builder(
          builder: (BuildContext ctx) => ACDAdaptiveTappable(
            design: ACDDesign.resolve(ctx, design),
            onTap: () {
              if (undone || toast.isDismissing) return;
              undone = true;
              onUndo?.call();
              toast.requestDismiss(reason: ACDToastDismissReason.user);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                undoLabel ?? ACDDesignScope.stringsOf(ctx).undo,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    ),
  );
  await toast.closed;
  return undone;
}
