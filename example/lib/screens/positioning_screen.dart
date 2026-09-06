import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../widgets/showcase_widgets.dart';

class PositioningScreen extends StatelessWidget {
  const PositioningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ACDDialog.init(context);

    return CategoryScaffold(
      title: 'Positioning & Misc',
      color: Colors.deepOrange,
      children: [
        buildList([
          listItem(
            'Bottom Drawer',
            'Slides up from bottom edge',
            Icons.keyboard_arrow_up,
            () => _showBottom(context),
          ),
          listItem(
            'Top Banner',
            'Notification style from top',
            Icons.keyboard_arrow_down,
            () => _showTop(context),
          ),
          listItem(
            'Side Panel (Left)',
            'Slides in from the left, rounded on the right',
            Icons.view_sidebar_outlined,
            () => _showSidePanel(context, fromLeft: true),
          ),
          listItem(
            'Side Panel (Right)',
            'Slides in from the right, rounded on the left',
            Icons.view_sidebar,
            () => _showSidePanel(context, fromLeft: false),
          ),
          listItem(
            'Queued Dialogs',
            'Chain 3 dialogs in sequence',
            Icons.layers_outlined,
            () => _showQueue(context),
          ),
        ]),
        const CodeSnippet(
          code: '''
ACDDialog().build(context)
  ..gravity = ACDGravity.left
  ..width = 280
  ..cornerRadius = const BorderRadius.only(
    topRight: Radius.circular(20),
    bottomRight: Radius.circular(20),
  )
  ..text(text: 'Side panel, only right corners rounded')
  ..show();''',
        ),
      ],
    );
  }

  void _showBottom(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..gravity = ACDGravity.bottom
      ..gravityAnimationEnable = true
      ..borderRadius = 28
      ..margin = const EdgeInsets.fromLTRB(16, 0, 16, 12)
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
        text: 'Quick Actions',
        fontSize: 20,
        fontWeight: FontWeight.bold,
      )
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        text: 'This menu slides up as a floating card above the bottom edge.',
        color: Colors.black54,
      )
      ..oneButton(
        text: 'Got it',
        color: Colors.teal,
        fontWeight: FontWeight.bold,
      )
      ..show();
  }

  void _showTop(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..gravity = ACDGravity.top
      ..gravityAnimationEnable = true
      ..borderRadius = 16
      ..backgroundColor = Colors.teal.shade800
      ..text(
        padding: const EdgeInsets.all(20),
        text: '✨ Success: Files Uploaded',
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        alignment: Alignment.center,
      )
      ..autoDismissAfter = const Duration(seconds: 2)
      ..show();
  }

  void _showSidePanel(BuildContext ctx, {required bool fromLeft}) {
    // The panel sits flush against the screen's left or right edge, so only
    // the opposite (exposed) corners should be rounded — cornerRadius gives
    // full per-corner control, unlike the uniform borderRadius shortcut.
    const radius = Radius.circular(20);
    ACDDialog().build(ctx)
      ..gravity = fromLeft ? ACDGravity.left : ACDGravity.right
      ..gravityAnimationEnable = true
      ..width = 280
      ..cornerRadius = fromLeft
          ? const BorderRadius.only(topRight: radius, bottomRight: radius)
          : const BorderRadius.only(topLeft: radius, bottomLeft: radius)
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
        text: fromLeft
            ? 'Side Menu\n\nSlides in from the left.'
            : 'Side Menu\n\nSlides in from the right.',
        fontSize: 16,
      )
      ..oneButton(
        text: 'Close Panel',
        color: Colors.teal,
        fontWeight: FontWeight.bold,
      )
      ..show();
  }

  void _showQueue(BuildContext ctx) {
    for (int i = 1; i <= 3; i++) {
      final dialog = ACDDialog().build(ctx)
        ..borderRadius = 24
        ..animation = ACDAnimation.scale
        ..info(
          title: 'Step $i of 3',
          message: 'This is a sequence of non-overlapping dialogs.',
          buttonText: i == 3 ? 'Finish' : 'Next Step',
        );
      ACDDialogQueue.enqueue(dialog);
    }
  }
}
