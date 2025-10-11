import 'dart:async';
import 'package:flutter/material.dart';

/// A typeahead/autocomplete widget that shows suggestions as you type.
///
/// This widget provides a search-first experience where suggestions appear
/// in a dropdown as the user types. Supports both single and multi-select modes.
class AllTypeahead<T> extends StatefulWidget {
  /// Callback to fetch suggestions based on the search pattern
  final Future<List<T>> Function(String pattern) suggestionsCallback;

  /// Callback when a suggestion is selected (single select mode)
  final ValueChanged<T>? onSuggestionSelected;

  /// Callback when multiple suggestions are selected (multi select mode)
  final ValueChanged<List<T>>? onMultipleSelected;

  /// Hint text for the text field
  final String? hintText;

  /// Custom builder for suggestion items
  final Widget Function(BuildContext context, T item)? itemBuilder;

  /// Function to convert item to string for display
  final String Function(T item)? itemAsString;

  /// Widget to show when no suggestions are found
  final Widget? emptyBuilder;

  /// Widget to show while loading suggestions
  final Widget? loadingBuilder;

  /// Decoration for the text field
  final InputDecoration? decoration;

  /// Decoration for the suggestions overlay
  final BoxDecoration? suggestionsDecoration;

  /// Maximum height of the suggestions overlay
  final double? maxHeight;

  /// Width of the suggestions overlay. If null, matches the field width
  final double? suggestionsWidth;

  /// Debounce duration for the search input
  final Duration debounceDuration;

  /// Minimum number of characters before showing suggestions
  final int minCharsForSuggestions;

  /// Whether to show suggestions on focus (even with empty input)
  final bool showSuggestionsOnFocus;

  /// Initial value for the text field
  final String? initialValue;

  /// Text controller for the text field (if you want external control)
  final TextEditingController? controller;

  /// Whether to clear the text field after selection
  final bool clearAfterSelection;

  /// Enable multi-select mode
  final bool multiSelect;

  /// Currently selected items (for multi-select mode)
  final List<T>? selectedItems;

  /// Text style for suggestions
  final TextStyle? suggestionStyle;

  /// Background color of selected/hovered item
  final Color? selectedItemColor;

  /// Padding for each suggestion item
  final EdgeInsetsGeometry? itemPadding;

  /// Border radius for the suggestions overlay
  final BorderRadius? suggestionsBorderRadius;

  /// Whether the text field is enabled
  final bool enabled;

  /// Focus node for the text field
  final FocusNode? focusNode;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Callback when the text field is submitted
  final ValueChanged<String>? onFieldSubmitted;

  /// Hide suggestions on keyboard dismiss
  final bool hideOnKeyboardDismiss;

  /// Auto-select the first suggestion on submit
  final bool autoSelectOnSubmit;

  /// Direction to show suggestions (up or down)
  final AxisDirection suggestionsDirection;

  const AllTypeahead({
    super.key,
    required this.suggestionsCallback,
    this.onSuggestionSelected,
    this.onMultipleSelected,
    this.hintText,
    this.itemBuilder,
    this.itemAsString,
    this.emptyBuilder,
    this.loadingBuilder,
    this.decoration,
    this.suggestionsDecoration,
    this.maxHeight,
    this.suggestionsWidth,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.minCharsForSuggestions = 0,
    this.showSuggestionsOnFocus = false,
    this.initialValue,
    this.controller,
    this.clearAfterSelection = false,
    this.multiSelect = false,
    this.selectedItems,
    this.suggestionStyle,
    this.selectedItemColor,
    this.itemPadding,
    this.suggestionsBorderRadius,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.hideOnKeyboardDismiss = false,
    this.autoSelectOnSubmit = false,
    this.suggestionsDirection = AxisDirection.down,
  });

  @override
  State<AllTypeahead<T>> createState() => _AllTypeaheadState<T>();
}

