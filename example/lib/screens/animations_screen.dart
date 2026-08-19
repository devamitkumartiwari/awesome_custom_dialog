import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../widgets/showcase_widgets.dart';

class AnimationsScreen extends StatelessWidget {
  const AnimationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ACDDialog.init(context);

    return CategoryScaffold(
      title: 'Animations',
      children: [
        sectionHeader('Tap a chip to preview'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              animChip(
                  'Scale', () => _showAnimation(context, ACDAnimation.scale)),
              animChip(
                  'Fade', () => _showAnimation(context, ACDAnimation.fade)),
              animChip(
                  'Bounce', () => _showAnimation(context, ACDAnimation.bounce)),
              animChip('Slide Up',
                  () => _showAnimation(context, ACDAnimation.slideUp)),
              animChip(
                  'Rotate', () => _showAnimation(context, ACDAnimation.rotate)),
            ],
          ),
        ),
      ],
    );
  }

  void _showAnimation(BuildContext ctx, ACDAnimation anim) {
    ACDDialog().build(ctx)
      ..borderRadius = 24
      ..animation = anim
      ..success(title: '${anim.name.toUpperCase()} Animation')
      ..show();
  }
}
