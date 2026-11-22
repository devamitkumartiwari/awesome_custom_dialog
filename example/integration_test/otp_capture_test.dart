import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gif_capture_harness.dart';

/// Captures README GIF frames for the OTP helpers: a wrong code shakes and
/// clears via ACDPinController, the resend countdown ticks down, and the
/// right code completes the field.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture otp', (tester) async {
    final capture = GifCapture(tester, 'build/gif_frames/otp');
    await capture.setSize();
    final ACDPinController pin = ACDPinController();
    addTearDown(pin.dispose);
    String? error;

    await tester.pumpWidget(
      capture.wrap(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: demoTheme,
          home: Scaffold(
            backgroundColor: demoBackground,
            body: StatefulBuilder(
              builder: (context, setState) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Enter the 6-digit code',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 20),
                      ACDPinField(
                        length: 6,
                        controller: pin,
                        forceErrorText: error,
                        onChanged: (_) {
                          if (error != null) setState(() => error = null);
                        },
                        onCompleted: (code) {
                          if (code != '246810') {
                            setState(() => error = 'Wrong code, try again');
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      ACDResendCountdown(
                        duration: const Duration(seconds: 5),
                        onResend: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await capture.pumpAndCapture(Duration.zero);
    await capture.hold(3);

    // Type a wrong code digit by digit.
    for (int i = 1; i <= 6; i++) {
      pin.setCode('135791'.substring(0, i));
      await capture.pumpAndCapture(const Duration(milliseconds: 120));
    }
    for (int i = 0; i < 10; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 60));
    }

    // Clear it with the controller and type the right one.
    pin.clear();
    await capture.pumpAndCapture(const Duration(milliseconds: 200));
    for (int i = 1; i <= 6; i++) {
      pin.setCode('246810'.substring(0, i));
      await capture.pumpAndCapture(const Duration(milliseconds: 120));
    }

    // Let the resend countdown finish.
    for (int i = 0; i < 8; i++) {
      await capture.pumpAndCapture(const Duration(milliseconds: 500));
    }
    await capture.hold(6);
  });
}
