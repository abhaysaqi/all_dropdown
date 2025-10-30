import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:all_dropdown/all_dropdown.dart';

void main() {
  group('AllDropdown', () {
    testWidgets('renders with items', (WidgetTester tester) async {
      final items = ['Apple', 'Banana', 'Orange'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllDropdown<String>(
              items: items,
              hintText: 'Select Fruit',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Select Fruit'), findsOneWidget);
    });

    testWidgets('shows dropdown on tap', (WidgetTester tester) async {
      final items = ['Apple', 'Banana', 'Orange'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllDropdown<String>(
              items: items,
              hintText: 'Select Fruit',
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Tap to open dropdown
      await tester.tap(find.text('Select Fruit'));
      await tester.pumpAndSettle();

      // Verify items are shown
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Orange'), findsOneWidget);
    });

    testWidgets('selects item on tap', (WidgetTester tester) async {
      final items = ['Apple', 'Banana', 'Orange'];
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllDropdown<String>(
              items: items,
              hintText: 'Select Fruit',
              onChanged: (value) {
                selectedValue = value;
              },
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.text('Select Fruit'));
      await tester.pumpAndSettle();

      // Tap on 'Banana'
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();

      expect(selectedValue, 'Banana');
    });
  });

  group('AllMultiDropdown', () {
    testWidgets('renders with items', (WidgetTester tester) async {
      final items = ['Flutter', 'React', 'Vue'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllMultiDropdown<String>(
              items: items,
              hintText: 'Select Frameworks',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Select Frameworks'), findsOneWidget);
    });

    testWidgets('allows multiple selections', (WidgetTester tester) async {
      final items = ['Flutter', 'React', 'Vue'];
      List<String> selectedValues = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AllMultiDropdown<String>(
                  items: items,
                  values: selectedValues,
                  hintText: 'Select Frameworks',
                  onChanged: (values) {
                    setState(() {
                      selectedValues = values;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.text('Select Frameworks'));
      await tester.pumpAndSettle();

      // Select Flutter
      await tester.tap(find.text('Flutter'));
      await tester.pumpAndSettle();

      // Select React
      await tester.tap(find.text('React'));
      await tester.pumpAndSettle();

      expect(selectedValues.length, 2);
      expect(selectedValues.contains('Flutter'), true);
      expect(selectedValues.contains('React'), true);
    });
  });

  group('AllDropdownChip', () {
    testWidgets('renders with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllDropdownChip(label: 'Test Chip', onDeleted: () {}),
          ),
        ),
      );

      expect(find.text('Test Chip'), findsOneWidget);
    });

    testWidgets('calls onDeleted when delete icon is tapped', (
      WidgetTester tester,
    ) async {
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllDropdownChip(
              label: 'Test Chip',
              onDeleted: () {
                deleted = true;
              },
            ),
          ),
        ),
      );

      // Find and tap the delete icon
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(deleted, true);
    });
  });

  group('AllTypeahead', () {
    testWidgets('renders with hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllTypeahead<String>(
              hintText: 'Search users',
              suggestionsCallback: (pattern) async {
                return ['User 1', 'User 2', 'User 3'];
              },
              onSuggestionSelected: (value) {},
            ),
          ),
        ),
      );

      expect(find.text('Search users'), findsOneWidget);
    });

    testWidgets('shows suggestions on typing', (WidgetTester tester) async {
      final suggestions = ['User 1', 'User 2', 'User 3'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllTypeahead<String>(
              hintText: 'Search users',
              suggestionsCallback: (pattern) async {
                return suggestions
                    .where(
                      (s) => s.toLowerCase().contains(pattern.toLowerCase()),
                    )
                    .toList();
              },
              onSuggestionSelected: (value) {},
              debounceDuration: const Duration(milliseconds: 0),
            ),
          ),
        ),
      );

      // Type in the text field
      await tester.enterText(find.byType(TextField), 'User');
      await tester.pumpAndSettle();

      // Check if suggestions are shown
      expect(find.text('User 1'), findsOneWidget);
      expect(find.text('User 2'), findsOneWidget);
      expect(find.text('User 3'), findsOneWidget);
    });
  });
}
