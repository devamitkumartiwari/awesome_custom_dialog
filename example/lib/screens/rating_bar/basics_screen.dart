import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDRatingBar` basics — whole stars, half stars, custom itemCount, and a
/// fully controlled rating.
class RatingBarBasicsScreen extends StatefulWidget {
  const RatingBarBasicsScreen({super.key});

  @override
  State<RatingBarBasicsScreen> createState() => _RatingBarBasicsScreenState();
}

class _RatingBarBasicsScreenState extends State<RatingBarBasicsScreen> {
  double _controlledRating = 3;

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Basics',
      color: Colors.amber,
      children: [
        sectionHeader('Whole stars (uncontrolled)'),
        ACDRatingBar(
          initialRating: 3,
          onRatingUpdate: (v) => debugPrint('Rated $v'),
        ),
        const CodeSnippet(
          code: '''
ACDRatingBar(
  initialRating: 3,
  onRatingUpdate: (rating) => print('Rated \$rating'),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Half-star precision'),
        const ACDRatingBar(initialRating: 3.5, allowHalfRating: true),
        const CodeSnippet(
          code: "ACDRatingBar(initialRating: 3.5, allowHalfRating: true)",
        ),
        const SizedBox(height: 24),
        sectionHeader('10-item scale, smaller icons'),
        const ACDRatingBar(itemCount: 10, itemSize: 20, initialRating: 6),
        const SizedBox(height: 24),
        sectionHeader('Fully controlled'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ACDRatingBar(
              rating: _controlledRating,
              onRatingUpdate: (v) => setState(() => _controlledRating = v),
            ),
            const SizedBox(height: 8),
            Text('Current rating: $_controlledRating'),
          ],
        ),
        const CodeSnippet(
          code: '''
ACDRatingBar(
  rating: rating,
  onRatingUpdate: (v) => setState(() => rating = v),
)''',
        ),
      ],
    );
  }
}
