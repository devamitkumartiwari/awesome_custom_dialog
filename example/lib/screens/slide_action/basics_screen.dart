import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDSlideAction` basics — standard, `.swipeButton` preset, dual-direction,
/// and circle shape with a wave trail.
class SlideActionBasicsScreen extends StatefulWidget {
  const SlideActionBasicsScreen({super.key});

  @override
  State<SlideActionBasicsScreen> createState() =>
      _SlideActionBasicsScreenState();
}

class _SlideActionBasicsScreenState extends State<SlideActionBasicsScreen> {
  final _standardController = ACDSlideActionController();
  final _dualController = ACDSlideActionController();

  @override
  void dispose() {
    _standardController.dispose();
    _dualController.dispose();
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
      title: 'Basics',
      color: Colors.deepPurple,
      children: [
        sectionHeader('Standard'),
        ACDSlideAction(
          controller: _standardController,
          label: 'Slide to confirm',
          onConfirm: () => _simulate(_standardController),
        ),
        const CodeSnippet(
          code: '''
final controller = ACDSlideActionController();

ACDSlideAction(
  controller: controller,
  label: 'Slide to confirm',
  onConfirm: () async {
    controller.loading();
    final ok = await submit();
    ok ? controller.success() : controller.reset();
  },
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Ready-made style (.swipeButton preset)'),
        ACDSlideAction.swipeButton(
          label: 'Swipe to pay',
          onConfirm: () => debugPrint('Paid'),
        ),
        const CodeSnippet(
          code: '''
ACDSlideAction.swipeButton(
  label: 'Swipe to pay',
  onConfirm: () => print('Paid'),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Dual direction'),
        ACDSlideAction(
          controller: _dualController,
          direction: ACDSlideActionDirection.dual,
          label: 'Slide either way',
          trackColor: Colors.deepPurple,
          onConfirm: () => _simulate(_dualController),
        ),
        const SizedBox(height: 24),
        sectionHeader('Circle shape + wave trail'),
        ACDSlideAction(
          shape: ACDSlideActionShape.circle,
          showWaveTrail: true,
          label: 'Swipe to unlock',
          trackColor: Colors.teal,
          onConfirm: () => debugPrint('Unlocked'),
        ),
      ],
    );
  }
}
