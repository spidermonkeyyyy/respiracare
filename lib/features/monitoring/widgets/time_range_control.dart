import 'package:flutter/material.dart';

import '../../../core/accessibility/accessibility_config.dart';
import '../../../core/theme/tokens/respi_shapes.dart';
import '../utils/clinical_time_range.dart';

/// Segmented control for choosing the displayed time window.
///
/// Uses Material 3 [SegmentedButton] so focus, keyboard and semantics
/// behaviour are inherited.  All segments are at least
/// [AccessibilityConfig.minTouchTarget] tall.
class TimeRangeControl extends StatelessWidget {
  const TimeRangeControl({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ClinicalTimeRange selected;
  final ValueChanged<ClinicalTimeRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ClinicalTimeRange>(
      segments: [
        for (final range in ClinicalTimeRange.values)
          ButtonSegment(
            value: range,
            label: Text(range.label),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.standard,
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(
              vertical: AccessibilityConfig.minTouchTarget / 3),
        ),
        textStyle: WidgetStatePropertyAll(
          Theme.of(context).textTheme.labelLarge,
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: RespiShapes.mdRadius),
        ),
      ),
    );
  }
}
