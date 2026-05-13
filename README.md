# awesome_custom_dialog

Awesome flutter dialog makes it easy to add highly customizable dialogs with a fluent builder API. Supports 10 gravity positions, built-in animations, presets, and more.

[![pub package](https://img.shields.io/pub/v/awesome_custom_dialog.svg)](https://pub.dev/packages/awesome_custom_dialog)
[![license](https://img.shields.io/github/license/devamitkumartiwari/awesome_custom_dialog.svg)](https://github.com/devamitkumartiwari/awesome_custom_dialog/blob/master/LICENSE)

---

## 🚀 Key Features

- **Fluent API**: Chainable methods for building dialogs easily.
- **10 Gravity Positions**: Position your dialog anywhere (Center, Top, Bottom, Corners, etc.).
- **Built-in Presets**: Quick Success, Error, Warning, and Info dialogs.
- **Rich Animations**: Scale, Fade, Rotate, Bounce, and Slide transitions.
- **Custom Content**: Add text, buttons (single/double/triple), radio lists, checkboxes, progress indicators, images, and text fields.
- **Toast Support**: Simple auto-dismissing toast factory.
- **Modern Standards**: Supports Kotlin 2.1.0, AGP 8.7.2, and iOS 16+.

---

## 🎖 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  awesome_custom_dialog: ^0.0.3
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

### 4. Custom Animation and Gravity
```dart
ACDDialog().build(context)
  ..gravity = ACDGravity.bottom
  ..animation = ACDAnimation.slideUp
  ..borderRadius = 20
  ..text(text: "I slid up from the bottom!")
  ..show();
```

---

## 🛠 API Overview

| Method | Description |
|---|---|
| `.success()` / `.error()` | Predefined status presets. |
| `.text()` | Add styled text. |
| `.oneButton()` / `.twoButton()` | Add action buttons. |
| `.acdTextField()` | Input field inside dialog. |
| `.acdProgress()` | Circular progress indicator. |
| `.acdImage()` | Asset or Network image helper. |
| `.autoDismissAfter` | Automatically close after a duration. |
| `.gravity` | Set position (Left, Top, Right, Bottom, etc.). |
| `.animation` | Select transition (Fade, Scale, Bounce, etc.). |

---

## 🤝 Contributing

Feel free to open issues or submit pull requests to help improve this package!

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
