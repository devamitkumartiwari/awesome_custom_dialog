import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/showcase_widgets.dart';

const List<String> _countries = [
  'United States',
  'United Kingdom',
  'Canada',
  'Australia',
  'Germany',
  'France',
  'Japan',
  'Brazil',
  'India',
  'South Africa',
];

const List<String> _skills = [
  'Flutter',
  'Dart',
  'Kotlin',
  'Swift',
  'React',
  'TypeScript',
  'Go',
  'Rust',
];

/// Basics of `ACDDropdownField`/`ACDMultiDropdownField` — validator, popup
/// presentation modes, and multi-select.
class DropdownBasicsScreen extends StatefulWidget {
  const DropdownBasicsScreen({super.key});

  @override
  State<DropdownBasicsScreen> createState() => _DropdownBasicsScreenState();
}

class _DropdownBasicsScreenState extends State<DropdownBasicsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _requiredCountry;

  @override
  Widget build(BuildContext context) {
    return CategoryScaffold(
      title: 'Basics',
      color: Colors.cyan,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              sectionHeader('Dialog mode + validator'),
              ACDDropdownField<String>(
                items: _countries,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
                searchHint: 'Search countries',
                validator: (value) =>
                    value == null ? 'Please pick a country' : null,
                onChanged: (value) => setState(() => _requiredCountry = value),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _formKey.currentState?.validate(),
                  child: const Text('Validate'),
                ),
              ),
              if (_requiredCountry != null) Text('Picked: $_requiredCountry'),
              const SizedBox(height: 24),
              sectionHeader('Bottom sheet mode + clear button'),
              ACDDropdownField<String>(
                items: _skills,
                mode: ACDDropdownMode.bottomSheet,
                showClearButton: true,
                decoration: const InputDecoration(
                  labelText: 'Primary skill',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => debugPrint('Skill: $value'),
              ),
              const SizedBox(height: 24),
              sectionHeader('Menu mode (anchored under the field)'),
              ACDDropdownField<String>(
                items: _countries,
                mode: ACDDropdownMode.menu,
                decoration: const InputDecoration(
                  labelText: 'Country (menu)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => debugPrint('Menu picked: $value'),
              ),
              const SizedBox(height: 24),
              sectionHeader('Multi-select'),
              ACDMultiDropdownField<String>(
                items: _skills,
                decoration: const InputDecoration(
                  labelText: 'Skills',
                  border: OutlineInputBorder(),
                ),
                checkboxActiveColor: Colors.teal,
                confirmColor: Colors.teal,
                onChanged: (values) => debugPrint('Skills: $values'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
