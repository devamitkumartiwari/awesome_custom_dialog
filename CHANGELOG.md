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
