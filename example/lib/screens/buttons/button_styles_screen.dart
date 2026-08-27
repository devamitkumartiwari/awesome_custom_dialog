import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// A gallery of `oneButton`/`twoButton` styling combinations —
/// backgroundColor, gradient, elevation/boxShadow, icon, and borderRadius.
class ButtonStylesScreen extends StatelessWidget {
  const ButtonStylesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ACDDialog.init(context);

    return CategoryScaffold(
      title: 'Styled',
      color: Colors.indigo,
      subtitle: 'backgroundColor · gradient · elevation · icon · borderRadius',
      children: [
        sectionHeader('Solid fill'),
        buildList([
          listItem(
            'Filled, rounded',
            'backgroundColor + borderRadius',
            Icons.crop_square_rounded,
            () => _showFilled(context),
          ),
        ]),
        const CodeSnippet(
          code: '''
..oneButton(
  text: 'Confirm',
  color: Colors.white,
  backgroundColor: Colors.teal,
  borderRadius: BorderRadius.circular(14),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Gradient'),
        buildList([
          listItem(
            'Gradient fill',
            'gradient overrides backgroundColor',
            Icons.gradient,
            () => _showGradient(context),
          ),
        ]),
        const CodeSnippet(
          code: '''
..oneButton(
  text: 'Upgrade',
  color: Colors.white,
  gradient: const LinearGradient(
    colors: [Colors.purple, Colors.pinkAccent],
  ),
  borderRadius: BorderRadius.circular(14),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Elevation & shadow'),
        buildList([
          listItem(
            'Floating button',
            'elevation1 / boxShadow1',
            Icons.layers,
            () => _showElevated(context),
          ),
        ]),
        const SizedBox(height: 24),
        sectionHeader('Icon + shape'),
        buildList([
          listItem(
            'Leading icon',
            'icon renders before the label',
            Icons.rocket_launch_outlined,
            () => _showIcon(context),
          ),
          listItem(
            'Pill shape',
            'fully-rounded borderRadius',
            Icons.circle_outlined,
            () => _showPill(context),
          ),
        ]),
        const SizedBox(height: 24),
        sectionHeader('Two-button gradient row'),
        buildList([
          listItem(
            'Both slots styled',
            'backgroundColor1/2 + icon1/2 together',
            Icons.compare_arrows,
            () => _showStyledPair(context),
          ),
        ]),
      ],
    );
  }

  void _showFilled(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Solid fill button',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
      )
      ..oneButton(
        text: 'Confirm',
        color: Colors.white,
        backgroundColor: Colors.teal,
        borderRadius: BorderRadius.circular(14),
      )
      ..show();
  }

  void _showGradient(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Gradient button',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
      )
      ..oneButton(
        text: 'Upgrade',
        color: Colors.white,
        gradient:
            const LinearGradient(colors: [Colors.purple, Colors.pinkAccent]),
        borderRadius: BorderRadius.circular(14),
      )
      ..show();
  }

  void _showElevated(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Elevated button',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
      )
      ..oneButton(
        text: 'Continue',
        color: Colors.white,
        backgroundColor: Colors.indigo,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      )
      ..show();
  }

  void _showIcon(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Icon button',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
      )
      ..oneButton(
        text: 'Launch',
        color: Colors.white,
        backgroundColor: Colors.deepOrange,
        borderRadius: BorderRadius.circular(14),
        icon: Icons.rocket_launch_outlined,
      )
      ..show();
  }

  void _showPill(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Pill-shaped button',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
      )
      ..oneButton(
        text: 'Get Started',
        color: Colors.white,
        backgroundColor: Colors.green.shade700,
        borderRadius: BorderRadius.circular(999),
      )
      ..show();
  }

  void _showStyledPair(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Styled button pair',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
      )
      ..twoButton(
        gravity: ACDGravity.spaceEvenly,
        text1: 'Cancel',
        color1: Colors.black87,
        backgroundColor1: Colors.grey.shade200,
        borderRadius1: BorderRadius.circular(12),
        text2: 'Delete',
        color2: Colors.white,
        backgroundColor2: Colors.redAccent,
        borderRadius2: BorderRadius.circular(12),
        icon2: Icons.delete_outline,
      )
      ..show();
  }
}
