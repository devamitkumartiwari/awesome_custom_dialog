import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDDashedBorder` — wraps any widget, including custom-path outlines.
class DashedBorderScreen extends StatelessWidget {
  const DashedBorderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Border',
      color: Colors.brown,
      children: [
        sectionHeader('Shapes'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _borderFor('Rect', ACDDashedBorderShape.rect),
            _borderFor('Rounded', ACDDashedBorderShape.roundedRect),
            _borderFor('Circle', ACDDashedBorderShape.circle),
          ],
        ),
        const SizedBox(height: 32),
        sectionHeader('Gradient + rounded caps'),
        const ACDDashedBorder(
          shape: ACDDashedBorderShape.roundedRect,
          strokeWidth: 3,
          roundedCaps: true,
          gradient: LinearGradient(colors: [Colors.blue, Colors.cyan]),
          child: SizedBox(
            width: 200,
            height: 60,
            child: Center(child: Text('Gradient + rounded caps')),
          ),
        ),
        const SizedBox(height: 32),
        sectionHeader(
          'Custom path',
          description: 'customPathBuilder draws an arbitrary outline',
        ),
        ACDDashedBorder(
          shape: ACDDashedBorderShape.customPath,
          color: Colors.deepOrange,
          customPathBuilder: (size) => Path()
            ..moveTo(size.width / 2, 0)
            ..lineTo(size.width, size.height / 2)
            ..lineTo(size.width / 2, size.height)
            ..lineTo(0, size.height / 2)
            ..close(),
          child: const SizedBox(
            width: 120,
            height: 120,
            child: Center(child: Text('Custom path')),
          ),
        ),
        const CodeSnippet(
          code: '''
ACDDashedBorder(
  shape: ACDDashedBorderShape.customPath,
  color: Colors.deepOrange,
  customPathBuilder: (size) => Path()
    ..moveTo(size.width / 2, 0)
    ..lineTo(size.width, size.height / 2)
    ..lineTo(size.width / 2, size.height)
    ..lineTo(0, size.height / 2)
    ..close(),
  child: const SizedBox(width: 120, height: 120),
)''',
        ),
      ],
    );
  }

  Widget _borderFor(String label, ACDDashedBorderShape shape) {
    return Column(
      children: [
        ACDDashedBorder(
          shape: shape,
          color: Colors.indigo,
          child: const SizedBox(width: 80, height: 80),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
