import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

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
            'ACDToastLength.long, showCloseButton, dismissOnTap',
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
        ]),
        const CodeSnippet(
          code: '''
ACDDialog.toast(
  context: context,
  message: 'Copied to clipboard',
  length: ACDToastLength.long,
  showCloseButton: true,
)..show();''',
        ),
      ],
    );
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
      showCloseButton: true,
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
}
