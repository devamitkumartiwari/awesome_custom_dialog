import 'package:flutter/material.dart';

/// Small caption-style header used above a group of demos on a category screen.
Widget sectionHeader(String label) => Padding(
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

/// 2-column grid of [actionCard]s.
Widget buildGrid(List<Widget> children) => GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: children,
    );

/// Rounded card containing a column of [listItem]s.
Widget buildList(List<Widget> children) => Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );

/// Square icon + label card, used in grid layouts.
Widget actionCard(
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
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );

/// Icon + title/subtitle row, used inside [buildList].
Widget listItem(
        String title, String subtitle, IconData icon, VoidCallback onTap) =>
    // Material(transparency) wrapper: buildList()'s Container has a
    // background color, and ListTile paints its ink/background on the
    // nearest Material ancestor — without this, the grey.shade50 container
    // hides the ListTile's splash/highlight effects.
    Material(
      type: MaterialType.transparency,
      child: ListTile(
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
      ),
    );

/// Horizontal-scroll chip used for animation demos.
Widget animChip(String label, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor: Colors.teal.withValues(alpha: 0.05),
        side: BorderSide(color: Colors.teal.withValues(alpha: 0.1)),
      ),
    );

/// Shared scaffold every category screen uses: an AppBar with the category
/// title, and a scrollable, padded body.
class CategoryScaffold extends StatelessWidget {
  const CategoryScaffold(
      {super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: children,
      ),
    );
  }
}
