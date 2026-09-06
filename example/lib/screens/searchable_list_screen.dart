import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../widgets/showcase_widgets.dart';

const List<String> _countries = [
  'United States',
  'United Kingdom',
  'Canada',
  'Australia',
  'Germany',
  'France',
  'Japan',
  'Brazil',
  'India',
  'South Africa',
];

const List<String> _skills = [
  'Flutter',
  'Dart',
  'Kotlin',
  'Swift',
  'React',
  'TypeScript',
  'Go',
  'Rust',
];

class _User {
  const _User(this.name, this.email);

  final String name;
  final String email;

  // Required for multiSearchableList()'s Set<T>-based selection tracking —
  // without this, two _User instances with the same data would be treated
  // as different selections.
  @override
  bool operator ==(Object other) =>
      other is _User && other.name == name && other.email == email;

  @override
  int get hashCode => Object.hash(name, email);
}

const List<_User> _users = [
  _User('Ava Thompson', 'ava@example.com'),
  _User('Liam Patel', 'liam@example.com'),
  _User('Noah García', 'noah@example.com'),
  _User('Mia Chen', 'mia@example.com'),
  _User('Ethan Rossi', 'ethan@example.com'),
];

class SearchableListScreen extends StatelessWidget {
  const SearchableListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ACDDialog.init(context);

    return CategoryScaffold(
      title: 'Searchable List',
      color: Colors.orange,
      children: [
        buildList([
          listItem(
            'Plain Strings',
            'Local filter over a simple list',
            Icons.search,
            () => _showLocalStringFilter(context),
          ),
          listItem(
            'Typed Model',
            'Custom item builder, single-select',
            Icons.person_search,
            () => _showTypedSingleSelect(context),
          ),
          listItem(
            'Multi Select',
            'Toggle rows, confirm to apply',
            Icons.checklist,
            () => _showMultiSelect(context),
          ),
          listItem(
            'Async Search',
            'Remote-style search with loading/empty/error',
            Icons.cloud_sync,
            () => _showAsyncSearch(context),
          ),
        ]),
        const CodeSnippet(
          code: '''
ACDDialog().build(context)
  ..searchableList<String>(
    items: countries,
    searchHint: 'Search countries',
    onChange: (country) => print('Picked \$country'),
  )
  ..show();''',
        ),
      ],
    );
  }

  void _showLocalStringFilter(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..height = 420
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        text: 'Choose a Country',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..searchableList<String>(
        items: _countries,
        searchHint: 'Search countries',
        onChange: (country) => debugPrint('Picked $country'),
      )
      ..show();
  }

  void _showTypedSingleSelect(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..height = 420
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        text: 'Assign To',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..searchableList<_User>(
        items: _users,
        itemAsString: (u) => u.name,
        searchHint: 'Search people',
        itemBuilder: (context, user, selected) => ListTile(
          leading: CircleAvatar(child: Text(user.name[0])),
          title: Text(user.name),
          subtitle: Text(user.email),
          trailing: selected
              ? const Icon(Icons.check, color: Colors.teal)
              : null,
        ),
        onChange: (user) => debugPrint('Assigned to ${user.name}'),
      )
      ..show();
  }

  void _showMultiSelect(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..height = 420
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        text: 'Your Skills',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..multiSearchableList<String>(
        items: _skills,
        initialValues: const ['Flutter'],
        searchHint: 'Search skills',
        checkboxActiveColor: Colors.teal,
        confirmColor: Colors.teal,
        confirmFontWeight: FontWeight.bold,
        onMultipleItemsChange: (skills) => debugPrint('Skills: $skills'),
      )
      ..show();
  }

  void _showAsyncSearch(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..height = 420
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        text: 'Remote Search',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..searchableList<String>(
        items: const [],
        searchHint: 'Try "error" to see the error state',
        onFind: _mockRemoteSearch,
        onChange: (result) => debugPrint('Picked $result'),
      )
      ..show();
  }

  // Simulates a network call so the demo can exercise the loading state
  // without needing a real backend — this package has zero runtime
  // dependencies, so no http client is pulled in just for this example.
  Future<List<String>> _mockRemoteSearch(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (query.toLowerCase() == 'error') {
      throw Exception('Simulated network failure');
    }
    return _countries
        .where((c) => c.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
