import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/showcase_widgets.dart';

/// `ACDStepper` (wizard and vertical progress) and `ACDStepperListView`
/// (a scrollable order-tracking timeline).
class StepperScreen extends StatefulWidget {
  const StepperScreen({super.key});

  @override
  State<StepperScreen> createState() => _StepperScreenState();
}

class _StepperScreenState extends State<StepperScreen> {
  int _step = 1;

  static const List<ACDStepperItemData<(String, String)>> _timeline = [
    ACDStepperItemData(id: 1, data: ('Order placed', 'Aug 24, 10:02')),
    ACDStepperItemData(id: 2, data: ('Shipped', 'Aug 25, 16:41')),
    ACDStepperItemData(id: 3, data: ('Out for delivery', 'Aug 27, 08:15')),
    ACDStepperItemData(id: 4, data: ('Delivered', 'Pending')),
  ];

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Stepper',
      color: Colors.indigo,
      children: [
        sectionHeader('Wizard (tap a step)'),
        ACDStepper(
          steps: const ['Cart', 'Address', 'Payment', 'Done'],
          activeStep: _step,
          onStepReached: (i) => setState(() => _step = i),
        ),
        const CodeSnippet(
          code: '''
ACDStepper(
  steps: const ['Cart', 'Address', 'Payment', 'Done'],
  activeStep: step,
  onStepReached: (i) => setState(() => step = i),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Vertical'),
        ACDStepper(
          steps: const ['Signed up', 'Verified email', 'Profile complete'],
          activeStep: 1,
          direction: Axis.vertical,
        ),
        const SizedBox(height: 24),
        sectionHeader('Timeline list'),
        SizedBox(
          height: 300,
          child: ACDStepperListView<(String, String)>(
            items: _timeline,
            theme: const ACDStepperThemeData(dashed: true),
            contentBuilder: (context, item, index) => Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                title: Text(item.data.$1),
                subtitle: Text(item.data.$2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
