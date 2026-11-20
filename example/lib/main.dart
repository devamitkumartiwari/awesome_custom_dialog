library;

import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import 'app_settings.dart';
import 'home_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, _) {
        final TargetPlatform? platform = platformNotifier.value;
        // One scope above the app: a widget's own `design:` still wins.
        return ACDDesignScope(
          design: designNotifier.value,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ACD',
            theme: AppTheme.light().copyWith(platform: platform),
            darkTheme: AppTheme.dark().copyWith(platform: platform),
            themeMode: themeModeNotifier.value,
            // Gives toasts their own dedicated Overlay, independent of this
            // app's Navigator — see ACDToastLayer's doc comment for why that
            // matters (it's optional; .toast()/.snackbar() work without it
            // too, falling back to the nearest ambient Overlay).
            builder: (context, child) {
              Widget app = ACDToastLayer(child: child!);
              if (reduceMotionNotifier.value) {
                app = MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(disableAnimations: true),
                  child: app,
                );
              }
              return app;
            },
            home: const HomeScreen(),
          ),
        );
      },
    );
  }
}
