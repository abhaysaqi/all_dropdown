# 🌟 All Dropdown — The Ultimate Flutter Dropdown Package

## 🧩 Overview

**All Dropdowns** is a powerful, fully customizable Flutter package that brings together all types of dropdown functionality in one place — single select, multi-select, searchable dropdowns, chip-based selections, and typeahead/autocomplete.

It's designed to look and feel like Flutter's native widgets (DropdownButton, Autocomplete, TextField) while offering extended capabilities and maximum flexibility — making it the **one-stop solution for all dropdown needs**.

## 🚀 Features

### 🎯 Single Select Dropdown
- Works just like Flutter's default dropdown
- Optional search bar to filter options
- Fully customizable height, width, and decoration
- Show selected value inside a TextField-like box

### 🧠 Multi Select Dropdown
- Select multiple items from the dropdown list
- Selected items appear as chips inside a TextField-like container
- Each chip includes a ❌ button for easy removal
- Optionally searchable dropdown list
- Automatically closes or stays open based on configuration

### 🔍 Searchable Dropdown
- Built-in search field for filtering options
- Supports debounce for smoother typing
- Customizable placeholder, input style, and decorations
- Perfect for long lists

### 💬 Typeahead / Autocomplete Mode
- Behaves like a suggestion box — shows matching options as you type
- Supports both single and multiple selection modes
- Selected values don't appear in the textfield (ideal for searching again)
- Works great with APIs or local data

### 🎨 Customization & Theming
Every part of All Dropdowns is customizable — just like Flutter's built-in widgets:
- Colors, borders, icons, shadows, shapes, and text styles
- Custom builder for dropdown items
- Support for icons, images, or leading widgets inside options
- Adjustable dropdown height and scroll behavior
- Automatically adapts to dark or light themes

## 🧱 Core Widgets

| Widget | Description |
|--------|-------------|
| **AllDropdown&lt;T&gt;** | Simple single-select dropdown with optional search |
| **AllMultiDropdown&lt;T&gt;** | Multi-select dropdown with chips and removal option |
| **AllTypeahead&lt;T&gt;** | Typeahead/autocomplete-style dropdown with suggestions |
| **AllDropdownChip** | Custom chip widget for displaying selected items |

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  all_dropdown: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 🧠 Usage Examples

### ✅ Single Select Example

```dart
import 'package:all_dropdown/all_dropdown.dart';

AllDropdown<String>(
  items: ['Apple', 'Banana', 'Orange', 'Mango', 'Pineapple'],
  hintText: 'Select Fruit',
  enableSearch: true,
  onChanged: (value) {
    print('Selected: $value');
  },
  decoration: InputDecoration(
    labelText: 'Fruit',
    border: OutlineInputBorder(),
  ),
);
```

### ✅ Multi Select Example

```dart
AllMultiDropdown<String>(
  items: ['Flutter', 'React', 'Vue', 'Angular', 'Svelte'],
  hintText: 'Select Frameworks',
  enableSearch: true,
  onChanged: (selectedList) {
    print('Selected: $selectedList');
  },
  chipColor: Colors.green.shade100,
  chipTextColor: Colors.green.shade900,
  showCheckboxes: true,
);
```

### ✅ Typeahead Example

```dart
AllTypeahead<String>(
  hintText: 'Search users...',
  suggestionsCallback: (pattern) async {
    // Fetch from API or filter local data
    await Future.delayed(Duration(milliseconds: 500));
    return allUsers
      .where((u) => u.toLowerCase().contains(pattern.toLowerCase()))
      .toList();
  },
  onSuggestionSelected: (value) {
    print('Selected: $value');
  },
  debounceDuration: Duration(milliseconds: 300),
  minCharsForSuggestions: 2,
);
```

### ✅ Advanced Customization

```dart
AllDropdown<User>(
  items: usersList,
  hintText: 'Select User',
  enableSearch: true,
  itemAsString: (user) => user.name,
  itemBuilder: (context, user) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.avatar),
          radius: 16,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(user.email, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  },
  onChanged: (user) {
    print('Selected: ${user?.name}');
  },
  maxHeight: 400,
  dropdownDecoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 15,
        offset: Offset(0, 5),
      ),
    ],
  ),
);
```

