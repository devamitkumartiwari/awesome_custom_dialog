import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/showcase_widgets.dart';

class ToastScreen extends StatelessWidget {
  const ToastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ACDDialog.init(context);

    return CategoryScaffold(
      title: 'Toast',
      color: Colors.teal,
      children: [
        buildList([
          listItem(
            'Basic Toast',
            'Minimal auto-dismissing toast',
            Icons.notifications_active_outlined,
            () => _showToast(context),
          ),
          listItem(
            'Long Toast + Close Button',
            'ACDToastLength.long, closeButtonMode, dismissOnTap',
            Icons.timer_outlined,
            () => _showAdvancedToast(context),
          ),
          listItem(
            'Cancel Active Toast',
            'ACDDialog.cancelToast()',
            Icons.cancel_outlined,
            () => _showCancelableToast(context),
          ),
          listItem(
            'Queued Toasts',
            'ACDDialogQueue.enqueue() with 3 toasts',
            Icons.playlist_play,
            () => _showToastQueue(context),
          ),
          listItem(
            'Stacked Toasts',
            'maxVisible + overflowPolicy — several visible at once',
            Icons.layers_outlined,
            () => _showStack(context),
          ),
          listItem(
            'Style Variants',
            'filled / flat / flatColored / minimal / simple',
            Icons.style_outlined,
            () => _showStyleVariants(context),
          ),
          listItem(
            'Success / Error / Warning / Info',
            'contentType presets, reusing ACDContentType',
            Icons.palette_outlined,
            () => _showContentTypes(context),
          ),
          listItem(
            'Progress Bar + Pause on Hover',
            'showProgressBar, pauseOnHover (hover on desktop/web)',
            Icons.hourglass_bottom_outlined,
            () => _showProgressToast(context),
          ),
          listItem(
            'Drag to Dismiss',
            'dragToDismiss — swipe the toast away',
            Icons.swipe_outlined,
            () => _showDragToDismiss(context),
          ),
          listItem(
            'Await the Result',
            'toastClosed — why did it close? (timeout / user / swipe …)',
            Icons.hourglass_empty_rounded,
            () => _showAwaitable(context),
          ),
          listItem(
            'Fully Custom Card',
            'customBuilder — bypass every built-in appearance field',
            Icons.widgets_outlined,
            () => _showCustomBuilder(context),
          ),
        ]),
        const CodeSnippet(
          code: '''
ACDDialog.toast(
  context: context,
  message: 'Copied to clipboard',
  length: ACDToastLength.long,
  closeButtonMode: ACDToastCloseButtonMode.always,
)..show();''',
        ),

        const SizedBox(height: 24),
        sectionHeader('Async feedback'),
        buildList([
          listItem(
            'Promise toast',
            'Saving… → Saved, in the same toast',
            Icons.cloud_upload_outlined,
            () => _promise(context, fail: false),
          ),
          listItem(
            'Promise toast (failure)',
            'Saving… → Could not save',
            Icons.cloud_off_outlined,
            () => _promise(context, fail: true),
          ),
          listItem(
            'Undo toast',
            'Tells you whether Undo was tapped',
            Icons.undo_rounded,
            () => _undo(context),
          ),
        ]),
        const CodeSnippet(
          code: '''
final undone = await ACDDialog.undoToast(
  context: context,
  message: 'Message deleted',
);
if (!undone) await api.delete(message);''',
        ),
      ],
    );
  }

  Future<void> _promise(BuildContext context, {required bool fail}) async {
    try {
      await ACDDialog.promiseToast<void>(
        context: context,
        future: Future<void>.delayed(const Duration(seconds: 2), () {
          if (fail) throw Exception('offline');
        }),
        loading: 'Saving…',
        success: (_) => 'Saved',
        error: (_) => 'Could not save',
      );
    } catch (_) {
      // Already shown in the toast.
    }
  }

  Future<void> _undo(BuildContext context) async {
    final bool undone = await ACDDialog.undoToast(
      context: context,
      message: 'Message deleted',
    );
    if (!context.mounted) return;
    ACDDialog.toast(
      context: context,
      message: undone ? 'Restored' : 'Deleted for good',
    ).show();
  }

  void _showToast(BuildContext ctx) {
    ACDDialog.toast(
      context: ctx,
      message: 'Copied to clipboard',
      backgroundColor: Colors.black87,
    ).show();
  }

  void _showAdvancedToast(BuildContext ctx) {
    ACDDialog.toast(
      context: ctx,
      message: 'Long toast with a close button — tap anywhere to dismiss',
      length: ACDToastLength.long,
      closeButtonMode: ACDToastCloseButtonMode.always,
      dismissOnTap: true,
      backgroundColor: Colors.black87,
    ).show();
  }

  void _showCancelableToast(BuildContext ctx) {
    ACDDialog.toast(
      context: ctx,
      message: 'Tap "Cancel Active Toast" again to dismiss me early',
      length: ACDToastLength.long,
      backgroundColor: Colors.black87,
    ).show();
  }

  Future<void> _showAwaitable(BuildContext ctx) async {
    final ACDDialog toast = ACDDialog.toast(
      context: ctx,
      message: 'Message archived — tap ✕ to undo',
      closeButtonMode: ACDToastCloseButtonMode.always,
      dragToDismiss: true,
    )..show();
    final ACDToastDismissReason reason = await toast.toastClosed!;
    if (!ctx.mounted) return;
    ACDDialog.toast(
      context: ctx,
      message: reason == ACDToastDismissReason.user
          ? 'Undone'
          : 'Closed by: ${reason.name}',
    ).show();
  }

  void _showToastQueue(BuildContext ctx) {
    for (int i = 1; i <= 3; i++) {
      final toast = ACDDialog.toast(
        context: ctx,
        message: 'Queued toast $i of 3',
        length: ACDToastLength.short,
        cancelPrevious: false,
        backgroundColor: Colors.black87,
      );
      ACDDialogQueue.enqueue(toast);
    }
  }

  void _showStack(BuildContext ctx) {
    for (int i = 1; i <= 4; i++) {
      ACDDialog.toast(
        context: ctx,
        message: 'Stacked toast $i',
        cancelPrevious: false,
        maxVisible: 3,
        showDuration: const Duration(seconds: 4),
        backgroundColor: Colors.black87,
      ).show();
    }
  }

  void _showStyleVariants(BuildContext ctx) {
    const styles = ACDToastStyle.values;
    for (int i = 0; i < styles.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (!ctx.mounted) return;
        ACDDialog.toast(
          context: ctx,
          message: styles[i].name,
          id: 'style-${styles[i].name}',
          style: styles[i],
          contentType: ACDContentType.help,
          cancelPrevious: false,
          maxVisible: 5,
          showDuration: const Duration(seconds: 5),
        ).show();
      });
    }
  }

  void _showContentTypes(BuildContext ctx) {
    const types = ACDContentType.values;
    for (int i = 0; i < types.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (!ctx.mounted) return;
        ACDDialog.toast(
          context: ctx,
          message: '${types[i].name} toast',
          id: 'content-${types[i].name}',
          contentType: types[i],
          style: ACDToastStyle.flatColored,
          cancelPrevious: false,
          maxVisible: 4,
          showDuration: const Duration(seconds: 4),
        ).show();
      });
    }
  }

  void _showProgressToast(BuildContext ctx) {
    ACDDialog.toast(
      context: ctx,
      message: 'Hover to pause the countdown',
      contentType: ACDContentType.success,
      showProgressBar: true,
      pauseOnHover: true,
      showDuration: const Duration(seconds: 6),
    ).show();
  }

  void _showDragToDismiss(BuildContext ctx) {
    ACDDialog.toast(
      context: ctx,
      message: 'Swipe me away',
      contentType: ACDContentType.warning,
      dragToDismiss: true,
      showDuration: const Duration(seconds: 8),
    ).show();
  }

  void _showCustomBuilder(BuildContext ctx) {
    ACDDialog.toast(
      context: ctx,
      message: 'unused — customBuilder replaces the whole card',
      showDuration: const Duration(seconds: 4),
      customBuilder: (context, config, dismiss) => Material(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: dismiss,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.rocket_launch, color: Colors.white),
                SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Fully custom card — tap to dismiss',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).show();
  }
}
