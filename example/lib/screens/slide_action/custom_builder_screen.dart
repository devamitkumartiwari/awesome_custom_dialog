import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// Full builder escape hatches (`foregroundBuilder`/`backgroundBuilder`/
/// `outerBackgroundBuilder`) and the active/inactive gradient pairs.
class SlideActionCustomBuilderScreen extends StatefulWidget {
  const SlideActionCustomBuilderScreen({super.key});

  @override
  State<SlideActionCustomBuilderScreen> createState() =>
      _SlideActionCustomBuilderScreenState();
}

class _SlideActionCustomBuilderScreenState
    extends State<SlideActionCustomBuilderScreen> {
  final _customController = ACDSlideActionController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _simulate(ACDSlideActionController controller) async {
    controller.loading();
    await Future.delayed(const Duration(seconds: 1));
    controller.success();
    await Future.delayed(const Duration(seconds: 1));
    controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Custom builders & gradients',
      color: Colors.deepPurple,
      children: [
        sectionHeader(
          'Active/inactive gradients',
          description: 'Drag to see the track & thumb gradient swap',
        ),
        ACDSlideAction(
          inactiveTrackGradient: const LinearGradient(
            colors: [Colors.blueGrey, Colors.blueGrey],
          ),
          activeTrackGradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.indigo],
          ),
          inactiveThumbGradient: const LinearGradient(
            colors: [Colors.white70, Colors.white],
          ),
          activeThumbGradient: const LinearGradient(
            colors: [Colors.amber, Colors.orange],
          ),
          label: 'Drag me',
          onConfirm: () => debugPrint('Confirmed'),
        ),
        const CodeSnippet(
          code: '''
ACDSlideAction(
  inactiveTrackGradient: LinearGradient(colors: [Colors.blueGrey, Colors.blueGrey]),
  activeTrackGradient: LinearGradient(colors: [Colors.deepPurple, Colors.indigo]),
  inactiveThumbGradient: LinearGradient(colors: [Colors.white70, Colors.white]),
  activeThumbGradient: LinearGradient(colors: [Colors.amber, Colors.orange]),
  label: 'Drag me',
  onConfirm: () {},
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Fully custom builders'),
        ACDSlideAction(
          controller: _customController,
          height: 64,
          onConfirm: () => _simulate(_customController),
          outerBackgroundBuilder: (context, progress, status) => Container(
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: [Colors.orange, Colors.pink]),
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          backgroundBuilder: (context, progress, status) => const Center(
            child: Text(
              'Custom track & label',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
