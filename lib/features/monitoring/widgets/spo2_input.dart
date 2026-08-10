import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../models/monitoring_submission.dart';

class SpO2Input extends StatefulWidget {
  final int? initialValue;
  final MeasurementSource measurementSource;
  final ValueChanged<int?> onChanged;

  const SpO2Input({
    super.key,
    this.initialValue,
    this.measurementSource = MeasurementSource.manual,
    required this.onChanged,
  });

  @override
  State<SpO2Input> createState() => _SpO2InputState();
}

class _SpO2InputState extends State<SpO2Input> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue != null ? widget.initialValue.toString() : '95',
    );
    // Validate initial value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateAndEmit(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndEmit(String text) {
    if (text.trim().isEmpty) {
      setState(() => _errorText = 'Veuillez saisir une valeur de SpO₂');
      widget.onChanged(null);
      return;
    }

    final val = int.tryParse(text.trim());
    if (val == null || val < 70 || val > 100) {
      setState(() =>
          _errorText = 'Veuillez entrer une valeur valide entre 70% et 100%');
      widget.onChanged(null);
      return;
    }

    setState(() => _errorText = null);
    widget.onChanged(val);
  }

  void _stepValue(int delta) {
    final current = int.tryParse(_controller.text.trim()) ?? 95;
    final newValue = (current + delta).clamp(70, 100);
    _controller.text = newValue.toString();
    _validateAndEmit(newValue.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Measurement Source Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.measurementSource == MeasurementSource.bluetooth
                    ? Icons.bluetooth_connected_rounded
                    : Icons.edit_note_rounded,
                size: 14.0,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                widget.measurementSource == MeasurementSource.bluetooth
                    ? 'Mesure Oxymètre Bluetooth'
                    : 'Mode de saisie : Manuelle',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // SpO2 Large Input Field & Stepper Controls
        Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Decrement Button
                  IconButton.filledTonal(
                    onPressed: () => _stepValue(-1),
                    icon: const Icon(Icons.remove_rounded),
                    iconSize: 28.0,
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Numeric Display Box
                  SizedBox(
                    width: 120.0,
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 42.0,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      onChanged: _validateAndEmit,
                      decoration: InputDecoration(
                        suffixText: '%',
                        suffixStyle: AppTypography.titleLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Increment Button
                  IconButton.filledTonal(
                    onPressed: () => _stepValue(1),
                    icon: const Icon(Icons.add_rounded),
                    iconSize: 28.0,
                  ),
                ],
              ),
              if (_errorText != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _errorText!,
                  style: AppTypography.secondaryText.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
