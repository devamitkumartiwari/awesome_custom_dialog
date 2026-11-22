import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/showcase_widgets.dart';

/// `ACDSwitch`: controlled, controller-driven, presets, styling, and the
/// `ACDSwitchFormField` wrapper.
class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {
  bool _wifi = true;
  final ValueNotifier<bool> _controller = ValueNotifier<bool>(false);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Switch',
      color: Colors.cyan,
      children: [
        sectionHeader('Controlled'),
        Row(
          children: [
            ACDSwitch(
              value: _wifi,
              semanticLabel: 'Wi-Fi',
              onChanged: (v) => setState(() => _wifi = v),
            ),
            const SizedBox(width: 12),
            Text('Wi-Fi ${_wifi ? 'on' : 'off'}'),
          ],
        ),
        const CodeSnippet(
          code: '''
ACDSwitch(
  value: enabled,
  onChanged: (v) => setState(() => enabled = v),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('External controller'),
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
        const SizedBox(height: 24),
        sectionHeader('Presets & styling'),
        const Wrap(
          spacing: 24,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ACDSwitch.material(initialValue: true),
            ACDSwitch.ios(initialValue: true),
            ACDSwitch(
              initialValue: true,
              width: 72,
              showOnOff: true,
              activeTrackColor: Colors.deepPurple,
            ),
          ],
        ),
        const SizedBox(height: 24),
        sectionHeader('In a form'),
        Form(
          key: _formKey,
          child: ACDSwitchFormField(
            title: const Text('I accept the terms'),
            validator: (on) => on == true ? null : 'Please accept to continue',
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _formKey.currentState?.validate(),
            child: const Text('Validate'),
          ),
        ),
      ],
    );
  }
}
