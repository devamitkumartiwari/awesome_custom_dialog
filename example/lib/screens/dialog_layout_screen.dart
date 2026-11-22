import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/showcase_widgets.dart';

/// Where and how a dialog appears: gravity, entrance animations, shape and
/// background styling, and a queue of dialogs.
class DialogLayoutScreen extends StatelessWidget {
  const DialogLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Position & style',
      color: Colors.blue,
      children: [
        sectionHeader('Position'),
        buildList([
          listItem(
            'Top banner',
            'Slides down, closes after 2 s',
            Icons.vertical_align_top,
            () => _top(context),
          ),
          listItem(
            'Side panel',
            'Docked to the start edge',
            Icons.view_sidebar_outlined,
            () => _side(context),
          ),
          listItem(
            'Queue',
            'Three dialogs, one after another',
            Icons.layers_outlined,
            () => _queue(context),
          ),
        ]),
        const SizedBox(height: 24),
        sectionHeader('Entrance animation'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final ACDAnimation a in const [
                ACDAnimation.fade,
                ACDAnimation.scale,
                ACDAnimation.bounce,
                ACDAnimation.slideUp,
                ACDAnimation.rotate,
              ])
                animChip(a.name, () => _animated(context, a)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        sectionHeader('Styling'),
        buildList([
          listItem(
            'Gradient + superellipse',
            'shape, backgroundGradient, contentStagger',
            Icons.palette_outlined,
            () => _styled(context),
          ),
        ]),
        const CodeSnippet(
          code: '''
ACDDialog().build(context)
  ..shape = RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(28))
  ..backgroundGradient = const LinearGradient(
    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
  )
  ..contentStagger = const ACDStaggerOptions()
  ..text(text: 'Styled dialog', color: Colors.white)
  ..oneButton(text: 'Nice', color: Colors.white)
  ..show();''',
        ),
      ],
    );
  }

  void _top(BuildContext context) {
    ACDDialog().build(context)
      ..gravity = ACDGravity.top
      ..gravityAnimationEnable = true
      ..borderRadius = 16
      ..backgroundColor = Colors.teal.shade800
      ..text(
        padding: const EdgeInsets.all(20),
        text: 'Files uploaded',
        color: Colors.white,
        alignment: Alignment.center,
      )
      ..autoDismissAfter = const Duration(seconds: 2)
      ..show();
  }

  void _side(BuildContext context) {
    const Radius r = Radius.circular(20);
    ACDDialog().build(context)
      ..gravity = ACDGravity.left
      ..gravityAnimationEnable = true
      ..width = 280
      ..cornerRadius = const BorderRadius.only(topRight: r, bottomRight: r)
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
        text: 'Side menu',
        fontSize: 18,
      )
      ..oneButton(text: 'Close', color: Colors.teal)
      ..show();
  }

  void _queue(BuildContext context) {
    for (int i = 1; i <= 3; i++) {
      ACDDialogQueue.enqueue(
        ACDDialog().build(context)
          ..borderRadius = 24
          ..info(
            title: 'Step $i of 3',
            message: 'Each dialog waits for the previous one.',
            buttonText: i == 3 ? 'Finish' : 'Next',
          ),
      );
    }
  }

  void _animated(BuildContext context, ACDAnimation animation) {
    ACDDialog().build(context)
      ..borderRadius = 20
      ..animation = animation
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'ACDAnimation.${animation.name}',
        alignment: Alignment.center,
      )
      ..oneButton(text: 'OK')
      ..show();
  }

  void _styled(BuildContext context) {
    ACDDialog().build(context)
      ..shape = RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(28),
      )
      ..backgroundGradient = const LinearGradient(
        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
      )
      ..elevation = 8
      ..contentStagger = const ACDStaggerOptions()
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
        text: 'Styled dialog',
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      )
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        text: 'Content appears piece by piece.',
        color: Colors.white70,
      )
      ..oneButton(text: 'Nice', color: Colors.white)
      ..show();
  }
}
