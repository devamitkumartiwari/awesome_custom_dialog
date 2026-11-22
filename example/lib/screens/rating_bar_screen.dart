import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/showcase_widgets.dart';

/// `ACDRatingBar`: whole and half stars, a controlled rating, custom icons,
/// read-only display, and the `ACDRatingFormField` wrapper.
class RatingBarScreen extends StatefulWidget {
  const RatingBarScreen({super.key});

  @override
  State<RatingBarScreen> createState() => _RatingBarScreenState();
}

class _RatingBarScreenState extends State<RatingBarScreen> {
  double _rating = 3;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Rating bar',
      color: Colors.amber,
      children: [
        sectionHeader('Controlled'),
        ACDRatingBar(
          rating: _rating,
          semanticLabel: 'Your rating',
          onRatingUpdate: (v) => setState(() => _rating = v),
        ),
        const SizedBox(height: 8),
        Text('Rating: $_rating'),
        const CodeSnippet(
          code: '''
ACDRatingBar(
  rating: rating,
  onRatingUpdate: (v) => setState(() => rating = v),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Half stars, hearts, read-only'),
        const ACDRatingBar(initialRating: 3.5, allowHalfRating: true),
        const SizedBox(height: 12),
        const ACDRatingBar(
          initialRating: 4,
          filledIcon: Icons.favorite,
          emptyIcon: Icons.favorite_border,
          filledColor: Colors.pink,
        ),
        const SizedBox(height: 12),
        const ACDRatingBar(
          initialRating: 4.2,
          itemSize: 18,
          ratingPrecision: 0.1,
          interactionMode: ACDRatingInteractionMode.none,
        ),
        const SizedBox(height: 24),
        sectionHeader('In a form'),
        Form(
          key: _formKey,
          child: ACDRatingFormField(
            validator: (r) => (r ?? 0) == 0 ? 'Please rate your stay' : null,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _formKey.currentState?.validate(),
            child: const Text('Validate'),
          ),
        ),
      ],
    );
  }
}
