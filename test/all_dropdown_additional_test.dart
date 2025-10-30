import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:all_dropdown/all_dropdown.dart';

void main() {
  group('AllDropdown - behavior', () {
    testWidgets('filters items when search is enabled', (tester) async {
      final items = ['Apple', 'Banana', 'Orange'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllDropdown<String>(
              items: items,
              hintText: 'Select Fruit',
              enableSearch: true,
              searchHintText: 'Search fruits',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.text('Select Fruit'));
      await tester.pumpAndSettle();

      // All items visible initially
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Orange'), findsOneWidget);

      // Type in search field to filter
      await tester.enterText(find.byType(TextField), 'ban');
      await tester.pumpAndSettle();

      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Orange'), findsNothing);
    });

    testWidgets('does not open when disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllDropdown<String>(
              items: const ['A', 'B'],
              hintText: 'Disabled',
              enabled: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();

      // Items should not appear
      expect(find.text('A'), findsNothing);
      expect(find.text('B'), findsNothing);
    });
  });

  group('AllMultiDropdown - selection and chips', () {
    testWidgets('selects and unselects items, updates callback', (
      tester,
    ) async {
      final items = ['Flutter', 'React', 'Vue'];
      List<String> selected = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllMultiDropdown<String>(
              items: items,
              values: const [],
              hintText: 'Pick',
              onChanged: (values) => selected = values,
              showCheckboxes: true,
            ),
          ),
        ),
      );

      // Open
      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();

      // Select two items
      await tester.tap(find.text('Flutter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('React'));
      await tester.pumpAndSettle();

      expect(selected.length, 2);
      expect(selected.contains('Flutter'), true);
      expect(selected.contains('React'), true);

      // Unselect one
      await tester.tap(find.text('React'));
      await tester.pumpAndSettle();
      expect(selected.length, 1);
      expect(selected.contains('React'), false);
    });

    testWidgets('onChipRemoved is called when deleting a chip', (tester) async {
      final items = ['A', 'B', 'C'];
      List<String> selected = ['A', 'B'];
      String? removed;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllMultiDropdown<String>(
              items: items,
              values: selected,
              hintText: 'Select',
              onChanged: (values) => selected = List.from(values),
              onChipRemoved: (item) => removed = item,
            ),
          ),
        ),
      );

      // Delete first chip (A)
      // Find the first delete icon in chips row
      final deleteButtons = find.byIcon(Icons.close);
      expect(deleteButtons, findsWidgets);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      expect(removed, 'A');
    });
  });

  group('AllTypeahead - suggestions and selection', () {
    testWidgets('shows suggestions on focus when enabled', (tester) async {
      final suggestions = ['User 1', 'User 2'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllTypeahead<String>(
              hintText: 'Search',
              suggestionsCallback: (pattern) async => suggestions,
              showSuggestionsOnFocus: true,
              debounceDuration: const Duration(milliseconds: 0),
            ),
          ),
        ),
      );

      // Focus the field
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.text('User 1'), findsOneWidget);
      expect(find.text('User 2'), findsOneWidget);
    });

    testWidgets('clearAfterSelection clears text and keeps overlay logic', (
      tester,
    ) async {
      final suggestions = ['Alpha', 'Beta'];
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllTypeahead<String>(
              hintText: 'Type',
              suggestionsCallback: (pattern) async => suggestions
                  .where((e) => e.toLowerCase().contains(pattern.toLowerCase()))
                  .toList(),
              onSuggestionSelected: (v) => selected = v,
              debounceDuration: const Duration(milliseconds: 0),
              clearAfterSelection: true,
              minCharsForSuggestions: 1,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pumpAndSettle();

      // Tap first suggestion
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();

      expect(selected, 'Alpha');
      // Text cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text ?? '', '');
    });
  });
}
