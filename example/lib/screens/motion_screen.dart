import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/showcase_widgets.dart';

/// `ACDMotion`: entrance presets, exit via `visible`, looping rest effects,
/// tap effects, and `ACDMotionSequence`.
class MotionScreen extends StatefulWidget {
  const MotionScreen({super.key});

  @override
  State<MotionScreen> createState() => _MotionScreenState();
}

class _MotionScreenState extends State<MotionScreen> {
  int _replay = 0;
  bool _visible = true;

  Widget _chip(String label, Color color) => Container(
    width: 72,
    height: 64,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final List<(String, ACDMotionEffect, Color)> presets = [
      ('Fade', ACDMotionEffect.fadeIn, Colors.pinkAccent),
      ('Scale', ACDMotionEffect.scaleIn, Colors.purple),
      ('Slide', ACDMotionEffect.slideInFromBottom(), Colors.indigo),
      ('Blur', ACDMotionEffect.blurIn(), Colors.deepOrange),
    ];
    return CategoryScaffold(
      title: 'Motion',
      color: Colors.pinkAccent,
      children: [
        sectionHeader('Entrance'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (int i = 0; i < presets.length; i++)
              ACDMotion(
                key: ValueKey('${presets[i].$1}-$_replay'),
                effect: presets[i].$2,
                delay: Duration(milliseconds: i * 100),
                child: _chip(presets[i].$1, presets[i].$3),
              ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => setState(() => _replay++),
            icon: const Icon(Icons.replay),
            label: const Text('Replay'),
          ),
        ),
        const CodeSnippet(
          code: '''
ACDMotion(
  effect: ACDMotionEffect.fadeSlideIn(),
  delay: const Duration(milliseconds: 100),
  child: const FlutterLogo(),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Exit (visible: false)'),
        Row(
          children: [
            ACDMotion(
              visible: _visible,
              effect: ACDMotionEffect.fadeSlideIn(),
              child: _chip('Hi', Colors.deepPurple),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () => setState(() => _visible = !_visible),
              child: Text(_visible ? 'Hide' : 'Show'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        sectionHeader('Looping & tap effects'),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            for (final ACDMotionRestEffect e in const [
              ACDMotionRestEffect.pulse,
              ACDMotionRestEffect.wave,
              ACDMotionRestEffect.swing,
            ])
              ACDMotion(
                restEffect: ACDRestEffectConfig(effect: e),
                child: _chip(e.name, Colors.pink),
              ),
            ACDMotion(
              onTap: () {},
              hapticFeedbackOnTap: true,
              child: _chip('Tap me', Colors.teal),
            ),
          ],
        ),
        const SizedBox(height: 24),
        sectionHeader('Sequence (tap to advance)'),
        ACDMotionSequence(
          trigger: ACDMotionSequenceTrigger.tap,
          loop: true,
          children: [
            ACDMotionSequenceStep(child: _chip('Step 1', Colors.teal)),
            ACDMotionSequenceStep(
              effect: ACDMotionEffect.scaleIn,
              child: _chip('Step 2', Colors.deepOrange),
            ),
            ACDMotionSequenceStep(child: _chip('Done!', Colors.green)),
          ],
        ),
      ],
    );
  }
}
