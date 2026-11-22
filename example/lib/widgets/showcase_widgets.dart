import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'design_switcher.dart';

/// Small caption-style header used above a group of demos on a category
/// screen. Pass [description] for a longer explanatory line underneath.
Widget sectionHeader(String label, {String? description}) => Padding(
  padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.xs),
  child: Builder(
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      );
    },
  ),
);

/// 2-column grid of [actionCard]s.
Widget buildGrid(List<Widget> children) => GridView.count(
  physics: const NeverScrollableScrollPhysics(),
  shrinkWrap: true,
  crossAxisCount: 2,
  mainAxisSpacing: AppSpacing.md,
  crossAxisSpacing: AppSpacing.md,
  childAspectRatio: 1.5,
  children: children,
);

/// Rounded card containing a column of [listItem]s.
Widget buildList(List<Widget> children) => Builder(
  builder: (context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  },
);

/// Square icon + label card, used in grid layouts.
Widget actionCard(
  String label,
  IconData icon,
  Color color,
  VoidCallback onTap,
) => Card(
  margin: EdgeInsets.zero,
  child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _IconChip(icon: icon, color: color, size: 44),
          const SizedBox(height: AppSpacing.sm),
          Builder(
            builder: (context) => Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  ),
);

/// Icon + title/subtitle row, used inside [buildList].
Widget listItem(
  String title,
  String subtitle,
  IconData icon,
  VoidCallback onTap,
) => Builder(
  builder: (context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: _IconChip(icon: icon, color: scheme.primary, size: 40),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: scheme.onSurfaceVariant),
      ),
      trailing: Icon(Icons.chevron_right, color: scheme.outline),
    );
  },
);

/// Horizontal-scroll chip used for animation demos.
Widget animChip(String label, VoidCallback onTap) => Padding(
  padding: const EdgeInsets.only(right: AppSpacing.sm),
  child: Builder(
    builder: (context) => ActionChip(label: Text(label), onPressed: onTap),
  ),
);

/// A gradient-tinted rounded icon chip — the recurring accent-color motif
/// used across cards, hub screens, and category app bars.
class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.color, this.size = 48});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// A collapsible "View code" panel showing the Dart snippet behind a demo,
/// with a one-tap copy-to-clipboard button.
class CodeSnippet extends StatefulWidget {
  const CodeSnippet({
    super.key,
    required this.code,
    this.initiallyExpanded = false,
  });

  final String code;
  final bool initiallyExpanded;

  @override
  State<CodeSnippet> createState() => _CodeSnippetState();
}

class _CodeSnippetState extends State<CodeSnippet> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.code_rounded,
                    size: 16,
                    color: scheme.onInverseSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _expanded ? 'Hide code' : 'View code',
                    style: TextStyle(
                      color: scheme.onInverseSurface.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (_expanded)
                    InkWell(
                      onTap: () => _copy(context),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: scheme.onInverseSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: scheme.onInverseSurface.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  widget.code,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    height: 1.5,
                    color: scheme.onInverseSurface,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.code));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
  }
}

/// Shared scaffold every category/demo screen uses: an AppBar tinted with
/// the category's accent [color], and a scrollable, padded body.
class CategoryScaffold extends StatelessWidget {
  const CategoryScaffold({
    super.key,
    required this.title,
    required this.children,
    this.color,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  /// Accent color carried from the originating card, tinting the app bar for
  /// visual continuity from wherever this screen was opened.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color?.withValues(alpha: 0.08),
        actions: const [DesignSwitcherButton()],
        bottom: subtitle == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(36),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: children,
      ),
    );
  }
}
