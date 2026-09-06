import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/showcase_widgets.dart';
import 'basics_screen.dart';
import 'custom_builder_screen.dart';
import 'gallery_screen.dart';

class SlideActionHubScreen extends StatelessWidget {
  const SlideActionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Slide to Confirm',
      color: Colors.deepPurple,
      children: [
        CategoryCard(
          title: 'Basics',
          subtitle: 'Standard, .swipeButton preset, dual, circle + wave',
          icon: Icons.swipe_right_alt,
          color: Colors.deepPurple,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SlideActionBasicsScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Styling gallery',
          subtitle: 'Six flutter_swipe_button-parity styling combinations',
          icon: Icons.style_outlined,
          color: Colors.deepPurple,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SlideActionGalleryScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Custom builders & gradients',
          subtitle:
              'foreground/background/outer builders, active/inactive gradients',
          icon: Icons.brush_outlined,
          color: Colors.deepPurple,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SlideActionCustomBuilderScreen(),
            ),
          ),
        ),
      ],
    );
  }
}
