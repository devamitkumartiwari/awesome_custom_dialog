import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDStaggeredSliverList`/`ACDStaggeredSliverGrid` — the `Sliver`
/// counterparts of `ACDStaggeredList`/`ACDStaggeredGrid`. The point of the
/// sliver variants is composing several staggered regions inside one
/// `CustomScrollView` — demoed here as a header, a sliver list, and a
/// sliver grid all sharing one scroll position.
class MotionStaggeredSliverScreen extends StatefulWidget {
  const MotionStaggeredSliverScreen({super.key});

  @override
  State<MotionStaggeredSliverScreen> createState() =>
      _MotionStaggeredSliverScreenState();
}

class _MotionStaggeredSliverScreenState
    extends State<MotionStaggeredSliverScreen> {
  int _replayCount = 0;

  static const List<String> _messages = ['Inbox', 'Sent', 'Drafts', 'Trash'];

  Widget _row(int index) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: ListTile(
      leading: const Icon(Icons.mail_outline),
      title: Text(_messages[index % _messages.length]),
    ),
  );

  Widget _tile(int index) => Container(
    margin: const EdgeInsets.all(4),
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
      title: 'Staggered Slivers',
      subtitle: 'ACDStaggeredSliverList / ACDStaggeredSliverGrid — one CustomScrollView',
      color: Colors.pinkAccent,
      children: [
        sectionHeader(
          'One scroll view, two staggered regions',
          description:
              'A header, a staggered sliver list, and a staggered '
              'sliver grid all composed inside a single CustomScrollView — '
              'this is the whole point of the sliver variants.',
        ),
        SizedBox(
          height: 480,
          child: CustomScrollView(
            key: ValueKey(_replayCount),
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Mail folders',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ACDStaggeredSliverList(
                itemCount: _messages.length,
                options: const ACDStaggerOptions(
                  interval: Duration(milliseconds: 80),
                ),
                itemBuilder: (context, index) => _row(index),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Attachments',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: ACDStaggeredSliverGrid(
                  itemCount: 9,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  options: const ACDStaggerOptions(
                    interval: Duration(milliseconds: 40),
                    effect: ACDMotionEffect(beginScale: 0, beginOpacity: 0),
                  ),
                  itemBuilder: (context, index) => _tile(index),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => setState(() => _replayCount++),
          icon: const Icon(Icons.replay),
          label: const Text('Replay entrance'),
        ),
        const CodeSnippet(
          code: '''
CustomScrollView(
  slivers: [
    const SliverToBoxAdapter(child: Text('Mail folders')),
    ACDStaggeredSliverList(
      itemCount: folders.length,
      itemBuilder: (context, index) => FolderTile(folders[index]),
    ),
    SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: ACDStaggeredSliverGrid(
        itemCount: attachments.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) => AttachmentTile(attachments[index]),
      ),
    ),
  ],
)''',
        ),
      ],
    );
  }
}
