import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDRatingBar` styling gallery — custom icons, a vector star shape,
/// continuous precision, and glow/pop feedback.
class RatingBarGalleryScreen extends StatelessWidget {
  const RatingBarGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Styling gallery',
      color: Colors.amber,
      children: [
        sectionHeader('Custom icons — hearts instead of stars'),
        const ACDRatingBar(
          initialRating: 3,
          filledIcon: Icons.favorite,
          emptyIcon: Icons.favorite_border,
          filledColor: Colors.pink,
        ),
        const CodeSnippet(
          code: '''
ACDRatingBar(
  filledIcon: Icons.favorite,
  emptyIcon: Icons.favorite_border,
  filledColor: Colors.pink,
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader("Vector star shape (Flutter's built-in StarBorder)"),
        const ACDRatingBar(
          initialRating: 4,
          itemIconStyle: ACDRatingIconStyle.vectorStar,
          itemSize: 40,
          starPointRounding: 0.3,
        ),
        const CodeSnippet(
          code: '''
ACDRatingBar(
  itemIconStyle: ACDRatingIconStyle.vectorStar,
  starPointRounding: 0.3,
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Continuous precision (ratingPrecision: 0.1)'),
        const ACDRatingBar(initialRating: 3.7, ratingPrecision: 0.1),
        const SizedBox(height: 24),
        sectionHeader('Fully custom itemBuilder'),
        ACDRatingBar(
          itemCount: 5,
          initialRating: 3,
          itemSize: 40,
          itemBuilder: (context, index, fillFraction, status) => Icon(
            Icons.local_fire_department,
            color: Color.lerp(
              Colors.grey.shade300,
              Colors.deepOrange,
              fillFraction,
            ),
          ),
        ),
        const SizedBox(height: 24),
        sectionHeader('Glow + pop animation on change'),
        const ACDRatingBar(
          initialRating: 3,
          glowOnActive: true,
          popAnimationOnChange: true,
        ),
        const SizedBox(height: 24),
        sectionHeader('Gradient fill'),
        const ACDRatingBar(
          initialRating: 4,
          filledGradient: LinearGradient(
            colors: [Colors.purple, Colors.pinkAccent],
          ),
        ),
      ],
    );
  }
}
