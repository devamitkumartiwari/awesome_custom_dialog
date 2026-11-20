import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../app_settings.dart';
import '../theme/app_theme.dart';

String _designLabel(ACDDesign d) => switch (d) {
  ACDDesign.material => 'Material',
  ACDDesign.cupertino => 'Cupertino',
  ACDDesign.adaptive => 'Adaptive',
};

/// App bar action shown on every screen: a small pill with the current
/// design ("Material", "Cupertino", "Adaptive → iOS"…). Tap it to open
/// [showDesignSettings].
class DesignSwitcherButton extends StatelessWidget {
  const DesignSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        final ACDDesign design = designNotifier.value;
        final bool cupertino = ACDDesign.resolve(context).isCupertino;
        final String label = design == ACDDesign.adaptive
            ? 'Auto · ${cupertino ? 'iOS' : 'M3'}'
            : _designLabel(design);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Tooltip(
            message: 'Change design (Material / Cupertino / Adaptive)',
            child: ActionChip(
              avatar: Icon(
                cupertino ? Icons.phone_iphone : Icons.android,
                size: 18,
                color: scheme.primary,
              ),
              label: Text(label),
              onPressed: () => showDesignSettings(context),
            ),
          ),
        );
      },
    );
  }
}

/// Opens a bottom sheet with every showcase setting: design, platform
/// preview, theme mode and reduce motion. Changes apply live.
Future<void> showDesignSettings(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => const SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: DesignSettingsPanel(),
      ),
    ),
  );
}

/// The settings controls themselves; used in the sheet and inline on the
/// home screen.
class DesignSettingsPanel extends StatelessWidget {
  const DesignSettingsPanel({super.key, this.compact = false});

  /// Shows only the design picker and the "now rendering" line.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final ACDDesign design = designNotifier.value;
        final bool cupertino = ACDDesign.resolve(context).isCupertino;
        final String platformName = switch (theme.platform) {
          TargetPlatform.iOS => 'iOS',
          TargetPlatform.macOS => 'macOS',
          TargetPlatform.android => 'Android',
          TargetPlatform.fuchsia => 'Fuchsia',
          TargetPlatform.linux => 'Linux',
          TargetPlatform.windows => 'Windows',
        };

        Widget label(String text) => Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!compact)
              Text('Showcase settings', style: theme.textTheme.titleLarge),
            label('DESIGN'),
            SegmentedButton<ACDDesign>(
              key: const ValueKey('design-picker'),
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: ACDDesign.material,
                  icon: Icon(Icons.android),
                  label: Text('Material'),
                ),
                ButtonSegment(
                  value: ACDDesign.cupertino,
                  icon: Icon(Icons.phone_iphone),
                  label: Text('Cupertino'),
                ),
                ButtonSegment(
                  value: ACDDesign.adaptive,
                  icon: Icon(Icons.devices),
                  label: Text('Adaptive'),
                ),
              ],
              selected: {design},
              onSelectionChanged: (s) => designNotifier.value = s.first,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              switch (design) {
                ACDDesign.adaptive =>
                  'Adaptive on $platformName → rendering '
                      '${cupertino ? 'Cupertino' : 'Material'}.',
                _ =>
                  'Every widget renders as ${_designLabel(design)}. '
                      'A widget\'s own design: parameter still wins.',
              },
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (!compact) ...[
              label('PLATFORM PREVIEW'),
              SegmentedButton<TargetPlatform?>(
                key: const ValueKey('platform-picker'),
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: null, label: Text('Device')),
                  ButtonSegment(
                    value: TargetPlatform.android,
                    label: Text('Android'),
                  ),
                  ButtonSegment(value: TargetPlatform.iOS, label: Text('iOS')),
                ],
                selected: {platformNotifier.value},
                onSelectionChanged: (s) => platformNotifier.value = s.first,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Adaptive follows the platform. Pick iOS here to see the '
                'adaptive iOS variants (action sheets, pickers, 44 pt '
                'targets) on any device. This also switches Flutter\'s own '
                'platform behaviour, such as page transitions and scrolling.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              label('APPEARANCE'),
              SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto_outlined),
                    label: Text('System'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_outlined),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_outlined),
                    label: Text('Dark'),
                  ),
                ],
                selected: {themeModeNotifier.value},
                onSelectionChanged: (s) => themeModeNotifier.value = s.first,
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reduce motion'),
                subtitle: const Text(
                  'Entrances jump to their end state; loops stop',
                ),
                value: reduceMotionNotifier.value,
                onChanged: (v) => reduceMotionNotifier.value = v,
              ),
            ],
          ],
        );
      },
    );
  }
}
