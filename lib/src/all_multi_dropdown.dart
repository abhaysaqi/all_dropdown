import 'package:flutter/material.dart';
import 'all_dropdown_chip.dart';

/// A customizable multi-select dropdown widget with chip display.
///
/// Selected items are displayed as chips inside a TextField-like container,
/// each with a remove button. Supports optional search functionality.
class AllMultiDropdown<T> extends StatefulWidget {
  /// List of items to display in the dropdown
  final List<T> items;

  /// Currently selected values
  final List<T>? values;

  /// Callback when selection changes
  final ValueChanged<List<T>>? onChanged;

  /// Hint text to display when no items are selected
  final String? hintText;

  /// Enable or disable search functionality
  final bool enableSearch;

  /// Placeholder text for the search field
  final String? searchHintText;

  /// Maximum height of the dropdown overlay
  final double? maxHeight;

  /// Decoration for the main dropdown field
  final InputDecoration? decoration;

  /// Decoration for the dropdown overlay container
  final BoxDecoration? dropdownDecoration;

  /// Custom builder for dropdown items
  final Widget Function(BuildContext context, T item, bool isSelected)? itemBuilder;

  /// Function to convert item to string for display and search
  final String Function(T item)? itemAsString;

  /// Widget to show when no items match the search
  final Widget? emptyBuilder;

  /// Width of the dropdown overlay. If null, matches the field width
  final double? dropdownWidth;

  /// Background color for chips
  final Color? chipColor;

  /// Text color for chips
  final Color? chipTextColor;

  /// Delete icon color for chips
  final Color? chipDeleteIconColor;

  /// Custom delete icon for chips
  final Widget? chipDeleteIcon;

  /// Callback when a chip is removed
  final ValueChanged<T>? onChipRemoved;

  /// Whether the dropdown is enabled
  final bool enabled;

  /// Text style for dropdown items
  final TextStyle? itemStyle;

  /// Background color of selected item in dropdown
  final Color? selectedItemColor;

  /// Text color of items in dropdown
  final Color? itemTextColor;

  /// Padding for each item in the dropdown
  final EdgeInsetsGeometry? itemPadding;

  /// Border radius for the dropdown overlay
  final BorderRadius? dropdownBorderRadius;

  /// Close dropdown after each selection
  final bool closeAfterSelection;

  /// Show checkboxes next to items
  final bool showCheckboxes;

  /// Maximum number of chips to display before showing count
  final int? maxChipsDisplay;

  /// Custom chip builder
  final Widget Function(BuildContext context, T item, VoidCallback onRemove)? chipBuilder;

  const AllMultiDropdown({
    super.key,
    required this.items,
    this.values,
    this.onChanged,
    this.hintText,
    this.enableSearch = false,
    this.searchHintText,
    this.maxHeight,
    this.decoration,
    this.dropdownDecoration,
    this.itemBuilder,
    this.itemAsString,
    this.emptyBuilder,
    this.dropdownWidth,
    this.chipColor,
    this.chipTextColor,
    this.chipDeleteIconColor,
    this.chipDeleteIcon,
    this.onChipRemoved,
    this.enabled = true,
    this.itemStyle,
    this.selectedItemColor,
    this.itemTextColor,
    this.itemPadding,
    this.dropdownBorderRadius,
    this.closeAfterSelection = false,
    this.showCheckboxes = true,
    this.maxChipsDisplay,
    this.chipBuilder,
  });

  @override
  State<AllMultiDropdown<T>> createState() => _AllMultiDropdownState<T>();
}

