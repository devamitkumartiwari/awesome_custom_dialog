import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

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

/// Advanced `ACDDropdownField` usage — custom equality/disabled/favorites,
/// paginated remote search, and full popup/search styling.
class DropdownAdvancedScreen extends StatelessWidget {
  const DropdownAdvancedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Advanced',
      color: Colors.cyan,
      children: [
        sectionHeader('compareFn + isDisabledItem + favoriteItems'),
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
            trailing:
                selected ? const Icon(Icons.check, color: Colors.teal) : null,
          ),
          decoration: const InputDecoration(
            labelText: 'Assign to',
            helperText: 'Noah is disabled · Ethan is pinned',
            border: OutlineInputBorder(),
          ),
          onChanged: (user) => debugPrint('Assigned to ${user?.name}'),
        ),
        const SizedBox(height: 24),
        sectionHeader('Paginated async search (onFindPaged)'),
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
        sectionHeader(
          'Full styling',
          description:
              'InputDecoration prefix icon, item text color/weight, tile '
              'and search field colors, custom clear icon',
        ),
        ACDDropdownField<String>(
          items: _countries,
          decoration: InputDecoration(
            labelText: 'Country',
            prefixIcon: const Icon(Icons.public),
            filled: true,
            fillColor: Colors.teal.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          itemTextColor: Colors.teal.shade900,
          itemFontWeight: FontWeight.w600,
          tileColor: Colors.teal.shade50,
          searchFillColor: Colors.white,
          searchBorderColor: Colors.teal,
          searchBorderRadius: 12,
          showClearButton: true,
          clearIcon: Icons.cancel_rounded,
          onChanged: (value) => debugPrint('Picked $value'),
        ),
        const CodeSnippet(
          code: '''
ACDDropdownField<String>(
  items: countries,
  decoration: InputDecoration(
    labelText: 'Country',
    prefixIcon: const Icon(Icons.public),
    filled: true,
    fillColor: Colors.teal.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  itemTextColor: Colors.teal.shade900,
  itemFontWeight: FontWeight.w600,
  tileColor: Colors.teal.shade50,
  searchFillColor: Colors.white,
  searchBorderColor: Colors.teal,
  searchBorderRadius: 12,
  showClearButton: true,
  clearIcon: Icons.cancel_rounded,
  onChanged: (value) => print('Picked \$value'),
)''',
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
