import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// Six styling combinations of `ACDSlideAction`, matching every look shown
/// in `flutter_swipe_button`'s own example gallery.
class SlideActionGalleryScreen extends StatelessWidget {
  const SlideActionGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Styling gallery',
      color: Colors.deepPurple,
      children: [
        sectionHeader('1. Expand + custom thumb icon + fast duration'),
        ACDSlideAction(
          animationDuration: const Duration(milliseconds: 200),
          thumbIcon: Icons.keyboard_double_arrow_right,
          activeThumbColor: Colors.red,
          label: 'Slide to expand',
          labelTextStyle: const TextStyle(color: Colors.red),
          onConfirm: () => debugPrint('Swiped'),
        ),
        const SizedBox(height: 20),
        sectionHeader('2. Elevation + trackPadding'),
        ACDSlideAction(
          elevationTrack: 2,
          elevationThumb: 2,
          trackPadding: const EdgeInsets.all(6),
          label: 'Elevated track & thumb',
          onConfirm: () => debugPrint('Swiped'),
        ),
        const SizedBox(height: 20),
        sectionHeader('3. Chevron icon + thumbPadding + bold text'),
        ACDSlideAction(
          thumbIcon: Icons.chevron_right,
          thumbPadding: 3,
          label: 'SLIDE TO CONFIRM',
          labelTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          onConfirm: () => debugPrint('Swiped'),
        ),
        const SizedBox(height: 20),
        sectionHeader('4. Amber active color + circular radius + height 60'),
        ACDSlideAction(
          height: 60,
          activeTrackColor: Colors.amber,
          borderRadius: BorderRadius.circular(30),
          label: 'Amber theme',
          labelTextStyle: const TextStyle(color: Colors.red),
          onConfirm: () => debugPrint('Swiped'),
        ),
        const SizedBox(height: 20),
        sectionHeader('5. Zero border radius + custom colors + height 30'),
        ACDSlideAction(
          height: 30,
          borderRadius: BorderRadius.zero,
          activeTrackColor: Colors.blue,
          activeThumbColor: Colors.yellow,
          label: 'Minimal',
          labelTextStyle: const TextStyle(color: Colors.white, fontSize: 12),
          onConfirm: () => debugPrint('Swiped'),
        ),
        const SizedBox(height: 20),
        sectionHeader('6. Fixed width (not stretched)'),
        ACDSlideAction(
          width: 200,
          stretchToFill: false,
          label: 'Fixed width',
          onConfirm: () => debugPrint('Swiped'),
        ),
      ],
    );
  }
}
