import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/showcase_widgets.dart';
import 'basics_screen.dart';
import 'gallery_screen.dart';
import 'interaction_modes_screen.dart';

class RatingBarHubScreen extends StatelessWidget {
  const RatingBarHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Rating Bar',
      color: Colors.amber,
      children: [
        CategoryCard(
          title: 'Basics',
          subtitle: 'Whole/half stars, itemCount, controlled state',
          icon: Icons.star_rate_rounded,
          color: Colors.amber,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RatingBarBasicsScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Interaction modes',
          subtitle: 'tapOnly/dragOnly/none, clearOnReTap, hover preview',
          icon: Icons.touch_app_outlined,
          color: Colors.amber,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const RatingBarInteractionModesScreen(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Styling gallery',
          subtitle: 'Custom itemBuilder, vector star, precision, glow',
          icon: Icons.style_outlined,
          color: Colors.amber,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RatingBarGalleryScreen()),
          ),
        ),
      ],
    );
  }
}
