import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

/// `ACDStepperListView` — a scrollable, order-tracking-style timeline list.
class StepperTimelineScreen extends StatelessWidget {
  const StepperTimelineScreen({super.key});

  static const _timelineItems = [
    ACDStepperItemData(id: 1, data: ('Order placed', 'Aug 24, 10:02 AM')),
    ACDStepperItemData(id: 2, data: ('Shipped', 'Aug 25, 4:41 PM')),
    ACDStepperItemData(id: 3, data: ('Out for delivery', 'Aug 27, 8:15 AM')),
    ACDStepperItemData(id: 4, data: ('Delivered', 'Pending')),
  ];

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Timeline list',
      color: Colors.indigo,
      children: [
        sectionHeader('Order tracking'),
        SizedBox(
          height: 320,
          child: ACDStepperListView<(String, String)>(
            items: _timelineItems,
            theme: const ACDStepperThemeData(dashed: true),
            contentBuilder: (context, item, index) => Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                title: Text(item.data.$1),
                subtitle: Text(item.data.$2),
              ),
            ),
          ),
        ),
        const CodeSnippet(
          code: '''
ACDStepperListView<(String, String)>(
  items: const [
    ACDStepperItemData(id: 1, data: ('Order placed', 'Aug 24, 10:02 AM')),
    ACDStepperItemData(id: 2, data: ('Shipped', 'Aug 25, 4:41 PM')),
  ],
  theme: const ACDStepperThemeData(dashed: true),
  contentBuilder: (context, item, index) => Card(
    child: ListTile(title: Text(item.data.\$1), subtitle: Text(item.data.\$2)),
  ),
)''',
        ),
      ],
    );
  }
}
