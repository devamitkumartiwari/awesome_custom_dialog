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

// No manual ==/hashCode override — ACDDropdownField's compareFn parameter
// (below) supplies selection equality instead, so a plain model class works
// as-is.
class _User {
  const _User(this.id, this.name, this.email);

  final int id;
  final String name;
  final String email;
}

const List<_User> _users = [
  _User(1, 'Ava Thompson', 'ava@example.com'),
  _User(2, 'Liam Patel', 'liam@example.com'),
  _User(3, 'Noah García', 'noah@example.com'),
  _User(4, 'Mia Chen', 'mia@example.com'),
  _User(5, 'Ethan Rossi', 'ethan@example.com'),
];

/// Showcases `ACDDropdownField`/`ACDMultiDropdownField` — the inline,
/// `Form`-compatible searchable dropdowns (vs. `searchableList()`, which
/// only works as content inside an already-open `ACDDialog`).
class DropdownFieldScreen extends StatefulWidget {
  const DropdownFieldScreen({super.key});

  @override
  State<DropdownFieldScreen> createState() => _DropdownFieldScreenState();
}

class _DropdownFieldScreenState extends State<DropdownFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _requiredCountry;

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Dropdown Field',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionLabel('Dialog mode + validator'),
              ACDDropdownField<String>(
                items: _countries,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
                searchHint: 'Search countries',
                validator: (value) =>
                    value == null ? 'Please pick a country' : null,
                onChanged: (value) => setState(() => _requiredCountry = value),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _formKey.currentState?.validate(),
                  child: const Text('Validate'),
                ),
              ),
              if (_requiredCountry != null) Text('Picked: $_requiredCountry'),
              const SizedBox(height: 24),
              const _SectionLabel('Bottom sheet mode + clear button'),
              ACDDropdownField<String>(
                items: _skills,
                mode: ACDDropdownMode.bottomSheet,
                showClearButton: true,
                decoration: const InputDecoration(
                  labelText: 'Primary skill',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => debugPrint('Skill: $value'),
              ),
              const SizedBox(height: 24),
              const _SectionLabel('Menu mode (anchored under the field)'),
              ACDDropdownField<String>(
                items: _countries,
                mode: ACDDropdownMode.menu,
                decoration: const InputDecoration(
                  labelText: 'Country (menu)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => debugPrint('Menu picked: $value'),
              ),
              const SizedBox(height: 24),
              const _SectionLabel('Multi-select'),
              ACDMultiDropdownField<String>(
                items: _skills,
                decoration: const InputDecoration(
                  labelText: 'Skills',
                  border: OutlineInputBorder(),
                ),
                checkboxActiveColor: Colors.teal,
                confirmColor: Colors.teal,
                onChanged: (values) => debugPrint('Skills: $values'),
              ),
              const SizedBox(height: 24),
              const _SectionLabel(
                'compareFn + isDisabledItem + favoriteItems',
              ),
              ACDDropdownField<_User>(
                items: _users,
                itemAsString: (u) => u.name,
                // Equality by id instead of a ==/hashCode override on _User.
                compareFn: (a, b) => a.id == b.id,
                isDisabledItem: (u) => u.id == 3,
                favoriteItems: [_users[4]],
                itemBuilder: (context, user, selected) => ListTile(
                  leading: CircleAvatar(child: Text(user.name[0])),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: selected
                      ? const Icon(Icons.check, color: Colors.teal)
                      : null,
                ),
                decoration: const InputDecoration(
                  labelText: 'Assign to',
                  helperText: 'Noah is disabled · Ethan is pinned',
                  border: OutlineInputBorder(),
                ),
                onChanged: (user) => debugPrint('Assigned to ${user?.name}'),
              ),
              const SizedBox(height: 24),
              const _SectionLabel('Paginated async search (onFindPaged)'),
              ACDDropdownField<String>(
                items: const [],
                onFindPaged: _mockPagedSearch,
                decoration: const InputDecoration(
                  labelText: 'Search a large remote list',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => debugPrint('Paged pick: $value'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  // Simulates a paginated backend: 12 pages of 20 generated results each,
  // filtered by [query]. This package has zero runtime dependencies, so
  // there's no real http client involved in the demo.
  Future<List<String>> _mockPagedSearch(String query, int page) async {
    await Future.delayed(const Duration(milliseconds: 400));
    const int pageSize = 20;
    const int totalPages = 12;
    if (page >= totalPages) return const [];
    return List.generate(
      pageSize,
      (i) => 'Result ${page * pageSize + i + 1}'
          '${query.isEmpty ? '' : ' ($query)'}',
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}
