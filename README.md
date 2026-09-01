# awesome_custom_dialog

A simple, flexible way to show dialogs, toasts, snackbars, autocomplete fields, slide-to-confirm actions, switches, rating bars, motion/animated text, dashed/dotted decorations, steppers, percent/loading indicators, and PIN/OTP fields in Flutter — all with one easy-to-chain API. No extra packages needed.

[![pub package](https://img.shields.io/pub/v/awesome_custom_dialog.svg)](https://pub.dev/packages/awesome_custom_dialog)
[![license](https://img.shields.io/github/license/devamitkumartiwari/awesome_custom_dialog.svg)](https://github.com/devamitkumartiwari/awesome_custom_dialog/blob/master/LICENSE)

---

## Contents

- [🎖 Installation](#-installation)
- [📖 Usage Examples](#-usage-examples)
  1. [Simple Success Preset](#1-simple-success-preset)
  2. [Custom Dialog with List](#2-custom-dialog-with-list)
  3. [Toast Message](#3-toast-message)
  4. [Custom Animation and Position](#4-custom-animation-and-position)
  5. [Text Field with Validation](#5-text-field-with-validation)
  6. [Searchable List](#6-searchable-list)
  7. [Dropdown Field](#7-dropdown-field)
  8. [Autocomplete](#8-autocomplete)
  9. [Slide to Confirm](#9-slide-to-confirm)
  10. [Dashed and Dotted Decoration](#10-dashed-and-dotted-decoration)
  11. [Stepper](#11-stepper)
  12. [Switch](#12-switch)
  13. [Rating Bar](#13-rating-bar)
  14. [Motion & Animated Text](#14-motion--animated-text)
  15. [Percent & Loading Indicators](#15-percent--loading-indicators)
  16. [Pin / OTP Field](#16-pin--otp-field)
- [🍞 Toast](#-toast)
- [🍫 Snackbar](#-snackbar)
- [🎨 Customizing Everything](#-customizing-everything)
- [🚀 Key Features](#-key-features)
- [🛠 API Overview](#-api-overview)
- [⚙️ A Few More Things](#️-a-few-more-things)
- [🤝 Contributing](#-contributing)
- [📜 License](#-license)

---

## 🎖 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  awesome_custom_dialog: ^1.5.0
```

---

## 📖 Usage Examples

### 1. Simple Success Preset
```dart
ACDDialog().build(context)
  ..success(
    title: "Awesome!",
    message: "This is a beautiful success dialog.",
    onTap: () => print("Success acknowledged"),
  )
  ..show();
```

### 2. Custom Dialog with List
```dart
ACDDialog().build(context)
  ..width = 300
  ..borderRadius = 12
  ..text(text: "Choose an option", fontSize: 18, fontWeight: FontWeight.bold)
  ..acdDivider()
  ..listOfACDListTile(
    items: [
      ACDListTileItem(text: "Option 1", leading: Icon(Icons.star)),
      ACDListTileItem(text: "Option 2", leading: Icon(Icons.settings)),
    ],
    onClickItemListener: (index) => print("Selected $index"),
  )
  ..show();
```

### 3. Toast Message
```dart
ACDDialog.toast(
  context: context,
  message: "Changes saved successfully!",
  showDuration: Duration(seconds: 2),
)..show();
```

### 4. Custom Animation and Position
```dart
ACDDialog().build(context)
  ..gravity = ACDGravity.bottom
  ..animation = ACDAnimation.slideUp
  ..borderRadius = 20
  ..text(text: "I slid up from the bottom!")
  ..show();
```

### 5. Text Field with Validation
`acdTextField()`'s `validator` is optional — add it only if you need it:
```dart
final fieldKey = GlobalKey<FormFieldState<String>>();
final dialog = ACDDialog().build(context)
  ..acdTextField(
    hint: "Enter your full name",
    fieldKey: fieldKey,
    validator: (value) =>
        (value == null || value.trim().isEmpty) ? "Name is required" : null,
  );
dialog
  ..oneButton(
    text: "Submit",
    isClickAutoDismiss: false, // let validation decide whether to dismiss
    onTap: () {
      if (fieldKey.currentState?.validate() ?? false) {
        dialog.dismiss(); // valid — dismiss manually
      }
    },
  )
  ..show();
```

### 6. Searchable List
```dart
ACDDialog().build(context)
  ..height = 400
  ..searchableList<String>(
    items: countries,
    searchHint: "Search countries",
    onChange: (country) => print("Picked $country"),
  )
  ..show();
```
Pass your own model type instead of `String` for typed selections (`itemAsString` extracts the label, `itemBuilder` fully customizes each row), or use `.multiSearchableList<T>()` for a multi-select version with a built-in Confirm/Cancel row. Supply `onFind` on either to delegate non-empty queries to your own async/remote search instead of filtering `items` locally.

### 7. Dropdown Field

`searchableList()` above only works as content inside an already-open `ACDDialog`. `ACDDropdownField<T>` is the inline counterpart — a real `FormField<T>`, so it drops straight into a `Form` with a `validator`, sits next to your other fields, and shows the current selection itself.

**Basic usage, inside a `Form`:**
```dart
ACDDropdownField<String>(
  items: countries,
  decoration: const InputDecoration(labelText: "Country"),
  searchHint: "Search countries",
  validator: (value) => value == null ? "Required" : null,
  onChanged: (value) => print("Picked $value"),
)
```

**Popup presentation** — `mode` controls how it opens: a centered dialog (default), a bottom sheet, or a non-modal menu anchored directly under the field:
```dart
ACDDropdownField<String>(
  items: skills,
  mode: ACDDropdownMode.bottomSheet, // or .dialog (default) / .menu
  decoration: const InputDecoration(labelText: "Primary skill"),
  onChanged: (value) => print("Skill: $value"),
)
```

**Multi-select**, with `ACDMultiDropdownField<T>` — same shape, `List<T>` value, confirmed via the popup's OK button:
```dart
ACDMultiDropdownField<String>(
  items: skills,
  decoration: const InputDecoration(labelText: "Skills"),
  checkboxActiveColor: Colors.teal,
  onChanged: (values) => print("Skills: $values"),
)
```

**Clear button & custom closed-state display** — `showClearButton` adds a trailing clear icon once something's selected; `dropdownBuilder` fully replaces the default `Text` shown when closed:
```dart
ACDDropdownField<String>(
  items: countries,
  showClearButton: true,
  dropdownBuilder: (context, value) => value == null
      ? const Text("Choose a country")
      : Row(
          mainAxisSize: MainAxisSize.min,
          children: [const Icon(Icons.flag, size: 16), const SizedBox(width: 6), Text(value)],
        ),
  onChanged: (value) => print("Picked $value"),
)
```

**Styling** — the closed-state field takes a normal `InputDecoration` (label, hint, border, fill, prefix/suffix icons — everything `TextFormField` accepts), and the popup's rows and search box style independently via `itemTextColor`/`itemFontSize`/`itemFontWeight`/`itemFontFamily`/`itemStyle` (or `itemBuilder` for full control), `tileColor`, and `searchFillColor`/`searchBorderColor`/`searchBorderRadius`:
```dart
ACDDropdownField<String>(
  items: countries,
  decoration: InputDecoration(
    labelText: "Country",
    prefixIcon: const Icon(Icons.public),
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
  itemTextColor: Colors.teal.shade900,
  itemFontWeight: FontWeight.w600,
  tileColor: Colors.teal.shade50,
  searchFillColor: Colors.white,
  searchBorderColor: Colors.teal,
  searchBorderRadius: 12,
  showClearButton: true,
  clearIcon: Icons.cancel_rounded,
  onChanged: (value) => print("Picked $value"),
)
```

**Custom equality, disabled rows, and pinned favorites** — `compareFn` lets a model type skip a `==`/`hashCode` override, `isDisabledItem` greys out and disables specific rows, and `favoriteItems` pins items to the top of the list before any search:
```dart
ACDDropdownField<User>(
  items: users,
  itemAsString: (u) => u.name,
  compareFn: (a, b) => a.id == b.id,        // instead of a ==/hashCode override
  isDisabledItem: (u) => u.id == blockedId,  // greyed out, ignores taps
  favoriteItems: [currentUser],              // pinned to the top
  onChanged: (user) => print("Assigned to ${user?.name}"),
)
```

**Paginated / infinite-scroll search** — `onFindPaged(query, page)` loads another page as the list is scrolled to its end; return fewer results than requested (or `[]`) to signal there's no more data:
```dart
ACDDropdownField<String>(
  items: const [],
  onFindPaged: (query, page) => api.search(query, page: page, pageSize: 20),
  decoration: const InputDecoration(labelText: "Search a large remote list"),
  onChanged: (value) => print("Picked $value"),
)
```

### 8. Autocomplete

`ACDAutocompleteField<T>` is a standalone typeahead text field — generic over your item type, with local or remote suggestion matching:
```dart
ACDAutocompleteField<String>(
  suggestions: countries,
  decoration: const InputDecoration(labelText: "Country"),
  onSuggestionSelected: (country) => print("Picked $country"),
)
```
Supply `filterFn` for custom local matching, or `onFind` to delegate to a remote/async source (debounced by `searchDebounce`) — same shape as `ACDDropdownField.onFind`. `submitOnSuggestionTap`/`clearOnSubmit` control what happens after a pick, and `itemBuilder` fully customizes each suggestion row.

For `@mention`/`#hashtag`-style autocomplete with multiple independent triggers in one field, use `ACDTriggerAutocompleteField` with a list of `ACDAutocompleteTrigger`s:
```dart
ACDTriggerAutocompleteField(
  decoration: const InputDecoration(labelText: "Message"),
  maxLines: 3,
  triggers: [
    ACDAutocompleteTrigger(trigger: "@", optionsBuilder: findUsers),
    ACDAutocompleteTrigger(trigger: "#", optionsBuilder: findHashtags),
  ],
  onOptionSelected: (trigger, option) => print("$option via ${trigger.trigger}"),
)
```
Each trigger's `optionsBuilder(query)` is its own async lookup, so `@` and `#` can search entirely different data sources. `triggerOnlyAtStart`/`triggerOnlyAfterSpace` control when a trigger arms, and `minCharsForSuggestions` sets how many characters must follow it first.

### 9. Slide to Confirm

`ACDSlideAction` requires a deliberate drag gesture before firing an action — useful anywhere an accidental tap shouldn't be enough (payments, deletions, unlocking):
```dart
ACDSlideAction(
  label: "Slide to confirm",
  onConfirm: () => print("Confirmed!"),
)
```

Pair it with `ACDSlideActionController` to show loading/success feedback for an async action:
```dart
final controller = ACDSlideActionController();

ACDSlideAction(
  controller: controller,
  label: "Slide to pay",
  onConfirm: () async {
    controller.loading();
    final ok = await submitPayment();
    ok ? controller.success() : controller.reset();
  },
)
```

Want a polished look with zero styling? `ACDSlideAction.swipeButton()` is a ready-made preset:
```dart
ACDSlideAction.swipeButton(
  label: "Swipe to pay",
  onConfirm: () => print("Paid"),
)
```
Both constructors share the same full customization surface — shape (`ACDSlideActionShape.rectangle`/`.circle`), drag direction (`ACDSlideActionDirection.startToEnd`/`.endToStart`/`.dual`), colors and gradients (including separate active/inactive variants for both thumb and track), elevation, a wave-trail animation, and full builder escape hatches (`foregroundBuilder`/`backgroundBuilder`/`outerBackgroundBuilder`) — see [Customizing Everything](#-customizing-everything) below.

### 10. Dashed and Dotted Decoration

`ACDDashedLine` draws a standalone dashed/dotted line, horizontal or vertical:
```dart
ACDDashedLine(length: 200, color: Colors.grey, dashLength: 6, gapLength: 4)
ACDDashedLine(axis: Axis.vertical, length: 100, roundedCaps: true)
```

`ACDDottedDecoration` is a drop-in `Decoration` — use it anywhere a `BoxDecoration` would go:
```dart
Container(
  decoration: const ACDDottedDecoration(shape: ACDDottedShape.box),
  child: const Padding(padding: EdgeInsets.all(12), child: Text("Hi")),
)
```
`shape` also supports `.line` (a single dashed edge, positioned via `linePosition`) and `.oval`.

`ACDDashedBorder` wraps any widget with a dashed outline:
```dart
ACDDashedBorder(
  shape: ACDDashedBorderShape.roundedRect,
  child: const Padding(padding: EdgeInsets.all(16), child: Text("Drop file here")),
)
```
`shape` also supports `.rect`, `.oval`, `.circle`, and `.customPath` (pass `customPathBuilder: (size) => Path()...` for an arbitrary outline).

### 11. Stepper

`ACDStepper` is a compact step-progress indicator — a horizontal wizard bar by default:
```dart
ACDStepper(
  steps: const ["Cart", "Address", "Payment", "Done"],
  activeStep: currentStep,
  onStepReached: (i) => setState(() => currentStep = i),
)
```
Set `direction: Axis.vertical` for a timeline layout instead. For a "minimal dots" look, combine `stepShape: ACDStepShape.circle`, a small `stepRadius`, and `showTitle: false`.

For a scrollable list of steps (e.g. order-tracking history) rather than a small fixed count, use `ACDStepperListView<T>`:
```dart
ACDStepperListView<String>(
  items: const [
    ACDStepperItemData(id: 1, data: "Order placed"),
    ACDStepperItemData(id: 2, data: "Shipped"),
    ACDStepperItemData(id: 3, data: "Delivered"),
  ],
  contentBuilder: (context, item, index) => Text(item.data),
)
```
`avatarBuilder`/`labelBuilder` customize each row's marker/label, and `theme: ACDStepperThemeData(dashed: true)` switches the connector line from solid to dashed.

---

### 12. Switch

`ACDSwitch` is a fully customizable, dependency-free toggle:
```dart
ACDSwitch(
  initialValue: isEnabled,
  activeTrackColor: Colors.green,
  onChanged: (value) => setState(() => isEnabled = value),
)
```
Works controlled (`value`/`onChanged`, like `Checkbox`), uncontrolled (`initialValue`), or driven by an external `ValueNotifier<bool>` `controller`. `ACDSwitch.material()`/`ACDSwitch.ios()` are ready-made platform presets. Every surface — track, thumb, border — accepts active/inactive/disabled colors *and* gradients, plus a `trackShapeBorder`/`thumbShapeBorder` escape hatch for any `ShapeBorder`. `dragEnabled` (default `true`) lets the thumb be dragged like a native switch.

---

### 13. Rating Bar

`ACDRatingBar` is a fully customizable, dependency-free rating bar:
```dart
ACDRatingBar(
  initialRating: 3,
  allowHalfRating: true,
  onRatingUpdate: (rating) => debugPrint('Rated $rating'),
)
```
`interactionMode` (`tapAndDrag`/`tapOnly`/`dragOnly`/`none`) controls input — use `.none` in place of a separate read-only "indicator" widget. Swap `filledIcon`/`emptyIcon` for a quick look change (e.g. hearts), or set `itemIconStyle: ACDRatingIconStyle.vectorStar` for a true vector star (Flutter's built-in `StarBorder` shape, not a font glyph) with `starPoints`/`starPointRounding` control. An opt-in continuous `ratingPrecision` (e.g. `0.1`) allows exact-fraction ratings beyond whole/half stars.

---

### 14. Motion & Animated Text

`ACDMotion` wraps any widget with entrance/exit/rest/tap effects, sharing one `ACDMotionEffect` vocabulary (opacity, offset, scale, rotation, skew, blur):
```dart
ACDMotion(
  effect: ACDMotionEffect.fadeSlideIn(),
  restEffect: const ACDRestEffectConfig(effect: ACDMotionRestEffect.pulse),
  onTap: () => debugPrint('tapped'),
  child: const FlutterLogo(),
)
```
`ACDAnimatedText` animates a string in per-character, grapheme- and RTL-aware, from a single `AnimationController` so `onComplete` fires reliably even for text ending in whitespace:
```dart
ACDAnimatedText(
  text: 'Hello, world!',
  effect: ACDMotionEffect.fadeSlideIn(),
  onComplete: () => debugPrint('done'),
)
```
Flip `visible` to `false` to play `exitEffect` (defaults to `effect` reversed) instead of unmounting. `ACDMotionSequence`/`ACDAnimatedTextSequence` chain multiple steps, time- or tap-triggered, with optional looping.

---

### 15. Percent & Loading Indicators

`ACDLinearPercentIndicator` and `ACDCircularPercentIndicator` are fully customizable, dependency-free progress indicators:
```dart
ACDLinearPercentIndicator(
  initialValue: 0.4,
  progressColor: Colors.blue,
  showPercentageText: true, // "40%", font size auto-scaled to lineHeight
)

ACDCircularPercentIndicator(
  radius: 60,
  initialValue: 0.7,
  progressColor: Colors.green,
  fillMode: ACDLoaderFillMode.pie, // or the default .ring
  showPercentageText: true, // "70%", font size auto-scaled to radius
)
```
Both work controlled (`value`), uncontrolled (`initialValue`), or driven by a `ValueNotifier<double>` `controller` — perfect for a download/upload progress stream. `ACDLinearPercentIndicator` fills its parent's width responsively by default; pass `width` for a fixed size. `ACDCircularPercentIndicator` supports `arcType` (`full`/`half`/`fullReversed`) for quick gauge shapes, or raw `startAngle`/`sweepAngle` for anything custom. Both animate every value change incrementally from the current value (never restarting from `0`), and support `direction: ACDLoaderDirection.reverse`, gradients (`linearGradient`/`circularGradient`, plus a genuinely working `backgroundGradient`), independent `progressBorderColor`/`backgroundBorderColor` outlines, a `boxShadow`, and `strokeCap`/`barRadius` for corner rounding — set either alone, they don't require each other. Pass your own `center` instead of `showPercentageText` for anything beyond a plain percentage label.

For multiple independent segments in one bar:
```dart
ACDMultiSegmentLinearIndicator(
  segments: [
    ACDLoaderSegment(key: 'download', percent: 0.6, color: Colors.blue),
    ACDLoaderSegment(key: 'verify', percent: 0.2, color: Colors.orange),
  ],
)
```
`segments` is diffed by `ACDLoaderSegment.key`, so adding, removing, or reordering segments at runtime — even mid-animation — is always safe.

---

### 16. Pin / OTP Field

`ACDPinField` is a dependency-free PIN/OTP input, built around one real (invisible) `TextField` so selection, cursor, IME, paste, and autofill are all Flutter's own native behavior — not reimplemented:
```dart
ACDPinField(
  length: 6,
  onCompleted: (pin) => debugPrint('Entered $pin'),
  validator: (pin) => pin != null && pin.length == 6 ? null : 'Enter all 6 digits',
)
```
Drop it straight into a `Form` — it's a real `FormField<String>`, so `validator`/`onSaved`/`autovalidateMode` all work as expected, and a validation error shows correctly on the very first interaction. Style each state independently with `pinTheme`/`focusedPinTheme`/`submittedPinTheme`/`errorPinTheme`/`disabledPinTheme`, pick a `pinAnimationType` (`scale`/`fade`/`slide`/`rotation`) for the per-digit entry animation, and use `obscureText` (with an optional `obscureRevealDuration` to briefly show each digit before masking it) for a passcode-style field. OTP autofill works out of the box via `AutofillHints.oneTimeCode` — no extra plugin required.

---

## 🍞 Toast

A small message that appears briefly and disappears on its own — like a native Android toast, but on any platform. It never blocks taps on the rest of your app, stacks multiple toasts cleanly, and is fully customizable: colors, gradients, borders, shapes, corner radius, styles, animations, progress bar, drag-to-dismiss, and more.

```dart
ACDDialog.toast(
  context: context,
  message: "Copied to clipboard",
  length: ACDToastLength.long,                       // short or long
  closeButtonMode: ACDToastCloseButtonMode.always,   // never / always / onHover
  dismissOnTap: true,                                 // tap the toast to dismiss it
  fontFamily: "Roboto",
)..show();

// Dismiss whichever toast is currently showing
ACDDialog.cancelToast();
```

Optionally wrap your app once to give toasts a dedicated `Overlay`, independent of your app's own navigation stack (recommended, but not required — `.toast()`/`.snackbar()` fall back to the nearest ambient `Overlay` otherwise):

```dart
MaterialApp(
  builder: (context, child) => ACDToastLayer(child: child!),
  home: const HomeScreen(),
)
```

**Stacking multiple toasts** — cap how many show at once with `maxVisible`, and choose what happens to the rest via `overflowPolicy` (`queue`, the default, holds extras back; `dropOldest` bumps the oldest to make room; `unlimited` ignores the cap):

```dart
for (final msg in ["Step 1", "Step 2", "Step 3", "Step 4"]) {
  ACDDialog.toast(
    context: context,
    message: msg,
    cancelPrevious: false,
    maxVisible: 3,
    overflowPolicy: ACDToastOverflowPolicy.queue,
  ).show();
}
```

**Styles and content types** — `style` picks a visual variant (`filled`, `flat`, `flatColored`, `minimal`, `simple`), `contentType` reuses the same success/failure/warning/help presets as [Snackbar](#-snackbar):

```dart
ACDDialog.toast(
  context: context,
  message: "Saved successfully",
  contentType: ACDContentType.success,
  style: ACDToastStyle.flatColored,
)..show();
```

**Progress bar, pause-on-hover, drag-to-dismiss:**

```dart
ACDDialog.toast(
  context: context,
  message: "Hover to pause the countdown",
  showProgressBar: true,
  pauseOnHover: true,   // desktop/web — a no-op on touch-only platforms
  dragToDismiss: true,  // swipe the toast away
  showDuration: const Duration(seconds: 6),
)..show();
```

**Full appearance control** — beyond `backgroundColor`/`borderRadius`, every toast also accepts `backgroundGradient`, `border`/`borderColor`/`borderWidth`, `boxShadow`, `cornerRadius` (per-corner), and a `shape` (`ShapeBorder`) escape hatch for pill/notched cards — plus `margin` (inset from the screen edge), `contentPadding` (inner spacing), and `stackSpacing` (gap between stacked toasts), kept as three distinct knobs on purpose. For anything else, `customBuilder` fully replaces the card.

**Management API** beyond a single call site — `ACDToastManager.dismissAll()`/`.dismissById(id)`/`.dismissFirst()`/`.dismissLast()`/`.findById(id)`/`.activeCount()`/`.activeToasts()`, plus `ACDToastManager.setDefaults(ACDToastConfig(...))` for app-wide defaults with per-call overrides.

Want to show several toasts one after another instead of stacking them? Reuse the built-in queue:

```dart
for (final msg in ["Step 1", "Step 2", "Step 3"]) {
  ACDDialogQueue.enqueue(
    ACDDialog.toast(context: context, message: msg, cancelPrevious: false),
  );
}
```

You can position a toast anywhere using `gravity` — top, bottom, center, or any corner (see `ACDGravity` below); every position automatically mirrors under RTL directionality.

---

## 🍫 Snackbar

A colorful banner for success, failure, warning, or help messages. Use it as a standalone widget inside Flutter's own `SnackBar`:

```dart
ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(
    SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: ACDSnackbarContent(
        title: "Oh Snap!",
        message: "This is an example error message.",
        contentType: ACDContentType.failure,
      ),
    ),
  );
```

Or skip `ScaffoldMessenger` entirely and let the package show it for you:

```dart
ACDDialog.snackbar(
  context: context,
  title: "Success",
  message: "Your changes have been saved.",
  contentType: ACDContentType.success,
)..show();
```

`ACDContentType` has four ready-made looks: `success`, `failure`, `warning`, and `help`.

---

## 🎨 Customizing Everything

Every part of every dialog, toast, snackbar, dropdown field, autocomplete field, slide action, decoration, and stepper can be styled — and everything has a sensible default if you don't touch it:

- **Color**: `color`, `backgroundColor`, `iconColor`, `titleColor`, `messageColor`, and more, depending on what you're building.
- **Font**: `fontFamily`, `fontSize`, `fontWeight` as quick shortcuts, or pass a full `TextStyle` (`style`, `titleStyle`, `messageStyle`, `textStyle1`/`2`/`3`...) for complete control — letter spacing, italics, underlines, anything `TextStyle` supports.
- **Buttons**: `oneButton`/`twoButton`/`threeButton` accept `backgroundColor`, `borderRadius`, `elevation`/`boxShadow`, `icon`, and `gradient` per button slot — not just text color/style:
  ```dart
  ACDDialog().build(context)
    ..oneButton(
      text: "Done",
      color: Colors.white,
      backgroundColor: Colors.teal,
      borderRadius: BorderRadius.circular(12),
      icon: Icons.check_circle_outline,
    )
    ..show();
  ```
- **Snackbar**: `ACDSnackbarContent`/`ACDDialog.snackbar()` accept `gradient` (overriding the flat background color), `elevation`/`boxShadow`, and `titleFontSize`/`titleFontWeight`/`titleFontFamily`/`messageFontSize`/`messageFontWeight`/`messageFontFamily` shortcuts alongside the existing full `titleTextStyle`/`messageTextStyle`.
- **Toast**: `ACDDialog.toast()` accepts `style` (`filled`/`flat`/`flatColored`/`minimal`/`simple`), `contentType`, `backgroundGradient`, `border`/`borderColor`/`borderWidth`, `boxShadow`, `cornerRadius`, and a full `shape` (`ShapeBorder`) escape hatch, plus a `customBuilder` that replaces the card entirely — on top of the existing `backgroundColor`/`textColor`/`fontSize`/`fontFamily`/`textStyle`/`borderRadius`. `margin` (outer inset), `contentPadding` (inner spacing), and `stackSpacing` (gap between stacked toasts) are three deliberately distinct knobs.
- **Lists**: `listOfACDListTile`/`listOfACDRadioButton`/`listOfACDCheckbox`/`searchableList` all accept a `borderRadius` for rounded rows; `ACDRadioItem`/`ACDCheckboxItem` accept `leading`/`trailing` widgets (previously only the plain list variant could); the searchable list's magnifying-glass icon is overridable via `searchIcon`.
- **`acdTextField`**: accepts `prefixIcon`/`suffixIcon`, on top of the existing fill/border/label styling.
- **Dropdown fields**: `ACDDropdownField`/`ACDMultiDropdownField` take a standard `InputDecoration` for the closed-state field (label, hint, border, fill, icons — same as `TextFormField`), plus their own `itemTextColor`/`itemFontSize`/`itemFontWeight`/`itemFontFamily`/`itemStyle`, `tileColor`, and `searchFillColor`/`searchBorderColor`/`searchBorderRadius` for the popup — see the styling example in [Dropdown Field](#7-dropdown-field) above.
- **Autocomplete popups**: `ACDAutocompleteField`/`ACDTriggerAutocompleteField` accept `popupElevation`/`popupBorderRadius`/`popupColor` for the suggestion card, plus the same `itemTextColor`/`itemFontSize`/`itemFontWeight`/`itemFontFamily`/`itemStyle` row-styling shortcuts as the dropdown field.
- **Dashed/dotted/border**: `ACDDashedLine`, `ACDDottedDecoration`, and `ACDDashedBorder` all accept a `gradient` (overriding the flat `color`) and `roundedCaps` (turns square dash segments into rounded — what actually makes a dotted pattern read as *dots*).
- **Slide to confirm**: `ACDSlideAction` accepts `activeThumbColor`/`inactiveThumbColor` and `activeTrackColor`/`inactiveTrackColor` for distinct idle-vs-dragging looks, with matching `activeThumbGradient`/`inactiveThumbGradient`/`activeTrackGradient`/`inactiveTrackGradient` gradient variants, plus `elevationThumb`/`elevationTrack`, `trackPadding`, `thumbBorderRadius`, and a `showWaveTrail` animated trail.
- **Stepper**: `ACDStepper` accepts per-status `finishedStepGradient`/`activeStepGradient`/`upcomingStepGradient`, `markerElevation`/`markerBoxShadow`, and an implicit `animationDuration`/`animationCurve` transition whenever `activeStep` changes; `ACDStepperListView` has the matching `avatarGradient`/`avatarElevation`/`animationDuration`/`animationCurve`.
- **Percent & loading indicators**: `progressColor`/`linearGradient`/`circularGradient` (defaulting to the theme's primary color, not an invisible same-as-background gray) plus a genuinely working `backgroundGradient`, independent `progressBorderColor`/`backgroundBorderColor` outlines with a `borderWidth`, a `boxShadow`, `strokeCap`, `barRadius`, `direction` (reverse fill), and `fillMode`/`arcType` for the circular indicator's ring/pie and gauge shapes; `ACDMultiSegmentLinearIndicator` colors/borders/animates each `ACDLoaderSegment` independently (including its own `backgroundColor`/`borderColor` overrides), plus a customizable `stripeColor` for the marching-stripe effect. All three loaders accept `padding` (inside) and `margin` (outside).
- **Pin / OTP field**: `ACDPinField` accepts per-state `pinTheme`/`focusedPinTheme`/`submittedPinTheme`/`errorPinTheme`/`disabledPinTheme` (each an `ACDPinTheme` with direct `color`/`gradient`/`borderColor`/`borderWidth`/`borderRadius`/`shape` (rectangle or circle)/`boxShadow` shortcuts, plus a full `decoration: BoxDecoration` escape hatch for anything beyond them), a `pinAnimationType` per-digit entry animation, and `obscureText`/`obscureRevealDuration`/`obscuringWidgetBuilder` for masked codes. Focused and error states already look distinct out of the box — no theme required to get sensible visual feedback. `ACDPinField` itself also takes a top-level `padding`/`margin` around the whole field, separate from each `ACDPinTheme`'s own per-cell `margin`/`padding`.
- **Gradients & elevation, consistently**: as a rule across the whole package, any widget with a background color also accepts a matching `Gradient?` override, and most now expose an `elevation`/`boxShadow` pair — not just the dialog core.
- **Corners**: `borderRadius` is available on dialogs, images, text fields, toasts, snackbars, lists, buttons, and every new widget above. For a dialog that only wants *some* corners rounded (like a side panel sitting flush against an edge), pass a full `cornerRadius` instead:
  ```dart
  ACDDialog().build(context)
    ..gravity = ACDGravity.left
    ..width = 280
    ..cornerRadius = const BorderRadius.only(
      topRight: Radius.circular(20),
      bottomRight: Radius.circular(20),
    )
    ..text(text: "Side panel with only its right corners rounded")
    ..show();
  ```
- **Padding & margin**: `padding` and `margin` are available almost everywhere content is added.
- **Icons**: swap the icon on any preset (`success()`, `error()`, `warning()`, `info()`), snackbar (`icon:`), button (`icon`/`icon1`/`icon2`/`icon3`), or the searchable list's search icon (`searchIcon`) for your own.

---

## 🚀 Key Features

- **Chainable API**: Build a dialog step by step with `..` calls, then `.show()` it.
- **10 Positions**: Show your dialog centered, top, bottom, or in any corner.
- **Ready-made dialogs**: Success, Error, Warning, and Info — just fill in a title and message.
- **Smooth animations**: Fade, scale, bounce, rotate, and slide.
- **Everything you need inside**: text, buttons (one/two/three), radio lists, checkboxes, progress spinners, images, and text fields (with optional validation).
- **Searchable lists**: A filterable, generic `<T>` list for the dialog — single- or multi-select, local filtering or async `onFind` remote search with loading/empty/error states.
- **Dropdown fields**: `ACDDropdownField<T>` / `ACDMultiDropdownField<T>` — an inline, `Form`-compatible searchable dropdown (validator, clear button, disabled items, pinned favorites, paginated search) that opens as a dialog, bottom sheet, or anchored menu.
- **Autocomplete**: `ACDAutocompleteField<T>` — a generic typeahead field with local or remote search — and `ACDTriggerAutocompleteField` for multi-trigger `@mention`/`#hashtag`-style autocomplete.
- **Slide to confirm**: `ACDSlideAction` — a drag-to-confirm action bar with RTL support, haptics, and loading/success feedback via `ACDSlideActionController`, plus a ready-made `.swipeButton` preset that needs no styling at all.
- **Switch**: `ACDSwitch` — a fully customizable toggle (shapes, gradients, images, custom track/thumb widgets, RTL, drag-to-toggle) with `.material()`/`.ios()` presets.
- **Rating bar**: `ACDRatingBar` — tap/drag star (or any icon, or a true vector star) rating with half-star, continuous-precision, glow, and pop-animation support.
- **Motion & animated text**: `ACDMotion`/`ACDMotionSequence` — an entrance/exit/rest/tap animation wrapper for any widget — and `ACDAnimatedText`/`ACDAnimatedTextSequence` for per-character staggered text, both sharing one `ACDMotionEffect` vocabulary.
- **Dashed & dotted decoration**: `ACDDashedLine`, `ACDDottedDecoration` (a drop-in `Decoration`), and `ACDDashedBorder` (wraps any widget, including custom-path outlines).
- **Stepper**: `ACDStepper` — a horizontal wizard or vertical timeline progress indicator — and `ACDStepperListView<T>` for a scrollable timeline list.
- **Percent & loading indicators**: `ACDLinearPercentIndicator`/`ACDCircularPercentIndicator`/`ACDMultiSegmentLinearIndicator` — responsive, gradient- and direction-aware progress bars/rings/pies with safe runtime-diffed segments.
- **Pin / OTP field**: `ACDPinField` — a single-`TextField`-driven PIN/OTP input with per-state theming, `Form` integration, and built-in OTP autofill.
- **Toast messages**: A tiny, auto-dismissing message that never blocks the rest of your screen — with stacking (`maxVisible`/`overflowPolicy`), style variants, a progress bar, pause-on-hover, drag-to-dismiss, and a full management API (`ACDToastManager`).
- **Snackbar messages**: Colorful success/failure/warning/help banners, usable on their own or through the dialog API.
- **Style everything**: Colors, gradients, fonts, padding, corner radius, elevation/shadow, and icons are all customizable, everywhere — with sensible defaults if you change nothing.
- **No extra dependencies**: Just Flutter itself.

---

## 🛠 API Overview

| Method | Description |
|---|---|
| `.success()` / `.error()` / `.warning()` / `.info()` | Ready-made status dialogs. |
| `.text()` | Add styled text. |
| `.oneButton()` / `.twoButton()` / `.threeButton()` | Add action buttons — colors, shape, elevation, icon, gradient. |
| `.acdTextField()` | Input field inside a dialog, with optional validation and prefix/suffix icons. |
| `.acdProgress()` | Loading spinner. |
| `.acdImage()` | Asset or network image. |
| `.acdDivider()` | A horizontal divider line. |
| `.listOfACDListTile()` / `.listOfACDRadioButton()` / `.listOfACDCheckbox()` | Scrollable list content, with per-row `borderRadius` and `leading`/`trailing` widgets. |
| `.searchableList<T>()` / `.multiSearchableList<T>()` | Filterable single/multi-select list, generic over your item type, with optional async `onFind` search. |
| `ACDDropdownField<T>` / `ACDMultiDropdownField<T>` | Inline, `Form`-compatible searchable dropdown — dialog/bottomSheet/menu popup, validator, clear button, paginated search. |
| `ACDAutocompleteField<T>` | Standalone typeahead text field with local or remote suggestion matching. |
| `ACDTriggerAutocompleteField` / `ACDAutocompleteTrigger` | Multi-trigger `@mention`/`#hashtag`-style autocomplete field. |
| `ACDSlideAction` / `ACDSlideAction.swipeButton()` | Drag-to-confirm action bar, with a ready-made zero-styling preset. |
| `ACDSlideActionController` | Drives an `ACDSlideAction`'s loading/success/reset lifecycle from an async handler. |
| `ACDDashedLine` | Standalone dashed/dotted line, horizontal or vertical. |
| `ACDDottedDecoration` | Dashed/dotted `Decoration` — drop into any `Container(decoration: ...)`. |
| `ACDDashedBorder` | Wraps any widget with a dashed/dotted border, including custom-path outlines. |
| `ACDStepper` | Horizontal wizard or vertical timeline step-progress indicator. |
| `ACDStepperListView<T>` / `ACDStepperItemData<T>` | Scrollable timeline list — avatar/marker + connector line + content per row. |
| `ACDSwitch` / `ACDSwitch.material()` / `ACDSwitch.ios()` | Fully customizable toggle switch, with ready-made platform-styled presets. |
| `ACDRatingBar` | Tap/drag rating bar — half-star, continuous precision, custom `itemBuilder`, glow, and pop animation. |
| `ACDMotion` / `ACDMotionSequence` | Entrance/exit/rest/tap animation wrapper for any widget, and a chained-step sequence of them. |
| `ACDAnimatedText` / `ACDAnimatedTextSequence` | Per-character staggered text animation, and a chained-step sequence of them. |
| `ACDLinearPercentIndicator` / `ACDCircularPercentIndicator` | Responsive linear bar / circular ring-or-pie progress indicator, gradient- and direction-aware. |
| `ACDMultiSegmentLinearIndicator` / `ACDLoaderSegment` | Multiple independently-colored, independently-animated progress segments in one bar, safely diffable at runtime. |
| `ACDPinField` | PIN/OTP input built on one real `TextField`, with per-state theming and `Form` integration. |
| `.autoDismissAfter` | Close automatically after a duration. |
| `.gravity` | Where the dialog appears (`ACDGravity`: left, top, bottom, right, center, corners...). |
| `.animation` | How it appears (`ACDAnimation`: fade, scale, bounce, rotate, slide...). |
| `ACDDialog.toast()` / `ACDDialog.cancelToast()` | Show/cancel a toast message — stacking, styles, progress bar, drag-to-dismiss. |
| `ACDToastLayer` | Optional root wrapper giving toasts their own dedicated `Overlay`. |
| `ACDToastManager` | Toast management: `dismissAll()`/`dismissById()`/`dismissFirst()`/`dismissLast()`/`findById()`/`activeToasts()`/`setDefaults()`. |
| `ACDToastStyle` / `ACDToastConfig` | Toast visual variants (`filled`/`flat`/`flatColored`/`minimal`/`simple`) and the full resolved-parameter config. |
| `ACDDialog.snackbar()` / `ACDSnackbarContent` | Show a snackbar message. |
| `ACDDialogQueue.enqueue()` | Show dialogs (or toasts) one after another, without overlapping. |

---

## ⚙️ A Few More Things

- **Right-to-left layouts**: gravity-based positioning, margins, and slide animations (dialogs, toasts, snackbars) all mirror automatically under ambient RTL `Directionality` — set `..textDirection = TextDirection.rtl` explicitly only to override that. `ACDSlideAction`, `ACDSwitch`, `ACDRatingBar`, and `ACDAnimatedText` mirror their own drag direction/fill/stagger order under RTL too. `ACDPinField`'s digit-entry order stays left-to-right by default regardless of ambient direction (the conventional PIN/OTP UX) — pass `textDirection: TextDirection.rtl` explicitly to mirror it. `ACDLinearPercentIndicator`/`ACDCircularPercentIndicator`'s fill direction is a manual `isRTL`/`direction` opt-in, independent of ambient `Directionality` by design (it's a data-visualization choice, not a text-flow one).
- **Safe area**: top/bottom dialogs automatically avoid notches and system bars; set `..respectSafeArea = true` to force it for any position.
- **Tapping outside the dialog**: `..barrierDismissible = false` stops taps outside from closing it, and `..onBarrierTap = () {}` lets you run your own logic when the user taps outside.
- **App theme**: `..useTheme = true` picks up your app's `ThemeData.dialogTheme` background instead of a fixed color.
- **Callbacks**: `..showCallBack` and `..dismissCallBack` fire when a dialog appears/disappears.

---

## 🤝 Contributing

Feel free to open issues or submit pull requests to help improve this package!

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
