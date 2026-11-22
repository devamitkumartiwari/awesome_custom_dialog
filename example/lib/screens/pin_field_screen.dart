import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/showcase_widgets.dart';

/// A live demo of `ACDPinField` — basic OTP entry, obscured passcode entry,
/// and `Form` validation.
class PinFieldScreen extends StatefulWidget {
  const PinFieldScreen({super.key});

  @override
  State<PinFieldScreen> createState() => _PinFieldScreenState();
}

class _PinFieldScreenState extends State<PinFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  final ACDPinController _pin = ACDPinController();

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  String? _submittedPin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CategoryScaffold(
      title: 'Pin / OTP Field',
      color: Colors.deepPurple,
      children: [
        sectionHeader('Basic OTP entry'),
        ACDPinField(
          length: 6,
          onCompleted: (pin) => setState(() => _submittedPin = pin),
        ),
        if (_submittedPin != null) ...[
          const SizedBox(height: 8),
          Text('Entered: $_submittedPin'),
        ],
        const CodeSnippet(
          code: '''
ACDPinField(
  length: 6,
  onCompleted: (pin) => debugPrint('Entered \$pin'),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Obscured passcode, with a brief reveal'),
        ACDPinField(
          length: 4,
          obscureText: true,
          obscureRevealDuration: const Duration(milliseconds: 300),
        ),
        const CodeSnippet(
          code: '''
ACDPinField(
  length: 4,
  obscureText: true,
  obscureRevealDuration: Duration(milliseconds: 300),
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader(
          'Form validation — fully styled per state',
          description: 'A wrong entry shakes (not under reduce motion)',
        ),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ACDPinField(
                length: 4,
                validator: (v) =>
                    v != null && v.length == 4 ? null : 'Enter all 4 digits',
                submittedPinTheme: const ACDPinTheme(
                  borderColor: Colors.green,
                  borderWidth: 2,
                ),
                errorPinTheme: ACDPinTheme(
                  borderColor: scheme.error,
                  borderWidth: 2,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _formKey.currentState?.validate(),
                child: const Text('Validate'),
              ),
            ],
          ),
        ),
        const CodeSnippet(
          code: '''
ACDPinField(
  length: 4,
  validator: (v) => v != null && v.length == 4 ? null : 'Enter all 4 digits',
  submittedPinTheme: ACDPinTheme(borderColor: Colors.green, borderWidth: 2),
  errorPinTheme: ACDPinTheme(borderColor: scheme.error, borderWidth: 2),
  // errorAnimation: ACDPinErrorAnimation.shake (default) / .none
  // clearOnError: true, // wipe the digits when an error appears
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Shape, corner radius, color & shadow'),
        ACDPinField(
          length: 4,
          pinTheme: ACDPinTheme(
            shape: BoxShape.circle,
            color: scheme.primaryContainer,
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          focusedPinTheme: ACDPinTheme(
            borderColor: scheme.primary,
            borderWidth: 2,
          ),
        ),
        const CodeSnippet(
          code: '''
ACDPinField(
  length: 4,
  pinTheme: ACDPinTheme(
    shape: BoxShape.circle, // or borderRadius: BorderRadius.circular(x)
    color: scheme.primaryContainer,
    boxShadow: [BoxShadow(color: scheme.primary.withValues(alpha: 0.25), blurRadius: 6)],
  ),
  focusedPinTheme: ACDPinTheme(borderColor: scheme.primary, borderWidth: 2),
)''',
        ),

        const SizedBox(height: 24),
        sectionHeader('Controller & resend'),
        ACDPinField(
          length: 6,
          controller: _pin,
          onCompleted: (code) {
            // Wrong code: wipe it and get ready for the next try.
            if (code != '123456') {
              _pin
                ..clear()
                ..focus();
            }
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _pin.setCode('123456'),
              child: const Text('Fill 123456'),
            ),
            ACDResendCountdown(
              duration: const Duration(seconds: 15),
              onResend: () =>
                  Future<void>.delayed(const Duration(milliseconds: 600)),
            ),
          ],
        ),
        const CodeSnippet(
          code: '''
final pin = ACDPinController();

ACDPinField(length: 6, controller: pin, onCompleted: verify);
ACDResendCountdown(onResend: () => auth.sendCode(phone));

// wrong code:
pin..clear()..focus();''',
        ),
      ],
    );
  }
}
