# Advanced guide

Everything the [README](../README.md) leaves out: every option for every widget, and the full
API list. Start with the README if you are new to the package.

- [Dialog options](#dialog-options)
- [Searchable list](#searchable-list)
- [Toast](#toast)
- [Snackbar](#snackbar)
- [Dropdown](#dropdown)
- [Autocomplete](#autocomplete)
- [PIN / OTP](#pin--otp)
- [Slide to confirm](#slide-to-confirm)
- [Switch](#switch)
- [Rating bar](#rating-bar)
- [Stepper](#stepper)
- [Percent & loading indicators](#percent--loading-indicators)
- [Motion](#motion)
- [Staggered lists & grids](#staggered-lists--grids)
- [Dashed & dotted](#dashed--dotted)
- [Design, accessibility & motion](#design-accessibility--motion)
- [Customizing everything](#customizing-everything)
- [API overview](#api-overview)

---

## Dialog options

Set these with `..` on the built dialog:

| Option | What it does |
|---|---|
| `width` / `height` | Size of the dialog card. |
| `gravity` | Where it appears (`ACDGravity`: center, top, bottom, left, right, and the four corners). Mirrors under RTL. |
| `animation` | How it appears (`ACDAnimation`: fade, scale, bounce, rotate, slide...). |
| `autoDismissAfter` | Close automatically after a duration. |
| `barrierDismissible` | `false` stops taps outside from closing it. |
| `onBarrierTap` | Run your own code when the user taps outside. |
| `canPop` / `onPopInvoked` | `canPop = false` keeps the dialog open on back. Dialogs follow Android's predictive back gesture. |
| `respectSafeArea` | Force safe-area padding for any position. Top and bottom dialogs already avoid notches. |
| `useTheme` | Use your app's `ThemeData.dialogTheme` background. |
| `textDirection` | Override the ambient text direction. |
| `showCallBack` / `dismissCallBack` | Called when the dialog appears / disappears. |
| `backgroundColor` / `borderRadius` / `decoration` | Basic card styling. |
| `cornerRadius` | Round only some corners, e.g. a side panel flush against an edge. |
| `shape` | Any `ShapeBorder`: pill, notched, superellipse, beveled... |
| `elevation` / `shadowColor` / `boxShadow` | Shadow under the card. |
| `backgroundGradient` / `backgroundImage` | Gradient or image fill for the card. |
| `contentStagger` | Animate each piece of content in, one after another (`ACDStaggerOptions`). |

A side panel with only its right corners rounded:

```dart
ACDDialog().build(context)
  ..gravity = ACDGravity.left
  ..width = 280
  ..cornerRadius = const BorderRadius.only(
    topRight: Radius.circular(20),
    bottomRight: Radius.circular(20),
  )
  ..text(text: 'Side panel')
  ..show();
```

`listOfACDListTile()`, `listOfACDRadioButton()` and `listOfACDCheckbox()` each take a `stagger`
parameter for their rows.

## Searchable list

- Pass your own model type instead of `String`. `itemAsString` gives the label, and
  `itemBuilder` builds each row yourself.
- `multiSearchableList<T>()` is the multi-select version, with Confirm / Cancel buttons.
- `onFind` sends non-empty searches to your own async or server search instead of filtering
  `items` locally. Loading, empty and error states are shown for you.
- `searchIcon` replaces the magnifying-glass icon. `borderRadius` rounds the rows.

`searchableList()` only works inside an open dialog. For a field inside a form, use
[Dropdown](#dropdown).

## Toast

```dart
ACDDialog.toast(
  context: context,
  message: 'Copied to clipboard',
  length: ACDToastLength.long,                     // short or long
  closeButtonMode: ACDToastCloseButtonMode.always, // never / always / onHover
  dismissOnTap: true,
  fontFamily: 'Roboto',
)..show();
```

**Why did it close?** `toastClosed` tells you: timeout, user, swipe, programmatic or replaced.

```dart
final toast = ACDDialog.toast(
  context: context,
  message: 'Archived. Tap ✕ to undo',
  closeButtonMode: ACDToastCloseButtonMode.always,
)..show();
if (await toast.toastClosed == ACDToastDismissReason.user) undoArchive();
```

**Stacking.** `maxVisible` caps how many show at once. `overflowPolicy` decides what happens to
the rest: `queue` (default) holds them back, `dropOldest` removes the oldest, `unlimited`
ignores the cap. Pass `cancelPrevious: false` so a new toast doesn't replace the old one.

```dart
for (final msg in ['Step 1', 'Step 2', 'Step 3', 'Step 4']) {
  ACDDialog.toast(
    context: context,
    message: msg,
    cancelPrevious: false,
    maxVisible: 3,
    overflowPolicy: ACDToastOverflowPolicy.queue,
  ).show();
}
```

**Looks.** `style` picks a variant: `filled`, `flat`, `flatColored`, `minimal`, `simple`.
`contentType` uses the same success / failure / warning / help presets as the snackbar.

**Behavior.** `showProgressBar`, `pauseOnHover` (desktop and web), `dragToDismiss`,
`showDuration`, and `gravity` for the position (mirrors under RTL).

**Appearance.** `backgroundColor`, `backgroundGradient`, `border` / `borderColor` /
`borderWidth`, `boxShadow`, `borderRadius`, `cornerRadius` (per corner), and `shape`.
`margin` (gap to the screen edge), `contentPadding` (inner spacing) and `stackSpacing` (gap
between stacked toasts) are three separate settings. `customBuilder` replaces the card
completely.

**Own layer (optional).** Without it, toasts use the nearest `Overlay`.

```dart
MaterialApp(
  builder: (context, child) => ACDToastLayer(child: child!),
  home: const HomeScreen(),
)
```

**Managing toasts.** `ACDToastManager` has `dismissAll()`, `dismissById(id)`,
`dismissFirst()`, `dismissLast()`, `findById(id)`, `activeCount()`, `activeToasts()`, and
`setDefaults(ACDToastConfig(...))` for app-wide defaults.

## Snackbar

Inside Flutter's own `SnackBar`:

```dart
ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(
    SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: ACDSnackbarContent(
        title: 'Oh Snap!',
        message: 'This is an example error message.',
        contentType: ACDContentType.failure,
      ),
    ),
  );
```

`ACDContentType` has four looks: `success`, `failure`, `warning`, `help`.

Styling: `gradient`, `elevation` / `boxShadow`, `icon`, `titleFontSize` / `titleFontWeight` /
`titleFontFamily`, `messageFontSize` / `messageFontWeight` / `messageFontFamily`, or full
`titleTextStyle` / `messageTextStyle`.

## Dropdown

`ACDDropdownField<T>` is a real `FormField<T>`.

**How it opens** (`mode:`): `dialog` (default), `bottomSheet`, `menu` (under the field, flips
above when there's no room), `actionSheet`, `picker`, or `adaptive` (on iOS an action sheet for
short lists and a picker for long ones; on Material a dialog).

**Multi-select** with `ACDMultiDropdownField<T>`. The value is a `List<T>`, confirmed with OK.
Selections show as removable chips and collapse to "+N" after `maxVisibleChips` (default 3).
`displayMode: ACDMultiDisplay.text` shows comma-separated text instead. `chipBuilder` builds
your own chips.

**Clear button & closed look.** `showClearButton` adds a clear icon (`clearIcon` to change it).
`dropdownBuilder` replaces the text shown when closed:

```dart
ACDDropdownField<String>(
  items: countries,
  showClearButton: true,
  dropdownBuilder: (context, value) => value == null
      ? const Text('Choose a country')
      : Row(
          mainAxisSize: MainAxisSize.min,
          children: [const Icon(Icons.flag, size: 16), const SizedBox(width: 6), Text(value)],
        ),
  onChanged: (value) => print('Picked $value'),
)
```

**Styling.** The closed field takes a normal `InputDecoration`. The popup rows use
`itemTextColor` / `itemFontSize` / `itemFontWeight` / `itemFontFamily` / `itemStyle` (or
`itemBuilder`), `tileColor`, and the search box uses `searchFillColor` / `searchBorderColor` /
`searchBorderRadius`.

```dart
ACDDropdownField<String>(
  items: countries,
  decoration: InputDecoration(
    labelText: 'Country',
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
  onChanged: (value) => print('Picked $value'),
)
```

**Your own types.** `compareFn` compares items without overriding `==`, `isDisabledItem` greys
out rows, and `favoriteItems` pins items to the top:

```dart
ACDDropdownField<User>(
  items: users,
  itemAsString: (u) => u.name,
  compareFn: (a, b) => a.id == b.id,
  isDisabledItem: (u) => u.id == blockedId,
  favoriteItems: [currentUser],
  onChanged: (user) => print('Assigned to ${user?.name}'),
)
```

**Server search, page by page.** `onFindPaged(query, page)` loads the next page when the user
scrolls to the end. Return fewer items than a full page (or `[]`) when there are no more.

```dart
ACDDropdownField<String>(
  items: const [],
  onFindPaged: (query, page) => api.search(query, page: page, pageSize: 20),
  decoration: const InputDecoration(labelText: 'Search a large list'),
  onChanged: (value) => print('Picked $value'),
)
```

## Autocomplete

**`ACDAutocompleteField<T>`**

- `filterFn` for your own local matching, or `onFind` for async / server search (waits
  `searchDebounce` between keystrokes).
- `submitOnSuggestionTap` / `clearOnSubmit` control what happens after a pick.
- `itemBuilder` builds each suggestion row.
- Popup styling: `popupElevation`, `popupBorderRadius`, `popupColor`, and the same `item...`
  text settings as the dropdown.

**`ACDTriggerAutocompleteField`**

- Each `ACDAutocompleteTrigger` has its own `optionsBuilder(query)`, so `@` and `#` can search
  different data.
- `triggerOnlyAtStart` / `triggerOnlyAfterSpace` control when a trigger starts, and
  `minCharsForSuggestions` how many characters must follow it.
- Multi-character triggers such as `::` work. When triggers overlap, the longest wins.
- `popupAnchor: ACDPopupAnchor.caret` makes the popup follow the cursor. Pair it with a
  `popupWidthFactor` below `1.0`.
- Keyboard: arrow keys move, Enter picks, Esc closes.

```dart
ACDTriggerAutocompleteField(
  decoration: const InputDecoration(labelText: 'Message'),
  maxLines: 3,
  triggers: [
    ACDAutocompleteTrigger(trigger: '@', optionsBuilder: findUsers),
    ACDAutocompleteTrigger(trigger: '#', optionsBuilder: findHashtags),
  ],
  onOptionSelected: (trigger, option) => print('$option via ${trigger.trigger}'),
)
```

## PIN / OTP

`ACDPinField` is built on one real, invisible `TextField`, so cursor, paste, keyboard and
autofill are Flutter's own. It is a `FormField<String>`: `validator`, `onSaved` and
`autovalidateMode` all work.

- **Per-state looks:** `pinTheme`, `focusedPinTheme`, `submittedPinTheme`, `errorPinTheme`,
  `disabledPinTheme`. Each `ACDPinTheme` has `color`, `gradient`, `borderColor`, `borderWidth`,
  `borderRadius`, `shape` (rectangle or circle), `boxShadow`, `margin`, `padding`, and a full
  `decoration` for anything else. Focused and error states already look different without any
  theme.
- **Entry animation:** `pinAnimationType` (`scale`, `fade`, `slide`, `rotation`).
- **Hidden digits:** `obscureText`, `obscureRevealDuration` (shows each digit briefly), and
  `obscuringWidgetBuilder`.
- **Errors:** cells shake on error (`errorAnimation: ACDPinErrorAnimation.none` turns it off).
  `clearOnError: true` clears the digits so the user can retype.
- **OTP autofill** works through `AutofillHints.oneTimeCode`, with no extra plugin.
- `padding` / `margin` around the whole field.
- Digits are entered left to right even in RTL apps (the usual PIN layout). Pass
  `textDirection: TextDirection.rtl` to mirror it.

## Slide to confirm

- **Ready-made look:** `ACDSlideAction.swipeButton(label: ..., onConfirm: ...)`.
- **Shape:** `ACDSlideActionShape.rectangle` / `.circle`.
- **Direction:** `ACDSlideActionDirection.startToEnd` / `.endToStart` / `.dual`. Mirrors under
  RTL.
- **Colors:** `activeThumbColor` / `inactiveThumbColor`, `activeTrackColor` /
  `inactiveTrackColor`, and matching `...Gradient` versions.
- **More:** `elevationThumb` / `elevationTrack`, `trackPadding`, `thumbBorderRadius`,
  `showWaveTrail`, haptics.
- **Build it yourself:** `foregroundBuilder`, `backgroundBuilder`, `outerBackgroundBuilder`.
- The thumb follows your finger and settles with a spring. A quick flick confirms even before
  the halfway point.

## Switch

- **Three ways to use it:** controlled (`value` + `onChanged`), uncontrolled (`initialValue`),
  or with a `ValueNotifier<bool>` `controller`.
- **Presets:** `ACDSwitch.material()` and `ACDSwitch.ios()`.
- **Styling:** track, thumb and border each take active / inactive / disabled colors and
  gradients, plus `trackShapeBorder` / `thumbShapeBorder` for any shape. Images and custom
  track / thumb widgets work too.
- `dragEnabled` (default `true`) lets the user drag the thumb.

## Rating bar

- `interactionMode`: `tapAndDrag`, `tapOnly`, `dragOnly` or `none` (read-only).
- `filledIcon` / `emptyIcon` for other icons, e.g. hearts.
- `itemIconStyle: ACDRatingIconStyle.vectorStar` draws a real vector star, tuned with
  `starPoints` and `starPointRounding`.
- `allowHalfRating`, or `ratingPrecision` (e.g. `0.1`) for exact fractions.
- `itemBuilder`, glow, and a pop animation.
- Arrow keys change the rating.

## Stepper

**`ACDStepper`**

- `direction: Axis.vertical` for a timeline.
- Minimal dots: `stepShape: ACDStepShape.circle`, a small `stepRadius`, `showTitle: false`.
- `finishedStepGradient` / `activeStepGradient` / `upcomingStepGradient`,
  `markerElevation` / `markerBoxShadow`, and `animationDuration` / `animationCurve` when
  `activeStep` changes.

**`ACDStepperListView<T>`** for a scrollable history:

```dart
ACDStepperListView<String>(
  items: const [
    ACDStepperItemData(id: 1, data: 'Order placed'),
    ACDStepperItemData(id: 2, data: 'Shipped'),
    ACDStepperItemData(id: 3, data: 'Delivered'),
  ],
  contentBuilder: (context, item, index) => Text(item.data),
)
```

`avatarBuilder` / `labelBuilder` change each row's marker and label.
`theme: ACDStepperThemeData(dashed: true)` makes the connector line dashed. Also
`avatarGradient`, `avatarElevation`, `animationDuration`, `animationCurve`.

## Percent & loading indicators

- **Three ways to use them:** controlled (`value`), uncontrolled (`initialValue`), or a
  `ValueNotifier<double>` `controller` (handy for a download stream).
- Value changes animate from the current value, never from 0.
- `ACDLinearPercentIndicator` fills its parent's width. Pass `width` for a fixed size.
- `ACDCircularPercentIndicator`: `fillMode` (`ring` or `pie`), `arcType` (`full`, `half`,
  `fullReversed`) for gauges, or raw `startAngle` / `sweepAngle`.
- `indeterminate: true` when the duration is unknown (an iOS activity indicator under the
  Cupertino design).
- `style: ACDLoaderStyle.wavy` for a moving wave track (stops under reduce motion).
- **Styling:** `progressColor`, `linearGradient` / `circularGradient`, `backgroundGradient`,
  `progressBorderColor` / `backgroundBorderColor` with `borderWidth`, `boxShadow`, `strokeCap`,
  `barRadius`, `direction: ACDLoaderDirection.reverse`, `padding`, `margin`.
- `center` replaces the percentage label with your own widget.

**Several parts in one bar:**

```dart
ACDMultiSegmentLinearIndicator(
  segments: [
    ACDLoaderSegment(key: 'download', percent: 0.6, color: Colors.blue),
    ACDLoaderSegment(key: 'verify', percent: 0.2, color: Colors.orange),
  ],
)
```

Segments are matched by `key`, so you can add, remove or reorder them at any time, even
mid-animation. Each segment can have its own `backgroundColor` / `borderColor`, and
`stripeColor` styles the moving stripes.

Fill direction is set with `isRTL` / `direction`, not by the app's text direction.

## Motion

- `ACDMotion` wraps any widget with entrance, exit, rest (`restEffect`, e.g. pulse) and tap
  effects. All use one `ACDMotionEffect` set: opacity, offset, scale, rotation, skew, blur.
- `ACDAnimatedText` animates text per character. It handles emoji and RTL, and `onComplete`
  always fires.
- Set `visible: false` to play `exitEffect` (the entrance reversed by default) instead of
  removing the widget.
- `ACDMotionSequence` / `ACDAnimatedTextSequence` chain steps, on a timer or on tap, with
  optional looping.

```dart
ACDMotion(
  effect: ACDMotionEffect.fadeSlideIn(),
  restEffect: const ACDRestEffectConfig(effect: ACDMotionRestEffect.pulse),
  onTap: () => print('tapped'),
  child: const FlutterLogo(),
)
```

## Staggered lists & grids

`ACDStaggeredList`, `ACDStaggeredGrid`, and `ACDStaggeredSliverList` /
`ACDStaggeredSliverGrid` for a `CustomScrollView`.

- `ACDStaggerOptions`: `interval`, `itemDuration`, `curve`, `effect`, `exitEffect`,
  `reverseOnExit`.
- `visible: false` plays a staggered exit (last in, first out by default).
- RTL-aware effects: `ACDMotionEffect.slideInFromStart(context)` / `slideInFromEnd(context)`.
- Also `reverse` and `scrollDirection`.
- All items share one clock. Items you scroll to later are already in place.

```dart
ACDStaggeredGrid(
  itemCount: items.length,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
  options: const ACDStaggerOptions(interval: Duration(milliseconds: 60)),
  itemBuilder: (context, index) => MyTile(items[index]),
)
```

## Dashed & dotted

```dart
ACDDashedLine(length: 200, color: Colors.grey, dashLength: 6, gapLength: 4);
ACDDashedLine(axis: Axis.vertical, length: 100, roundedCaps: true);

Container(
  decoration: const ACDDottedDecoration(shape: ACDDottedShape.box),
  child: const Padding(padding: EdgeInsets.all(12), child: Text('Hi')),
);
```

- `ACDDottedDecoration` shapes: `box`, `line` (one edge, set with `linePosition`), `oval`.
- `ACDDashedBorder` shapes: `rect`, `roundedRect`, `oval`, `circle`, `customPath` (with
  `customPathBuilder: (size) => Path()...`).
- All three take `gradient` and `roundedCaps`. Rounded caps are what make dashes look like
  dots.

## Design, accessibility & motion

**Designs.** `ACDDesign.material` (default), `cupertino` (iOS text fields, alert actions,
inset-grouped lists with checkmarks, activity indicators, iOS colors, blur, no ripples), or
`adaptive` (Cupertino on iOS and macOS, or inside a bare `CupertinoApp`; Material elsewhere).
Set it per widget with `design:` or for the app with `ACDDesignScope`. A widget's own setting
wins.

**Accessibility.**

- Screen readers: switch state, rating value with increase / decrease, loader percentages,
  "Step 2 of 5, completed", and one labelled PIN field.
- Keyboard: Tab, Space, Enter, arrow keys in autocomplete and the rating bar, Esc closes popups.
- Reduce motion: entrances jump to the end, looping effects stop.
- Touch targets: at least 48 dp (Material) / 44 pt (iOS).
- Translations: `ACDDesignScope(strings: ACDStrings(ok: ..., cancel: ...))`.

**Right-to-left.** Dialog, toast and snackbar positions, margins and slides mirror
automatically. Set `..textDirection` only to override. `ACDSlideAction`, `ACDSwitch`,
`ACDRatingBar` and `ACDAnimatedText` mirror too. The PIN field and progress indicators do not
(see their sections).

## Customizing everything

Everything has a default. Change only what you need.

- **Color:** `color`, `backgroundColor`, `iconColor`, `titleColor`, `messageColor` and more.
- **Font:** `fontFamily`, `fontSize`, `fontWeight`, or a full `TextStyle` (`style`,
  `titleStyle`, `messageStyle`, `textStyle1` / `2` / `3`...).
- **Buttons:** `oneButton` / `twoButton` / `threeButton` take `backgroundColor`,
  `borderRadius`, `elevation` / `boxShadow`, `icon` and `gradient` for each button.
- **Lists:** `borderRadius` for rows. `ACDRadioItem` / `ACDCheckboxItem` take `leading` /
  `trailing` widgets.
- **`acdTextField`:** `prefixIcon` / `suffixIcon`, fill, border and label styling.
- **Gradients & shadows:** any widget with a background color also takes a `Gradient`, and
  every widget has `elevation` / `boxShadow`.
- **Corners:** `borderRadius` almost everywhere, `cornerRadius` for some corners only, `shape`
  for anything else.
- **Padding & margin:** almost everywhere content is added.
- **Icons:** replace the icon on any preset (`success()`, `error()`, `warning()`, `info()`),
  snackbar (`icon:`), button (`icon` / `icon1` / `icon2` / `icon3`), or search (`searchIcon`).

Widget-specific options are in each section above.

## API overview

| API | What it does |
|---|---|
| `.success()` / `.error()` / `.warning()` / `.info()` | Ready-made status dialogs. |
| `.text()` | Styled text. |
| `.oneButton()` / `.twoButton()` / `.threeButton()` | Action buttons. |
| `.actions()` + `.showForResult<T>()` | Role-based buttons that return a value. |
| `.acdTextField()` | Input field, with optional validation. |
| `.acdProgress()` | Loading spinner. |
| `.acdImage()` | Asset or network image. |
| `.acdDivider()` | Divider line. |
| `.listOfACDListTile()` / `.listOfACDRadioButton()` / `.listOfACDCheckbox()` | List content. |
| `.searchableList<T>()` / `.multiSearchableList<T>()` | Filterable single / multi-select list. |
| `ACDDialog.toast()` / `ACDDialog.cancelToast()` | Show / close a toast. |
| `ACDToastLayer` | Optional own layer for toasts. |
| `ACDToastManager` | Manage all toasts and set defaults. |
| `ACDDialog.snackbar()` / `ACDSnackbarContent` | Snackbar message. |
| `ACDDialogQueue.enqueue()` | Show dialogs or toasts one after another. |
| `ACDDropdownField<T>` / `ACDMultiDropdownField<T>` | Searchable dropdown form field. |
| `ACDAutocompleteField<T>` | Typeahead text field. |
| `ACDTriggerAutocompleteField` / `ACDAutocompleteTrigger` | `@mention` / `#hashtag` field. |
| `ACDPinField` | PIN / OTP field. |
| `ACDSlideAction` / `.swipeButton()` / `ACDSlideActionController` | Slide to confirm. |
| `ACDSwitch` / `.material()` / `.ios()` | Switch. |
| `ACDRatingBar` | Rating bar. |
| `ACDStepper` / `ACDStepperListView<T>` | Step progress and timeline list. |
| `ACDLinearPercentIndicator` / `ACDCircularPercentIndicator` | Progress bar and circle. |
| `ACDMultiSegmentLinearIndicator` / `ACDLoaderSegment` | Several progress parts in one bar. |
| `ACDMotion` / `ACDMotionSequence` | Animate any widget. |
| `ACDAnimatedText` / `ACDAnimatedTextSequence` | Letter-by-letter text. |
| `ACDStaggeredList` / `ACDStaggeredGrid` (+ sliver versions) | Staggered lists and grids. |
| `ACDStaggerOptions` | Shared stagger timing and effects. |
| `ACDDashedLine` / `ACDDottedDecoration` / `ACDDashedBorder` | Dashed and dotted decorations. |
| `ACDDesign` / `ACDDesignScope` / `ACDStrings` | Design choice and translations. |
