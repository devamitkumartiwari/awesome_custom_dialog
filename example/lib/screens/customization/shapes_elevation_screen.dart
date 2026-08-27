import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// Shape variety (rect/rounded/oval/circle/custom-path) and an elevation
/// ladder, both shown across `ACDDashedBorder` and `ACDSlideAction`.
class ShapesElevationScreen extends StatelessWidget {
  const ShapesElevationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Shapes & Elevation',
      color: Colors.amber.shade800,
      children: [
        sectionHeader('ACDDashedBorder shapes'),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _shape('Rect', ACDDashedBorderShape.rect),
            _shape('Rounded', ACDDashedBorderShape.roundedRect),
            _shape('Oval', ACDDashedBorderShape.oval),
            _shape('Circle', ACDDashedBorderShape.circle),
          ],
        ),
        const SizedBox(height: 28),
        sectionHeader('ACDSlideAction shapes'),
        ACDSlideAction(
          shape: ACDSlideActionShape.rectangle,
          label: 'Rectangle',
          onConfirm: () {},
        ),
        const SizedBox(height: 12),
        ACDSlideAction(
          shape: ACDSlideActionShape.circle,
          label: 'Circle',
          onConfirm: () {},
        ),
        const SizedBox(height: 28),
        sectionHeader(
          'Elevation ladder',
          description: 'elevationTrack / elevationThumb from 0 to 12',
        ),
        for (final e in [0.0, 2.0, 4.0, 8.0, 12.0]) ...[
          ACDSlideAction(
            elevationTrack: e,
            elevationThumb: e,
            label: 'elevation ${e.toInt()}',
            onConfirm: () {},
          ),
          const SizedBox(height: 12),
        ],
        const CodeSnippet(
          code: '''
ACDSlideAction(
  elevationTrack: 8,
  elevationThumb: 8,
  label: 'elevation 8',
)''',
        ),
      ],
    );
  }

  Widget _shape(String label, ACDDashedBorderShape shape) {
    return Column(
      children: [
        ACDDashedBorder(
          shape: shape,
          color: Colors.amber.shade800,
          child: const SizedBox(width: 70, height: 70),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