class _AllMultiDropdownState<T> extends State<AllMultiDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<T> _filteredItems = [];
  List<T> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _selectedItems = widget.values ?? [];
  }

  @override
  void didUpdateWidget(AllMultiDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
      _searchController.clear();
    }
    if (oldWidget.values != widget.values) {
      _selectedItems = widget.values ?? [];
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _itemToString(T item) {
    if (widget.itemAsString != null) {
      return widget.itemAsString!(item);
    }
    return item.toString();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => _itemToString(item).toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
    _updateOverlay();
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: widget.dropdownWidth ?? size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 8,
            borderRadius: widget.dropdownBorderRadius ?? BorderRadius.circular(8),
            child: Container(
              decoration: widget.dropdownDecoration ??
                  BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: widget.dropdownBorderRadius ?? BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
              constraints: BoxConstraints(
                maxHeight: widget.maxHeight ?? 300,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.enableSearch) _buildSearchField(),
                  Flexible(
                    child: _filteredItems.isEmpty
                        ? _buildEmptyWidget()
                        : _buildItemsList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchController.clear();
    _filteredItems = widget.items;
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.searchHintText ?? 'Search...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _filterItems('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
        ),
        onChanged: _filterItems,
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return widget.emptyBuilder ??
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No items found',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            ),
          ),
        );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final isSelected = _selectedItems.contains(item);

        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedItems.remove(item);
              } else {
                _selectedItems.add(item);
              }
              widget.onChanged?.call(_selectedItems);
            });
            _updateOverlay();
            
            if (widget.closeAfterSelection) {
              _removeOverlay();
            }
          },
          child: Container(
            padding: widget.itemPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isSelected
                ? (widget.selectedItemColor ?? Theme.of(context).primaryColor.withOpacity(0.1))
                : null,
            child: Row(
              children: [
                if (widget.showCheckboxes)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) {
                        setState(() {
                          if (isSelected) {
                            _selectedItems.remove(item);
                          } else {
                            _selectedItems.add(item);
                          }
                          widget.onChanged?.call(_selectedItems);
                        });
                        _updateOverlay();
                        
                        if (widget.closeAfterSelection) {
                          _removeOverlay();
                        }
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                Expanded(
                  child: widget.itemBuilder?.call(context, item, isSelected) ??
                      Text(
                        _itemToString(item),
                        style: (widget.itemStyle ?? const TextStyle()).copyWith(
                          color: widget.itemTextColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeChip(T item) {
    setState(() {
      _selectedItems.remove(item);
      widget.onChanged?.call(_selectedItems);
      widget.onChipRemoved?.call(item);
    });
  }

  Widget _buildChipsContainer() {
    if (_selectedItems.isEmpty) {
      return Text(
        widget.hintText ?? '',
        style: Theme.of(context).inputDecorationTheme.hintStyle,
      );
    }

    final displayItems = widget.maxChipsDisplay != null && _selectedItems.length > widget.maxChipsDisplay!
        ? _selectedItems.take(widget.maxChipsDisplay!).toList()
        : _selectedItems;

    final hasMore = widget.maxChipsDisplay != null && _selectedItems.length > widget.maxChipsDisplay!;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...displayItems.map((item) {
          return widget.chipBuilder?.call(context, item, () => _removeChip(item)) ??
              AllDropdownChip(
                label: _itemToString(item),
                onDeleted: () => _removeChip(item),
                backgroundColor: widget.chipColor,
                labelColor: widget.chipTextColor,
                deleteIconColor: widget.chipDeleteIconColor,
                deleteIcon: widget.chipDeleteIcon,
              );
        }),
        if (hasMore)
          Chip(
            label: Text('+${_selectedItems.length - widget.maxChipsDisplay!} more'),
            backgroundColor: widget.chipColor?.withOpacity(0.5) ?? 
                Theme.of(context).colorScheme.primary.withOpacity(0.08),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultDecoration = InputDecoration(
      hintText: widget.hintText,
      border: const OutlineInputBorder(),
      suffixIcon: IconButton(
        icon: Icon(
          _overlayEntry != null ? Icons.arrow_drop_up : Icons.arrow_drop_down,
        ),
        onPressed: widget.enabled ? _toggleDropdown : null,
      ),
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: widget.enabled ? _toggleDropdown : null,
        focusNode: _focusNode,
        child: InputDecorator(
          decoration: (widget.decoration ?? defaultDecoration).copyWith(
            enabled: widget.enabled,
          ),
          child: _buildChipsContainer(),
        ),
      ),
    );
  }
}

