import 'package:awesome_custom_dialog_example/home_screen.dart';
import 'package:awesome_custom_dialog_example/screens/animated_text_screen.dart';
import 'package:awesome_custom_dialog_example/screens/autocomplete_screen.dart';
import 'package:awesome_custom_dialog_example/screens/bottom_sheet_screen.dart';
import 'package:awesome_custom_dialog_example/screens/dashed_screen.dart';
import 'package:awesome_custom_dialog_example/screens/dialog_content_screen.dart';
import 'package:awesome_custom_dialog_example/screens/dialog_layout_screen.dart';
import 'package:awesome_custom_dialog_example/screens/dropdown_screen.dart';
import 'package:awesome_custom_dialog_example/screens/loaders_screen.dart';
import 'package:awesome_custom_dialog_example/screens/motion_screen.dart';
import 'package:awesome_custom_dialog_example/screens/pin_field_screen.dart';
import 'package:awesome_custom_dialog_example/screens/presets_screen.dart';
import 'package:awesome_custom_dialog_example/screens/rating_bar_screen.dart';
import 'package:awesome_custom_dialog_example/screens/searchable_list_screen.dart';
import 'package:awesome_custom_dialog_example/screens/slide_action_screen.dart';
import 'package:awesome_custom_dialog_example/screens/snackbar_screen.dart';
import 'package:awesome_custom_dialog_example/screens/staggered_screen.dart';
import 'package:awesome_custom_dialog_example/screens/stepper_screen.dart';
import 'package:awesome_custom_dialog_example/screens/switch_screen.dart';
import 'package:awesome_custom_dialog_example/screens/toast_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Every demo screen (and the home list) builds and runs its first
/// animations without throwing.
void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  for (final MapEntry<String, Widget> entry in <String, Widget>{
    'HomeScreen': const HomeScreen(),
    'PresetsScreen': const PresetsScreen(),
    'DialogContentScreen': const DialogContentScreen(),
    'DialogLayoutScreen': const DialogLayoutScreen(),
    'BottomSheetScreen': const BottomSheetScreen(),
    'SearchableListScreen': const SearchableListScreen(),
    'ToastScreen': const ToastScreen(),
    'SnackbarScreen': const SnackbarScreen(),
    'DropdownScreen': const DropdownScreen(),
    'AutocompleteScreen': const AutocompleteScreen(),
    'PinFieldScreen': const PinFieldScreen(),
    'SlideActionScreen': const SlideActionScreen(),
    'SwitchScreen': const SwitchScreen(),
    'RatingBarScreen': const RatingBarScreen(),
    'StepperScreen': const StepperScreen(),
    'LoadersScreen': const LoadersScreen(),
    'MotionScreen': const MotionScreen(),
    'AnimatedTextScreen': const AnimatedTextScreen(),
    'StaggeredScreen': const StaggeredScreen(),
    'DashedScreen': const DashedScreen(),
  }.entries) {
    testWidgets('${entry.key} renders without error', (tester) async {
      await tester.pumpWidget(wrap(entry.value));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    });
  }
}
