## 1.3.0

### ✨ New Features
- New `ACDAutocompleteField<T>` — a generic typeahead text field with local (`filterFn`) or remote (`onFind`, debounced) suggestion matching, a custom `itemBuilder`, and `submitOnSuggestionTap`/`clearOnSubmit` toggles.
- New `ACDTriggerAutocompleteField` / `ACDAutocompleteTrigger` — a mention/hashtag-style field that reacts to multiple trigger characters (e.g. `@`, `#`) at once, each with its own async `optionsBuilder`, `triggerOnlyAtStart`/`triggerOnlyAfterSpace` rules, and minimum-character threshold.
- New `ACDSlideAction` — a "slide/swipe to confirm" action bar with rectangle/circle shapes, `startToEnd`/`endToStart`/`dual` drag directions, RTL support, haptic feedback, an optional animated wave trail and label shimmer, active/inactive track and thumb colors, independent `elevationThumb`/`elevationTrack`/`trackPadding`, and full escape-hatch builders (`foregroundBuilder`/`backgroundBuilder`/`outerBackgroundBuilder`) for a fully custom look. Paired with `ACDSlideActionController` to drive `loading()`/`success()`/`reset()` from an async handler. `ACDSlideAction.swipeButton()` is a ready-made preset with a polished look out of the box, no styling required.
- New `ACDDashedLine`, `ACDDottedDecoration` (a dashed/dotted `Decoration`, usable directly as `Container(decoration: ...)`), and `ACDDashedBorder` (wraps any child with a dashed rect/rounded-rect/oval/circle/custom-path outline) — all sharing one internal dash-path utility.
- New `ACDStepper` — a compact step-progress indicator with horizontal (wizard) or vertical (timeline) layouts, circle/rounded-rectangle markers, per-status colors (finished/active/upcoming), tap-to-navigate via `onStepReached` + `steppingEnabled`, a fully custom `customStep` builder, and dashed or solid connector lines (reusing the dash-path utility above). `showLoadingAnimation` uses a plain built-in spinner, keeping the package dependency-free.
- New `ACDStepperListView<T>` / `ACDStepperItemData<T>` / `ACDStepperThemeData` — a scrollable vertical timeline list (avatar/marker + connector line + content per row), with custom `avatarBuilder`/`labelBuilder`/`contentBuilder`, a `showLineOnLast` toggle, and dashed/solid line styling via `ACDStepperThemeData`.

### 🎨 Customization parity pass
Every feature — old and new — now offers the same baseline customization (colors, text styles, shapes, sizes, icons, elevation/shadow, gradients):

