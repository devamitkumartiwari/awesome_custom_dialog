import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDAnimatedText` — per-character stagger, RTL, and `onComplete`.
class MotionAnimatedTextScreen extends StatefulWidget {
  const MotionAnimatedTextScreen({super.key});

  @override
  State<MotionAnimatedTextScreen> createState() =>
      _MotionAnimatedTextScreenState();
}

class _MotionAnimatedTextScreenState extends State<MotionAnimatedTextScreen> {
  int _replayCount = 0;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold);

    return CategoryScaffold(
      title: 'Animated text',
      color: Colors.pinkAccent,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () => setState(() {
              _replayCount++;
              _completed = false;
            }),
            icon: const Icon(Icons.replay),
            label: const Text('Replay'),
          ),
        ),
        const SizedBox(height: 16),
        sectionHeader('Fade + slide per character'),
        ACDAnimatedText(
          key: ValueKey('basic-$_replayCount'),
          text: 'Hello, world!',
          style: style,
          onComplete: () => setState(() => _completed = true),
        ),
        Text(
          _completed ? 'onComplete fired ✓' : 'animating…',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const CodeSnippet(
          code: '''
ACDAnimatedText(
  text: 'Hello, world!',
  onComplete: () => debugPrint('done'),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('onComplete fires even when text ends in a space'),
        ACDAnimatedText(
          key: ValueKey('space-$_replayCount'),
          text: 'Trailing space test ',
          style: style,
        ),
        const SizedBox(height: 24),
        sectionHeader('Word-by-word pacing (spaceDelay)'),
        ACDAnimatedText(
          key: ValueKey('word-$_replayCount'),
          text: 'One word at a time',
          style: style,
          staggerDelay: const Duration(milliseconds: 20),
          spaceDelay: const Duration(milliseconds: 200),
        ),
        const SizedBox(height: 24),
        sectionHeader('RTL (Hebrew) — stagger order mirrors automatically'),
        Directionality(
          textDirection: TextDirection.rtl,
          child: ACDAnimatedText(
            key: ValueKey('rtl-$_replayCount'),
            text: 'שלום עולם',
            style: style,
          ),
        ),
        const SizedBox(height: 24),
        sectionHeader('Scale + rotate effect'),
        ACDAnimatedText(
          key: ValueKey('scale-$_replayCount'),
          text: 'Bouncy!',
          style: style,
          effect: const ACDMotionEffect(
            beginOpacity: 0,
            beginScale: 0,
            beginRotationTurns: -0.1,
          ),
          curve: Curves.elasticOut,
          charDuration: const Duration(milliseconds: 600),
        ),
      ],
    );
  }
}
