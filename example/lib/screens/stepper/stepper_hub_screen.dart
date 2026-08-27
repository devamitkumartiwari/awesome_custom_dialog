import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/showcase_widgets.dart';
import 'progress_screen.dart';
import 'timeline_screen.dart';

class StepperHubScreen extends StatelessWidget {
  const StepperHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Stepper',
      color: Colors.indigo,
      children: [
        CategoryCard(
          title: 'Progress',
          subtitle: 'Horizontal wizard, vertical, minimal dots, gradients',
          icon: Icons.linear_scale,
          color: Colors.indigo,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StepperProgressScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Timeline list',
          subtitle: 'ACDStepperListView — scrollable order-tracking style',
          icon: Icons.timeline_rounded,
          color: Colors.indigo,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StepperTimelineScreen()),
          ),
        ),
      ],
    );
  }
}
