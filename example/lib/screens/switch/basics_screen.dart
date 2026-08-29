import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDSwitch` basics — controlled, uncontrolled, an external
/// `ValueNotifier<bool>` controller, and the `.material()`/`.ios()` presets.
class SwitchBasicsScreen extends StatefulWidget {
  const SwitchBasicsScreen({super.key});

  @override
  State<SwitchBasicsScreen> createState() => _SwitchBasicsScreenState();
}

class _SwitchBasicsScreenState extends State<SwitchBasicsScreen> {
  bool _controlledValue = true;
  final ValueNotifier<bool> _controller = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Basics',
      color: Colors.cyan,
      children: [
        sectionHeader('Controlled (value + onChanged)'),
        ACDSwitch(
          value: _controlledValue,
          onChanged: (v) => setState(() => _controlledValue = v),
        ),
        const CodeSnippet(
          code: '''
ACDSwitch(
  value: enabled,
  onChanged: (v) => setState(() => enabled = v),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Uncontrolled (initialValue)'),
        const ACDSwitch(initialValue: true),
        const CodeSnippet(code: "ACDSwitch(initialValue: true)"),
        const SizedBox(height: 24),
        sectionHeader('External ValueNotifier<bool> controller'),
        Row(
          children: [
            ACDSwitch(controller: _controller),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () => _controller.value = !_controller.value,
              child: const Text('Toggle from outside'),
            ),
          ],
        ),
        const CodeSnippet(
          code: '''
final controller = ValueNotifier<bool>(false);

ACDSwitch(controller: controller)
// ...
controller.value = !controller.value;''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Platform presets'),
        const Row(
          children: [
            ACDSwitch.material(initialValue: true),
            SizedBox(width: 24),
            ACDSwitch.ios(initialValue: true),
          ],
        ),
        const CodeSnippet(
          code: '''
ACDSwitch.material(initialValue: true)
ACDSwitch.ios(initialValue: true)''',
        ),
      ],
    );
  }
}