class _AllTypeaheadState<T> extends State<AllTypeahead<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _debounce;
  List<T> _suggestions = [];
  List<T> _selectedItems = [];
  bool _isLoading = false;
  String _previousPattern = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _selectedItems = widget.selectedItems ?? [];

    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(AllTypeahead<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedItems != widget.selectedItems) {
      _selectedItems = widget.selectedItems ?? [];
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  String _itemToString(T item) {
    if (widget.itemAsString != null) {
      return widget.itemAsString!(item);
    }
    return item.toString();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      if (widget.showSuggestionsOnFocus || _controller.text.length >= widget.minCharsForSuggestions) {
        _fetchSuggestions(_controller.text);
      }
    } else if (widget.hideOnKeyboardDismiss) {
      _removeOverlay();
    }
  }

  void _onTextChanged() {
    final pattern = _controller.text;
    
    if (pattern.length < widget.minCharsForSuggestions) {
      _removeOverlay();
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(widget.debounceDuration, () {
      if (pattern != _previousPattern) {
        _previousPattern = pattern;
        _fetchSuggestions(pattern);
      }
    });
  }

  Future<void> _fetchSuggestions(String pattern) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await widget.suggestionsCallback(pattern);
      
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });

        if (_suggestions.isNotEmpty || pattern.isNotEmpty) {
          if (_overlayEntry == null) {
            _showOverlay();
          } else {
            _updateOverlay();
          }
        } else {
          _removeOverlay();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final isUp = widget.suggestionsDirection == AxisDirection.up;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: widget.suggestionsWidth ?? size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: isUp ? Offset(0, -5) : Offset(0, size.height + 5),
          targetAnchor: isUp ? Alignment.topLeft : Alignment.bottomLeft,
          followerAnchor: isUp ? Alignment.bottomLeft : Alignment.topLeft,
          child: Material(
            elevation: 8,
            borderRadius: widget.suggestionsBorderRadius ?? BorderRadius.circular(8),
            child: Container(
              decoration: widget.suggestionsDecoration ??
                  BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: widget.suggestionsBorderRadius ?? BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
              constraints: BoxConstraints(
                maxHeight: widget.maxHeight ?? 250,
              ),
              child: _buildSuggestionsList(),
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
  }

  Widget _buildSuggestionsList() {
    if (_isLoading) {
      return widget.loadingBuilder ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
    }

    if (_suggestions.isEmpty) {
      return widget.emptyBuilder ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No suggestions found',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final item = _suggestions[index];
        final isSelected = widget.multiSelect && _selectedItems.contains(item);

        return InkWell(
          onTap: () => _onSuggestionTap(item),
          child: Container(
            padding: widget.itemPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isSelected
                ? (widget.selectedItemColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.1))
                : null,
            child: Row(
              children: [
                if (widget.multiSelect)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 20,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                  ),
                Expanded(
                  child: widget.itemBuilder?.call(context, item) ??
                      Text(
                        _itemToString(item),
                        style: (widget.suggestionStyle ?? const TextStyle()).copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
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

  void _onSuggestionTap(T item) {
    if (widget.multiSelect) {
      setState(() {
        if (_selectedItems.contains(item)) {
          _selectedItems.remove(item);
        } else {
          _selectedItems.add(item);
        }
        widget.onMultipleSelected?.call(_selectedItems);
      });
      _updateOverlay();
      
      if (widget.clearAfterSelection) {
        _controller.clear();
      }
    } else {
      widget.onSuggestionSelected?.call(item);
      
      if (widget.clearAfterSelection) {
        _controller.clear();
      } else {
        _controller.text = _itemToString(item);
      }
      
      _removeOverlay();
    }
  }

  void _onSubmit(String value) {
    if (widget.autoSelectOnSubmit && _suggestions.isNotEmpty) {
      _onSuggestionTap(_suggestions.first);
    }
    widget.onFieldSubmitted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final defaultDecoration = InputDecoration(
      hintText: widget.hintText,
      border: const OutlineInputBorder(),
      suffixIcon: _controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                _controller.clear();
                _removeOverlay();
              },
            )
          : null,
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: widget.decoration ?? defaultDecoration,
        enabled: widget.enabled,
        textInputAction: widget.textInputAction ?? TextInputAction.search,
        onSubmitted: _onSubmit,
      ),
    );
  }
}

