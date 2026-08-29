import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'screens/autocomplete/autocomplete_hub_screen.dart';
import 'screens/buttons/buttons_hub_screen.dart';
import 'screens/customization/customization_hub_screen.dart';
import 'screens/dashed/dashed_hub_screen.dart';
import 'screens/dropdown/dropdown_hub_screen.dart';
import 'screens/inputs_screen.dart';
import 'screens/motion/motion_hub_screen.dart';
import 'screens/positioning_screen.dart';
import 'screens/presets_screen.dart';
import 'screens/rating_bar/rating_bar_hub_screen.dart';
import 'screens/searchable_list_screen.dart';
import 'screens/slide_action/slide_action_hub_screen.dart';
import 'screens/snackbar_screen.dart';
import 'screens/stepper/stepper_hub_screen.dart';
import 'screens/switch/switch_hub_screen.dart';
import 'screens/toast_screen.dart';
import 'screens/animations_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/showcase_widgets.dart';

class _Category {
  const _Category({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.group,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String group;
  final WidgetBuilder builder;
}

const String _dialogsGroup = 'Dialogs & Feedback';
const String _formsGroup = 'Forms & Inputs';
const String _controlsGroup = 'Interactive Controls';
const String _decorationGroup = 'Decoration & Motion';

final List<_Category> _categories = [
  _Category(
    title: 'Presets & Feedback',
    subtitle: 'Success, Error, Warning, Info dialogs',
    icon: Icons.auto_awesome,
    color: Colors.green,
    group: _dialogsGroup,
    builder: (_) => const PresetsScreen(),
  ),
  _Category(
    title: 'Toast',
    subtitle: 'Auto-dismissing toast messages',
    icon: Icons.notifications_active_outlined,
    color: Colors.teal,
    group: _dialogsGroup,
    builder: (_) => const ToastScreen(),
  ),
  _Category(
    title: 'Snackbar',
    subtitle: 'Colorful success/failure/warning/help banners',
    icon: Icons.chat_bubble_outline,
    color: Colors.blueGrey,
    group: _dialogsGroup,
    builder: (_) => const SnackbarScreen(),
  ),
  _Category(
    title: 'Inputs & Menus',
    subtitle: 'Text fields, lists, radio, checkboxes, progress',
    icon: Icons.edit_note,
    color: Colors.purple,
    group: _formsGroup,
    builder: (_) => const InputsScreen(),
  ),
  _Category(
    title: 'Searchable List',
    subtitle: 'Filterable single/multi-select, local or async',
    icon: Icons.search,
    color: Colors.orange,
    group: _formsGroup,
    builder: (_) => const SearchableListScreen(),
  ),
  _Category(
    title: 'Dropdown Field',
    subtitle: 'Inline Form field: dialog, bottom sheet, or menu popup',
    icon: Icons.arrow_drop_down_circle_outlined,
    color: Colors.cyan,
    group: _formsGroup,
    builder: (_) => const DropdownHubScreen(),
  ),
  _Category(
    title: 'Autocomplete',
    subtitle: 'Typeahead field + @mention/#hashtag triggers',
    icon: Icons.alternate_email,
    color: Colors.lightBlue,
    group: _formsGroup,
    builder: (_) => const AutocompleteHubScreen(),
  ),
  _Category(
    title: 'Buttons & Actions',
    subtitle: 'Layouts plus color, gradient, elevation, icon styling',
    icon: Icons.smart_button,
    color: Colors.indigo,
    group: _controlsGroup,
    builder: (_) => const ButtonsHubScreen(),
  ),
  _Category(
    title: 'Slide to Confirm',
    subtitle: 'Swipe-to-confirm action bar, presets, and a styling gallery',
    icon: Icons.swipe_right_alt,
    color: Colors.deepPurple,
    group: _controlsGroup,
    builder: (_) => const SlideActionHubScreen(),
  ),
  _Category(
    title: 'Switch',
    subtitle: 'Fully customizable toggle switch',
    icon: Icons.toggle_on_outlined,
    color: Colors.cyan,
    group: _controlsGroup,
    builder: (_) => const SwitchHubScreen(),
  ),
  _Category(
    title: 'Rating Bar',
    subtitle: 'Tap/drag star rating, continuous precision, presets',
    icon: Icons.star_rate_rounded,
    color: Colors.amber,
    group: _controlsGroup,
    builder: (_) => const RatingBarHubScreen(),
  ),
  _Category(
    title: 'Dashed & Dotted',
    subtitle: 'Dashed lines, box decoration, and border wrapper',
    icon: Icons.border_style,
    color: Colors.brown,
    group: _decorationGroup,
    builder: (_) => const DashedHubScreen(),
  ),
  _Category(
    title: 'Stepper',
    subtitle: 'Wizard progress bar and a scrollable timeline list',
    icon: Icons.linear_scale,
    color: Colors.indigo,
    group: _decorationGroup,
    builder: (_) => const StepperHubScreen(),
  ),
  _Category(
    title: 'Animations',
    subtitle: 'Fade, scale, bounce, slide, rotate',
    icon: Icons.animation,
    color: Colors.pink,
    group: _decorationGroup,
    builder: (_) => const AnimationsScreen(),
  ),
  _Category(
    title: 'Motion & Animated Text',
    subtitle: 'Entrance/rest/gesture effects, per-character text',
    icon: Icons.movie_filter_outlined,
    color: Colors.pinkAccent,
    group: _decorationGroup,
    builder: (_) => const MotionHubScreen(),
  ),
  _Category(
    title: 'Positioning & Misc',
    subtitle: 'Bottom drawer, top banner, side panel, queue',
    icon: Icons.open_with,
    color: Colors.deepOrange,
    group: _decorationGroup,
    builder: (_) => const PositioningScreen(),
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Category> get _filtered {
    if (_query.isEmpty) return _categories;
    return _categories
        .where(
          (c) =>
              c.title.toLowerCase().contains(_query) ||
              c.subtitle.toLowerCase().contains(_query),
        )
        .toList();
  }

  void _cycleTheme() {
    final current = themeModeNotifier.value;
    themeModeNotifier.value = switch (current) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }

  IconData get _themeIcon => switch (themeModeNotifier.value) {
        ThemeMode.light => Icons.light_mode_outlined,
        ThemeMode.dark => Icons.dark_mode_outlined,
        ThemeMode.system => Icons.brightness_auto_outlined,
      };

  @override
  Widget build(BuildContext context) {
    ACDDialog.init(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final filtered = _filtered;
    final searching = _query.isNotEmpty;

    final Map<String, List<_Category>> grouped = {};
    for (final c in filtered) {
      grouped.putIfAbsent(c.group, () => []).add(c);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 168,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            actions: [
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeModeNotifier,
                builder: (context, mode, _) => IconButton(
                  tooltip: 'Theme: ${mode.name}',
                  icon: Icon(_themeIcon),
                  onPressed: _cycleTheme,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showAbout(context),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
              title: Text(
                'Awesome Custom Dialog',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primaryContainer.withValues(alpha: 0.5),
                      scheme.surface,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A chainable, zero-dependency toolkit of dialogs, form '
                    'fields, and interactive widgets for Flutter.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      Chip(
                        avatar: Icon(Icons.widgets_outlined, size: 16),
                        label: Text('16+ features'),
                      ),
                      Chip(
                        avatar: Icon(Icons.block_flipped, size: 16),
                        label: Text('0 dependencies'),
                      ),
                      Chip(
                        avatar: Icon(Icons.palette_outlined, size: 16),
                        label: Text('Material 3'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search features…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searching
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                    ),
                  ),
                  if (!searching) ...[
                    const SizedBox(height: AppSpacing.lg),
                    CategoryCard(
                      title: 'Customization Showcase',
                      subtitle:
                          'Colors, gradients, shapes, elevation & icons — live',
                      icon: Icons.auto_fix_high_rounded,
                      color: scheme.primary,
                      featured: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CustomizationHubScreen(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (searching)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _openCard(context, filtered[index]),
                  ),
                  childCount: filtered.length,
                ),
              ),
            )
          else
            for (final group in grouped.entries)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(child: sectionHeader(group.key)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _openCard(context, group.value[index]),
                        ),
                        childCount: group.value.length,
                      ),
                    ),
                  ],
                ),
              ),
          const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xl)),
        ],
      ),
    );
  }

  Widget _openCard(BuildContext context, _Category category) {
    return CategoryCard(
      title: category.title,
      subtitle: category.subtitle,
      icon: category.icon,
      color: category.color,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: category.builder)),
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
        text: 'v1.4.0 • MIT License',
        color: Colors.black38,
        alignment: Alignment.center,
      )
      ..acdDivider()
      ..oneButton(
        text: 'Close',
        color: Colors.white,
        backgroundColor: Colors.teal,
        borderRadius: BorderRadius.circular(12),
      )
      ..show();
  }
}
