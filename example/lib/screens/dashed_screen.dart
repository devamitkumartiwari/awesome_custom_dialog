import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/showcase_widgets.dart';

/// `ACDDashedLine`, `ACDDottedDecoration` and `ACDDashedBorder`.
class DashedScreen extends StatelessWidget {
  const DashedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Dashed & dotted',
      color: Colors.brown,
      children: [
        sectionHeader('Lines'),
        const ACDDashedLine(length: double.infinity, color: Colors.black54),
        const SizedBox(height: 16),
        const ACDDashedLine(
          length: double.infinity,
          color: Colors.teal,
          dashLength: 8,
          gapLength: 4,
          thickness: 2,
          roundedCaps: true,
        ),
        const SizedBox(height: 24),
        sectionHeader('Decoration (any Container)'),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Labelled(
              'Box',
              child: SizedBox(
                width: 80,
                height: 80,
                child: DecoratedBox(decoration: ACDDottedDecoration()),
              ),
            ),
            _Labelled(
              'Oval, gradient',
              child: SizedBox(
                width: 80,
                height: 80,
                child: DecoratedBox(
                  decoration: ACDDottedDecoration(
                    shape: ACDDottedShape.oval,
                    strokeWidth: 3,
                    roundedCaps: true,
                    gradient: LinearGradient(
                      colors: [Colors.pink, Colors.orange],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        sectionHeader('Border around a widget'),
        const Center(
          child: ACDDashedBorder(
            shape: ACDDashedBorderShape.roundedRect,
            strokeWidth: 2,
            dashPattern: [6, 4],
            color: Colors.indigo,
            child: SizedBox(
              width: 220,
              height: 72,
              child: Center(child: Text('Drop files here')),
            ),
          ),
        ),
        const CodeSnippet(
          code: '''
ACDDashedBorder(
  shape: ACDDashedBorderShape.roundedRect,
  dashPattern: const [6, 4],
  color: Colors.indigo,
  child: const SizedBox(width: 220, height: 72),
)''',
        ),
      ],
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled(this.label, {required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Column(children: [child, const SizedBox(height: 8), Text(label)]);
}
