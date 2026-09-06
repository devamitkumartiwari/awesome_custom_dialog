library awesome_custom_dialog_example;

import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const MyApp());

/// Lets [HomeScreen] cycle the app's theme mode (light → dark → system) from
/// its app bar without lifting a `StatefulWidget` all the way up manually.
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Awesome Custom Dialog',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          // Gives toasts their own dedicated Overlay, independent of this
          // app's Navigator — see ACDToastLayer's doc comment for why that
          // matters (it's optional; .toast()/.snackbar() work without it
          // too, falling back to the nearest ambient Overlay).
          builder: (context, child) => ACDToastLayer(child: child!),
          home: const HomeScreen(),
        );
      },
    );
  }
}
