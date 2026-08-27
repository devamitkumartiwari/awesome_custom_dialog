import 'package:flutter/foundation.dart';

import 'acd_slide_action_status.dart';

/// Drives an [ACDSlideAction]'s post-confirm lifecycle from outside the
/// widget tree — typically from the async handler passed to `onConfirm`.
///
/// ```dart
/// final controller = ACDSlideActionController();
/// ACDSlideAction(
///   controller: controller,
///   onConfirm: () async {
///     controller.loading();
///     final ok = await submit();
///     ok ? controller.success() : controller.reset();
///   },
/// );
/// ```
class ACDSlideActionController extends ChangeNotifier {
  /// Creates an [ACDSlideActionController], starting in
  /// [ACDSlideActionStatus.idle].
  ACDSlideActionController();

  ACDSlideActionStatus _status = ACDSlideActionStatus.idle;

  /// The controller's current status.
  ACDSlideActionStatus get status => _status;

  /// Switches to [ACDSlideActionStatus.loading] — call after `onConfirm`
  /// fires, while awaiting the async result.
  void loading() {
    _status = ACDSlideActionStatus.loading;
    notifyListeners();
  }

  /// Switches to [ACDSlideActionStatus.success] — call once the async work
  /// completes successfully.
  void success() {
    _status = ACDSlideActionStatus.success;
    notifyListeners();
  }

  /// Switches back to [ACDSlideActionStatus.idle] — call to let the user
  /// try again, whether after a failure or after a `success()` display
  /// window has elapsed.
  void reset() {
    _status = ACDSlideActionStatus.idle;
    notifyListeners();
  }
}
