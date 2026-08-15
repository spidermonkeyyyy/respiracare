import 'package:flutter/material.dart';
import '../../theme/tokens/respi_shapes.dart';
import '../../theme/tokens/respi_spacing.dart';
import '../../theme/tokens/respi_typography.dart';

/// Filter/selection chip with clear selected/unselected states.
class RespiChip extends StatelessWidget {
  const RespiChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label, style: RespiTypography.labelMedium),
      selected: isSelected,
      onSelected: onSelected,
      avatar: icon != null ? Icon(icon, size: 18) : null,
      showCheckmark: false,
      selectedColor: cs.primaryContainer,
      backgroundColor: cs.surfaceContainerHighest,
      labelStyle: RespiTypography.labelMedium.copyWith(
        color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: RespiSpacing.sm, vertical: RespiSpacing.xs),
      shape: const RoundedRectangleBorder(borderRadius: RespiShapes.fullRadius),
      side: BorderSide.none,
    );
  }
}
