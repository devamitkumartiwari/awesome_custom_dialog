import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDStaggeredGrid` — a dependency-free, staggered-entrance/exit grid
/// built on the existing `ACDMotion` engine.
class MotionStaggeredGridScreen extends StatefulWidget {
  const MotionStaggeredGridScreen({super.key});

  @override
  State<MotionStaggeredGridScreen> createState() =>
      _MotionStaggeredGridScreenState();
}

class _MotionStaggeredGridScreenState extends State<MotionStaggeredGridScreen> {
  bool _visible = true;
  int _crossAxisCount = 3;
  int _replayCount = 0;

  Widget _tile(int index) => Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.primaries[index % Colors.primaries.length],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      '${index + 1}',
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Staggered Grid',
      subtitle: 'ACDStaggeredGrid — zero-dependency staggered entrance/exit',
      color: Colors.pinkAccent,
      children: [
        sectionHeader(
          'Columns',
          description: 'Each cell scales + fades in, delayed by index.',
        ),
        Slider(
          value: _crossAxisCount.toDouble(),
          min: 2,
          max: 5,
          divisions: 3,
          label: '$_crossAxisCount columns',
          onChanged: (value) => setState(() {
            _crossAxisCount = value.round();
            _replayCount++;
          }),
        ),
        SizedBox(
          height: 260,
          child: ACDStaggeredGrid(
            key: ValueKey('grid-$_replayCount-$_crossAxisCount'),
            visible: _visible,
            itemCount: 12,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _crossAxisCount,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            options: const ACDStaggerOptions(
              interval: Duration(milliseconds: 50),
              effect: ACDMotionEffect(beginScale: 0, beginOpacity: 0),
            ),
            itemBuilder: (context, index) => _tile(index),
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
ACDStaggeredGrid(
  itemCount: items.length,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
  ),
  options: const ACDStaggerOptions(interval: Duration(milliseconds: 50)),
  itemBuilder: (context, index) => MyTile(items[index]),
)''',
        ),
      ],
    );
  }
}
