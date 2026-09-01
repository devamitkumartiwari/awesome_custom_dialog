## 1.5.0

### ✨ New Features
- New `ACDLinearPercentIndicator` / `ACDCircularPercentIndicator` / `ACDMultiSegmentLinearIndicator` — a fully customizable, dependency-free progress/loader family, sharing one internal painting and animation core across all three. `ACDLinearPercentIndicator` fills its parent's available width responsively by default (no fixed-width-at-build-time trap) or takes an explicit `width`; supports `progressColor` (defaults to the ambient theme's primary color, not an invisible same-as-background gray)/`linearGradient`, a genuinely functional `backgroundGradient`, independent `progressBorderColor`/`backgroundBorderColor` outlines with a configurable `borderWidth`, a `boxShadow`, `strokeCap` (`butt`/`round`/`roundAll`), `barRadius`, `leading`/`trailing`/`center` content, and a `direction`-driven reverse fill. `ACDCircularPercentIndicator` adds the same `progressBorderColor`/`backgroundBorderColor`/`borderWidth`/`boxShadow` outline-and-shadow support, `fillMode: .pie` for a filled radial slice (alongside the default stroked `.ring`), `arcType` (`full`/`half`/`fullReversed`) convenience presets on top of raw `startAngle`/`sweepAngle` for custom gauges, `center`/`header`/`footer`, and a `reverse` fill direction — its background arc always spans the same extent as the foreground, so a half-circle/arc gauge's background never goes missing, and a 100%-full ring never silently vanishes. `ACDMultiSegmentLinearIndicator` takes a `List<ACDLoaderSegment>` (each with its own `percent`/`color`/`gradient`/`backgroundColor`/`backgroundGradient`/`borderColor`/`borderWidth`/`strokeCap`/`flex`/`enableStripes`, individually overriding the row-level defaults), diffed by key so adding, removing, or reordering segments at runtime — even mid-animation — never throws; its track background and marching-stripe color are both fully customizable (previously hardcoded). Every value is available fully controlled (`value`), uncontrolled (`initialValue`), or via a `ValueNotifier<double>` `controller`; every value change animates incrementally from its current displayed value (never restarts from `0`), every `AnimationController` is rigorously disposed, and nothing reads a `RenderBox`'s size before layout — sidestepping the whole class of bugs that pattern causes. Also ships `animate`/`animateFromInitial`/`animateFromLastPercent`/`restartAnimation` animation controls, `maskFilter` (glow), a `widgetIndicator`-style `indicator` marker painted at the live progress position, `onAnimationEnd`/`onPercentChanged` callbacks, a `keepAlive` flag for indicators inside scrollables, and a `showPercentageText` convenience (with `percentageTextStyle`/`percentageFormatter` overrides) that displays the live value as text with its font size automatically scaled to the indicator's own size — no manual font-size math needed for a bigger bar/ring to get bigger text. Corner rounding (`barRadius` on the linear/multi-segment widgets) is fully independent of `strokeCap` — set either one alone and it works, rather than requiring both together. All three now also accept `padding` (inside) and `margin` (outside) — `ACDCircularPercentIndicator` previously had neither.
- New `ACDPinField` — a dependency-free PIN/OTP input. The whole field is driven by one real, invisible `TextField` handling all actual text editing, cursor, IME, autofill, paste, and selection — the visible boxes are a pure presentation layer painted from that field's live text and selection, never a hand-rolled per-cell focus/selection reimplementation. Ships with per-state `ACDPinTheme` (default/focused/submitted/following/error/disabled, `submitted` correctly taking priority over `focused`) with animated cross-fade — each theme exposes direct `color`/`gradient`/`borderColor`/`borderWidth`/`borderRadius`/`shape` (rectangle or a fully circular cell)/`boxShadow` shortcuts (matching the rest of this package's widgets) plus a full `decoration: BoxDecoration` escape hatch for anything beyond them, and unfocused/focused/error states are visually distinct out of the box even with zero configuration. Also ships a `pinAnimationType` entry animation per digit (`scale`/`fade`/`slide`/`rotation`), `Form`/`FormField<String>` integration (`validator`, `onSaved`, a sensibly-defaulting `autovalidateMode` so a validation error shows on the very first interaction, and `forceErrorText` that never steals focus), obscured text with an optional brief reveal (`obscureRevealDuration`) before masking, a fully custom `cursor`/`obscuringWidgetBuilder`/`cellBuilder` escape hatch, OTP autofill via Flutter's own `AutofillHints.oneTimeCode` (no SMS-autofill plugin), haptic feedback and auto-close-keyboard on completion, a `separatorBuilder` for digit grouping, an optional `wrap` layout for long codes, and top-level `padding`/`margin` around the whole field (on top of each `ACDPinTheme`'s own per-cell `margin`/`padding`).
- **Toast overhaul** — `ACDDialog.toast()` now supports stacking multiple simultaneous toasts (`maxVisible` + `overflowPolicy`: `queue`/`dropOldest`/`unlimited`), a real exit transition (previously entrance-only), five style variants (`ACDToastStyle`: `filled`/`flat`/`flatColored`/`minimal`/`simple`), `contentType` presets shared with `ACDDialog.snackbar()`, a countdown `showProgressBar` (top or bottom), `pauseOnHover` (a no-op on touch-only platforms), `dragToDismiss`, a `closeButtonMode` (`never`/`always`/`onHover`, replacing the old plain `showCloseButton` bool — kept as a deprecated shortcut, zero breakage), a `showDelay` before appearing, a sticky/no-auto-dismiss mode (`showDuration: Duration.zero`), a per-toast `blockBackgroundInteraction` override, an optional trailing `actions` row, `onTap`/`onCloseButtonTap`/`onAutoDismiss`/`onShown` callbacks, and a `customBuilder` escape hatch that replaces the card entirely. Every toast is also fully customizable in appearance: `backgroundGradient`, `border`/`borderColor`/`borderWidth`, `boxShadow` (now always rendered on the outermost layer, never silently clipped away by the card's own content-clipping), `cornerRadius` (per-corner), and a full `shape` (`ShapeBorder`) escape hatch for pill/notched cards, on top of the existing `backgroundColor`/`textColor`/`fontSize`/`fontFamily`/`textStyle`/`borderRadius`/`width`/`height`/`constraints`. `margin` (outer inset), `contentPadding` (inner spacing), and the new `stackSpacing` (gap between stacked toasts) are three deliberately distinct, unambiguously-named knobs. Custom colors always render exactly as given (never coerced through a `MaterialColor` swatch), and every animation controller/timer/overlay entry is disposed exactly once via an idempotent dismiss state machine — a racing auto-dismiss timer and a manual/drag/dismiss-all call can never double-dispose or leave a toast half-torn-down.
- New `ACDToastManager` — a static management API beyond a single call site: `dismissAll()`/`dismissById()`/`dismissFirst()`/`dismissLast()`/`findById()`/`activeToasts()`/`activeCount()`, all optionally scoped to one `ACDGravity` position, plus `setDefaults(ACDToastConfig(...))`/`clearDefaults()` for app-wide toast defaults with per-call overrides. `ACDDialog.cancelToast()` now delegates to `dismissAll()`.
- New `ACDToastLayer` — an optional root-level wrapper (`MaterialApp(builder: (context, child) => ACDToastLayer(child: child!))`) giving toasts their own dedicated `Overlay`, independent of the app's Navigator. Entirely optional: `.toast()`/`.snackbar()` still work without it, falling back to the nearest ambient `Overlay`, and now throw a clear, actionable error instead of a raw framework crash if neither is available.
- Toasts never interact with the app's `Navigator` in any way — dismissal is always a plain `OverlayEntry` removal, so a toast can never pop a real screen and navigating screens can never affect an active toast.

### 🎨 Customization parity
All additions ship parity-complete from day one — active/disabled/error states, gradients, and implicit `animationDuration`/`animationCurve` transitions.

### 🐛 Bug fixes — right-to-left (RTL) layouts
A package-wide RTL audit found gravity-based positioning was inconsistently mirrored: `ACDGravity.left`/`.right`/the four corners meant "physical side, always" for screen docking, margin, and slide animations, while the button-row/column alignment helpers in the same file already auto-mirrored via `start`/`end` — an internal contradiction. Fixed at the source (`acdGravityToAlignment`/`acdResolveMarginForGravity`, plus the dialog presenter's slide-transition offset), so it's correct everywhere gravity is used: dialogs, toasts, snackbars, and the new toast stacking positions. `ACDDialog.textDirection` now also falls back to the ambient `Directionality` when not set explicitly, and actually reaches the overlay-mode presentation path (`.toast()`/`.snackbar()` use), not just the modal path's content column. `ACDDialog().text()`'s default alignment is now direction-aware (`AlignmentDirectional.centerStart`) instead of a hardcoded physical left. `ACDSnackbarContent`'s icon bubble and content padding now mirror alongside its decorative splash graphic under RTL (previously only the splash moved, a half-mirrored result). `ACDSlideAction`'s default thumb icon now visually flips under RTL to match its already-correctly-mirrored drag direction. `ACDPinField` gains an explicit `textDirection` parameter (LTR by default, independent of the app's ambient direction) so digit-entry order is a deliberate choice rather than an accidental side effect of the app's language — conventional PIN/OTP UX keeps digits left-to-right even in RTL apps.

All of the above are zero-dependency additions — no new packages were added to `pubspec.yaml` (OTP autofill uses Flutter's own `AutofillHints.oneTimeCode`, not a plugin). This release is fully backward compatible: every new/changed toast parameter is optional and resolves to the exact same output as before when omitted, and the RTL fixes only change behavior for apps already running under RTL `Directionality` (where the prior behavior was inconsistent/broken).

## 1.4.0

### ✨ New Features
- New `ACDSwitch` — a fully customizable, dependency-free toggle: `pill`/`roundedRectangle` shapes plus a `trackShapeBorder`/`thumbShapeBorder` escape hatch for any `ShapeBorder` (stadium, squircle, star...), full active/inactive/disabled color *and* gradient trios for track and thumb, matching active/inactive/disabled *border* trios, `EdgeInsets`-typed `thumbPadding`, `activeChild`/`inactiveChild` arbitrary-widget track content (plus plain `activeText`/`inactiveText` with per-state text styles/alignment and a `showOnOff` built-in-label fallback), `activeImage`/`inactiveImage` with an explicit `imageFit`, `trackBuilder`/`thumbBuilder` escape hatches, automatic RTL mirroring via `AlignmentDirectional`, a configurable `disabledOpacity`, desktop/web `mouseCursor` feedback, and opt-in native-style drag-to-toggle (`dragEnabled`) that flips past the 50% mark like a platform switch. Supports a fully controlled `value`/`onChanged` path, an uncontrolled `initialValue` convenience path, and an optional `ValueNotifier<bool>` `controller`. `ACDSwitch.material()`/`ACDSwitch.ios()` are ready-made platform-styled presets.
- New `ACDRatingBar` — a fully customizable, dependency-free rating bar: `tapAndDrag`/`tapOnly`/`dragOnly`/`none` interaction modes, `allowHalfRating` plus an opt-in continuous `ratingPrecision` for exact-fraction drag ratings, a unified status-aware `itemBuilder(context, index, fillFraction, status)`, `itemSpacing`/`itemPadding`/`separatorBuilder`, `minRating`/`maxRating`, `updateOnDrag`, `wrapAlignment`, `textDirection`, `clearOnReTap`, a strictly opt-in `enableHoverPreview` that never mutates state on its own, per-item glow (auto-matched to the current fill color) and pop-on-change animation, desktop/web `mouseCursor` feedback, and a single robust opaque `GestureDetector` for reliable tap/drag disambiguation. The default item can render as swappable icon glyphs (`filledIcon`/`halfIcon`/`emptyIcon`, e.g. hearts instead of stars with no `itemBuilder` needed) or, via `itemIconStyle: .vectorStar`, as a true vector star polygon using Flutter's built-in `StarBorder` shape (`starPoints`/`starPointRounding`/`starInnerRadiusRatio`). Fully controlled via a nullable `rating` + `onRatingUpdate`, with an uncontrolled `initialRating` convenience path that seeds exactly once — eliminating the classic "initial rating doesn't persist across rebuilds" bug by construction. No separate read-only "indicator" class — use `interactionMode: ACDRatingInteractionMode.none`.
- New `ACDMotion` / `ACDMotionSequence` — a dependency-free entrance/exit/rest/tap animation wrapper for any widget, driven by a single shared `ACDMotionEffect` config (opacity, offset, scale, rotation, skew, independent-axis blur) so entrance, exit, looping "at-rest" effects, and tap one-shots all speak the same typed vocabulary — plus an `effectBuilder` escape hatch for fully custom, hand-written animations. A controlled `visible` flag drives an independently-configurable `exitEffect`/`onExitComplete`, not just the entrance played backwards. The tap layer adds `onTapDown`/`onTapUp`/`onLongPress`, `hapticFeedbackOnTap`, `deferTapCallbackUntilAnimationComplete`, and `tapEffectRepeatCount`. Ten built-in looping presets via `ACDMotionRestEffect`/`ACDRestEffectConfig` (wave, pulse, rotate, bounce, slide, swing, size, fidget, dangle, vibrate), each with a `delay` and a `customEffect` escape hatch. `ACDMotionSequence` chains multiple steps, time- or tap-triggered, with looping and an `onPressed` hook. Every frame's scale/rotation/skew is composed into one `Matrix4` — no nested `Transform.translate`/`.scale`/`.rotate` widgets.
- New `ACDAnimatedText` / `ACDAnimatedTextSequence` — per-character staggered text animation sharing `ACDMotionEffect`/`ACDMotionRestEffect` with the `ACDMotion` family, including the same `visible`/`exitEffect` exit path (applied to the whole block, not per character). Grapheme-cluster aware (correct with emoji/combining marks, via `String.characters`), respects `Directionality`/`textDirection` for stagger order without disturbing bidi text shaping, supports `initialDelay` and a per-space `spaceDelay` for word-level pacing, and drives the whole entrance stagger from a single `AnimationController` so `onComplete` fires deterministically even when the text ends in whitespace.

### 🎨 Customization parity
All three additions above ship parity-complete from day one — active/inactive/disabled color and gradient variants, elevation/`boxShadow` overrides, border/`borderRadius`, and implicit `animationDuration`/`animationCurve` transitions — no follow-up parity pass needed this release.

All of the above are zero-dependency additions — no new packages were added to `pubspec.yaml` (grapheme-cluster splitting uses `String.characters`, already re-exported transitively by `package:flutter/widgets.dart`). This release is fully backward compatible.

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
