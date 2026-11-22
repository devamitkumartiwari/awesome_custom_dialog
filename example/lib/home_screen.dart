import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import 'app_settings.dart';
import 'screens/animated_text_screen.dart';
import 'screens/autocomplete_screen.dart';
import 'screens/bottom_sheet_screen.dart';
import 'screens/dashed_screen.dart';
import 'screens/dialog_content_screen.dart';
import 'screens/dialog_layout_screen.dart';
import 'screens/dropdown_screen.dart';
import 'screens/loaders_screen.dart';
import 'screens/motion_screen.dart';
import 'screens/pin_field_screen.dart';
import 'screens/presets_screen.dart';
import 'screens/rating_bar_screen.dart';
import 'screens/searchable_list_screen.dart';
import 'screens/slide_action_screen.dart';
import 'screens/snackbar_screen.dart';
import 'screens/staggered_screen.dart';
import 'screens/stepper_screen.dart';
import 'screens/switch_screen.dart';
import 'screens/toast_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/design_switcher.dart';
import 'widgets/showcase_widgets.dart';

/// One demo screen per feature, grouped into four sections.
class _Demo {
  const _Demo(this.title, this.subtitle, this.icon, this.screen);

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget screen;
}

const List<(String, List<_Demo>)> _sections = [
  (
    'Dialogs',
    [
      _Demo(
        'Presets & loading',
        'Success, error, warning, info, loading',
        Icons.auto_awesome,
        PresetsScreen(),
      ),
      _Demo(
        'Dialog content',
        'Actions, buttons, text field, lists',
        Icons.touch_app_outlined,
        DialogContentScreen(),
      ),
      _Demo(
        'Position & style',
        'Gravity, animations, gradients, queue',
        Icons.open_with,
        DialogLayoutScreen(),
      ),
      _Demo(
        'Bottom sheet',
        'Grab handle, drag to close, results',
        Icons.vertical_align_bottom,
        BottomSheetScreen(),
      ),
      _Demo(
        'Searchable list',
        'Filter, multi-select, async, long lists',
        Icons.manage_search,
        SearchableListScreen(),
      ),
    ],
  ),
  (
    'Messages',
    [
      _Demo(
        'Toast',
        'Styles, stacking, promise & undo',
        Icons.notifications_active_outlined,
        ToastScreen(),
      ),
      _Demo(
        'Snackbar',
        'Success, failure, warning, help',
        Icons.chat_bubble_outline,
        SnackbarScreen(),
      ),
    ],
  ),
  (
    'Form fields',
    [
      _Demo(
        'Dropdown',
        'Dialog, sheet, menu, multi-select',
        Icons.arrow_drop_down_circle_outlined,
        DropdownScreen(),
      ),
      _Demo(
        'Autocomplete',
        'Typeahead, form field, @mentions',
        Icons.text_fields,
        AutocompleteScreen(),
      ),
      _Demo(
        'PIN / OTP',
        'Code field, controller, resend',
        Icons.pin_outlined,
        PinFieldScreen(),
      ),
    ],
  ),
  (
    'Controls & motion',
    [
      _Demo(
        'Slide to confirm',
        'Loading → success, presets',
        Icons.swipe_right_alt,
        SlideActionScreen(),
      ),
      _Demo(
        'Switch',
        'Toggles and a form field',
        Icons.toggle_on,
        SwitchScreen(),
      ),
      _Demo(
        'Rating bar',
        'Stars, hearts, form field',
        Icons.star_outline,
        RatingBarScreen(),
      ),
      _Demo(
        'Stepper',
        'Wizard, vertical, timeline',
        Icons.linear_scale,
        StepperScreen(),
      ),
      _Demo(
        'Progress',
        'Linear, circular, segments',
        Icons.donut_large,
        LoadersScreen(),
      ),
      _Demo(
        'Motion',
        'Entrance, exit, loops, sequences',
        Icons.animation,
        MotionScreen(),
      ),
      _Demo(
        'Animated text',
        'Per-character text effects',
        Icons.text_rotation_none,
        AnimatedTextScreen(),
      ),
      _Demo(
        'Staggered lists',
        'Cascading lists and grids',
        Icons.view_agenda_outlined,
        StaggeredScreen(),
      ),
      _Demo(
        'Dashed & dotted',
        'Lines, decorations, borders',
        Icons.border_style,
        DashedScreen(),
      ),
    ],
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static void _cycleTheme() {
    themeModeNotifier.value = switch (themeModeNotifier.value) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }

  @override
  Widget build(BuildContext context) {
    ACDDialog.init(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awesome Custom Dialog'),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeModeNotifier,
            builder: (context, mode, _) => IconButton(
              tooltip: 'Theme: ${mode.name}',
              icon: Icon(switch (mode) {
                ThemeMode.light => Icons.light_mode_outlined,
                ThemeMode.dark => Icons.dark_mode_outlined,
                ThemeMode.system => Icons.brightness_auto_outlined,
              }),
              onPressed: _cycleTheme,
            ),
          ),
          const DesignSwitcherButton(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          for (final (String title, List<_Demo> demos) in _sections) ...[
            sectionHeader(title),
            buildList([
              for (final _Demo d in demos)
                listItem(
                  d.title,
                  d.subtitle,
                  d.icon,
                  () => Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => d.screen)),
                ),
            ]),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}
