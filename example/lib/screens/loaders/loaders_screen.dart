import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// A live demo of `ACDLinearPercentIndicator`, `ACDCircularPercentIndicator`,
/// and `ACDMultiSegmentLinearIndicator`.
class LoadersScreen extends StatefulWidget {
  const LoadersScreen({super.key});

  @override
  State<LoadersScreen> createState() => _LoadersScreenState();
}

class _LoadersScreenState extends State<LoadersScreen> {
  double _value = 0.35;

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Percent & Loading Indicators',
      color: Colors.blue,
      children: [
        sectionHeader('Linear — drag the slider'),
        ACDLinearPercentIndicator(
          value: _value,
          lineHeight: 12,
          progressColor: Colors.blue,
          barRadius: const Radius.circular(6),
          showPercentageText: true,
        ),
        Slider(value: _value, onChanged: (v) => setState(() => _value = v)),
        const CodeSnippet(
          code: '''
ACDLinearPercentIndicator(
  value: value,
  progressColor: Colors.blue,
  barRadius: const Radius.circular(6),
  showPercentageText: true, // font size auto-scales with lineHeight
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Auto-sized percentage text — big bar, big text'),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ACDLinearPercentIndicator(
                initialValue: 0.5,
                lineHeight: 8,
                showPercentageText: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ACDLinearPercentIndicator(
                initialValue: 0.5,
                lineHeight: 28,
                barRadius: Radius.circular(14),
                showPercentageText: true,
              ),
            ),
          ],
        ),
        const CodeSnippet(
          code: '''
// Small bar -> small text, big bar -> big text, no manual font sizing.
ACDLinearPercentIndicator(lineHeight: 8, showPercentageText: true)
ACDLinearPercentIndicator(lineHeight: 28, showPercentageText: true)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Circular — ring vs pie'),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ACDCircularPercentIndicator(
              radius: 48,
              initialValue: 0.7,
              progressColor: Colors.green,
              showPercentageText: true,
            ),
            ACDCircularPercentIndicator(
              radius: 48,
              initialValue: 0.55,
              fillMode: ACDLoaderFillMode.pie,
              progressColor: Colors.deepOrange,
            ),
            ACDCircularPercentIndicator(
              radius: 48,
              initialValue: 0.4,
              arcType: ACDLoaderArcType.half,
              progressColor: Colors.purple,
            ),
          ],
        ),
        const CodeSnippet(
          code: '''
ACDCircularPercentIndicator(
  radius: 48,
  initialValue: 0.7,
  fillMode: ACDLoaderFillMode.pie, // or .ring (default)
  arcType: ACDLoaderArcType.half,   // or .full / .fullReversed
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Multi-segment'),
        const ACDMultiSegmentLinearIndicator(
          lineHeight: 14,
          spacing: 6,
          segments: [
            ACDLoaderSegment(
              key: 'downloaded',
              percent: 0.6,
              color: Colors.blue,
            ),
            ACDLoaderSegment(
              key: 'verified',
              percent: 0.3,
              color: Colors.orange,
            ),
            ACDLoaderSegment(
              key: 'installed',
              percent: 0.1,
              color: Colors.green,
            ),
          ],
        ),
        const CodeSnippet(
          code: '''
ACDMultiSegmentLinearIndicator(
  segments: [
    ACDLoaderSegment(key: 'downloaded', percent: 0.6, color: Colors.blue),
    ACDLoaderSegment(key: 'verified', percent: 0.3, color: Colors.orange),
    ACDLoaderSegment(key: 'installed', percent: 0.1, color: Colors.green),
  ],
)''',
        ),
        const SizedBox(height: 24),
        sectionHeader('Border & shadow'),
        SizedBox(
          width: 200,
          child: ACDLinearPercentIndicator(
            initialValue: 0.6,
            lineHeight: 16,
            barRadius: const Radius.circular(8),
            progressColor: Colors.teal,
            progressBorderColor: Colors.teal.shade900,
            backgroundBorderColor: Colors.grey.shade400,
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
        const CodeSnippet(
          code: '''
ACDLinearPercentIndicator(
  initialValue: 0.6,
  progressColor: Colors.teal,
  progressBorderColor: Colors.teal.shade900,
  backgroundBorderColor: Colors.grey.shade400,
  boxShadow: [BoxShadow(color: Colors.teal.withValues(alpha: 0.3), blurRadius: 8)],
)''',
        ),
      ],
    );
  }
}
