import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDStepper` — horizontal wizard, vertical timeline, minimal dots, and
/// gradient markers with elevation.
class StepperProgressScreen extends StatefulWidget {
  const StepperProgressScreen({super.key});

  @override
  State<StepperProgressScreen> createState() => _StepperProgressScreenState();
}

class _StepperProgressScreenState extends State<StepperProgressScreen> {
  int _wizardStep = 1;

  static const _wizardSteps = ['Cart', 'Address', 'Payment', 'Done'];

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Progress',
      color: Colors.indigo,
      children: [
        sectionHeader('Horizontal wizard (tap a step)'),
        ACDStepper(
          steps: _wizardSteps,
          activeStep: _wizardStep,
          onStepReached: (i) => setState(() => _wizardStep = i),
        ),
        const CodeSnippet(
          code: '''
ACDStepper(
  steps: const ['Cart', 'Address', 'Payment', 'Done'],
  activeStep: currentStep,
  onStepReached: (i) => setState(() => currentStep = i),
)''',
        ),
        const SizedBox(height: 32),
        sectionHeader('Vertical timeline, side titles'),
        ACDStepper(
          steps: const ['Signed up', 'Verified email', 'Profile complete'],
          activeStep: 1,
          direction: Axis.vertical,
        ),
        const SizedBox(height: 32),
        sectionHeader('Gradient markers + elevation'),
        ACDStepper(
          steps: const ['Draft', 'Review', 'Published'],
          activeStep: 1,
          finishedStepGradient:
              const LinearGradient(colors: [Colors.teal, Colors.green]),
          activeStepGradient:
              const LinearGradient(colors: [Colors.deepPurple, Colors.indigo]),
          markerElevation: 4,
        ),
        const SizedBox(height: 32),
        sectionHeader('Minimal dots'),
        ACDStepper(
          steps: const ['', '', '', '', ''],
          activeStep: 2,
          stepRadius: 6,
          showTitle: false,
        ),
      ],
    );
  }
}
