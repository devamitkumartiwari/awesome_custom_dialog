import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDDottedDecoration` — a drop-in `Decoration`, usable directly on any
/// `Container`.
class DottedDecorationScreen extends StatelessWidget {
  const DottedDecorationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Decoration',
      color: Colors.brown,
      children: [
        sectionHeader('Shapes'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _boxFor(
              'Line',
              const ACDDottedDecoration(shape: ACDDottedShape.line),
            ),
            _boxFor(
              'Box',
              const ACDDottedDecoration(shape: ACDDottedShape.box),
            ),
            _boxFor(
              'Oval',
              const ACDDottedDecoration(shape: ACDDottedShape.oval),
            ),
          ],
        ),
        const SizedBox(height: 32),
        sectionHeader('Gradient + rounded caps'),
        Center(
          child: _boxFor(
            'Gradient',
            const ACDDottedDecoration(
              shape: ACDDottedShape.oval,
              strokeWidth: 3,
              roundedCaps: true,
              gradient: LinearGradient(colors: [Colors.pink, Colors.orange]),
            ),
          ),
        ),
        const CodeSnippet(
          code: '''
Container(
  decoration: const ACDDottedDecoration(
    shape: ACDDottedShape.oval,
    strokeWidth: 3,
    roundedCaps: true,
    gradient: LinearGradient(colors: [Colors.pink, Colors.orange]),
  ),
)''',
        ),
      ],
    );
  }

  Widget _boxFor(String label, ACDDottedDecoration decoration) {
    return Column(
      children: [
        Container(width: 80, height: 80, decoration: decoration),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
