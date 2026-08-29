import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/showcase_widgets.dart';
import 'animated_text_screen.dart';
import 'entrance_basics_screen.dart';
import 'rest_effects_screen.dart';
import 'sequences_screen.dart';

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
                builder: (_) => const MotionEntranceBasicsScreen()),
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
      ],
    );
  }
}
