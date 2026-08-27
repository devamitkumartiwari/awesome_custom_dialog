import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

const List<String> _mentionCandidates = ['alice', 'albert', 'amy', 'bob'];
const List<String> _hashtagCandidates = ['art', 'automation', 'android'];

/// `ACDTriggerAutocompleteField` — multi-trigger `@mention`/`#hashtag`
/// autocomplete, including styled option rows via `itemTextColor`/`itemStyle`.
class TriggerScreen extends StatelessWidget {
  const TriggerScreen({super.key});

  Future<List<String>> _findMentions(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mentionCandidates
        .where((n) => n.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
  }

  Future<List<String>> _findHashtags(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _hashtagCandidates
        .where((n) => n.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Triggers',
      color: Colors.lightBlue,
      children: [
        sectionHeader(
          'Mentions & hashtags',
          description: 'Two independent triggers, each with its own lookup',
        ),
        ACDTriggerAutocompleteField(
          decoration: const InputDecoration(
            labelText: 'Message',
            hintText: 'Try @al or #a…',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          minLines: 1,
          triggers: [
            ACDAutocompleteTrigger(
              trigger: '@',
              optionsBuilder: (q) async =>
                  (await _findMentions(q)).cast<Object?>(),
              itemBuilder: (context, option) => ListTile(
                leading: const Icon(Icons.alternate_email, size: 18),
                title: Text('$option'),
              ),
            ),
            ACDAutocompleteTrigger(
              trigger: '#',
              optionsBuilder: (q) async =>
                  (await _findHashtags(q)).cast<Object?>(),
              itemBuilder: (context, option) => ListTile(
                leading: const Icon(Icons.tag, size: 18),
                title: Text('$option'),
              ),
            ),
          ],
          onOptionSelected: (trigger, option) =>
              debugPrint('${trigger.trigger}$option selected'),
        ),
        const SizedBox(height: 32),
        sectionHeader(
          'Styled default rows',
          description:
              'itemTextColor/itemFontWeight instead of a custom itemBuilder',
        ),
        ACDTriggerAutocompleteField(
          decoration: const InputDecoration(
            labelText: 'Mention someone',
            hintText: 'Try @al…',
            border: OutlineInputBorder(),
          ),
          itemTextColor: Colors.deepPurple,
          itemFontWeight: FontWeight.w600,
          popupBorderRadius: BorderRadius.circular(16),
          triggers: [
            ACDAutocompleteTrigger(trigger: '@', optionsBuilder: _findMentions),
          ],
          onOptionSelected: (trigger, option) => debugPrint('$option selected'),
        ),
        const CodeSnippet(
          code: '''
ACDTriggerAutocompleteField(
  decoration: const InputDecoration(labelText: 'Mention someone'),
  itemTextColor: Colors.deepPurple,
  itemFontWeight: FontWeight.w600,
  popupBorderRadius: BorderRadius.circular(16),
  triggers: [
    ACDAutocompleteTrigger(trigger: '@', optionsBuilder: findMentions),
  ],
  onOptionSelected: (trigger, option) => print('\$option selected'),
)''',
        ),
      ],
    );
  }
}
