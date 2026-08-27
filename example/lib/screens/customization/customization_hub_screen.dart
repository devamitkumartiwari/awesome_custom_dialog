import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/showcase_widgets.dart';
import 'colors_gradients_screen.dart';
import 'icons_typography_screen.dart';
import 'shapes_elevation_screen.dart';

/// Entry point for a live, interactive tour of the package's customization
/// surface — colors, gradients, shapes, elevation, icons, and typography —
/// across several widget families at once.
class CustomizationHubScreen extends StatelessWidget {
  const CustomizationHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CategoryScaffold(
      title: 'Customization Showcase',
      subtitle: 'Every widget shares the same styling surface — try it live',
      color: scheme.primary,
      children: [
        CategoryCard(
          title: 'Colors & Gradients',
          subtitle: 'Live palette + flat-vs-gradient across four widgets',
          icon: Icons.palette_outlined,
          color: Colors.pink,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ColorsGradientsScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Shapes & Elevation',
          subtitle:
              'Rect / rounded / circle / custom path, and a shadow ladder',
          icon: Icons.category_outlined,
          color: Colors.amber.shade800,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ShapesElevationScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Icons & Typography',
          subtitle: 'Icon overrides + font shortcuts vs full TextStyle',
          icon: Icons.text_fields_rounded,
          color: Colors.blue,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const IconsTypographyScreen()),
          ),
        ),
      ],
    );
  }
}
