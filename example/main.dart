import 'package:flutter/material.dart';
import 'package:all_dropdown/all_dropdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'All Dropdown Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AllDropdownDemo(),
    );
  }
}

class AllDropdownDemo extends StatefulWidget {
  const AllDropdownDemo({super.key});

  @override
  State<AllDropdownDemo> createState() => _AllDropdownDemoState();
}

class _AllDropdownDemoState extends State<AllDropdownDemo> {
  String? selectedFruit;
  List<String> selectedFrameworks = [];
  String? selectedUser;

  final List<String> fruits = [
    'Apple',
    'Banana',
    'Orange',
    'Mango',
    'Pineapple',
    'Strawberry',
    'Watermelon',
    'Grapes',
  ];

  final List<String> frameworks = [
    'Flutter',
    'React',
    'Vue',
    'Angular',
    'Svelte',
    'Next.js',
    'Nuxt.js',
  ];

  final List<String> users = [
    'John Doe',
    'Jane Smith',
    'Bob Johnson',
    'Alice Williams',
    'Charlie Brown',
    'Diana Prince',
    'Eve Anderson',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Dropdown Examples'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Single Select Dropdown
            _buildSection(
              title: '🎯 Single Select Dropdown',
              description: 'Select one item from the list with optional search',
              child: AllDropdown<String>(
                items: fruits,
                value: selectedFruit,
                hintText: 'Select a fruit',
                enableSearch: true,
                searchHintText: 'Search fruits...',
                onChanged: (value) {
                  setState(() {
                    selectedFruit = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected: $value')),
                  );
                },
                decoration: const InputDecoration(
                  labelText: 'Favorite Fruit',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.apple),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Multi Select Dropdown
            _buildSection(
              title: '🧠 Multi Select Dropdown',
              description: 'Select multiple items with chips',
              child: AllMultiDropdown<String>(
                items: frameworks,
                values: selectedFrameworks,
                hintText: 'Select frameworks',
                enableSearch: true,
                searchHintText: 'Search frameworks...',
                onChanged: (selected) {
                  setState(() {
                    selectedFrameworks = selected;
                  });
                },
                chipColor: Colors.blue.shade100,
                chipTextColor: Colors.blue.shade900,
                showCheckboxes: true,
                decoration: const InputDecoration(
                  labelText: 'Frameworks',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Typeahead / Autocomplete
            _buildSection(
              title: '💬 Typeahead / Autocomplete',
              description: 'Search and select with async suggestions',
              child: AllTypeahead<String>(
                hintText: 'Search users...',
                suggestionsCallback: (pattern) async {
                  // Simulate API call
                  await Future.delayed(const Duration(milliseconds: 500));
                  return users
                      .where((user) =>
                          user.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                onSuggestionSelected: (value) {
                  setState(() {
                    selectedUser = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected: $value')),
                  );
                },
                decoration: const InputDecoration(
                  labelText: 'User Search',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                debounceDuration: const Duration(milliseconds: 300),
                minCharsForSuggestions: 2,
              ),
            ),

            const SizedBox(height: 24),

            // Custom Styled Dropdown
            _buildSection(
              title: '🎨 Custom Styled Dropdown',
              description: 'Fully customized appearance',
              child: AllDropdown<String>(
                items: fruits,
                hintText: 'Select a fruit',
                enableSearch: true,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected: $value')),
                  );
                },
                decoration: InputDecoration(
                  labelText: 'Custom Style',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.purple.shade50,
                  prefixIcon: const Icon(Icons.star, color: Colors.purple),
                ),
                dropdownDecoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                selectedItemColor: Colors.purple.shade100,
                itemTextColor: Colors.purple.shade900,
              ),
            ),

            const SizedBox(height: 24),

            // Results Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 Current Selections',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildResult('Selected Fruit', selectedFruit ?? 'None'),
                    _buildResult(
                      'Selected Frameworks',
                      selectedFrameworks.isEmpty
                          ? 'None'
                          : selectedFrameworks.join(', '),
                    ),
                    _buildResult('Selected User', selectedUser ?? 'None'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildResult(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

