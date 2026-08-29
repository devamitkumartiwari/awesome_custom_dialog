import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDSwitch` custom builders and drag-to-toggle.
class SwitchCustomBuilderScreen extends StatelessWidget {
  const SwitchCustomBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Custom builders & drag',
      color: Colors.cyan,
      children: [
        sectionHeader('trackBuilder — fully custom track'),
        ACDSwitch(
          width: 90,
          initialValue: true,
          trackBuilder: (context, progress, value, enabled) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Color.lerp(Colors.grey.shade300, Colors.purple, progress),
            ),
            alignment: Alignment.center,
            child: Text(
              value ? 'YES' : 'NO',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const CodeSnippet(
          code: '''
ACDSwitch(
  trackBuilder: (context, progress, value, enabled) => Container(
    decoration: BoxDecoration(
      color: Color.lerp(Colors.grey, Colors.purple, progress),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(value ? 'YES' : 'NO'),
  ),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('thumbShapeBorder — squircle thumb'),
        const ACDSwitch(
          initialValue: true,
          activeTrackColor: Colors.deepPurple,
          thumbShapeBorder: ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        const SizedBox(height: 24),
        sectionHeader('Drag-to-toggle (default) vs. tap-only'),
        const Row(
          children: [
            ACDSwitch(),
            SizedBox(width: 24),
            ACDSwitch(dragEnabled: false),
          ],
        ),
        const CodeSnippet(
          code: '''
ACDSwitch()                     // drag + tap
ACDSwitch(dragEnabled: false)   // tap only''',
        ),
      ],
    );
  }
}
