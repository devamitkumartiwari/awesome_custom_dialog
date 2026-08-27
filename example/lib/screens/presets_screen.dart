import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../widgets/showcase_widgets.dart';

class PresetsScreen extends StatelessWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ACDDialog.init(context);

    return CategoryScaffold(
      title: 'Presets & Feedback',
      color: Colors.green,
      children: [
        buildGrid([
          actionCard(
            'Success',
            Icons.check_circle_outline,
            Colors.green,
            () => _showSuccess(context),
          ),
          actionCard(
            'Error',
            Icons.error_outline,
            Colors.red,
            () => _showError(context),
          ),
          actionCard(
            'Warning',
            Icons.warning_amber_rounded,
            Colors.orange,
            () => _showWarning(context),
          ),
          actionCard(
            'Info',
            Icons.info_outline,
            Colors.blue,
            () => _showInfo(context),
          ),
        ]),
        const CodeSnippet(
          code: '''
ACDDialog().build(context)
  ..success(
    title: 'Payment Sent!',
    message: 'Your transfer of \$42.00 was successful.',
    onTap: () => print('success tapped'),
  )
  ..show();''',
        ),
      ],
    );
  }

  void _showSuccess(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 24
      ..animation = ACDAnimation.bounce
      ..success(
        title: 'Payment Sent!',
        message: 'Your transfer of \$42.00 was successful.',
        onTap: () => debugPrint('success tapped'),
      )
      ..show();
  }

  void _showError(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 24
      ..animation = ACDAnimation.scale
      ..error(
        title: 'Upload Failed',
        message: 'Could not connect to the server. Please try again.',
      )
      ..show();
  }

  void _showWarning(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 24
      ..warning(
        title: 'Delete Project?',
        message: 'This action cannot be undone. Are you sure?',
        buttonText: 'Yes, Delete',
      )
      ..show();
  }

  void _showInfo(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 24
      ..info(
        title: 'New Update',
        message: 'Version 2.0 is ready with new features.',
        buttonText: 'Install Now',
      )
      ..show();
  }
}
