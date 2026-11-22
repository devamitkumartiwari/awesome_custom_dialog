import 'package:material_ui/material_ui.dart';

/// Text with every case-insensitive occurrence of [query] emphasised —
/// used by suggestion rows when match highlighting is enabled.
class ACDHighlightedText extends StatelessWidget {
  /// Creates highlighted text.
  const ACDHighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.highlightStyle = const TextStyle(fontWeight: FontWeight.w700),
  });

  /// The full text.
  final String text;

  /// The substring to emphasise. Empty → plain text.
  final String query;

  /// Base style.
  final TextStyle? style;

  /// Style merged over [style] for matched runs.
  final TextStyle highlightStyle;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text, style: style);
    final String lower = text.toLowerCase();
    final String q = query.toLowerCase();
    final List<TextSpan> spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final int hit = lower.indexOf(q, start);
      if (hit < 0) break;
      if (hit > start) spans.add(TextSpan(text: text.substring(start, hit)));
      spans.add(
        TextSpan(
          text: text.substring(hit, hit + q.length),
          style: highlightStyle,
        ),
      );
      start = hit + q.length;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return Text.rich(TextSpan(style: style, children: spans));
  }
}
