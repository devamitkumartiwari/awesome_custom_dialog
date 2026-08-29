import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// All 10 `ACDMotionRestEffect` presets, side by side.
class MotionRestEffectsScreen extends StatelessWidget {
  const MotionRestEffectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Rest effects',
      color: Colors.pinkAccent,
      children: [
        sectionHeader('All 10 presets, looping continuously'),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: [
            for (final effect in ACDMotionRestEffect.values)
              _RestEffectTile(effect: effect),
          ],
        ),
        const CodeSnippet(
          code: '''
ACDMotion(
  restEffect: const ACDRestEffectConfig(
    effect: ACDMotionRestEffect.pulse,
  ),
  child: const Icon(Icons.favorite),
)''',
        ),
      ],
    );
  }
}

class _RestEffectTile extends StatelessWidget {
  const _RestEffectTile({required this.effect});

  final ACDMotionRestEffect effect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      child: Column(
        children: [
          ACDMotion(
            restEffect: ACDRestEffectConfig(effect: effect),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.pinkAccent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.star, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(effect.name, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
