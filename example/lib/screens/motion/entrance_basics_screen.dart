import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDMotion` entrance/exit basics — presets, delay/duration/curve, and
/// the tap gesture layer.
class MotionEntranceBasicsScreen extends StatefulWidget {
  const MotionEntranceBasicsScreen({super.key});

  @override
  State<MotionEntranceBasicsScreen> createState() =>
      _MotionEntranceBasicsScreenState();
}

class _MotionEntranceBasicsScreenState
    extends State<MotionEntranceBasicsScreen> {
  int _replayCount = 0;
  bool _visible = true;

  Widget _chip(String label, Color color) => Container(
    width: 64,
    height: 64,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      label,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Entrance & exit',
      color: Colors.pinkAccent,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _replayCount++),
            icon: const Icon(Icons.replay),
            label: const Text('Replay entrances'),
          ),
        ),
        const SizedBox(height: 16),
        sectionHeader('Presets'),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ACDMotion(
              key: ValueKey('fade-$_replayCount'),
              effect: ACDMotionEffect.fadeIn,
              child: _chip('Fade', Colors.pinkAccent),
            ),
            ACDMotion(
              key: ValueKey('scale-$_replayCount'),
              effect: ACDMotionEffect.scaleIn,
              child: _chip('Scale', Colors.purple),
            ),
            ACDMotion(
              key: ValueKey('slide-$_replayCount'),
              effect: ACDMotionEffect.slideInFromBottom(),
              child: _chip('Slide', Colors.indigo),
            ),
            ACDMotion(
              key: ValueKey('fadeslide-$_replayCount'),
              effect: ACDMotionEffect.fadeSlideIn(),
              child: _chip('Fade+Slide', Colors.teal),
            ),
            ACDMotion(
              key: ValueKey('blur-$_replayCount'),
              effect: ACDMotionEffect.blurIn(),
              child: _chip('Blur', Colors.deepOrange),
            ),
          ],
        ),
        const CodeSnippet(
          code: '''
ACDMotion(
  effect: ACDMotionEffect.fadeSlideIn(),
  child: const FlutterLogo(),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Staggered delay'),
        Wrap(
          spacing: 16,
          children: [
            for (int i = 0; i < 4; i++)
              ACDMotion(
                key: ValueKey('stagger-$i-$_replayCount'),
                effect: ACDMotionEffect.fadeSlideIn(),
                delay: Duration(milliseconds: i * 120),
                child: _chip(
                  '${i + 1}',
                  Colors.primaries[i % Colors.primaries.length],
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        sectionHeader('visible toggles the exit effect'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ACDMotion(
              visible: _visible,
              effect: ACDMotionEffect.fadeSlideIn(),
              child: _chip('Hi', Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => setState(() => _visible = !_visible),
              child: Text(_visible ? 'Hide' : 'Show'),
            ),
          ],
        ),
        const CodeSnippet(
          code: '''
ACDMotion(
  visible: visible,
  effect: ACDMotionEffect.fadeSlideIn(),
  child: const FlutterLogo(),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Tap effect + haptics'),
        ACDMotion(
          onTap: () {},
          hapticFeedbackOnTap: true,
          child: _chip('Tap me', Colors.pink),
        ),
        const SizedBox(height: 24),
        sectionHeader('Looping rest effect'),
        const ACDMotion(
          restEffect: ACDRestEffectConfig(effect: ACDMotionRestEffect.pulse),
          child: Icon(Icons.favorite, color: Colors.red, size: 40),
        ),
      ],
    );
  }
}
