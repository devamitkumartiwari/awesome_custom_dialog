import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../widgets/showcase_widgets.dart';

class SnackbarScreen extends StatelessWidget {
  const SnackbarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ACDDialog.init(context);

    return CategoryScaffold(
      title: 'Snackbar',
      color: Colors.blueGrey,
      children: [
        buildGrid([
          actionCard(
            'Success',
            Icons.done_rounded,
            const Color(0xFF2D6A4F),
            () => _showSnackbar(context, ACDContentType.success),
          ),
          actionCard(
            'Failure',
            Icons.close_rounded,
            const Color(0xFFC72C41),
            () => _showSnackbar(context, ACDContentType.failure),
          ),
          actionCard(
            'Warning',
            Icons.priority_high_rounded,
            const Color(0xFFFCA652),
            () => _showSnackbar(context, ACDContentType.warning),
          ),
          actionCard(
            'Help',
            Icons.question_mark_rounded,
            const Color(0xFF3282B8),
            () => _showSnackbar(context, ACDContentType.help),
          ),
        ]),
        const SizedBox(height: 12),
        buildList([
          listItem(
            'Standalone ScaffoldMessenger Snackbar',
            'ACDSnackbarContent inside a real SnackBar',
            Icons.chat_bubble_outline,
            () => _showStandaloneSnackbar(context),
          ),
        ]),
        const CodeSnippet(
          code: '''
ACDDialog.snackbar(
  context: context,
  title: 'Success',
  message: 'Your changes have been saved.',
  contentType: ACDContentType.success,
)..show();''',
        ),
      ],
    );
  }

  void _showSnackbar(BuildContext ctx, ACDContentType contentType) {
    ACDDialog.snackbar(
      context: ctx,
      title: contentType.name[0].toUpperCase() + contentType.name.substring(1),
      message:
          'This is an example ${contentType.name} message shown in the body.',
      contentType: contentType,
    ).show();
  }

  void _showStandaloneSnackbar(BuildContext ctx) {
    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: ACDSnackbarContent(
            title: 'Standalone Usage',
            message: 'This ACDSnackbarContent is hosted in a real SnackBar.',
            contentType: ACDContentType.help,
          ),
        ),
      );
  }
}
