import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDDashedLine` — horizontal and vertical, solid and rounded-cap dots.
class DashedLinesScreen extends StatelessWidget {
  const DashedLinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Lines',
      color: Colors.brown,
      children: [
        sectionHeader('Horizontal'),
        const ACDDashedLine(length: double.infinity, color: Colors.black54),
        const SizedBox(height: 16),
        const ACDDashedLine(
          length: double.infinity,
          color: Colors.teal,
          dashLength: 8,
          gapLength: 4,
          thickness: 2,
        ),
        const SizedBox(height: 32),
        sectionHeader('Vertical, rounded caps'),
        const Row(
          children: [
            SizedBox(
              height: 80,
              child: ACDDashedLine(
                axis: Axis.vertical,
                length: 80,
                color: Colors.teal,
                dashLength: 6,
                gapLength: 4,
                roundedCaps: true,
              ),
            ),
            SizedBox(width: 16),
            Text('axis: Axis.vertical, roundedCaps: true'),
          ],
        ),
        const CodeSnippet(
          code: '''
ACDDashedLine(
  axis: Axis.vertical,
  length: 80,
  color: Colors.teal,
  dashLength: 6,
  gapLength: 4,
  roundedCaps: true,
)''',
        ),
      ],
    );
  }
}
