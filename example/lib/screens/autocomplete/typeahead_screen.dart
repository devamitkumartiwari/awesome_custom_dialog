import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

const List<String> _fruits = [
  'Apple',
  'Apricot',
  'Banana',
  'Blueberry',
  'Cherry',
  'Cranberry',
  'Grape',
  'Grapefruit',
  'Mango',
  'Melon',
  'Orange',
  'Papaya',
];

/// `ACDAutocompleteField` — local `filterFn` matching vs. a remote `onFind`
/// lookup, both generic typeahead fields.
class TypeaheadScreen extends StatelessWidget {
  const TypeaheadScreen({super.key});

  Future<List<String>> _remoteSearch(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _fruits
        .where((f) => f.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Typeahead',
      color: Colors.lightBlue,
      children: [
        sectionHeader('Local suggestions (default filter)'),
        ACDAutocompleteField<String>(
          suggestions: _fruits,
          decoration: const InputDecoration(
            labelText: 'Fruit',
            hintText: 'Type to search…',
            border: OutlineInputBorder(),
          ),
          onSuggestionSelected: (fruit) => debugPrint('Picked $fruit'),
        ),
        const SizedBox(height: 32),
        sectionHeader(
          'Custom filterFn',
          description: 'startsWith instead of the default contains',
        ),
        ACDAutocompleteField<String>(
          suggestions: _fruits,
          filterFn: (item, query) =>
              item.toLowerCase().startsWith(query.toLowerCase()),
          decoration: const InputDecoration(
            labelText: 'Fruit (starts with…)',
            border: OutlineInputBorder(),
          ),
          onSuggestionSelected: (fruit) => debugPrint('Picked $fruit'),
        ),
        const SizedBox(height: 32),
        sectionHeader(
          'Remote onFind',
          description: 'Debounced async lookup instead of local filtering',
        ),
        ACDAutocompleteField<String>(
          suggestions: const [],
          onFind: _remoteSearch,
          popupElevation: 8,
          popupBorderRadius: BorderRadius.circular(16),
          decoration: const InputDecoration(
            labelText: 'Remote fruit search',
            border: OutlineInputBorder(),
          ),
          onSuggestionSelected: (fruit) => debugPrint('Picked $fruit'),
        ),
        const CodeSnippet(
          code: '''
ACDAutocompleteField<String>(
  suggestions: const [],
  onFind: (query) => api.searchFruits(query),
  popupElevation: 8,
  popupBorderRadius: BorderRadius.circular(16),
  decoration: const InputDecoration(labelText: 'Remote fruit search'),
  onSuggestionSelected: (fruit) => print('Picked \$fruit'),
)''',
        ),
      ],
    );
  }
}
