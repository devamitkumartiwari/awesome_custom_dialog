import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDSwitch` styling gallery — shapes, gradients, custom text/children,
/// and per-state borders.
class SwitchStylingGalleryScreen extends StatelessWidget {
  const SwitchStylingGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Styling gallery',
      color: Colors.cyan,
      children: [
        sectionHeader('Rounded rectangle shape'),
        const ACDSwitch(
          shape: ACDSwitchShape.roundedRectangle,
          initialValue: true,
          activeTrackColor: Colors.indigo,
        ),
        const SizedBox(height: 24),
        sectionHeader('Gradients'),
        const ACDSwitch(
          initialValue: true,
          activeTrackGradient: LinearGradient(
            colors: [Colors.pink, Colors.deepOrange],
          ),
          inactiveTrackGradient: LinearGradient(
            colors: [Colors.grey, Colors.blueGrey],
          ),
        ),
        const CodeSnippet(
          code: '''
ACDSwitch(
  activeTrackGradient: LinearGradient(colors: [Colors.pink, Colors.deepOrange]),
  inactiveTrackGradient: LinearGradient(colors: [Colors.grey, Colors.blueGrey]),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Built-in On/Off label'),
        const ACDSwitch(width: 70, showOnOff: true, initialValue: true),
        const SizedBox(height: 24),
        sectionHeader('Custom active/inactive child'),
        const ACDSwitch(
          width: 76,
          initialValue: true,
          activeChild: Icon(Icons.check, color: Colors.white, size: 14),
          inactiveChild: Icon(Icons.close, color: Colors.white70, size: 14),
        ),
        const SizedBox(height: 24),
        sectionHeader('Per-state border'),
        const ACDSwitch(
          initialValue: true,
          trackColor: Colors.transparent,
          activeBorderColor: Colors.teal,
          inactiveBorderColor: Colors.grey,
          borderWidth: 2,
          thumbColor: Colors.teal,
        ),
        const SizedBox(height: 24),
        sectionHeader('Disabled'),
        const ACDSwitch(enabled: false, initialValue: true),
      ],
    );
  }
}
