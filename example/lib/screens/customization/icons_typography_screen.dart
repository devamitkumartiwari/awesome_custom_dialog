import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// Icon overrides across widgets, plus a font-shortcut-vs-full-`TextStyle`
/// comparison.
class IconsTypographyScreen extends StatelessWidget {
  const IconsTypographyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Icons & Typography',
      color: Colors.blue,
      children: [
        sectionHeader('Icon overrides'),
        const ACDSnackbarContent(
          title: 'Custom icon',
          message: 'icon: overrides the contentType default.',
          contentType: ACDContentType.help,
          icon: Icons.emoji_objects_outlined,
        ),
        const SizedBox(height: 16),
        ACDSlideAction(
          thumbIcon: Icons.key_rounded,
          label: 'Custom thumbIcon',
          onConfirm: () {},
        ),
        const CodeSnippet(
          code: '''
ACDSnackbarContent(
  title: 'Custom icon',
  message: 'icon: overrides the contentType default.',
  contentType: ACDContentType.help,
  icon: Icons.emoji_objects_outlined,
)''',
        ),
        const SizedBox(height: 28),
        sectionHeader(
          'Font shortcuts vs. full TextStyle',
          description: 'Both style the same ACDSnackbarContent',
        ),
        const ACDSnackbarContent(
          title: 'Shortcut fields',
          message: 'titleFontSize/titleFontWeight, no TextStyle needed.',
          contentType: ACDContentType.success,
          titleFontSize: 22,
          titleFontWeight: FontWeight.w900,
          messageFontSize: 15,
          messageFontFamily: 'monospace',
        ),
        const SizedBox(height: 16),
        ACDSnackbarContent(
          title: 'Full TextStyle',
          message: 'titleTextStyle/messageTextStyle for total control.',
          contentType: ACDContentType.success,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
            decoration: TextDecoration.underline,
          ),
          messageTextStyle: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
        const CodeSnippet(
          code: '''
// Shortcuts — quick, no TextStyle needed
ACDSnackbarContent(
  title: 'Shortcut fields',
  message: '...',
  titleFontSize: 22,
  titleFontWeight: FontWeight.w900,
),

// Full control via TextStyle
ACDSnackbarContent(
  title: 'Full TextStyle',
  message: '...',
  titleTextStyle: const TextStyle(
    fontStyle: FontStyle.italic,
    letterSpacing: 1.2,
    decoration: TextDecoration.underline,
  ),
)''',
        ),
      ],
    );
  }
}
