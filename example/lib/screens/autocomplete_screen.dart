import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/showcase_widgets.dart';

const List<String> _fruits = [
  'Apple',
  'Apricot',
  'Banana',
  'Blueberry',
  'Cherry',
  'Grape',
  'Mango',
  'Melon',
  'Orange',
  'Papaya',
];

/// `ACDAutocompleteField` (typeahead), its form-field wrapper, and
/// `ACDTriggerAutocompleteField` (@mentions / #hashtags).
class AutocompleteScreen extends StatefulWidget {
  const AutocompleteScreen({super.key});

  @override
  State<AutocompleteScreen> createState() => _AutocompleteScreenState();
}

class _AutocompleteScreenState extends State<AutocompleteScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static Future<List<String>> _remote(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _fruits
        .where((f) => f.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static Future<List<Object?>> _people(String q) async =>
      ['alice', 'albert', 'amy', 'bob'].where((n) => n.startsWith(q)).toList();

  static Future<List<Object?>> _tags(String q) async =>
      ['art', 'automation', 'android'].where((n) => n.startsWith(q)).toList();

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Autocomplete',
      color: Colors.lightBlue,
      children: [
        sectionHeader('Typeahead'),
        ACDAutocompleteField<String>(
          suggestions: _fruits,
          highlightMatches: true,
          decoration: const InputDecoration(
            labelText: 'Fruit',
            border: OutlineInputBorder(),
          ),
          onSuggestionSelected: (f) => debugPrint('Picked $f'),
        ),
        const SizedBox(height: 16),
        ACDAutocompleteField<String>(
          suggestions: const [],
          onFind: _remote,
          decoration: const InputDecoration(
            labelText: 'Remote search (onFind)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        sectionHeader('In a form: must pick from the list'),
        Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                child: ACDAutocompleteFormField<String>(
                  suggestions: _fruits,
                  decoration: const InputDecoration(
                    labelText: 'Favourite fruit',
                    border: OutlineInputBorder(),
                  ),
                  validator: (f) => f == null ? 'Pick one from the list' : null,
                ),
              ),
              TextButton(
                onPressed: () => _formKey.currentState?.validate(),
                child: const Text('Check'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        sectionHeader('@mentions & #hashtags'),
        ACDTriggerAutocompleteField(
          maxLines: 3,
          minLines: 1,
          popupAnchor: ACDPopupAnchor.caret,
          decoration: const InputDecoration(
            labelText: 'Message',
            hintText: 'Try @al or #a',
            border: OutlineInputBorder(),
          ),
          triggers: [
            ACDAutocompleteTrigger(trigger: '@', optionsBuilder: _people),
            ACDAutocompleteTrigger(trigger: '#', optionsBuilder: _tags),
          ],
          onOptionSelected: (t, o) => debugPrint('${t.trigger}$o'),
        ),
        const CodeSnippet(
          code: '''
ACDTriggerAutocompleteField(
  triggers: [
    ACDAutocompleteTrigger(trigger: '@', optionsBuilder: findPeople),
    ACDAutocompleteTrigger(trigger: '#', optionsBuilder: findTags),
  ],
  onOptionSelected: (trigger, option) => print('\${trigger.trigger}\$option'),
)''',
        ),
      ],
    );
  }
}
