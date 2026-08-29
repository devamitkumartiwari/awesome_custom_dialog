import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDRatingBar` interaction modes — tap-only, drag-only, read-only, plus
/// `clearOnReTap` and an opt-in hover preview.
class RatingBarInteractionModesScreen extends StatelessWidget {
  const RatingBarInteractionModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Interaction modes',
      color: Colors.amber,
      children: [
        sectionHeader('Tap and drag (default)'),
        const ACDRatingBar(initialRating: 2),
        const SizedBox(height: 24),
        sectionHeader('Tap only'),
        const ACDRatingBar(
          initialRating: 2,
          interactionMode: ACDRatingInteractionMode.tapOnly,
        ),
        const SizedBox(height: 24),
        sectionHeader('Drag only'),
        const ACDRatingBar(
          initialRating: 2,
          interactionMode: ACDRatingInteractionMode.dragOnly,
        ),
        const SizedBox(height: 24),
        sectionHeader('Read-only (no separate "indicator" widget needed)'),
        const ACDRatingBar(
          initialRating: 4,
          interactionMode: ACDRatingInteractionMode.none,
        ),
        const CodeSnippet(
          code:
              "ACDRatingBar(rating: 4, interactionMode: ACDRatingInteractionMode.none)",
        ),
        const SizedBox(height: 24),
        sectionHeader('clearOnReTap — tap the top rating again to clear it'),
        const ACDRatingBar(initialRating: 5, clearOnReTap: true),
        const SizedBox(height: 24),
        sectionHeader('Opt-in hover preview (desktop/web)'),
        const ACDRatingBar(initialRating: 2, enableHoverPreview: true),
      ],
    );
  }
}
