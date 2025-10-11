import 'package:flutter/material.dart';

/// A customizable chip widget for displaying selected items in dropdowns.
///
/// Used primarily by [AllMultiDropdown] to show selected items with a remove button.
class AllDropdownChip extends StatelessWidget {
  /// The text to display on the chip
  final String label;

  /// Callback when the remove button is pressed
  final VoidCallback? onDeleted;

  /// Background color of the chip
  final Color? backgroundColor;

  /// Text color of the chip label
  final Color? labelColor;

  /// Delete icon color
  final Color? deleteIconColor;

  /// Custom delete icon
  final Widget? deleteIcon;

  /// Padding inside the chip
  final EdgeInsetsGeometry? padding;

  /// Custom avatar/leading widget
  final Widget? avatar;

  /// Custom shape for the chip
  final OutlinedBorder? shape;

  /// Text style for the label
  final TextStyle? labelStyle;

  /// Elevation of the chip
  final double? elevation;

  /// Shadow color of the chip
  final Color? shadowColor;

  const AllDropdownChip({
    super.key,
    required this.label,
    this.onDeleted,
    this.backgroundColor,
    this.labelColor,
    this.deleteIconColor,
    this.deleteIcon,
    this.padding,
    this.avatar,
    this.shape,
    this.labelStyle,
    this.elevation,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor = backgroundColor ?? theme.chipTheme.backgroundColor ?? theme.colorScheme.primary.withOpacity(0.12);
    final defaultLabelColor = labelColor ?? theme.chipTheme.labelStyle?.color ?? theme.colorScheme.onSurface;
    final defaultDeleteIconColor = deleteIconColor ?? theme.chipTheme.deleteIconColor ?? theme.colorScheme.onSurface.withOpacity(0.6);

    return Chip(
      label: Text(
        label,
        style: (labelStyle ?? const TextStyle()).copyWith(
          color: defaultLabelColor,
        ),
      ),
      onDeleted: onDeleted,
      deleteIcon: deleteIcon ?? Icon(Icons.close, size: 18, color: defaultDeleteIconColor),
      backgroundColor: defaultBackgroundColor,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      avatar: avatar,
      shape: shape,
      elevation: elevation,
      shadowColor: shadowColor,
      deleteIconColor: defaultDeleteIconColor,
    );
  }
}

