# awesome_custom_dialog

A simple, flexible way to show dialogs, toasts, snackbars, autocomplete fields, slide-to-confirm actions, dashed/dotted decorations, and steppers in Flutter — all with one easy-to-chain API. No extra packages needed.

[![pub package](https://img.shields.io/pub/v/awesome_custom_dialog.svg)](https://pub.dev/packages/awesome_custom_dialog)
[![license](https://img.shields.io/github/license/devamitkumartiwari/awesome_custom_dialog.svg)](https://github.com/devamitkumartiwari/awesome_custom_dialog/blob/master/LICENSE)

---

## Contents

- [🚀 Key Features](#-key-features)
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
- [🍞 Toast](#-toast)
- [🍫 Snackbar](#-snackbar)
- [🎨 Customizing Everything](#-customizing-everything)
- [🛠 API Overview](#-api-overview)
- [⚙️ A Few More Things](#️-a-few-more-things)
- [🤝 Contributing](#-contributing)
- [📜 License](#-license)

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
- **Dashed & dotted decoration**: `ACDDashedLine`, `ACDDottedDecoration` (a drop-in `Decoration`), and `ACDDashedBorder` (wraps any widget, including custom-path outlines).
- **Stepper**: `ACDStepper` — a horizontal wizard or vertical timeline progress indicator — and `ACDStepperListView<T>` for a scrollable timeline list.
- **Toast messages**: A tiny, auto-dismissing message that never blocks the rest of your screen — with length, close button, and cancel support.
- **Snackbar messages**: Colorful success/failure/warning/help banners, usable on their own or through the dialog API.
- **Style everything**: Colors, gradients, fonts, padding, corner radius, elevation/shadow, and icons are all customizable, everywhere — with sensible defaults if you change nothing.
- **No extra dependencies**: Just Flutter itself.

---

## 🎖 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  awesome_custom_dialog: ^1.0.0
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

## 🍞 Toast

A small message that appears briefly and disappears on its own — like a native Android toast, but on any platform. It never blocks taps on the rest of your app.

```dart
ACDDialog.toast(
  context: context,
  message: "Copied to clipboard",
  length: ACDToastLength.long,   // short or long
  showCloseButton: true,          // adds a small X to dismiss early
  dismissOnTap: true,             // tap the toast to dismiss it
  fontFamily: "Roboto",
)..show();

// Dismiss whichever toast is currently showing
ACDDialog.cancelToast();
```

Want to show several toasts one after another? Reuse the built-in queue:

```dart
for (final msg in ["Step 1", "Step 2", "Step 3"]) {
  ACDDialogQueue.enqueue(
    ACDDialog.toast(context: context, message: msg, cancelPrevious: false),
  );
}
```

You can position a toast anywhere using `gravity` — top, bottom, center, or any corner (see `ACDGravity` below).

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
- **Lists**: `listOfACDListTile`/`listOfACDRadioButton`/`listOfACDCheckbox`/`searchableList` all accept a `borderRadius` for rounded rows; `ACDRadioItem`/`ACDCheckboxItem` accept `leading`/`trailing` widgets (previously only the plain list variant could); the searchable list's magnifying-glass icon is overridable via `searchIcon`.
- **`acdTextField`**: accepts `prefixIcon`/`suffixIcon`, on top of the existing fill/border/label styling.
- **Dropdown fields**: `ACDDropdownField`/`ACDMultiDropdownField` take a standard `InputDecoration` for the closed-state field (label, hint, border, fill, icons — same as `TextFormField`), plus their own `itemTextColor`/`itemFontSize`/`itemFontWeight`/`itemFontFamily`/`itemStyle`, `tileColor`, and `searchFillColor`/`searchBorderColor`/`searchBorderRadius` for the popup — see the styling example in [Dropdown Field](#7-dropdown-field) above.
- **Autocomplete popups**: `ACDAutocompleteField`/`ACDTriggerAutocompleteField` accept `popupElevation`/`popupBorderRadius`/`popupColor` for the suggestion card, plus the same `itemTextColor`/`itemFontSize`/`itemFontWeight`/`itemFontFamily`/`itemStyle` row-styling shortcuts as the dropdown field.
- **Dashed/dotted/border**: `ACDDashedLine`, `ACDDottedDecoration`, and `ACDDashedBorder` all accept a `gradient` (overriding the flat `color`) and `roundedCaps` (turns square dash segments into rounded — what actually makes a dotted pattern read as *dots*).
- **Slide to confirm**: `ACDSlideAction` accepts `activeThumbColor`/`inactiveThumbColor` and `activeTrackColor`/`inactiveTrackColor` for distinct idle-vs-dragging looks, with matching `activeThumbGradient`/`inactiveThumbGradient`/`activeTrackGradient`/`inactiveTrackGradient` gradient variants, plus `elevationThumb`/`elevationTrack`, `trackPadding`, `thumbBorderRadius`, and a `showWaveTrail` animated trail.
- **Stepper**: `ACDStepper` accepts per-status `finishedStepGradient`/`activeStepGradient`/`upcomingStepGradient`, `markerElevation`/`markerBoxShadow`, and an implicit `animationDuration`/`animationCurve` transition whenever `activeStep` changes; `ACDStepperListView` has the matching `avatarGradient`/`avatarElevation`/`animationDuration`/`animationCurve`.
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
| `.autoDismissAfter` | Close automatically after a duration. |
| `.gravity` | Where the dialog appears (`ACDGravity`: left, top, bottom, right, center, corners...). |
| `.animation` | How it appears (`ACDAnimation`: fade, scale, bounce, rotate, slide...). |
| `ACDDialog.toast()` / `ACDDialog.cancelToast()` | Show/cancel a toast message. |
| `ACDDialog.snackbar()` / `ACDSnackbarContent` | Show a snackbar message. |
| `ACDDialogQueue.enqueue()` | Show dialogs (or toasts) one after another, without overlapping. |

---

## ⚙️ A Few More Things

- **Right-to-left layouts**: set `..textDirection = TextDirection.rtl` for RTL apps — `ACDSlideAction` also mirrors its own drag direction automatically under RTL.
- **Safe area**: top/bottom dialogs automatically avoid notches and system bars; set `..respectSafeArea = true` to force it for any position.
- **Tapping outside the dialog**: `..barrierDismissible = false` stops taps outside from closing it, and `..onBarrierTap = () {}` lets you run your own logic when the user taps outside.
- **App theme**: `..useTheme = true` picks up your app's `ThemeData.dialogTheme` background instead of a fixed color.
- **Callbacks**: `..showCallBack` and `..dismissCallBack` fire when a dialog appears/disappears.

---

## 🤝 Contributing

Feel free to open issues or submit pull requests to help improve this package!

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
