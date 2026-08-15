import 'package:flutter/material.dart';

import '../models/measurement_type.dart';

/// Filter chips letting the patient toggle which measurement series appear.
///
/// At least one type always stays selected (enforced by the notifier —
/// [MeasurementType.spo2] is the fallback).
class MeasurementTypeFilter extends StatelessWidget {
  const MeasurementTypeFilter({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<MeasurementType> selected;
  final ValueChanged<MeasurementType> onToggle;

  static const List<MeasurementType> _order = [
    MeasurementType.spo2,
    MeasurementType.heartRate,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final type in _order)
          _TypeChip(
            type: type,
            isSelected: selected.contains(type),
            onToggle: () => onToggle(type),
            color: type == MeasurementType.spo2 ? cs.primary : cs.tertiary,
          ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.isSelected,
    required this.onToggle,
    required this.color,
  });

  final MeasurementType type;
  final bool isSelected;
  final VoidCallback onToggle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final info = MeasurementTypeInfo.of(type);

    return FilterChip(
      label: Text(info.label),
      selected: isSelected,
      onSelected: (_) => onToggle(),
      showCheckmark: false,
      avatar: Icon(
        isSelected ? Icons.check_rounded : Icons.show_chart_rounded,
        size: 16,
      ),
      selectedColor: color.withValues(alpha: 0.18),
      backgroundColor: cs.surfaceContainerHighest,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isSelected ? color : cs.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
      avatarBoxConstraints:
          const BoxConstraints.tightFor(width: 20, height: 20),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(
        color: isSelected ? color : cs.outlineVariant,
        width: 1.5,
      ),
    );
  }
}
