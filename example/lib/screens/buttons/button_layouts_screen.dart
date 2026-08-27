import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

class ButtonLayoutsScreen extends StatelessWidget {
  const ButtonLayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ACDDialog.init(context);

    return CategoryScaffold(
      title: 'Layouts',
      color: Colors.indigo,
      children: [
        buildList([
          listItem(
            'Confirmation Style',
            'Single teal button center aligned',
            Icons.smart_button,
            () => _showOneButton(context),
          ),
          listItem(
            'Decision Style',
            'Two buttons with vertical divider',
            Icons.call_split,
            () => _showTwoButton(context),
          ),
          listItem(
            'Multi Action',
            'Three buttons layout',
            Icons.more_horiz,
            () => _showThreeButton(context),
          ),
        ]),
      ],
    );
  }

  void _showOneButton(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
        text: 'Settings Saved',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
        textAlign: TextAlign.center,
      )
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        text: 'Your preferences have been updated across all devices.',
        color: Colors.black54,
        alignment: Alignment.center,
        textAlign: TextAlign.center,
      )
      ..acdDivider()
      ..oneButton(
        text: 'Done',
        color: Colors.white,
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.teal,
        borderRadius: BorderRadius.circular(12),
        icon: Icons.check_circle_outline,
      )
      ..show();
  }

  void _showTwoButton(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        text: 'Discard Changes?',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
      )
      ..acdDivider()
      ..twoButton(
        gravity: ACDGravity.spaceEvenly,
        withDivider: true,
        text1: 'Keep Editing',
        color1: Colors.blueGrey,
        text2: 'Discard',
        color2: Colors.red,
        fontWeight2: FontWeight.bold,
      )
      ..show();
  }

  void _showThreeButton(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        text: 'Save Progress?',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
      )
      ..acdDivider()
      ..threeButton(
        text1: 'Cancel',
        text2: 'No',
        color2: Colors.red,
        text3: 'Save',
        color3: Colors.teal,
        onTap3: () => debugPrint('saved'),
      )
      ..show();
  }
}
