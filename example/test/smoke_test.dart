import 'package:awesome_custom_dialog_example/screens/motion/animated_text_screen.dart';
import 'package:awesome_custom_dialog_example/screens/motion/entrance_basics_screen.dart';
import 'package:awesome_custom_dialog_example/screens/motion/motion_hub_screen.dart';
import 'package:awesome_custom_dialog_example/screens/motion/rest_effects_screen.dart';
import 'package:awesome_custom_dialog_example/screens/motion/sequences_screen.dart';
import 'package:awesome_custom_dialog_example/screens/rating_bar/basics_screen.dart';
import 'package:awesome_custom_dialog_example/screens/rating_bar/gallery_screen.dart';
import 'package:awesome_custom_dialog_example/screens/rating_bar/interaction_modes_screen.dart';
import 'package:awesome_custom_dialog_example/screens/rating_bar/rating_bar_hub_screen.dart';
import 'package:awesome_custom_dialog_example/screens/switch/basics_screen.dart';
import 'package:awesome_custom_dialog_example/screens/switch/custom_builder_screen.dart';
import 'package:awesome_custom_dialog_example/screens/switch/styling_gallery_screen.dart';
import 'package:awesome_custom_dialog_example/screens/switch/switch_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  for (final entry in <String, Widget>{
    'SwitchHubScreen': const SwitchHubScreen(),
    'SwitchBasicsScreen': const SwitchBasicsScreen(),
    'SwitchStylingGalleryScreen': const SwitchStylingGalleryScreen(),
    'SwitchCustomBuilderScreen': const SwitchCustomBuilderScreen(),
    'RatingBarHubScreen': const RatingBarHubScreen(),
    'RatingBarBasicsScreen': const RatingBarBasicsScreen(),
    'RatingBarInteractionModesScreen': const RatingBarInteractionModesScreen(),
    'RatingBarGalleryScreen': const RatingBarGalleryScreen(),
    'MotionHubScreen': const MotionHubScreen(),
    'MotionEntranceBasicsScreen': const MotionEntranceBasicsScreen(),
    'MotionRestEffectsScreen': const MotionRestEffectsScreen(),
    'MotionAnimatedTextScreen': const MotionAnimatedTextScreen(),
    'MotionSequencesScreen': const MotionSequencesScreen(),
  }.entries) {
    testWidgets('${entry.key} renders without error', (tester) async {
      await tester.pumpWidget(wrap(entry.value));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    });
  }
}
