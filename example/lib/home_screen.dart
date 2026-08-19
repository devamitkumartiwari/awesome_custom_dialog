import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import 'screens/animations_screen.dart';
import 'screens/buttons_screen.dart';
import 'screens/inputs_screen.dart';
import 'screens/positioning_screen.dart';
import 'screens/presets_screen.dart';
import 'screens/snackbar_screen.dart';
import 'screens/toast_screen.dart';

class _Category {
  const _Category({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
}

final List<_Category> _categories = [
  _Category(
    title: 'Presets & Feedback',
    subtitle: 'Success, Error, Warning, Info dialogs',
    icon: Icons.auto_awesome,
    color: Colors.green,
    builder: (_) => const PresetsScreen(),
  ),
  _Category(
    title: 'Buttons & Actions',
    subtitle: 'One, two, and three button layouts',
    icon: Icons.smart_button,
    color: Colors.indigo,
    builder: (_) => const ButtonsScreen(),
  ),
  _Category(
    title: 'Inputs & Menus',
    subtitle: 'Text fields, lists, radio, checkboxes, progress',
    icon: Icons.edit_note,
    color: Colors.purple,
    builder: (_) => const InputsScreen(),
  ),
  _Category(
    title: 'Animations',
    subtitle: 'Fade, scale, bounce, slide, rotate',
    icon: Icons.animation,
    color: Colors.pink,
    builder: (_) => const AnimationsScreen(),
  ),
  _Category(
    title: 'Positioning & Misc',
    subtitle: 'Bottom drawer, top banner, side panel, queue',
    icon: Icons.open_with,
    color: Colors.deepOrange,
    builder: (_) => const PositioningScreen(),
  ),
  _Category(
    title: 'Toast',
    subtitle: 'Auto-dismissing toast messages',
    icon: Icons.notifications_active_outlined,
    color: Colors.teal,
    builder: (_) => const ToastScreen(),
  ),
  _Category(
    title: 'Snackbar',
    subtitle: 'Colorful success/failure/warning/help banners',
    icon: Icons.chat_bubble_outline,
    color: Colors.blueGrey,
    builder: (_) => const SnackbarScreen(),
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ACDDialog.init(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text(
              'Awesome Custom Dialog\nShowcase',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor:
                colorScheme.primaryContainer.withValues(alpha: 0.3),
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showAbout(context),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _CategoryCard(category: _categories[index]),
                childCount: _categories.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  void _showAbout(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 30
      ..animation = ACDAnimation.scale
      ..acdImage(
        assetPath: 'images/success.png',
        width: 80,
        height: 80,
        padding: const EdgeInsets.only(top: 32),
      )
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        text: 'Awesome Custom Dialog',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
      )
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        text: 'v1.0.0 • MIT License',
        color: Colors.black38,
        alignment: Alignment.center,
      )
      ..acdDivider()
      ..oneButton(text: 'Close', color: Colors.teal)
      ..show();
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final _Category category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: category.builder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(category.icon, color: category.color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
