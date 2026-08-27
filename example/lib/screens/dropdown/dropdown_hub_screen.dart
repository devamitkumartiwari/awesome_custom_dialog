import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/showcase_widgets.dart';
import 'dropdown_advanced_screen.dart';
import 'dropdown_basics_screen.dart';

class DropdownHubScreen extends StatelessWidget {
  const DropdownHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Dropdown Field',
      color: Colors.cyan,
      children: [
        CategoryCard(
          title: 'Basics',
          subtitle: 'Validator, popup modes, multi-select',
          icon: Icons.checklist_rtl_outlined,
          color: Colors.cyan,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DropdownBasicsScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Advanced',
          subtitle: 'Custom equality, disabled rows, pagination, styling',
          icon: Icons.tune_rounded,
          color: Colors.cyan,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DropdownAdvancedScreen()),
          ),
        ),
      ],
    );
  }
}
