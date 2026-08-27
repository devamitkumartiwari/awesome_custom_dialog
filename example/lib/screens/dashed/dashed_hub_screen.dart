import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/showcase_widgets.dart';
import 'border_screen.dart';
import 'decoration_screen.dart';
import 'lines_screen.dart';

class DashedHubScreen extends StatelessWidget {
  const DashedHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Dashed & Dotted',
      color: Colors.brown,
      children: [
        CategoryCard(
          title: 'Lines',
          subtitle: 'ACDDashedLine — horizontal & vertical',
          icon: Icons.horizontal_rule_rounded,
          color: Colors.brown,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DashedLinesScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Decoration',
          subtitle: 'ACDDottedDecoration — a drop-in Decoration',
          icon: Icons.crop_square_rounded,
          color: Colors.brown,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DottedDecorationScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CategoryCard(
          title: 'Border',
          subtitle: 'ACDDashedBorder — wraps any widget, custom paths too',
          icon: Icons.border_outer_rounded,
          color: Colors.brown,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DashedBorderScreen()),
          ),
        ),
      ],
    );
  }
}