## ⚙️ Customization Options

### AllDropdown Properties

| Property | Type | Description |
|----------|------|-------------|
| `items` | `List<T>` | List of items to display |
| `value` | `T?` | Currently selected value |
| `onChanged` | `ValueChanged<T?>?` | Callback when selection changes |
| `hintText` | `String?` | Hint text when nothing is selected |
| `enableSearch` | `bool` | Enable search functionality (default: false) |
| `searchHintText` | `String?` | Placeholder for search field |
| `maxHeight` | `double?` | Maximum height of dropdown overlay |
| `decoration` | `InputDecoration?` | Decoration for the field |
| `dropdownDecoration` | `BoxDecoration?` | Decoration for dropdown overlay |
| `itemBuilder` | `Widget Function(BuildContext, T)?` | Custom builder for items |
| `itemAsString` | `String Function(T)?` | Convert item to string |
| `emptyBuilder` | `Widget?` | Widget shown when no items found |
| `dropdownWidth` | `double?` | Width of dropdown overlay |
| `showSelectedInTextField` | `bool` | Show selected value in field (default: true) |
| `enabled` | `bool` | Whether dropdown is enabled (default: true) |

### AllMultiDropdown Properties

Inherits most properties from `AllDropdown`, plus:

| Property | Type | Description |
|----------|------|-------------|
| `values` | `List<T>?` | Currently selected values |
| `chipColor` | `Color?` | Background color for chips |
| `chipTextColor` | `Color?` | Text color for chips |
| `chipDeleteIconColor` | `Color?` | Delete icon color |
| `onChipRemoved` | `ValueChanged<T>?` | Callback when chip is removed |
| `closeAfterSelection` | `bool` | Close dropdown after each selection (default: false) |
| `showCheckboxes` | `bool` | Show checkboxes next to items (default: true) |
| `maxChipsDisplay` | `int?` | Max chips to show before "+N more" |
| `chipBuilder` | `Widget Function(BuildContext, T, VoidCallback)?` | Custom chip builder |

### AllTypeahead Properties

| Property | Type | Description |
|----------|------|-------------|
| `suggestionsCallback` | `Future<List<T>> Function(String)` | Fetch suggestions based on pattern |
| `onSuggestionSelected` | `ValueChanged<T>?` | Callback for single selection |
| `onMultipleSelected` | `ValueChanged<List<T>>?` | Callback for multi selection |
| `debounceDuration` | `Duration` | Debounce duration (default: 300ms) |
| `minCharsForSuggestions` | `int` | Min characters to show suggestions (default: 0) |
| `showSuggestionsOnFocus` | `bool` | Show suggestions on focus (default: false) |
| `clearAfterSelection` | `bool` | Clear field after selection (default: false) |
| `multiSelect` | `bool` | Enable multi-select mode (default: false) |
| `autoSelectOnSubmit` | `bool` | Auto-select first suggestion on submit (default: false) |
| `loadingBuilder` | `Widget?` | Widget shown while loading |

## 🧩 Why Choose All Dropdowns?

✅ **Combines all dropdown types in one package**  
✅ **Consistent Flutter-style API**  
✅ **Elegant UI with excellent performance**  
✅ **Works seamlessly on mobile and web**  
✅ **Ideal for forms, filters, and selection UIs**  
✅ **Fully customizable to match your design system**  
✅ **Generic type support for any data type**  
✅ **Built-in search and filtering**  

## 🛠️ Planned Features

- [ ] Async data loading and pagination
- [ ] "Select All" and "Clear All" options
- [ ] Max selection limit
- [ ] Keyboard navigation and shortcuts
- [ ] Form field integration and validation
- [ ] Drag-and-drop reordering
- [ ] Grouped items support
- [ ] Virtual scrolling for large lists

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

Created with ❤️ by the Flutter community

## 🐛 Issues and Feedback

Please file issues, bugs, or feature requests in our [issue tracker](https://github.com/yourusername/all_dropdown/issues).

## ⭐ Show Your Support

If you like this package, please give it a ⭐ on GitHub and like it on pub.dev!

---

Made with Flutter 💙
