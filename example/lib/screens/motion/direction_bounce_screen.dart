import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

enum _Direction { vertical, horizontal, both }

enum _BounceStrength { none, soft, springy }

extension on _BounceStrength {
  Curve get curve => switch (this) {
    _BounceStrength.none => Curves.easeOut,
    _BounceStrength.soft => Curves.easeOutBack,
    _BounceStrength.springy => Curves.bounceOut,
  };
}

/// Direction, bounce curve, and start-opacity as independently tunable
/// knobs on top of `ACDStaggeredList`/`ACDStaggerOptions` — the entrance
/// direction and curve are just an `ACDMotionEffect`/`Curve` choice, not a
/// separate widget or vocabulary.
class MotionDirectionBounceScreen extends StatefulWidget {
  const MotionDirectionBounceScreen({super.key});

  @override
  State<MotionDirectionBounceScreen> createState() =>
      _MotionDirectionBounceScreenState();
}

class _MotionDirectionBounceScreenState
    extends State<MotionDirectionBounceScreen> {
  _Direction _direction = _Direction.vertical;
  _BounceStrength _bounce = _BounceStrength.springy;
  double _startOpacity = 0.3;
  bool _reverse = false;
  int _replayCount = 0;

  static const List<String> _fruits = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
  ];

  Widget _row(int index) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    width: _direction == _Direction.vertical ? null : 120,
    child: Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(_fruits[index % _fruits.length]),
      ),
    ),
  );

  ACDMotionEffect get _effect => switch (_direction) {
    _Direction.vertical => ACDMotionEffect(
      beginOpacity: _startOpacity,
      beginOffsetFactor: const Offset(0, 1),
    ),
    _Direction.horizontal => ACDMotionEffect(
      beginOpacity: _startOpacity,
      beginOffsetFactor: const Offset(1, 0),
    ),
    _Direction.both => ACDMotionEffect(
      beginOpacity: _startOpacity,
      beginOffsetFactor: const Offset(1, 1),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Direction & Bounce',
      subtitle: 'Direction, bounce curve, and start opacity as ACDStaggerOptions knobs',
      color: Colors.pinkAccent,
      children: [
        sectionHeader('Direction'),
        Wrap(
          spacing: 8,
          children: [
            for (final direction in _Direction.values)
              ChoiceChip(
                label: Text(direction.name),
                selected: _direction == direction,
                onSelected: (_) => setState(() {
                  _direction = direction;
                  _replayCount++;
                }),
              ),
          ],
        ),
        const SizedBox(height: 16),
        sectionHeader('Bounce curve'),
        Wrap(
          spacing: 8,
          children: [
            for (final bounce in _BounceStrength.values)
              ChoiceChip(
                label: Text(bounce.name),
                selected: _bounce == bounce,
                onSelected: (_) => setState(() {
                  _bounce = bounce;
                  _replayCount++;
                }),
              ),
          ],
        ),
        const SizedBox(height: 16),
        sectionHeader('Start opacity: ${_startOpacity.toStringAsFixed(1)}'),
        Slider(
          value: _startOpacity,
          onChanged: (value) => setState(() {
            _startOpacity = value;
            _replayCount++;
          }),
        ),
        Row(
          children: [
            Switch(
              value: _reverse,
              onChanged: (value) => setState(() {
                _reverse = value;
                _replayCount++;
              }),
            ),
            const Text('Reverse'),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 260,
          child: ACDStaggeredList(
            key: ValueKey(_replayCount),
            itemCount: _fruits.length,
            reverse: _reverse,
            scrollDirection: _direction == _Direction.vertical
                ? Axis.vertical
                : Axis.horizontal,
            options: ACDStaggerOptions(
              interval: const Duration(milliseconds: 100),
              itemDuration: const Duration(milliseconds: 500),
              curve: _bounce.curve,
              effect: _effect,
            ),
            itemBuilder: (context, index) => _row(index),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() => _replayCount++),
          icon: const Icon(Icons.replay),
          label: const Text('Replay'),
        ),
        const CodeSnippet(
          code: '''
ACDStaggeredList(
  itemCount: fruits.length,
  scrollDirection: Axis.horizontal,
  reverse: reverse,
  options: ACDStaggerOptions(
    interval: const Duration(milliseconds: 100),
    curve: Curves.bounceOut,
    effect: ACDMotionEffect(
      beginOpacity: 0.3,
      beginOffsetFactor: const Offset(1, 0),
    ),
  ),
  itemBuilder: (context, index) => ListTile(title: Text(fruits[index])),
)''',
        ),
      ],
    );
  }
}
