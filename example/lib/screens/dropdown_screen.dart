import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/showcase_widgets.dart';

const List<String> _countries = [
  'Australia',
  'Brazil',
  'Canada',
  'France',
  'Germany',
  'India',
  'Japan',
  'United Kingdom',
  'United States',
];

const List<String> _skills = [
  'Dart',
  'Flutter',
  'Go',
  'Kotlin',
  'React',
  'Rust',
  'Swift',
  'TypeScript',
];

/// `ACDDropdownField` / `ACDMultiDropdownField` in a form: presentation
/// modes, validation, multi-select chips and the long-list helpers.
class DropdownScreen extends StatefulWidget {
  const DropdownScreen({super.key});

  @override
  State<DropdownScreen> createState() => _DropdownScreenState();
}

class _DropdownScreenState extends State<DropdownScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const InputDecoration _border = InputDecoration(
    border: OutlineInputBorder(),
  );

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Dropdown',
      color: Colors.cyan,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              sectionHeader('Dialog + validator'),
              ACDDropdownField<String>(
                items: _countries,
                decoration: _border.copyWith(labelText: 'Country'),
                validator: (v) => v == null ? 'Please pick a country' : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _formKey.currentState?.validate(),
                  child: const Text('Validate'),
                ),
              ),
              sectionHeader('Bottom sheet, menu, adaptive'),
              ACDDropdownField<String>(
                items: _skills,
                mode: ACDDropdownMode.bottomSheet,
                showClearButton: true,
                decoration: _border.copyWith(labelText: 'Bottom sheet'),
              ),
              const SizedBox(height: 12),
              ACDDropdownField<String>(
                items: _countries,
                mode: ACDDropdownMode.menu,
                decoration: _border.copyWith(labelText: 'Menu'),
              ),
              const SizedBox(height: 12),
              ACDDropdownField<String>(
                items: _skills,
                mode: ACDDropdownMode.adaptive,
                decoration: _border.copyWith(
                  labelText: 'Adaptive (iOS: sheet / wheel)',
                ),
              ),
              const SizedBox(height: 24),
              sectionHeader('Multi-select'),
              ACDMultiDropdownField<String>(
                items: _skills,
                showSelectAll: true,
                maxSelection: 4,
                decoration: _border.copyWith(labelText: 'Skills (max 4)'),
              ),
              const SizedBox(height: 12),
              ACDMultiDropdownField<String>(
                items: _countries,
                groupBy: (c) => c[0],
                decoration: _border.copyWith(labelText: 'Grouped A–Z'),
              ),
            ],
          ),
        ),
        const CodeSnippet(
          code: '''
ACDMultiDropdownField<String>(
  items: skills,
  showSelectAll: true,
  maxSelection: 4,
  decoration: const InputDecoration(labelText: 'Skills'),
  onChanged: (values) => print(values),
)''',
        ),
      ],
    );
  }
}
