import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/showcase_widgets.dart';
import 'trigger_screen.dart';
import 'typeahead_screen.dart';

class AutocompleteHubScreen extends StatelessWidget {
  const AutocompleteHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Autocomplete',
      color: Colors.lightBlue,
      children: [
        CategoryCard(
          title: 'Typeahead',
          subtitle: 'ACDAutocompleteField — local & remote suggestions',
          icon: Icons.text_fields_rounded,
          color: Colors.lightBlue,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TypeaheadScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Triggers',
          subtitle: 'ACDTriggerAutocompleteField — @mention / #hashtag',
          icon: Icons.alternate_email,
          color: Colors.lightBlue,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TriggerScreen()),
          ),
        ),
      ],
    );
  }
}
