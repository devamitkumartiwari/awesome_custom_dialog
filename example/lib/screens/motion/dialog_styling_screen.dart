import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

enum _FillType { solid, gradient, texture }

enum _ShapeChoice { rounded, stadium, superellipse, beveled, continuous }

extension on _ShapeChoice {
  String get label => switch (this) {
    _ShapeChoice.rounded => 'Rounded rect',
    _ShapeChoice.stadium => 'Stadium',
    _ShapeChoice.superellipse => 'Superellipse',
    _ShapeChoice.beveled => 'Beveled',
    _ShapeChoice.continuous => 'Continuous',
  };

  // null means "use ACDDialog.borderRadius instead of a custom shape".
  ShapeBorder? resolve() => switch (this) {
    _ShapeChoice.rounded => null,
    _ShapeChoice.stadium => const StadiumBorder(),
    _ShapeChoice.superellipse => const RoundedSuperellipseBorder(
      borderRadius: BorderRadius.all(Radius.circular(28)),
    ),
    _ShapeChoice.beveled => const BeveledRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
    _ShapeChoice.continuous => const ContinuousRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
    ),
  };
}

/// `ACDDialog`'s shape/elevation/gradient/background-image/contentStagger
/// customization surface, plus the `stagger` param on the list builders —
/// filling the one gap the base dialog had versus its toast/snackbar
/// siblings (shape/elevation), and adding gradient/texture backgrounds and
/// staggered content entrance/exit on top.
class MotionDialogStylingScreen extends StatefulWidget {
  const MotionDialogStylingScreen({super.key});

  @override
  State<MotionDialogStylingScreen> createState() =>
      _MotionDialogStylingScreenState();
}

class _MotionDialogStylingScreenState extends State<MotionDialogStylingScreen> {
  _ShapeChoice _shape = _ShapeChoice.superellipse;
  _FillType _fill = _FillType.gradient;
  double _elevation = 16;
  bool _contentStagger = true;

  static const LinearGradient _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
  );

  bool get _onGradientOrTexture => _fill != _FillType.solid;

  void _openStyledDialog(BuildContext context) {
    final dialog = ACDDialog().build(context)
      ..shape = _shape.resolve()
      ..borderRadius = 24
      ..elevation = _elevation
      ..width = 300;

    switch (_fill) {
      case _FillType.solid:
        dialog.backgroundColor = Colors.white;
      case _FillType.gradient:
        dialog.backgroundGradient = _gradient;
      case _FillType.texture:
        dialog.backgroundColor = Colors.white;
        dialog.backgroundImage = const DecorationImage(
          image: NetworkImage('https://picsum.photos/seed/acd/400/400'),
          fit: BoxFit.cover,
          opacity: 0.35,
        );
    }

    if (_contentStagger) {
      dialog.contentStagger = const ACDStaggerOptions(
        interval: Duration(milliseconds: 80),
      );
    }

    final Color textColor = _onGradientOrTexture ? Colors.white : Colors.black;
    dialog
      ..text(
        text: 'Styled dialog',
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      )
      ..text(
        text:
            'shape / elevation / background / contentStagger — all '
            'opt-in fields on ACDDialog.',
        color: _onGradientOrTexture ? Colors.white70 : Colors.black54,
      )
      ..oneButton(
        text: 'Nice',
        backgroundColor: _onGradientOrTexture ? Colors.white : null,
        color: _onGradientOrTexture ? const Color(0xFF6A11CB) : null,
      )
      ..show();
  }

  void _openStaggeredListDialog(BuildContext context) {
    ACDDialog().build(context)
      ..borderRadius = 20
      ..text(text: 'Pick a fruit', fontSize: 18, fontWeight: FontWeight.bold)
      ..listOfACDListTile(
        height: 220,
        items: const [
          ACDListTileItem(text: 'Apple'),
          ACDListTileItem(text: 'Banana'),
          ACDListTileItem(text: 'Cherry'),
          ACDListTileItem(text: 'Date'),
        ],
        stagger: const ACDStaggerOptions(interval: Duration(milliseconds: 70)),
      )
      ..show();
  }

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Dialog Styling & Content Stagger',
      subtitle:
          'shape / elevation / gradient / backgroundImage / '
          'contentStagger / stagger',
      color: Colors.pinkAccent,
      children: [
        sectionHeader('Shape'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final choice in _ShapeChoice.values)
              ChoiceChip(
                label: Text(choice.label),
                selected: _shape == choice,
                onSelected: (_) => setState(() => _shape = choice),
              ),
          ],
        ),
        const SizedBox(height: 16),
        sectionHeader('Elevation: ${_elevation.round()}'),
        Slider(
          value: _elevation,
          min: 0,
          max: 24,
          divisions: 24,
          label: '${_elevation.round()}',
          onChanged: (value) => setState(() => _elevation = value),
        ),
        const SizedBox(height: 8),
        sectionHeader('Background fill'),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Solid color'),
              selected: _fill == _FillType.solid,
              onSelected: (_) => setState(() => _fill = _FillType.solid),
            ),
            ChoiceChip(
              label: const Text('Gradient'),
              selected: _fill == _FillType.gradient,
              onSelected: (_) => setState(() => _fill = _FillType.gradient),
            ),
            ChoiceChip(
              label: const Text('Texture (network image)'),
              selected: _fill == _FillType.texture,
              onSelected: (_) => setState(() => _fill = _FillType.texture),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _contentStagger,
          onChanged: (value) => setState(() => _contentStagger = value),
          title: const Text('contentStagger'),
          subtitle: const Text(
            'Stagger every top-level widget added to the dialog (text, '
            'buttons, …) instead of showing them all at once.',
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _openStyledDialog(context),
          child: const Text('Open styled dialog'),
        ),
        const CodeSnippet(
          code: '''
ACDDialog().build(context)
  ..shape = const RoundedSuperellipseBorder(
    borderRadius: BorderRadius.circular(28),
  )
  ..elevation = 16
  ..backgroundGradient = const LinearGradient(
    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
  )
  ..contentStagger = const ACDStaggerOptions()
  ..text(text: 'Styled dialog')
  ..oneButton(text: 'Nice')
  ..show();''',
        ),
        const SizedBox(height: 24),
        sectionHeader(
          'List-builder stagger',
          description:
              'listOfACDListTile()/listOfACDRadioButton()/'
              'listOfACDCheckbox() all take an optional `stagger` param too.',
        ),
        ElevatedButton(
          onPressed: () => _openStaggeredListDialog(context),
          child: const Text('Open dialog with a staggered list'),
        ),
        const CodeSnippet(
          code: '''
ACDDialog().build(context)
  ..listOfACDListTile(
    items: fruitItems,
    stagger: const ACDStaggerOptions(interval: Duration(milliseconds: 70)),
  )
  ..show();''',
        ),
      ],
    );
  }
}
