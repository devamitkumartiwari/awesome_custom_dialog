# awesome_custom_dialog

A simple, flexible way to show dialogs, toasts, and snackbars in Flutter — all with one easy-to-chain API. No extra packages needed.

[![pub package](https://img.shields.io/pub/v/awesome_custom_dialog.svg)](https://pub.dev/packages/awesome_custom_dialog)
[![license](https://img.shields.io/github/license/devamitkumartiwari/awesome_custom_dialog.svg)](https://github.com/devamitkumartiwari/awesome_custom_dialog/blob/master/LICENSE)

---

## 🚀 Key Features

- **Chainable API**: Build a dialog step by step with `..` calls, then `.show()` it.
- **10 Positions**: Show your dialog centered, top, bottom, or in any corner.
- **Ready-made dialogs**: Success, Error, Warning, and Info — just fill in a title and message.
- **Smooth animations**: Fade, scale, bounce, rotate, and slide.
- **Everything you need inside**: text, buttons (one/two/three), radio lists, checkboxes, progress spinners, images, and text fields (with optional validation).
- **Searchable lists**: A filterable, generic `<T>` list for the dialog — single- or multi-select, local filtering or async `onFind` remote search with loading/empty/error states.
- **Dropdown fields**: `ACDDropdownField<T>` / `ACDMultiDropdownField<T>` — an inline, `Form`-compatible searchable dropdown (validator, clear button, disabled items, pinned favorites, paginated search) that opens as a dialog, bottom sheet, or anchored menu.
- **Toast messages**: A tiny, auto-dismissing message that never blocks the rest of your screen — with length, close button, and cancel support.
- **Snackbar messages**: Colorful success/failure/warning/help banners, usable on their own or through the dialog API.
- **Style everything**: Colors, fonts, padding, corner radius, and icons are all customizable, everywhere — with sensible defaults if you change nothing.
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

Every part of every dialog, toast, snackbar, and dropdown field can be styled — and everything has a sensible default if you don't touch it:

- **Color**: `color`, `backgroundColor`, `iconColor`, `titleColor`, `messageColor`, and more, depending on what you're building.
- **Font**: `fontFamily`, `fontSize`, `fontWeight` as quick shortcuts, or pass a full `TextStyle` (`style`, `titleStyle`, `messageStyle`, `textStyle1`/`2`/`3`...) for complete control — letter spacing, italics, underlines, anything `TextStyle` supports.
- **Dropdown fields**: `ACDDropdownField`/`ACDMultiDropdownField` take a standard `InputDecoration` for the closed-state field (label, hint, border, fill, icons — same as `TextFormField`), plus their own `itemTextColor`/`itemFontSize`/`itemFontWeight`/`itemFontFamily`/`itemStyle`, `tileColor`, and `searchFillColor`/`searchBorderColor`/`searchBorderRadius` for the popup — see the styling example in [Dropdown Field](#7-dropdown-field) above.
- **Corners**: `borderRadius` is available on dialogs, images, text fields, toasts, and snackbars. For a dialog that only wants *some* corners rounded (like a side panel sitting flush against an edge), pass a full `cornerRadius` instead:
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
- **Icons**: swap the icon on any preset (`success()`, `error()`, `warning()`, `info()`) or snackbar (`icon:`) for your own.

---

## 🛠 API Overview

| Method | Description |
|---|---|
| `.success()` / `.error()` / `.warning()` / `.info()` | Ready-made status dialogs. |
| `.text()` | Add styled text. |
| `.oneButton()` / `.twoButton()` / `.threeButton()` | Add action buttons. |
| `.acdTextField()` | Input field inside a dialog, with optional validation. |
| `.acdProgress()` | Loading spinner. |
| `.acdImage()` | Asset or network image. |
| `.acdDivider()` | A horizontal divider line. |
| `.listOfACDListTile()` / `.listOfACDRadioButton()` / `.listOfACDCheckbox()` | Scrollable list content. |
| `.searchableList<T>()` / `.multiSearchableList<T>()` | Filterable single/multi-select list, generic over your item type, with optional async `onFind` search. |
| `ACDDropdownField<T>` / `ACDMultiDropdownField<T>` | Inline, `Form`-compatible searchable dropdown — dialog/bottomSheet/menu popup, validator, clear button, paginated search. |
| `.autoDismissAfter` | Close automatically after a duration. |
| `.gravity` | Where the dialog appears (`ACDGravity`: left, top, bottom, right, center, corners...). |
| `.animation` | How it appears (`ACDAnimation`: fade, scale, bounce, rotate, slide...). |
| `ACDDialog.toast()` / `ACDDialog.cancelToast()` | Show/cancel a toast message. |
| `ACDDialog.snackbar()` / `ACDSnackbarContent` | Show a snackbar message. |
| `ACDDialogQueue.enqueue()` | Show dialogs (or toasts) one after another, without overlapping. |

---

## ⚙️ A Few More Things

- **Right-to-left layouts**: set `..textDirection = TextDirection.rtl` for RTL apps.
- **Safe area**: top/bottom dialogs automatically avoid notches and system bars; set `..respectSafeArea = true` to force it for any position.
- **Tapping outside the dialog**: `..barrierDismissible = false` stops taps outside from closing it, and `..onBarrierTap = () {}` lets you run your own logic when the user taps outside.
- **App theme**: `..useTheme = true` picks up your app's `ThemeData.dialogTheme` background instead of a fixed color.
- **Callbacks**: `..showCallBack` and `..dismissCallBack` fire when a dialog appears/disappears.

---

## 🤝 Contributing

Feel free to open issues or submit pull requests to help improve this package!

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
