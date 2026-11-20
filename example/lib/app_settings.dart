/// App-wide showcase settings, switched live from any screen's app bar.
library;

import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

/// Light → dark → system theme mode.
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);

/// App-wide design for every awesome_custom_dialog widget in the showcase
/// (Material / Cupertino / Adaptive). A widget's own `design:` still wins.
final ValueNotifier<ACDDesign> designNotifier = ValueNotifier(
  ACDDesign.material,
);

/// Platform preview: `null` follows the device. Setting it to iOS on an
/// Android phone (or the reverse) shows what [ACDDesign.adaptive] picks on
/// the other platform, since adaptive follows `Theme.of(context).platform`.
final ValueNotifier<TargetPlatform?> platformNotifier = ValueNotifier(null);

/// Previews the reduce-motion accessibility setting without changing the
/// device setting.
final ValueNotifier<bool> reduceMotionNotifier = ValueNotifier(false);

/// Every setting above, for widgets that rebuild on any of them.
final Listenable appSettings = Listenable.merge([
  themeModeNotifier,
  designNotifier,
  platformNotifier,
  reduceMotionNotifier,
]);
