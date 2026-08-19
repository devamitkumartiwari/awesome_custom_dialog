# awesome_custom_dialog — Project Analysis

**Version:** 0.0.2 | **Date:** 2026-05-12 | **Platform:** Flutter / Dart

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Current Architecture](#current-architecture)
3. [Bug Fixes Required](#bug-fixes-required)
4. [Improvements](#improvements)
5. [New Features](#new-features)
6. [README & Documentation Gaps](#readme--documentation-gaps)
7. [Testing Plan](#testing-plan)
8. [Priority Roadmap](#priority-roadmap)

---

## Project Overview

`awesome_custom_dialog` is a lightweight Flutter package for displaying highly customisable dialogs using a fluent/builder API. It supports 10 gravity positions, slide animations per position, custom animation overrides, radio buttons, list tiles, progress indicators, and more.

**Core files:**
| File | Role |
|---|---|
| `lib/awesome_custom_dialog.dart` | `ACDDialog` builder, `ACD` presenter, `ACDChildren` stateful widget, enums, data classes |
| `lib/awesome_custom_dialog_widget.dart` | `ACDRadioListTile` stateful widget |
| `example/lib/main.dart` | Example app entry point |
| `example/lib/notice_dialog.dart` | Usage demonstration |

---

## Current Architecture

```
ACDDialog (builder / fluent API)
  ├── .build([context])      → sets context
  ├── .widget(Widget)        → add arbitrary widget
  ├── .text(...)             → add styled Text
  ├── .twoButton(...)        → add two TextButtons in a Row
  ├── .listOfACDListTile(...)→ add InkWell list
  ├── .listOfACDRadioButton(...)→ add radio list
  ├── .acdProgress(...)      → add CircularProgressIndicator
  ├── .acdDivider(...)       → add Divider
  └── .show([x, y])          → creates ACD and calls showGeneralDialog()
        └── ACDChildren (StatefulWidget)
              └── Column(widgetList)

ACD (internal presenter)
  └── showGeneralDialog()
        └── _buildMaterialDialogTransitions() → SlideTransition / custom animatedFunc
```

---

## Bug Fixes Required

### BUG-01 — `acdProgress` crashes when `valueColor` is null

**File:** [lib/awesome_custom_dialog.dart:264](lib/awesome_custom_dialog.dart#L264)

```dart
// CURRENT — crashes with null argument
valueColor: AlwaysStoppedAnimation<Color>(valueColor),

// FIX — make it nullable-safe
valueColor: valueColor != null
    ? AlwaysStoppedAnimation<Color>(valueColor)
    : null,
```

**Why it's a bug:** `AlwaysStoppedAnimation<Color>` requires a non-null `Color`. Calling `acdProgress()` without `valueColor` will throw a `Null check operator used on a null value` error at runtime.

---

### BUG-02 — `isShowingChange(true)` called inside `build()`

**File:** [lib/awesome_custom_dialog.dart:431-433](lib/awesome_custom_dialog.dart#L431)

```dart
// CURRENT — setState/callback during frame build causes framework errors
Widget build(BuildContext context) {
  if (widget.isShowingChange != null) {
    widget.isShowingChange!(true);   // <-- side-effect in build!
  }
  ...
}

// FIX — defer to post-frame callback
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    widget.isShowingChange?.call(true);
  });
}
```

**Why it's a bug:** Triggering external callbacks (which may call `setState` on the parent) from inside `build()` violates Flutter's rendering pipeline contract and can cause `setState() or markNeedsBuild() called during build` assertions.

---

### BUG-03 — `useRootNavigator` is stored but never passed to `showGeneralDialog`

**File:** [lib/awesome_custom_dialog.dart:487](lib/awesome_custom_dialog.dart#L487) and [lib/awesome_custom_dialog.dart:36](lib/awesome_custom_dialog.dart#L36)

`ACDDialog.useRootNavigator` defaults to `true` and is used in `dismiss()`, but it is **never forwarded** to `showGeneralDialog()` in `ACD.show()`. This means the dialog is always pushed on the root navigator regardless of the user's setting.

```dart
// FIX — pass useRootNavigator to ACD constructor and to showGeneralDialog
showGeneralDialog(
  context: _context,
  useRootNavigator: _useRootNavigator,  // add this line
  ...
);
```

---

### BUG-04 — Forced null unwrap on context in `listOfACDRadioButton`

**File:** [lib/awesome_custom_dialog.dart:240](lib/awesome_custom_dialog.dart#L240)

```dart
// CURRENT — hard crash if context is null
Size size = MediaQuery.of(context!).size;

// FIX — guard or use safe access
if (context == null) return this;
Size size = MediaQuery.of(context!).size;
```

If the dialog is built before `build()` is called or the context is not set, this crashes with a `Null check operator used on a null value` error.

---

### BUG-05 — `InkWell` in `listOfACDListTile` is a no-op wrapper

**File:** [lib/awesome_custom_dialog.dart:199-225](lib/awesome_custom_dialog.dart#L199)

```dart
// CURRENT — InkWell has no onTap; ListTile.onTap handles tapping
return Material(
  color: Colors.white,
  child: InkWell(         // <-- no onTap here; redundant
    child: ListTile(
      onTap: () { ... },
      ...
    ),
  ),
);

// FIX — remove the InkWell wrapper
return Material(
  color: Colors.white,
  child: ListTile(
    onTap: () { ... },
    ...
  ),
);
```

---

### BUG-06 — `twoButton`'s `onTap2` has no type annotation

**File:** [lib/awesome_custom_dialog.dart:127](lib/awesome_custom_dialog.dart#L127)

`onTap1` is typed as `VoidCallback?` but `onTap2` is untyped (`dynamic`). This breaks type safety and can cause silent runtime failures.

```dart
// FIX
VoidCallback? onTap2,
```

---

### BUG-07 — `acdDivider` default height is `0.1` (essentially invisible)

**File:** [lib/awesome_custom_dialog.dart:276](lib/awesome_custom_dialog.dart#L276)

A height of `0.1` is sub-pixel and renders as invisible on all displays. The intended default is likely `1.0`.

```dart
// FIX
Divider(
  color: color ?? Colors.grey[300],
  height: height ?? 1.0,
)
```

---

### BUG-08 — Static `_context` is never cleared (memory leak)

**File:** [lib/awesome_custom_dialog.dart:11](lib/awesome_custom_dialog.dart#L11)

`ACDDialog._context` is a static field set once via `init()`. It is never nulled out after use, holding a reference to a potentially disposed `BuildContext` across navigations. This can produce `Looking up a deactivated widget's ancestor is unsafe` errors.

**Fix:** Add a `dispose()` method or clear `_context` when the widget that called `init()` is disposed.

---

### BUG-09 — `dismissCallBack` not triggered on barrier tap

When the user taps outside the dialog (`barrierDismissible: true`), the dialog is popped by the framework directly — `ACDDialog.dismiss()` is never called, so `_isShowing` stays `true` and `dismissCallBack` is never fired.

**Fix:** Use the `dispose()` lifecycle of `ACDChildren` to always fire the dismiss callback, which already happens — but `_isShowing` is never reset to `false` in this path. Ensure `_isShowing = false` is set on `dispose`.

---

### BUG-10 — `ACDRadioItem` missing `fontFamily` property

**File:** [lib/awesome_custom_dialog.dart:607-623](lib/awesome_custom_dialog.dart#L607)

`ACDListTileItem` has a `fontFamily` field but `ACDRadioItem` does not, causing an inconsistency in the API surface.

```dart
// FIX — add to ACDRadioItem
String? fontFamily;
```

---

## Improvements

### IMP-01 — Replace all untyped parameters with proper Dart types

The `text()`, `twoButton()`, `acdProgress()`, and `acdDivider()` methods use bare untyped parameters (no `String?`, `Color?`, etc.), losing all IDE autocomplete and type-checking benefits.

```dart
// BEFORE
ACDDialog text({padding, text, color, fontSize, ...})

// AFTER
ACDDialog text({
  EdgeInsets? padding,
  String? text,
  Color? color,
  double? fontSize,
  Alignment? alignment,
  TextAlign? textAlign,
  int? maxLines,
  TextDirection? textDirection,
  TextOverflow? overflow,
  FontWeight? fontWeight,
  String? fontFamily,
})
```

---

### IMP-02 — Export `awesome_custom_dialog_widget.dart` from main library file

`ACDRadioItem` and `ACDRadioListTile` are defined in `awesome_custom_dialog_widget.dart` but not re-exported from the main library barrel. Users must add a second import.

```dart
// Add to awesome_custom_dialog.dart top-level
export 'awesome_custom_dialog_widget.dart';
```

---

### IMP-03 — Add `ScrollController` and `ScrollPhysics` to list helpers

`listOfACDListTile` and `listOfACDRadioButton` have no way to control scroll behaviour from the outside. Add optional `physics` and `controller` parameters.

---

### IMP-04 — Make `gravity` in `twoButton` typed

```dart
// BEFORE
ACDDialog twoButton({gravity, ...})

// AFTER
ACDDialog twoButton({ACDGravity? gravity, ...})
```

---

### IMP-05 — Replace deprecated `withOpacity` calls

`Colors.black.withOpacity(.3)` is deprecated in recent Flutter SDK versions. Replace with `Colors.black.withValues(alpha: 0.3)` or `Color.fromRGBO(0, 0, 0, 0.3)`.

---

### IMP-06 — Replace `MaterialButton` in example with `ElevatedButton`

**File:** [example/lib/main.dart:51](example/lib/main.dart#L51)

`MaterialButton` is deprecated. The example should use `ElevatedButton` or `FilledButton`.

---

### IMP-07 — Add `mainAxisSize` control to dialog content `Column`

**File:** [lib/awesome_custom_dialog.dart:435](lib/awesome_custom_dialog.dart#L435)

The inner `Column` in `ACDChildren.build()` always expands to fill available height. Adding `mainAxisSize: MainAxisSize.min` would allow content-wrapping dialogs without a fixed `height`.

```dart
// FIX
Column(
  mainAxisSize: MainAxisSize.min,
  children: widget.widgetList,
)
```

---

### IMP-08 — Add accessibility / semantics support

`showGeneralDialog` is called with an empty `barrierLabel: ""`. This should be a descriptive string for screen readers (e.g., `"Dialog"` or a user-provided label).

---

### IMP-09 — Update `pubspec.yaml` version constraint to reference Flutter SDK

The `pubspec.yaml` only constrains the Dart SDK but not Flutter SDK. Add:
```yaml
environment:
  sdk: '>=3.1.0 <4.0.0'
  flutter: '>=3.10.0'
```

---

### IMP-10 — Add `const` constructors where possible

`ACDListTileItem` and `ACDRadioItem` should support `const` constructors for performance.

---

## New Features

### FEAT-01 — Predefined dialog presets (success / error / warning / info)

```dart
ACDDialog().build()
  ..success(title: "Done!", message: "Your file was saved.")
  ..show();

// Also: .error(), .warning(), .info()
```

Each preset bundles an icon, title text, message text, and a single "OK" button with sensible defaults.

---

### FEAT-02 — Auto-dismiss timer

```dart
ACDDialog().build()
  ..autoDismissAfter = const Duration(seconds: 3)
  ..show();
```

Automatically pops the dialog after the given duration. Useful for toast-style confirmations.

---

### FEAT-03 — Single button helper

Currently only `twoButton` exists. Add a `oneButton` helper for simple acknowledgement dialogs.

```dart
ACDDialog().build()
  ..oneButton(text: "OK", onTap: () {})
  ..show();
```

---

### FEAT-04 — Three-button helper

```dart
ACDDialog().build()
  ..threeButton(
    text1: "Cancel", onTap1: () {},
    text2: "Later",  onTap2: () {},
    text3: "Accept", onTap3: () {},
  )
  ..show();
```

---

### FEAT-05 — `acdTextField` — input field inside dialog

```dart
final controller = TextEditingController();
ACDDialog().build()
  ..acdTextField(
    controller: controller,
    hint: "Enter your name",
    onSubmitted: (value) {},
  )
  ..show();
```

---

### FEAT-06 — `acdImage` helper widget

Currently users must wrap images manually in a `widget()` call. A convenience helper:

```dart
ACDDialog().build()
  ..acdImage(assetPath: 'assets/success.png', width: 60, height: 60)
  ..show();
```

---

### FEAT-07 — Checkbox list (`listOfACDCheckbox`)

Parallel to `listOfACDRadioButton` but allows multi-selection:

```dart
ACDDialog().build()
  ..listOfACDCheckbox(
    items: [...],
    initialValues: [0, 2],
    onChanged: (List<int> selected) {},
  )
  ..show();
```

---

### FEAT-08 — Built-in animation presets

Add named animation shortcuts so users don't need to write `animatedFunc` manually:

```dart
enum ACDAnimation { fade, scale, slideUp, slideDown, bounce, rotate }

ACDDialog().build()
  ..animation = ACDAnimation.scale
  ..show();
```

---

### FEAT-09 — Toast / Snackbar-style overlay

A non-blocking, auto-dismissing notification that does not dim the background:

```dart
ACDDialog().build()
  ..barrierColor = Colors.transparent
  ..barrierDismissible = false
  ..autoDismissAfter = const Duration(seconds: 2)
  ..gravity = ACDGravity.bottom
  ..gravityAnimationEnable = true
  ..text(text: "Saved successfully!", color: Colors.white)
  ..show();
```

Expose this as a named constructor `ACDDialog.toast(...)` for convenience.

---

### FEAT-10 — Theme integration

Allow the dialog to automatically pick up `ThemeData` from the app:

```dart
ACDDialog().build()
  ..useTheme = true   // reads Theme.of(context).dialogTheme
  ..show();
```

---

### FEAT-11 — Safe-area awareness

Dialogs near screen edges (`bottom`, `top`) should respect system insets. Add:

```dart
ACDDialog().build()
  ..respectSafeArea = true
  ..gravity = ACDGravity.bottom
  ..show();
```

This wraps the dialog child in a `SafeArea` widget.

---

### FEAT-12 — `onBarrierTap` callback

Currently there is no callback for when the user taps outside the dialog. Add:

```dart
ACDDialog().build()
  ..onBarrierTap = () { print("Barrier tapped"); }
  ..show();
```

---

### FEAT-13 — Dialog stacking / queue

A static `ACDDialogQueue` that shows dialogs one after another without overlapping:

```dart
ACDDialogQueue.enqueue(myDialog1);
ACDDialogQueue.enqueue(myDialog2);
// myDialog2 shows only after myDialog1 is dismissed
```

---

### FEAT-14 — RTL (right-to-left) layout support

Expose `textDirection` at the dialog level, not just on individual text widgets:

```dart
ACDDialog().build()
  ..textDirection = TextDirection.rtl
  ..show();
```

---

### FEAT-15 — Full-featured toast messages (implemented in 1.0.0)

`ACDDialog.toast()` gained `ACDToastLength` (short/long), `cancelPrevious`/`ACDDialog.cancelToast()`, `showCloseButton`, `dismissOnTap`, `fontFamily`, and now presents through a non-blocking overlay by default (`blockTouches` restores the old modal presentation). See CHANGELOG 1.0.0 for the full parameter list.

---

### FEAT-16 — Full-featured snackbar messages (implemented in 1.0.0)

New `ACDContentType` enum (success/failure/warning/help) with real accent colors, a standalone `ACDSnackbarContent` widget for use in a real `SnackBar`/`ScaffoldMessenger`/`MaterialBanner`, and a convenience `ACDDialog.snackbar()` factory presenting it through the same overlay pipeline `.toast()` uses. See CHANGELOG 1.0.0.

---

## README & Documentation Gaps

The current README is essentially empty (only shows the install snippet). It needs:

- [ ] Feature overview with bullet list
- [ ] Screenshots / GIF of example dialogs
- [ ] Full API reference table
- [ ] Code examples for every helper method (`text`, `twoButton`, `listOfACDListTile`, `listOfACDRadioButton`, `acdProgress`, `acdDivider`, gravity positions, custom animations)
- [ ] Migration guide section (for future version bumps)
- [ ] Changelog kept current
- [ ] Pub.dev badges (version, license, popularity, dart SDK)

---

## Testing Plan

Currently there are **zero tests**. Minimum recommended coverage:

| Area | Test Type | Priority |
|---|---|---|
| `ACDDialog.build()` sets context | Unit | High |
| `acdProgress` with null `valueColor` does not throw | Unit | High |
| `listOfACDRadioButton` respects `initialValue` | Widget | High |
| `twoButton` fires correct callbacks | Widget | High |
| `dismiss()` does not call pop when not showing | Unit | High |
| `gravity` positions produce correct alignments | Widget | Medium |
| `gravityAnimationEnable` applies slide offset | Widget | Medium |
| `autoDismissAfter` closes dialog on timer | Widget | Medium (post FEAT-02) |
| `onBarrierTap` fires when barrier is tapped | Integration | Medium (post FEAT-12) |
| Screenshot / golden tests for presets | Golden | Low |

---

## Priority Roadmap

### v0.0.3 — Bug Fix Release (immediate)
- BUG-01 `acdProgress` null crash
- BUG-02 `isShowingChange` in `build()`
- BUG-03 `useRootNavigator` not forwarded
- BUG-05 remove redundant `InkWell`
- BUG-06 type `onTap2`
- BUG-07 `acdDivider` height default
- IMP-07 `mainAxisSize: min` on inner Column

### v0.1.0 — Quality Release
- IMP-01 Full typed parameter signatures
- IMP-02 Export widget file
- IMP-05 Replace deprecated `withOpacity`
- IMP-08 Accessibility / barrier label
- BUG-08 Static context memory leak
- BUG-09 `dismissCallBack` on barrier tap
- BUG-10 `fontFamily` in `ACDRadioItem`
- Unit + widget test suite

### v0.2.0 — Feature Release
- FEAT-01 Predefined presets (success / error / warning / info)
- FEAT-02 Auto-dismiss timer
- FEAT-03 Single button helper
- FEAT-05 `acdTextField`
- FEAT-06 `acdImage` helper
- FEAT-08 Built-in animation presets
- FEAT-11 Safe-area awareness
- Full README rewrite with screenshots

### v0.3.0 — Advanced Features
- FEAT-04 Three-button helper
- FEAT-07 Checkbox list
- FEAT-09 Toast / Snackbar-style overlay
- FEAT-10 Theme integration
- FEAT-12 `onBarrierTap` callback
- FEAT-13 Dialog queue
- FEAT-14 RTL support

### v1.0.0 — Toast + Snackbar (shipped)
- FEAT-15 Full-featured toast messages (length presets, cancel, close button, dismiss-on-tap, custom font, non-blocking overlay presentation)
- FEAT-16 Full-featured snackbar messages (`ACDContentType`, `ACDSnackbarContent`, `ACDDialog.snackbar()`)
- Full style customization pass (colors/fonts/padding/corners/icons) across presets, buttons, lists, text fields, toast, and snackbar
- Code reorganized from one file into small per-purpose files under `lib/src/`
- Tooling: Flutter `>=3.29.0`; example Android bumped to Gradle 9.3.1 / AGP 9.1.0 / Kotlin 2.4.0 / Java 17; iOS UIScene lifecycle (example iOS); SPM scaffold (`ios/awesome_custom_dialog/Package.swift`)
