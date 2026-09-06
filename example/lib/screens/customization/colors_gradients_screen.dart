import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

const List<Color> _palette = [
  Colors.teal,
  Colors.deepPurple,
  Colors.orange,
  Colors.pink,
  Colors.blue,
];

/// A live playground: toggle gradient on/off and swap the active accent
/// color, watching four different widget families update together —
/// `ACDSlideAction`, `ACDStepper`, `ACDSnackbarContent`, and
/// `ACDDashedBorder` all share the same `Gradient?`-overrides-`Color`
/// pattern.
class ColorsGradientsScreen extends StatefulWidget {
  const ColorsGradientsScreen({super.key});

  @override
  State<ColorsGradientsScreen> createState() => _ColorsGradientsScreenState();
}

class _ColorsGradientsScreenState extends State<ColorsGradientsScreen> {
  bool _useGradient = true;
  int _colorIndex = 0;

  Color get _color => _palette[_colorIndex];

  Gradient? get _gradient => _useGradient
      ? LinearGradient(
          colors: [_color, Color.alphaBlend(Colors.white38, _color)],
        )
      : null;

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Colors & Gradients',
      color: Colors.pink,
      children: [
        sectionHeader('Controls'),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use gradient'),
                  subtitle: const Text(
                    'Every widget below accepts a Gradient? override',
                  ),
                  value: _useGradient,
                  onChanged: (v) => setState(() => _useGradient = v),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accent color',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: [
                    for (int i = 0; i < _palette.length; i++)
                      GestureDetector(
                        onTap: () => setState(() => _colorIndex = i),
                        child: CircleAvatar(
                          backgroundColor: _palette[i],
                          radius: 18,
                          child: i == _colorIndex
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        sectionHeader('ACDSlideAction'),
        ACDSlideAction(
          key: ValueKey('slide-$_useGradient-$_colorIndex'),
          inactiveTrackColor: _color,
          activeTrackColor: _color,
          inactiveTrackGradient: _gradient,
          activeTrackGradient: _gradient,
          label: 'Slide to confirm',
          onConfirm: () {},
        ),
        const SizedBox(height: 24),
        sectionHeader('ACDStepper marker'),
        ACDStepper(
          key: ValueKey('stepper-$_useGradient-$_colorIndex'),
          steps: const ['Start', 'Active', 'Next'],
          activeStep: 1,
          activeStepBackgroundColor: _color,
          activeStepGradient: _gradient,
        ),
        const SizedBox(height: 24),
        sectionHeader('ACDSnackbarContent'),
        ACDSnackbarContent(
          key: ValueKey('snackbar-$_useGradient-$_colorIndex'),
          title: _useGradient ? 'Gradient banner' : 'Flat color banner',
          message: 'color is ignored once gradient is set.',
          color: _color,
          gradient: _gradient,
        ),
        const SizedBox(height: 24),
        sectionHeader('ACDDashedBorder'),
        Center(
          child: ACDDashedBorder(
            key: ValueKey('border-$_useGradient-$_colorIndex'),
            shape: ACDDashedBorderShape.roundedRect,
            strokeWidth: 3,
            roundedCaps: true,
            color: _color,
            gradient: _gradient,
            child: const SizedBox(
              width: 200,
              height: 56,
              child: Center(child: Text('Dashed border')),
            ),
          ),
        ),
      ],
    );
  }
}