- **Buttons** (`oneButton`/`twoButton`/`threeButton`): added `backgroundColor`, `borderRadius`, `elevation`/`boxShadow`, `icon`, and `gradient` per button slot — previously text-color/style only. A filled/gradient/shadowed button now gets sensible default internal padding automatically (the original flat text-button default was zero, which left a colored button's label jammed against its own rounded edge); an explicit `buttonPadding` still always wins. The button row also only takes a fixed height when you pass one explicitly, so a taller filled button is never clipped.
- **Snackbar** (`ACDSnackbarContent`, `ACDDialog.snackbar()`): added `gradient`, `elevation`/`boxShadow`, and `titleFontSize`/`titleFontWeight`/`titleFontFamily`/`messageFontSize`/`messageFontWeight`/`messageFontFamily` shortcuts.
- **Lists** (`listOfACDListTile`/`listOfACDRadioButton`/`listOfACDCheckbox`, `searchableList`/`multiSearchableList`): added a `borderRadius` per-row shape option everywhere; added `leading`/`trailing` to `ACDRadioItem`/`ACDCheckboxItem` (previously only `ACDListTileItem` had them); added a `searchIcon` override to the searchable list (previously hardcoded).
- **`acdTextField`**: added `prefixIcon`/`suffixIcon`.
- **Dashed/dotted/border trio** (`ACDDashedLine`/`ACDDottedDecoration`/`ACDDashedBorder`): `gradient` and `roundedCaps` — previously only `ACDDashedLine` had them.
- **`ACDTriggerAutocompleteField`**: added the same `itemTextColor`/`itemFontSize`/`itemFontWeight`/`itemFontFamily`/`itemStyle` shortcuts `ACDAutocompleteField` already had.
- **Autocomplete popups** (`ACDAutocompleteField`/`ACDTriggerAutocompleteField`): added `popupElevation`/`popupBorderRadius`/`popupColor` — previously hardcoded.
- **`ACDStepper`/`ACDStepperListView`**: added per-status gradients, marker/avatar elevation, and an implicit `animationDuration`/`animationCurve` transition on status changes — previously flat colors with no transition.
- **`ACDSlideAction`**: added `activeThumbGradient`/`inactiveThumbGradient`/`activeTrackGradient`/`inactiveTrackGradient`, matching the existing active/inactive color pairs — gradient users previously lost the idle/dragging visual distinction color users already had.

All of the above are zero-dependency additions — no new packages were added to `pubspec.yaml`, and every change is additive (new optional parameters with defaults matching prior behavior). This release is fully backward compatible.

## 1.2.0

### ✨ New Features
- New `ACDDropdownField<T>` / `ACDMultiDropdownField<T>` — an inline, `Form`-compatible searchable dropdown (a real `FormField<T>`, so it works with `validator`/`onSaved`/`enabled` like any other form field). Tapping it opens the same filterable list as `.searchableList()`, presented as a `dialog` (default), `bottomSheet`, or a non-modal `menu` anchored directly under the field (`ACDDropdownMode`).
- `.searchableList()` / `.multiSearchableList()` and the new dropdown fields all gained:
  - `compareFn` — custom equality for selection tracking, so a model type no longer needs a `==`/`hashCode` override.
  - `isDisabledItem` — greys out and disables individual rows.
  - `favoriteItems` — pins items to the top of the list before any search.
  - `onFindPaged(query, page)` — infinite-scroll pagination for async search/loading; loads another page as the list is scrolled to its end.
- `ACDDropdownField` additionally supports `showClearButton` (a trailing clear icon) and `dropdownBuilder` (fully custom closed-state display).

This release is fully backward compatible — every addition above is optional, and no existing method signature changed.

## 1.1.0

### ✨ New Features
- New `.searchableList<T>()` / `.multiSearchableList<T>()` — a filterable list embedded in the dialog, generic over your own item type. Filters locally as you type, or delegate to an optional async `onFind` hook for remote/API-backed search, complete with built-in loading, empty, and error states. Multi-select includes a built-in Confirm/Cancel row since selection is cumulative — cancel discards your changes, confirm reports the final set.

## 1.0.0

First stable release. This version adds toast and snackbar support, lets you style almost anything, reorganizes the code for easier maintenance, and refreshes the example app's Android/iOS setup.

### ✨ Toast messages
- New `ACDDialog.toast()` options: `length` (short/long), `showCloseButton`, `dismissOnTap`, `fontFamily`, `borderRadius`, `contentPadding`, `closeIcon`.
- `ACDDialog.cancelToast()` dismisses the currently showing toast; a new toast automatically cancels the old one (turn this off with `cancelPrevious: false`, handy for queueing several toasts with `ACDDialogQueue`).
- Toasts no longer block taps on the rest of your app while they're showing.

### ✨ Snackbar messages
- New `ACDSnackbarContent` widget — a colorful success/failure/warning/help banner you can drop into any Flutter `SnackBar`.
- New `ACDDialog.snackbar()` — shows the same banner without needing to set up `ScaffoldMessenger` yourself.
- New `ACDContentType` enum: `success`, `failure`, `warning`, `help`.

### 🎨 Style everything
- Every preset (`success`/`error`/`warning`/`info`) now accepts its own `icon`, `iconColor`, `iconSize`, `padding`, and full text styles for the title/message/button.
- Buttons, list items, radio/checkbox items, and text fields all accept a full `TextStyle` for complete control (letter spacing, decoration, italics, and anything else `TextStyle` supports), on top of the simple `color`/`fontSize`/`fontWeight`/`fontFamily` shortcuts that were already there.
- Added `borderRadius` to images and text fields, `padding` to the divider and list helpers, and a `tileColor` option for list tiles.
- Added a `trailing` widget option to list tile items.
- `acdTextField()` now supports an optional `validator` (with `autovalidateMode` and `fieldKey` for manually triggering validation, e.g. from a submit button) — the field itself is otherwise unchanged if you don't use it.
- Added `cornerRadius` (a full `BorderRadius`) alongside the existing uniform `borderRadius` shortcut, for dialogs that only want some corners rounded — e.g. a side panel flush against the screen edge that should only round its exposed corners.

### 🐞 Bug Fixes
- A dialog positioned on the left or right edge (e.g. a side panel) now sits flush against that edge instead of floating away from it.
- Radio list items now respect their `padding`, matching how checkbox list items already worked.
- Toasts and snackbars no longer block taps on the rest of the screen while showing.
- List, radio, and checkbox items no longer sit flush against the dialog edge with no breathing room by default — they now use a sensible default padding (matching Flutter's own `ListTile`) unless you set your own.

### 🧹 Code organization
- The package's code was reorganized from one large file into many small files by purpose (dialog, toast, snackbar, animations, gravity/positioning, presets, lists, etc.) under `lib/src/`. This doesn't change how you use the package — it just makes the code easier to navigate and fix bugs in.

### 🚀 Example app tooling
- Updated the example app's Android build to a current Gradle/Kotlin/Java setup, and added iOS scene-lifecycle support. This only affects the bundled example project, not your own app.

## 0.0.3

### 🚀 Modernization
- **Kotlin Update**: Upgraded to **Kotlin 2.1.0** for better performance and latest Flutter compatibility.
- **Gradle & AGP**: Migrated to **Kotlin DSL (`.kts`)**, updated **AGP to 8.7.2**, and **Gradle to 8.10.2**.
- **iOS Update**: Minimum deployment target updated to **16.0**.

### ✨ New Features
- **Presets**: Added quick presets for `success`, `error`, `warning`, and `info` dialogs.
- **Animation Presets**: Added `ACDAnimation` enum with built-in `fade`, `scale`, `bounce`, `rotate`, and `slide` animations.
- **Toast Support**: Added `ACDDialog.toast()` factory for non-blocking notifications.
- **New Components**: Added `acdTextField`, `acdImage`, and `listOfACDCheckbox` helpers.
- **Advanced Controls**: Added `autoDismissAfter` timer, `respectSafeArea`, and `onBarrierTap` callback.
- **Layout**: Added full **RTL (Right-to-Left)** support.
- **Stacking**: Added `ACDDialogQueue` for showing multiple dialogs sequentially.

### 🐞 Bug Fixes
- Fixed `acdProgress` crash when `valueColor` was null.
- Fixed `isShowingChange` side-effect during build by using post-frame callbacks.
- Fixed `useRootNavigator` not being forwarded correctly.
- Removed redundant `InkWell` wrappers in list tiles.
- Fixed `acdDivider` default height.
- Added null-safety guards for context in several builder methods.
- Resolved memory leaks by allowing manual static context clearing.

### 🛠 Improvements
- **Type Safety**: Fully typed all parameter signatures in the builder API.
- **List Controls**: Added `ScrollPhysics` and `ScrollController` support to list helpers.
- **API Cleanup**: Merged internal widget files for a cleaner import experience.
- Replaced deprecated `withOpacity` calls with modern alternatives.

## 0.0.2

- ✨ Fixed build-related issues in Android.

## 0.0.1

- ✨ `awesome_custom_dialog` initial release.
