import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/showcase_widgets.dart';

/// What goes inside a dialog: actions, buttons, a validated text field,
/// lists (tiles, radio, checkbox) and a progress spinner.
class DialogContentScreen extends StatelessWidget {
  const DialogContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Dialog content',
      color: Colors.teal,
      children: [
        sectionHeader('Buttons'),
        buildList([
          listItem(
            'Actions + result',
            'Role-based buttons, await the choice',
            Icons.touch_app_outlined,
            () => _actions(context),
          ),
          listItem(
            'Two buttons',
            'Styled Cancel / Confirm row',
            Icons.view_column_outlined,
            () => _twoButtons(context),
          ),
        ]),
        const CodeSnippet(
          code: '''
final delete = await (ACDDialog().build(context)
      ..text(text: 'Delete this photo?')
      ..actions(const [
        ACDAction(label: 'Cancel', role: ACDActionRole.cancel),
        ACDAction(label: 'Delete', role: ACDActionRole.destructive, value: true),
      ]))
    .showForResult<bool>();''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Inputs & lists'),
        buildList([
          listItem(
            'Text field',
            'Validated input with Cancel / Submit',
            Icons.text_fields,
            () => _textField(context),
          ),
          listItem(
            'List tiles',
            'Tap an action row',
            Icons.list_alt,
            () => _tiles(context),
          ),
          listItem(
            'Radio buttons',
            'Pick one option',
            Icons.radio_button_checked,
            () => _radio(context),
          ),
          listItem(
            'Checkboxes',
            'Pick several options',
            Icons.check_box_outlined,
            () => _checkboxes(context),
          ),
          listItem(
            'Progress',
            'Spinner that closes after 3 s',
            Icons.hourglass_empty,
            () => _progress(context),
          ),
        ]),
      ],
    );
  }

  Future<void> _actions(BuildContext context) async {
    final bool? delete =
        await (ACDDialog().build(context)
              ..text(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                text: 'Delete this photo?',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )
              ..text(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                text: 'It will be removed from all your devices.',
              )
              ..actions(const [
                ACDAction(label: 'Cancel', role: ACDActionRole.cancel),
                ACDAction(
                  label: 'Delete',
                  role: ACDActionRole.destructive,
                  value: true,
                ),
              ]))
            .showForResult<bool>();
    if (!context.mounted) return;
    ACDDialog.toast(
      context: context,
      message: delete == true ? 'Deleted' : 'Kept',
    ).show();
  }

  void _twoButtons(BuildContext context) {
    ACDDialog().build(context)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Save changes before leaving?',
        fontSize: 16,
      )
      ..twoButton(
        text1: 'Discard',
        color1: Colors.grey,
        text2: 'Save',
        color2: Colors.teal,
        fontWeight2: FontWeight.bold,
      )
      ..show();
  }

  void _textField(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final GlobalKey<FormFieldState<String>> fieldKey = GlobalKey();
    final ACDDialog dialog = ACDDialog().build(context)
      ..borderRadius = 24
      ..dismissCallBack = controller.dispose
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
        text: "What's your name?",
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..acdTextField(
        controller: controller,
        hint: 'Enter your full name',
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        fieldKey: fieldKey,
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Name is required' : null,
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
        isClickAutoDismiss: false,
        onTap1: dialog.dismiss,
        onTap2: () {
          if (fieldKey.currentState?.validate() ?? false) dialog.dismiss();
        },
      )
      ..show();
  }

  void _tiles(BuildContext context) {
    ACDDialog().build(context)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Choose action',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..listOfACDListTile(
        height: 200,
        items: const [
          ACDListTileItem(leading: Icon(Icons.edit_outlined), text: 'Edit'),
          ACDListTileItem(leading: Icon(Icons.share_outlined), text: 'Share'),
          ACDListTileItem(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            text: 'Move to trash',
            color: Colors.red,
          ),
        ],
        onClickItemListener: (i) => debugPrint('Tapped $i'),
      )
      ..show();
  }

  void _radio(BuildContext context) {
    ACDDialog().build(context)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Language',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..listOfACDRadioButton(
        initialValue: 0,
        activeColor: Colors.teal,
        items: const [
          ACDRadioItem(text: 'English'),
          ACDRadioItem(text: 'Español'),
          ACDRadioItem(text: 'Français'),
        ],
      )
      ..oneButton(text: 'Apply', color: Colors.teal)
      ..show();
  }

  void _checkboxes(BuildContext context) {
    ACDDialog().build(context)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Features',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..listOfACDCheckbox(
        initialValues: const [0, 2],
        activeColor: Colors.teal,
        items: const [
          ACDCheckboxItem(text: 'Offline access'),
          ACDCheckboxItem(text: 'Biometric login'),
          ACDCheckboxItem(text: 'Dark mode'),
        ],
      )
      ..oneButton(text: 'Done', color: Colors.teal)
      ..show();
  }

  void _progress(BuildContext context) {
    ACDDialog().build(context)
      ..borderRadius = 24
      ..barrierDismissible = false
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        text: 'Syncing…',
        fontSize: 18,
        alignment: Alignment.center,
      )
      ..acdProgress(padding: const EdgeInsets.only(bottom: 32))
      ..autoDismissAfter = const Duration(seconds: 3)
      ..show();
  }
}
