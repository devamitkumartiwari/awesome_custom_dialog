import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/showcase_widgets.dart';
import 'basics_screen.dart';
import 'custom_builder_screen.dart';
import 'styling_gallery_screen.dart';

class SwitchHubScreen extends StatelessWidget {
  const SwitchHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Switch',
      color: Colors.cyan,
      children: [
        CategoryCard(
          title: 'Basics',
          subtitle: 'Controlled, uncontrolled, controller, .material/.ios',
          icon: Icons.toggle_on_outlined,
          color: Colors.cyan,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SwitchBasicsScreen())),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Styling gallery',
          subtitle: 'Shapes, gradients, images, text, borders',
          icon: Icons.style_outlined,
          color: Colors.cyan,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SwitchStylingGalleryScreen(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Custom builders & drag',
          subtitle: 'trackBuilder/thumbBuilder, drag-to-toggle',
          icon: Icons.brush_outlined,
          color: Colors.cyan,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SwitchCustomBuilderScreen(),
            ),
          ),
        ),
      ],
    );
  }
}
