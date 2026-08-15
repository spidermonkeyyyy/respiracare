import 'package:flutter/material.dart';

import '../../../../core/theme/tokens/respi_shapes.dart';
import '../../../../core/theme/tokens/respi_spacing.dart';
import '../../../../core/theme/tokens/respi_typography.dart';
import '../providers/nurse_worklist_provider.dart';

/// Horizontal, scrollable filter bar for the nurse worklist.
///
/// Displays every [NurseWorklistFilter] category, highlights the currently
/// selected one, and notifies the parent through [onSelected]. The selected
/// filter is both visually distinct and announced to screen readers via the
/// trailing 'selected' semantics. It does no data work itself: filtering is
/// delegated to the consuming provider.
class WorklistFilterBar extends StatelessWidget {
  final NurseWorklistFilter selected;
  final void Function(NurseWorklistFilter) onSelected;

  const WorklistFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Filtres de la file de travail',
      container: true,
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: NurseWorklistFilter.values.length,
          separatorBuilder: (_, __) => const SizedBox(width: RespiSpacing.xs),
          itemBuilder: (context, index) {
            final filter = NurseWorklistFilter.values[index];
            final isSelected = filter == selected;
            return _FilterChip(
              filter: filter,
              isSelected: isSelected,
              onSelected: () => onSelected(filter),
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final NurseWorklistFilter filter;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.filter,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final label = switch (filter) {
      NurseWorklistFilter.all => 'Tous',
      NurseWorklistFilter.alerts => 'Alertes',
      NurseWorklistFilter.tasks => 'Tâches',
      NurseWorklistFilter.monitoring => 'Suivis',
      NurseWorklistFilter.needsAttention => 'À traiter',
    };

    return Semantics(
      button: true,
      selected: isSelected,
      // Explicit selected-state announcement for screen readers.
      label: isSelected ? '$label, sélectionné' : label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onSelected,
        borderRadius: RespiShapes.fullRadius,
        child: Container(
          width: 48,
          height: 48, // 48dp minimum touch target (WCAG 2.5.5).
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: RespiSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected ? cs.primary : cs.surfaceContainerHighest,
            borderRadius: RespiShapes.fullRadius,
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: RespiTypography.labelMedium.copyWith(
              color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
