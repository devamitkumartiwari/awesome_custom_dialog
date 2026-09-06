import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/showcase_widgets.dart';
import 'animated_text_screen.dart';
import 'dialog_styling_screen.dart';
import 'direction_bounce_screen.dart';
import 'entrance_basics_screen.dart';
import 'rest_effects_screen.dart';
import 'sequences_screen.dart';
import 'staggered_grid_screen.dart';
import 'staggered_list_screen.dart';
import 'staggered_sliver_screen.dart';

class MotionHubScreen extends StatelessWidget {
  const MotionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Motion & Animated Text',
      color: Colors.pinkAccent,
      children: [
        CategoryCard(
          title: 'Entrance & exit',
          subtitle: 'ACDMotion presets, delay/duration/curve, tap effects',
          icon: Icons.movie_filter_outlined,
          color: Colors.pinkAccent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MotionEntranceBasicsScreen(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Rest effects',
          subtitle: 'All 10 ACDMotionRestEffect presets',
          icon: Icons.autorenew_rounded,
          color: Colors.pinkAccent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MotionRestEffectsScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Animated text',
          subtitle: 'Per-character stagger, RTL, onComplete',
          icon: Icons.text_fields_rounded,
          color: Colors.pinkAccent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MotionAnimatedTextScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Sequences',
          subtitle: 'ACDMotionSequence & ACDAnimatedTextSequence',
          icon: Icons.playlist_play_rounded,
          color: Colors.pinkAccent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MotionSequencesScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        sectionHeader(
          'Staggered lists & grids',
          description: 'Each capability gets its own page below.',
        ),
        CategoryCard(
          title: 'Staggered list',
          subtitle: 'ACDStaggeredList — staggered ListView entrance/exit',
          icon: Icons.view_list_rounded,
          color: Colors.pinkAccent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MotionStaggeredListScreen(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Staggered grid',
          subtitle: 'ACDStaggeredGrid — staggered GridView entrance/exit',
          icon: Icons.grid_view_rounded,
          color: Colors.pinkAccent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MotionStaggeredGridScreen(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Staggered slivers',
          subtitle: 'ACDStaggeredSliverList/Grid — composed in one scroll view',
          icon: Icons.view_agenda_rounded,
          color: Colors.pinkAccent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MotionStaggeredSliverScreen(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Direction & bounce',
          subtitle: 'direction, bounce curve, start opacity, reverse',
          icon: Icons.swap_vert_circle_rounded,
          color: Colors.pinkAccent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MotionDirectionBounceScreen(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Dialog styling & content stagger',
          subtitle: 'shape, elevation, gradient, texture, contentStagger',
          icon: Icons.style_rounded,
          color: Colors.pinkAccent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MotionDialogStylingScreen(),
            ),
          ),
        ),
      ],
    );
  }
}
