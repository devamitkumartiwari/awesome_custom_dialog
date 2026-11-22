import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/showcase_widgets.dart';

/// `ACDStaggeredList` and `ACDStaggeredGrid`: rows and cells cascade in by
/// index, and play a staggered exit when `visible` turns false.
class StaggeredScreen extends StatefulWidget {
  const StaggeredScreen({super.key});

  @override
  State<StaggeredScreen> createState() => _StaggeredScreenState();
}

class _StaggeredScreenState extends State<StaggeredScreen> {
  bool _visible = true;
  int _replay = 0;

  static const List<String> _fruits = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Fig',
  ];

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Staggered lists & grids',
      color: Colors.pinkAccent,
      children: [
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _replay++;
                _visible = true;
              }),
              icon: const Icon(Icons.replay),
              label: const Text('Replay'),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => _visible = !_visible),
              icon: Icon(_visible ? Icons.visibility_off : Icons.visibility),
              label: Text(_visible ? 'Play exit' : 'Show again'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        sectionHeader('List'),
        SizedBox(
          height: 300,
          child: ACDStaggeredList(
            key: ValueKey('list-$_replay'),
            itemCount: _fruits.length,
            visible: _visible,
            options: ACDStaggerOptions(
              interval: const Duration(milliseconds: 80),
              effect: ACDMotionEffect.slideInFromStart(context),
            ),
            itemBuilder: (context, i) => Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(_fruits[i]),
              ),
            ),
          ),
        ),
        const CodeSnippet(
          code: '''
ACDStaggeredList(
  itemCount: fruits.length,
  visible: visible, // false plays a staggered exit
  options: ACDStaggerOptions(
    interval: const Duration(milliseconds: 80),
    effect: ACDMotionEffect.slideInFromStart(context),
  ),
  itemBuilder: (context, i) => ListTile(title: Text(fruits[i])),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Grid'),
        SizedBox(
          height: 220,
          child: ACDStaggeredGrid(
            key: ValueKey('grid-$_replay'),
            visible: _visible,
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.6,
            ),
            options: const ACDStaggerOptions(
              interval: Duration(milliseconds: 50),
              effect: ACDMotionEffect(beginScale: 0, beginOpacity: 0),
            ),
            itemBuilder: (context, i) => Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.primaries[i % Colors.primaries.length],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${i + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
