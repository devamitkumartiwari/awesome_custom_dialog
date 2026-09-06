import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDStaggeredList` — a dependency-free, staggered-entrance/exit list
/// built on the existing `ACDMotion` engine. Covers effects, `reverse`,
/// RTL-aware slide, and the entrance/exit lifecycle via `visible`.
class MotionStaggeredListScreen extends StatefulWidget {
  const MotionStaggeredListScreen({super.key});

  @override
  State<MotionStaggeredListScreen> createState() =>
      _MotionStaggeredListScreenState();
}

class _MotionStaggeredListScreenState extends State<MotionStaggeredListScreen> {
  bool _rtl = false;
  bool _reverse = false;
  bool _visible = true;
  int _replayCount = 0;

  static const List<String> _fruits = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
  ];

  Widget _row(int index) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: CircleAvatar(child: Text('${index + 1}')),
      title: Text(_fruits[index % _fruits.length]),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Staggered List',
      subtitle: 'ACDStaggeredList — zero-dependency staggered entrance/exit',
      color: Colors.pinkAccent,
      children: [
        sectionHeader(
          'Options',
          description: 'Every row cascades in, delayed by index.',
        ),
        Row(
          children: [
            Switch(
              value: _rtl,
              onChanged: (value) => setState(() => _rtl = value),
            ),
            const Text('RTL (slideInFromStart mirrors)'),
          ],
        ),
        Row(
          children: [
            Switch(
              value: _reverse,
              onChanged: (value) => setState(() => _reverse = value),
            ),
            const Text('Reverse'),
          ],
        ),
        const SizedBox(height: 8),
        Directionality(
          textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
          child: SizedBox(
            height: 320,
            child: ACDStaggeredList(
              key: ValueKey('list-$_replayCount-$_rtl-$_reverse'),
              itemCount: _fruits.length,
              visible: _visible,
              reverse: _reverse,
              options: ACDStaggerOptions(
                interval: const Duration(milliseconds: 80),
                effect: ACDMotionEffect.slideInFromStart(context),
              ),
              itemBuilder: (context, index) => _row(index),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _replayCount++;
                _visible = true;
              }),
              icon: const Icon(Icons.replay),
              label: const Text('Replay entrance'),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => _visible = !_visible),
              icon: Icon(_visible ? Icons.visibility_off : Icons.visibility),
              label: Text(_visible ? 'Play exit' : 'Show again'),
            ),
          ],
        ),
        const CodeSnippet(
          code: '''
ACDStaggeredList(
  itemCount: fruits.length,
  visible: visible,      // false plays a staggered exit
  reverse: reverse,      // covers a scrolled-reversed list
  options: ACDStaggerOptions(
    interval: const Duration(milliseconds: 80),
    effect: ACDMotionEffect.slideInFromStart(context), // RTL-aware
  ),
  itemBuilder: (context, index) => ListTile(title: Text(fruits[index])),
)''',
        ),
      ],
    );
  }
}
