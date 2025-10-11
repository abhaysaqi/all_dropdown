/// All Dropdowns - The Ultimate Flutter Dropdown Package
///
/// A powerful, fully customizable Flutter package that brings together all types
/// of dropdown functionality in one place — single select, multi-select,
/// searchable dropdowns, chip-based selections, and typeahead/autocomplete.
///
/// ## Features
///
/// - **AllDropdown**: Simple single-select dropdown with optional search
/// - **AllMultiDropdown**: Multi-select dropdown with chips and removal option
/// - **AllTypeahead**: Typeahead/autocomplete-style dropdown with suggestions
/// - **AllDropdownChip**: Custom chip widget for displaying selected items
///
/// ## Usage
///
/// ### Single Select Example
/// ```dart
/// AllDropdown<String>(
///   items: ['Apple', 'Banana', 'Orange'],
///   hintText: 'Select Fruit',
///   enableSearch: true,
///   onChanged: (value) => print(value),
///   decoration: InputDecoration(
///     labelText: 'Fruit',
///     border: OutlineInputBorder(),
///   ),
/// );
/// ```
///
/// ### Multi Select Example
/// ```dart
/// AllMultiDropdown<String>(
///   items: ['Flutter', 'React', 'Vue', 'Angular'],
///   hintText: 'Select Frameworks',
///   enableSearch: true,
///   onChanged: (selected) => print(selected),
///   chipColor: Colors.green.shade100,
///   chipTextColor: Colors.green.shade900,
/// );
/// ```
///
/// ### Typeahead Example
/// ```dart
/// AllTypeahead<String>(
///   hintText: 'Search users...',
///   suggestionsCallback: (pattern) async {
///     return allUsers.where((u) =>
///       u.toLowerCase().contains(pattern.toLowerCase())).toList();
///   },
///   onSuggestionSelected: (value) => print('Selected: $value'),
/// );
/// ```
library;

export 'src/all_dropdown.dart';
export 'src/all_multi_dropdown.dart';
export 'src/all_typeahead.dart';
export 'src/all_dropdown_chip.dart';
