import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/showcase_widgets.dart';
import 'button_layouts_screen.dart';
import 'button_styles_screen.dart';

class ButtonsHubScreen extends StatelessWidget {
  const ButtonsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Buttons & Actions',
      color: Colors.indigo,
      children: [
        CategoryCard(
          title: 'Layouts',
          subtitle: 'One, two, and three button rows',
          icon: Icons.view_agenda_outlined,
          color: Colors.indigo,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ButtonLayoutsScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Styled',
          subtitle: 'Background color, gradient, elevation, icon, shape',
          icon: Icons.palette_outlined,
          color: Colors.indigo,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ButtonStylesScreen()),
          ),
        ),
      ],
    );
  }
}
