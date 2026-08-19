import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../widgets/showcase_widgets.dart';

class InputsScreen extends StatelessWidget {
  const InputsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ACDDialog.init(context);

    return CategoryScaffold(
      title: 'Inputs & Menus',
      children: [
        buildList([
          listItem(
            'Form Input',
            'Text field with submit/cancel',
            Icons.edit_note,
            () => _showTextField(context),
          ),
          listItem(
            'Action Sheet',
            'List of icons and labels',
            Icons.menu_open,
            () => _showListTile(context),
          ),
          listItem(
            'Single Choice',
            'Radio button selection list',
            Icons.radio_button_checked,
            () => _showRadio(context),
          ),
          listItem(
            'Multi Choice',
            'Checkbox multi-selection list',
            Icons.check_box,
            () => _showCheckbox(context),
          ),
          listItem(
            'Progress',
            'Loading state with auto-dismiss',
            Icons.sync,
            () => _showProgress(context),
          ),
        ]),
      ],
    );
  }

  void _showTextField(BuildContext ctx) {
    final controller = TextEditingController();
    // acdTextField's validator is optional — omit it for a plain field.
    // Here we use it to require a non-empty name before Submit is allowed.
    final fieldKey = GlobalKey<FormFieldState<String>>();
    final dialog = ACDDialog().build(ctx)
      ..borderRadius = 24
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
        text: 'What\'s your name?',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..acdTextField(
        controller: controller,
        hint: 'Enter your full name',
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        fieldKey: fieldKey,
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'Name is required' : null,
      );
    dialog
      ..twoButton(
        padding: const EdgeInsets.only(top: 10),
        gravity: ACDGravity.right,
        text1: 'Cancel',
        color1: Colors.grey,
        text2: 'Submit',
        color2: Colors.teal,
        fontWeight2: FontWeight.bold,
        // Auto-dismiss is off so Submit can block on invalid input; Cancel
        // dismisses manually instead.
        isClickAutoDismiss: false,
        onTap1: dialog.dismiss,
        onTap2: () {
          if (fieldKey.currentState?.validate() ?? false) {
            debugPrint('Name: ${controller.text}');
            dialog.dismiss();
          }
        },
      )
      ..show();
  }

  void _showListTile(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Choose Action',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..acdDivider()
      ..listOfACDListTile(
        height: 240,
        items: const [
          ACDListTileItem(
              leading: Icon(Icons.edit_outlined), text: 'Edit Item'),
          ACDListTileItem(
              leading: Icon(Icons.share_outlined), text: 'Share Project'),
          ACDListTileItem(
              leading: Icon(Icons.copy_all_outlined), text: 'Duplicate'),
          ACDListTileItem(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            text: 'Move to Trash',
            color: Colors.red,
          ),
        ],
        onClickItemListener: (i) => debugPrint('Tapped $i'),
      )
      ..show();
  }

  void _showRadio(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Display Language',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..listOfACDRadioButton(
        initialValue: 0,
        activeColor: Colors.teal,
        items: const [
          ACDRadioItem(text: 'English (US)'),
          ACDRadioItem(text: 'Español'),
          ACDRadioItem(text: 'Français'),
          ACDRadioItem(text: 'Deutsch'),
        ],
      )
      ..acdDivider()
      ..oneButton(
          text: 'Apply Changes',
          color: Colors.teal,
          fontWeight: FontWeight.bold)
      ..show();
  }

  void _showCheckbox(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Select Features',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..listOfACDCheckbox(
        initialValues: const [0, 2],
        activeColor: Colors.teal,
        items: const [
          ACDCheckboxItem(text: 'Offline Access'),
          ACDCheckboxItem(text: 'Biometric Login'),
          ACDCheckboxItem(text: 'Dark Mode'),
          ACDCheckboxItem(text: 'Push Notifications'),
        ],
      )
      ..acdDivider()
      ..oneButton(text: 'Done', color: Colors.teal, fontWeight: FontWeight.bold)
      ..show();
  }

  void _showProgress(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 24
      ..barrierDismissible = false
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        text: 'Syncing Data...',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
      )
      ..acdProgress(
        padding: const EdgeInsets.only(bottom: 32),
        valueColor: Colors.teal,
      )
      ..autoDismissAfter = const Duration(seconds: 3)
      ..show();
  }
}
