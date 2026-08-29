import 'dart:async' show Timer;

import 'package:flutter/material.dart';

import 'acd_animated_text.dart';
import 'acd_motion_effect.dart';
import 'acd_motion_sequence_trigger.dart';

/// One step of an [ACDAnimatedTextSequence].
final class ACDAnimatedTextSequenceStep {
  /// Creates an [ACDAnimatedTextSequenceStep].
  const ACDAnimatedTextSequenceStep({
    required this.text,
    this.style,
    this.effect,
    this.staggerDelay,
    this.holdDuration = Duration.zero,
  });

  /// The text shown while this step is active.
  final String text;

  /// Text style for this step. Falls back to the sequence's ambient style.
  final TextStyle? style;

  /// Per-character effect for this step. `null` uses [ACDAnimatedText]'s
  /// own default.
  final ACDMotionEffect? effect;

  /// Stagger delay for this step. `null` uses [ACDAnimatedText]'s own
  /// default.
  final Duration? staggerDelay;

  /// How long to hold once this step's stagger completes before
  /// auto-advancing (only relevant when the sequence's `trigger` is
  /// [ACDMotionSequenceTrigger.auto]).
  final Duration holdDuration;
}

/// Chains multiple [ACDAnimatedTextSequenceStep]s, advancing automatically
/// or on tap, with optional looping — the [ACDAnimatedText] counterpart of
/// [ACDMotionSequence].
class ACDAnimatedTextSequence extends StatefulWidget {
  /// Creates an [ACDAnimatedTextSequence].
  ACDAnimatedTextSequence({
    super.key,
    required this.children,
    this.trigger = ACDMotionSequenceTrigger.auto,
    this.loop = false,
    this.onStepChanged,
    this.onSequenceComplete,
    this.onPressed,
  }) : assert(children.isNotEmpty, 'children must not be empty');

  /// The steps to play in order.
  final List<ACDAnimatedTextSequenceStep> children;

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
  State<ACDAnimatedTextSequence> createState() =>
      _ACDAnimatedTextSequenceState();
}

class _ACDAnimatedTextSequenceState extends State<ACDAnimatedTextSequence> {
  int _index = 0;
  Timer? _holdTimer;

  ACDAnimatedTextSequenceStep get _current => widget.children[_index];

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

  void _handleComplete() {
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
    final ACDAnimatedTextSequenceStep step = _current;
    Widget content = ACDAnimatedText(
      key: ValueKey(_index),
      text: step.text,
      style: step.style,
      effect:
          step.effect ??
          const ACDMotionEffect(
            beginOpacity: 0,
            beginOffsetFactor: Offset(0, 0.3),
          ),
      staggerDelay: step.staggerDelay ?? const Duration(milliseconds: 40),
      onComplete: _handleComplete,
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
