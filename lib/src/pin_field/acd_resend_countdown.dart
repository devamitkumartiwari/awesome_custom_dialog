import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../design/acd_design.dart';
import '../design/acd_design_scope.dart';
import '../design/internal/acd_adaptive_widgets.dart';
import '../design/internal/acd_platform_support.dart';

/// The "Resend code" button that sits under an OTP [ACDPinField]: disabled
/// with a countdown ("Resend code (0:28)"), then tappable. Tapping runs
/// [onResend] (a spinner shows while it's a pending `Future`) and restarts
/// the countdown.
///
/// ```dart
/// ACDResendCountdown(
///   duration: const Duration(seconds: 30),
///   onResend: () => auth.sendCode(phone),
/// )
/// ```
///
/// Screen readers hear when resending becomes available. If [onResend]
/// throws, the button is enabled again right away so the user can retry.
class ACDResendCountdown extends StatefulWidget {
  /// Creates an [ACDResendCountdown].
  const ACDResendCountdown({
    super.key,
    required this.onResend,
    this.duration = const Duration(seconds: 30),
    this.startCounting = true,
    this.label,
    this.waitingLabelBuilder,
    this.style,
    this.design,
  });

  /// Sends a new code. May return a `Future`; the button waits for it.
  final FutureOr<void> Function() onResend;

  /// How long the user must wait between sends.
  final Duration duration;

  /// Whether the first countdown starts immediately (the usual case right
  /// after the first code was sent). When `false`, the button starts
  /// enabled.
  final bool startCounting;

  /// The button label. Defaults to [ACDStrings.resendCode].
  final String? label;

  /// The disabled label for a remaining time. Defaults to
  /// `"<label> (m:ss)"`.
  final String Function(Duration remaining)? waitingLabelBuilder;

  /// Text style of the label (its colour is dimmed while waiting).
  final TextStyle? style;

  /// Material (default) / Cupertino / adaptive.
  final ACDDesign? design;

  @override
  State<ACDResendCountdown> createState() => _ACDResendCountdownState();
}

class _ACDResendCountdownState extends State<ACDResendCountdown> {
  Timer? _ticker;
  Duration _remaining = Duration.zero;
  bool _sending = false;

  bool get _waiting => _remaining > Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.startCounting) _start();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    _ticker?.cancel();
    _remaining = widget.duration;
    if (!_waiting) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return t.cancel();
      setState(() {
        final Duration next = _remaining - const Duration(seconds: 1);
        _remaining = next.isNegative ? Duration.zero : next;
      });
      if (!_waiting) {
        t.cancel();
        acdAnnounce(context, _label(context));
      }
    });
  }

  String _label(BuildContext context) =>
      widget.label ?? ACDDesignScope.stringsOf(context).resendCode;

  static String _clock(Duration d) {
    final int s = d.inSeconds;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _resend() async {
    if (_waiting || _sending) return;
    setState(() => _sending = true);
    try {
      await widget.onResend();
      if (mounted) _start();
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'awesome_custom_dialog',
          context: ErrorDescription('while resending a code'),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ACDResolvedDesign design = ACDDesign.resolve(context, widget.design);
    final String label = _label(context);
    final bool enabled = !_waiting && !_sending;
    final Color active = Theme.of(context).colorScheme.primary;
    final TextStyle base = TextStyle(
      color: enabled ? active : Theme.of(context).disabledColor,
      fontWeight: FontWeight.w600,
    ).merge(widget.style);
    final String text = _waiting
        ? (widget.waitingLabelBuilder?.call(_remaining) ??
              '$label (${_clock(_remaining)})')
        : label;

    return Semantics(
      button: true,
      enabled: enabled,
      label: text,
      excludeSemantics: true,
      onTap: enabled ? _resend : null,
      child: ACDAdaptiveTappable(
        design: design,
        onTap: enabled ? _resend : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_sending) ...[
                ACDAdaptiveProgress(design: design, size: 14, strokeWidth: 2),
                const SizedBox(width: 8),
              ],
              Text(text, style: base),
            ],
          ),
        ),
      ),
    );
  }
}
