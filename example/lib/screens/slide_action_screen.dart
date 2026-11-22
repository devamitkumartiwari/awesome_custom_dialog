import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/showcase_widgets.dart';

/// `ACDSlideAction`: the async loading → success flow, the ready-made
/// `.swipeButton` preset, dual direction, and auto-reset.
class SlideActionScreen extends StatefulWidget {
  const SlideActionScreen({super.key});

  @override
  State<SlideActionScreen> createState() => _SlideActionScreenState();
}

class _SlideActionScreenState extends State<SlideActionScreen> {
  final ACDSlideActionController _controller = ACDSlideActionController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    _controller.loading();
    await Future<void>.delayed(const Duration(seconds: 1));
    _controller.success();
    await Future<void>.delayed(const Duration(seconds: 1));
    _controller.reset(); // ready to slide again
  }

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Slide to confirm',
      color: Colors.deepPurple,
      children: [
        sectionHeader('Loading → success'),
        ACDSlideAction(
          controller: _controller,
          label: 'Slide to pay',
          onConfirm: _pay,
        ),
        const CodeSnippet(
          code: '''
final controller = ACDSlideActionController();

ACDSlideAction(
  controller: controller,
  label: 'Slide to pay',
  onConfirm: () async {
    controller.loading();
    final ok = await submitPayment();
    ok ? controller.success() : controller.reset();
  },
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Ready-made style'),
        ACDSlideAction.swipeButton(
          label: 'Swipe to unlock',
          autoResetAfter: const Duration(seconds: 2),
          onConfirm: () => debugPrint('Unlocked'),
        ),
        const SizedBox(height: 24),
        sectionHeader('Either direction, circle thumb'),
        ACDSlideAction(
          direction: ACDSlideActionDirection.dual,
          shape: ACDSlideActionShape.circle,
          showWaveTrail: true,
          trackColor: Colors.teal,
          label: 'Slide either way',
          autoResetAfter: const Duration(seconds: 1),
          onConfirm: () => debugPrint('Confirmed'),
        ),
      ],
    );
  }
}
