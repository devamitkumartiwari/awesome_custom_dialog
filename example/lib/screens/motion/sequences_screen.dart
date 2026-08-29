import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDMotionSequence` and `ACDAnimatedTextSequence` — chained steps,
/// auto-advancing or tap-triggered, with looping.
class MotionSequencesScreen extends StatelessWidget {
  const MotionSequencesScreen({super.key});

  Widget _chip(String label, Color color) => Container(
        width: 120,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Sequences',
      color: Colors.pinkAccent,
      children: [
        sectionHeader('ACDMotionSequence — auto-advancing, looping'),
        ACDMotionSequence(
          loop: true,
          children: [
            ACDMotionSequenceStep(
              effect: ACDMotionEffect.fadeSlideIn(),
              holdDuration: const Duration(milliseconds: 700),
              child: _chip('Step 1', Colors.pink),
            ),
            ACDMotionSequenceStep(
              effect: ACDMotionEffect.scaleIn,
              holdDuration: const Duration(milliseconds: 700),
              child: _chip('Step 2', Colors.purple),
            ),
            ACDMotionSequenceStep(
              effect: ACDMotionEffect.slideInFromLeft(),
              holdDuration: const Duration(milliseconds: 700),
              child: _chip('Step 3', Colors.indigo),
            ),
          ],
        ),
        const CodeSnippet(
          code: '''
ACDMotionSequence(
  loop: true,
  children: [
    ACDMotionSequenceStep(child: Text('Step 1')),
    ACDMotionSequenceStep(child: Text('Step 2')),
  ],
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('ACDMotionSequence — tap to advance'),
        ACDMotionSequence(
          trigger: ACDMotionSequenceTrigger.tap,
          children: [
            ACDMotionSequenceStep(child: _chip('Tap me', Colors.teal)),
            ACDMotionSequenceStep(child: _chip('Again', Colors.deepOrange)),
            ACDMotionSequenceStep(child: _chip('Done!', Colors.green)),
          ],
        ),
        const SizedBox(height: 24),
        sectionHeader('ACDAnimatedTextSequence — rotating headline'),
        ACDAnimatedTextSequence(
          loop: true,
          children: const [
            ACDAnimatedTextSequenceStep(
              text: 'Build beautiful dialogs',
              holdDuration: Duration(seconds: 1),
            ),
            ACDAnimatedTextSequenceStep(
              text: 'Animate anything',
              holdDuration: Duration(seconds: 1),
            ),
            ACDAnimatedTextSequenceStep(
              text: 'Zero dependencies',
              holdDuration: Duration(seconds: 1),
            ),
          ],
        ),
      ],
    );
  }
}
