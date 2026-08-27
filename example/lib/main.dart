library awesome_custom_dialog_example;

import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const MyApp());

/// Lets [HomeScreen] cycle the app's theme mode (light → dark → system) from
/// its app bar without lifting a `StatefulWidget` all the way up manually.
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(ThemeMode.system);

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
          home: const HomeScreen(),
        );
      },
    );
  }
}
