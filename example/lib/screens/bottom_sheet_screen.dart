import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/showcase_widgets.dart';

/// `ACDDialog.bottomSheet()` — a modal sheet with a grab handle and
/// drag-to-close, built from the usual dialog builder methods.
class BottomSheetScreen extends StatelessWidget {
  const BottomSheetScreen({super.key});

  static const List<String> _countries = [
    'Argentina',
    'Australia',
    'Austria',
    'Belgium',
    'Brazil',
    'Canada',
    'Chile',
    'Denmark',
  ];

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Bottom sheet',
      color: Colors.indigo,
      children: [
        buildList([
          listItem(
            'Share sheet',
            'Actions, returns the choice',
            Icons.ios_share_rounded,
            () => _share(context),
          ),
          listItem(
            'Picker sheet',
            'Searchable multi-select inside a sheet',
            Icons.public_rounded,
            () => _picker(context),
          ),
          listItem(
            "Can't be dragged away",
            'canPop = false',
            Icons.lock_outline,
            () => _locked(context),
          ),
        ]),
        const CodeSnippet(
          code: '''
final target = await (ACDDialog.bottomSheet(context: context)
      ..text(text: 'Share to')
      ..actions(const [
        ACDAction(label: 'Mail', value: 'mail'),
        ACDAction(label: 'Messages', value: 'messages'),
      ]))
    .showForResult<String>();''',
        ),
      ],
    );
  }

  Future<void> _share(BuildContext context) async {
    final String? target =
        await (ACDDialog.bottomSheet(context: context)
              ..text(
                text: 'Share to',
                fontWeight: FontWeight.w600,
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
              )
              ..actions(const [
                ACDAction(label: 'Mail', value: 'mail'),
                ACDAction(label: 'Messages', value: 'messages'),
                ACDAction(label: 'Cancel', role: ACDActionRole.cancel),
              ]))
            .showForResult<String>();
    if (target != null && context.mounted) {
      ACDDialog.toast(context: context, message: 'Shared via $target').show();
    }
  }

  void _picker(BuildContext context) {
    ACDDialog.bottomSheet(context: context)
      ..multiSearchableList<String>(
        items: _countries,
        groupBy: (c) => c[0],
        showSelectAll: true,
        maxSelection: 5,
        onMultipleItemsChange: (picked) => debugPrint('Picked $picked'),
      )
      ..show();
  }

  void _locked(BuildContext context) {
    ACDDialog.bottomSheet(context: context)
      ..canPop = false
      ..text(
        text: 'Finish this step first',
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      )
      ..oneButton(text: 'Done') // closes it
      ..show();
  }
}
