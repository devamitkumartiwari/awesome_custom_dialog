library awesome_custom_dialog_example;

import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Awesome Custom Dialog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.teal.withValues(alpha: 0.05),
        ),
      ),
      home: const AppHome(),
    );
  }
}

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    ACDDialog.init(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text(
              'Awesome Custom Dialog\nShowcase',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor:
                colorScheme.primaryContainer.withValues(alpha: 0.3),
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showAbout(context),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionHeader('Presets & Feedback'),
                _buildGrid([
                  _actionCard(
                    'Success',
                    Icons.check_circle_outline,
                    Colors.green,
                    () => _showSuccess(context),
                  ),
                  _actionCard(
                    'Error',
                    Icons.error_outline,
                    Colors.red,
                    () => _showError(context),
                  ),
                  _actionCard(
                    'Warning',
                    Icons.warning_amber_rounded,
                    Colors.orange,
                    () => _showWarning(context),
                  ),
                  _actionCard(
                    'Info',
                    Icons.info_outline,
                    Colors.blue,
                    () => _showInfo(context),
                  ),
                ]),
                const SizedBox(height: 24),
                _sectionHeader('Buttons & Actions'),
                _buildList([
                  _listItem(
                    'Confirmation Style',
                    'Single teal button center aligned',
                    Icons.smart_button,
                    () => _showOneButton(context),
                  ),
                  _listItem(
                    'Decision Style',
                    'Two buttons with vertical divider',
                    Icons.call_split,
                    () => _showTwoButton(context),
                  ),
                  _listItem(
                    'Multi Action',
                    'Three buttons layout',
                    Icons.more_horiz,
                    () => _showThreeButton(context),
                  ),
                ]),
                const SizedBox(height: 24),
                _sectionHeader('Inputs & Menus'),
                _buildList([
                  _listItem(
                    'Form Input',
                    'Text field with submit/cancel',
                    Icons.edit_note,
                    () => _showTextField(context),
                  ),
                  _listItem(
                    'Action Sheet',
                    'List of icons and labels',
                    Icons.menu_open,
                    () => _showListTile(context),
                  ),
                  _listItem(
                    'Single Choice',
                    'Radio button selection list',
                    Icons.radio_button_checked,
                    () => _showRadio(context),
                  ),
                  _listItem(
                    'Multi Choice',
                    'Checkbox multi-selection list',
                    Icons.check_box,
                    () => _showCheckbox(context),
                  ),
                  _listItem(
                    'Progress',
                    'Loading state with auto-dismiss',
                    Icons.sync,
                    () => _showProgress(context),
                  ),
                ]),
                const SizedBox(height: 24),
                _sectionHeader('Animations'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _animChip('Scale',
                          () => _showAnimation(context, ACDAnimation.scale)),
                      _animChip('Fade',
                          () => _showAnimation(context, ACDAnimation.fade)),
                      _animChip('Bounce',
                          () => _showAnimation(context, ACDAnimation.bounce)),
                      _animChip('Slide Up',
                          () => _showAnimation(context, ACDAnimation.slideUp)),
                      _animChip('Rotate',
                          () => _showAnimation(context, ACDAnimation.rotate)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _sectionHeader('Positioning & Misc'),
                _buildList([
                  _listItem(
                    'Bottom Drawer',
                    'Slides up from bottom edge',
                    Icons.keyboard_arrow_up,
                    () => _showBottom(context),
                  ),
                  _listItem(
                    'Top Banner',
                    'Notification style from top',
                    Icons.keyboard_arrow_down,
                    () => _showTop(context),
                  ),
                  _listItem(
                    'Side Panel',
                    'Slides in from the left',
                    Icons.view_sidebar_outlined,
                    () => _showLeft(context),
                  ),
                  _listItem(
                    'Toast',
                    'Minimal auto-dismissing toast',
                    Icons.notifications_active_outlined,
                    () => _showToast(context),
                  ),
                  _listItem(
                    'Queued Dialogs',
                    'Chain 3 dialogs in sequence',
                    Icons.layers_outlined,
                    () => _showQueue(context),
                  ),
                ]),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── UI Components ───────────────────────────────────────────────────────

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.black38,
            letterSpacing: 1.2,
          ),
        ),
      );

  Widget _buildGrid(List<Widget> children) => GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: children,
      );

  Widget _buildList(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(children: children),
      );

  Widget _actionCard(
          String label, IconData icon, Color color, VoidCallback onTap) =>
      Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        ),
      );

  Widget _listItem(
          String title, String subtitle, IconData icon, VoidCallback onTap) =>
      ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.teal, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black45)),
        trailing:
            const Icon(Icons.chevron_right, size: 18, color: Colors.black26),
      );

  Widget _animChip(String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ActionChip(
          label: Text(label),
          onPressed: onTap,
          backgroundColor: Colors.teal.withValues(alpha: 0.05),
          side: BorderSide(color: Colors.teal.withValues(alpha: 0.1)),
        ),
      );

  // ── Presets ─────────────────────────────────────────────────────────────

  void _showSuccess(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 24
      ..animation = ACDAnimation.bounce
      ..success(
        title: 'Payment Sent!',
        message: 'Your transfer of \$42.00 was successful.',
        onTap: () => debugPrint('success tapped'),
      )
      ..show();
  }

  void _showError(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 24
      ..animation = ACDAnimation.scale
      ..error(
        title: 'Upload Failed',
        message: 'Could not connect to the server. Please try again.',
      )
      ..show();
  }

  void _showWarning(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 24
      ..warning(
        title: 'Delete Project?',
        message: 'This action cannot be undone. Are you sure?',
        buttonText: 'Yes, Delete',
      )
      ..show();
  }

  void _showInfo(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 24
      ..info(
        title: 'New Update',
        message: 'Version 2.0 is ready with new features.',
        buttonText: 'Install Now',
      )
      ..show();
  }

  // ── Buttons ──────────────────────────────────────────────────────────────

  void _showOneButton(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
        text: 'Settings Saved',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
        textAlign: TextAlign.center,
      )
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        text: 'Your preferences have been updated across all devices.',
        color: Colors.black54,
        alignment: Alignment.center,
        textAlign: TextAlign.center,
      )
      ..acdDivider()
      ..oneButton(text: 'Done', color: Colors.teal, fontWeight: FontWeight.bold)
      ..show();
  }

  void _showTwoButton(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        text: 'Discard Changes?',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
      )
      ..acdDivider()
      ..twoButton(
        gravity: ACDGravity.spaceEvenly,
        withDivider: true,
        text1: 'Keep Editing',
        color1: Colors.blueGrey,
        text2: 'Discard',
        color2: Colors.red,
        fontWeight2: FontWeight.bold,
      )
      ..show();
  }

  void _showThreeButton(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        text: 'Save Progress?',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
      )
      ..acdDivider()
      ..threeButton(
        text1: 'Cancel',
        text2: 'No',
        color2: Colors.red,
        text3: 'Save',
        color3: Colors.teal,
        onTap3: () => debugPrint('saved'),
      )
      ..show();
  }

  // ── Inputs & Content ─────────────────────────────────────────────────────

  void _showTextField(BuildContext ctx) {
    final controller = TextEditingController();
    ACDDialog().build(ctx)
      ..borderRadius = 24
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
        text: 'What\'s your name?',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..acdTextField(
        controller: controller,
        hint: 'Enter your full name',
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      )
      ..twoButton(
        padding: const EdgeInsets.only(top: 10),
        gravity: ACDGravity.right,
        text1: 'Cancel',
        color1: Colors.grey,
        text2: 'Submit',
        color2: Colors.teal,
        fontWeight2: FontWeight.bold,
        onTap2: () => debugPrint('Name: ${controller.text}'),
      )
      ..show();
  }

  void _showListTile(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Choose Action',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..acdDivider()
      ..listOfACDListTile(
        height: 240,
        items: const [
          ACDListTileItem(
              leading: Icon(Icons.edit_outlined), text: 'Edit Item'),
          ACDListTileItem(
              leading: Icon(Icons.share_outlined), text: 'Share Project'),
          ACDListTileItem(
              leading: Icon(Icons.copy_all_outlined), text: 'Duplicate'),
          ACDListTileItem(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            text: 'Move to Trash',
            color: Colors.red,
          ),
        ],
        onClickItemListener: (i) => debugPrint('Tapped $i'),
      )
      ..show();
  }

  void _showRadio(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Display Language',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..listOfACDRadioButton(
        initialValue: 0,
        activeColor: Colors.teal,
        items: const [
          ACDRadioItem(text: 'English (US)'),
          ACDRadioItem(text: 'Español'),
          ACDRadioItem(text: 'Français'),
          ACDRadioItem(text: 'Deutsch'),
        ],
      )
      ..acdDivider()
      ..oneButton(
          text: 'Apply Changes',
          color: Colors.teal,
          fontWeight: FontWeight.bold)
      ..show();
  }

  void _showCheckbox(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 20
      ..text(
        padding: const EdgeInsets.all(24),
        text: 'Select Features',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      )
      ..listOfACDCheckbox(
        initialValues: const [0, 2],
        activeColor: Colors.teal,
        items: const [
          ACDCheckboxItem(text: 'Offline Access'),
          ACDCheckboxItem(text: 'Biometric Login'),
          ACDCheckboxItem(text: 'Dark Mode'),
          ACDCheckboxItem(text: 'Push Notifications'),
        ],
      )
      ..acdDivider()
      ..oneButton(text: 'Done', color: Colors.teal, fontWeight: FontWeight.bold)
      ..show();
  }

  void _showProgress(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 24
      ..barrierDismissible = false
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        text: 'Syncing Data...',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
      )
      ..acdProgress(
        padding: const EdgeInsets.only(bottom: 32),
        valueColor: Colors.teal,
      )
      ..autoDismissAfter = const Duration(seconds: 3)
      ..show();
  }

  // ── Positioning & Misc ──────────────────────────────────────────────────

  void _showBottom(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..gravity = ACDGravity.bottom
      ..gravityAnimationEnable = true
      ..borderRadius = 28
      ..margin = const EdgeInsets.only(bottom: 12)
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
        text: 'Quick Actions',
        fontSize: 20,
        fontWeight: FontWeight.bold,
      )
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        text: 'This menu slides from the bottom and sits above the edge.',
        color: Colors.black54,
      )
      ..oneButton(
          text: 'Got it', color: Colors.teal, fontWeight: FontWeight.bold)
      ..show();
  }

  void _showTop(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..gravity = ACDGravity.top
      ..gravityAnimationEnable = true
      ..borderRadius = 16
      ..backgroundColor = Colors.teal.shade800
      ..text(
        padding: const EdgeInsets.all(20),
        text: '✨ Success: Files Uploaded',
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        alignment: Alignment.center,
      )
      ..autoDismissAfter = const Duration(seconds: 2)
      ..show();
  }

  void _showLeft(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..gravity = ACDGravity.left
      ..gravityAnimationEnable = true
      ..width = 280
      ..borderRadius = 0
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
        text: 'Side Menu\n\nFull height side panel simulation.',
        fontSize: 16,
      )
      ..oneButton(text: 'Close Panel')
      ..show();
  }

  void _showToast(BuildContext ctx) {
    ACDDialog.toast(
      context: ctx,
      message: 'Copied to clipboard',
      backgroundColor: Colors.black87,
    ).show();
  }

  void _showQueue(BuildContext ctx) {
    for (int i = 1; i <= 3; i++) {
      final dialog = ACDDialog().build(ctx)
        ..borderRadius = 24
        ..animation = ACDAnimation.scale
        ..info(
          title: 'Step $i of 3',
          message: 'This is a sequence of non-overlapping dialogs.',
          buttonText: i == 3 ? 'Finish' : 'Next Step',
        );
      ACDDialogQueue.enqueue(dialog);
    }
  }

  void _showAbout(BuildContext ctx) {
    ACDDialog().build(ctx)
      ..borderRadius = 30
      ..animation = ACDAnimation.scale
      ..acdImage(
        assetPath: 'images/success.png',
        width: 80,
        height: 80,
        padding: const EdgeInsets.only(top: 32),
      )
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        text: 'Awesome Custom Dialog',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        alignment: Alignment.center,
      )
      ..text(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        text: 'v0.0.3 • MIT License',
        color: Colors.black38,
        alignment: Alignment.center,
      )
      ..acdDivider()
      ..oneButton(text: 'Close', color: Colors.teal)
      ..show();
  }

  void _showAnimation(BuildContext ctx, ACDAnimation anim) {
    ACDDialog().build(ctx)
      ..borderRadius = 24
      ..animation = anim
      ..success(title: '${anim.name.toUpperCase()} Animation')
      ..show();
  }
}
