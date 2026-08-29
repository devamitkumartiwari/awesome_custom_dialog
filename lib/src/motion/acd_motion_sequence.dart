import 'dart:async' show Timer;

import 'package:flutter/material.dart';

import 'acd_motion.dart';
import 'acd_motion_effect.dart';
import 'acd_motion_sequence_trigger.dart';

/// One step of an [ACDMotionSequence].
final class ACDMotionSequenceStep {
  /// Creates an [ACDMotionSequenceStep].
  const ACDMotionSequenceStep({
    required this.child,
    this.effect = const ACDMotionEffect(beginOpacity: 0),
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOut,
    this.holdDuration = Duration.zero,
  });

  /// The widget shown while this step is active.
  final Widget child;

  /// This step's entrance effect.
  final ACDMotionEffect effect;

  /// This step's entrance duration.
  final Duration duration;

  /// This step's entrance curve.
  final Curve curve;

  /// How long to hold after the entrance settles before auto-advancing
  /// (only relevant when the sequence's `trigger` is
  /// [ACDMotionSequenceTrigger.auto]).
  final Duration holdDuration;
}

/// Chains multiple [ACDMotionSequenceStep]s, advancing automatically or on
/// tap, with optional looping.
///
/// ```dart
/// ACDMotionSequence(
///   trigger: ACDMotionSequenceTrigger.auto,
///   loop: true,
///   children: [
///     ACDMotionSequenceStep(child: Text('Step 1')),
///     ACDMotionSequenceStep(child: Text('Step 2')),
///   ],
/// )
/// ```
class ACDMotionSequence extends StatefulWidget {
  /// Creates an [ACDMotionSequence].
  ACDMotionSequence({
    super.key,
    required this.children,
    this.trigger = ACDMotionSequenceTrigger.auto,
    this.loop = false,
    this.onStepChanged,
    this.onSequenceComplete,
    this.onPressed,
  }) : assert(children.isNotEmpty, 'children must not be empty');

  /// The steps to play in order.
  final List<ACDMotionSequenceStep> children;

  /// How the sequence advances between steps.
  final ACDMotionSequenceTrigger trigger;

  /// Restarts from the first step after the last one finishes.
  final bool loop;

  /// Fires whenever the active step changes, with its new index.
  final ValueChanged<int>? onStepChanged;

  /// Fires once the last step finishes, when [loop] is `false`.
  final VoidCallback? onSequenceComplete;

  /// Fires on every tap, regardless of whether it advances the sequence.
  final VoidCallback? onPressed;

  @override
  State<ACDMotionSequence> createState() => _ACDMotionSequenceState();
}

class _ACDMotionSequenceState extends State<ACDMotionSequence> {
  int _index = 0;
  Timer? _holdTimer;

  ACDMotionSequenceStep get _current => widget.children[_index];

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _advance() {
    if (!mounted) return;
    final bool isLast = _index == widget.children.length - 1;
    if (isLast) {
      if (widget.loop) {
        setState(() => _index = 0);
        widget.onStepChanged?.call(_index);
      } else {
        widget.onSequenceComplete?.call();
      }
    } else {
      setState(() => _index += 1);
      widget.onStepChanged?.call(_index);
    }
  }

  void _handleEntranceComplete() {
    if (widget.trigger != ACDMotionSequenceTrigger.auto) return;
    _holdTimer?.cancel();
    if (_current.holdDuration > Duration.zero) {
      _holdTimer = Timer(_current.holdDuration, _advance);
    } else {
      _advance();
    }
  }

  void _handleTap() {
    widget.onPressed?.call();
    if (widget.trigger == ACDMotionSequenceTrigger.tap) _advance();
  }

  @override
  Widget build(BuildContext context) {
    final ACDMotionSequenceStep step = _current;
    Widget content = ACDMotion(
      key: ValueKey(_index),
      effect: step.effect,
      duration: step.duration,
      curve: step.curve,
      onEntranceComplete: _handleEntranceComplete,
      child: step.child,
    );
    if (widget.trigger == ACDMotionSequenceTrigger.tap ||
        widget.onPressed != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: content,
      );
    }
    return content;
  }
}
