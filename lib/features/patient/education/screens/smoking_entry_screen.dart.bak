import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/animations/app_animations.dart';
import '../../../../core/widgets/buttons/app_button.dart'
    show AppButton;
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/inputs/app_input.dart';
import '../models/smoking_entry.dart';
import '../providers/smoking_cessation_provider.dart';

/// Daily smoking entry form screen
class SmokingEntryScreen extends ConsumerStatefulWidget {
  final SmokingEntry? existingEntry;

  const SmokingEntryScreen({
    super.key,
    this.existingEntry,
  });

  @override
  ConsumerState<SmokingEntryScreen> createState() => _SmokingEntryScreenState();
}

class _SmokingEntryScreenState extends ConsumerState<SmokingEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cigarettesController = TextEditingController();
  final _notesController = TextEditingController();

  CravingIntensity _selectedCraving = CravingIntensity.moderate;
  SmokingTrigger _selectedTrigger = SmokingTrigger.habit;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _cigarettesController.text =
          widget.existingEntry!.cigarettesConsumed.toString();
      _selectedCraving = widget.existingEntry!.cravingIntensity;
      _selectedTrigger = widget.existingEntry!.trigger;
      _notesController.text = widget.existingEntry!.personalNote ?? '';
    } else {
      _cigarettesController.text = '0';
    }
  }

  @override
  void dispose() {
    _cigarettesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier l\'entrée' : 'Nouvelle entrée'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Header
              AppFadeAnimation(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing
                          ? 'Modifiez votre entrée du jour'
                          : 'Comment s\'est passée votre journée ?',
                      style: AppTypography.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Renseignez votre consommation et vos ressentis. Cela aide à identifier vos déclencheurs.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Cigarettes consumed
              AppSlideAnimation(
                delay: const Duration(milliseconds: 100),
                child: _buildCigarettesField(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Craving intensity
              AppSlideAnimation(
                delay: const Duration(milliseconds: 150),
                child: _buildCravingSelector(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Trigger selector
              AppSlideAnimation(
                delay: const Duration(milliseconds: 200),
                child: _buildTriggerSelector(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Personal note
              AppSlideAnimation(
                delay: const Duration(milliseconds: 250),
                child: _buildNotesField(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save button
              AppSlideAnimation(
                delay: const Duration(milliseconds: 300),
                direction: SlideDirection.up,
                child: AppButton(
                  text: isEditing
                      ? 'Enregistrer les modifications'
                      : 'Enregistrer',
                  icon: Icons.save_rounded,
                  fullWidth: true,
                  loading: _isSaving,
                  onPressed: _saveEntry,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCigarettesField() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: const Icon(
                  Icons.smoking_rooms_rounded,
                  size: 20.0,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Cigarettes consommées',
                style: AppTypography.titleLarge.copyWith(fontSize: 16.0),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppInput(
            controller: _cigarettesController,
            label: 'Nombre de cigarettes',
            hint: 'Ex: 2',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un nombre';
              }
              final count = int.tryParse(value);
              if (count == null || count < 0) {
                return 'Entrez un nombre valide';
              }
              if (count > 100) {
                return 'Valeur trop élevée';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCravingSelector() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  size: 20.0,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Envie de fumer',
                style: AppTypography.titleLarge.copyWith(fontSize: 16.0),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: CravingIntensity.values.map((intensity) {
              final isSelected = _selectedCraving == intensity;
              final color = _getCravingColor(intensity);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: intensity != CravingIntensity.values.last
                        ? AppSpacing.sm
                        : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCraving = intensity),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.15)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(
                          color: isSelected ? color : AppColors.border,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getCravingIcon(intensity),
                            size: 24.0,
                            color: isSelected ? color : AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            intensity.label,
                            style: AppTypography.bodyMedium.copyWith(
                              color:
                                  isSelected ? color : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerSelector() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: const Icon(
                  Icons.label_outline_rounded,
                  size: 20.0,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Déclencheur',
                style: AppTypography.titleLarge.copyWith(fontSize: 16.0),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: SmokingTrigger.values.map((trigger) {
              final isSelected = _selectedTrigger == trigger;
              return GestureDetector(
                onTap: () => setState(() => _selectedTrigger = trigger),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.info.withValues(alpha: 0.15)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: isSelected ? AppColors.info : AppColors.border,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTriggerIcon(trigger),
                        size: 16.0,
                        color: isSelected
                            ? AppColors.info
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        trigger.label,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isSelected
                              ? AppColors.info
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: const Icon(
                  Icons.note_alt_outlined,
                  size: 20.0,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Note personnelle (optionnel)',
                style: AppTypography.titleLarge.copyWith(fontSize: 16.0),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppInput(
            controller: _notesController,
            hint: 'Ex: "Envie pendant les révisions", "Stress au travail"...',
            maxLines: 3,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final cigarettes = int.parse(_cigarettesController.text);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final entry = SmokingEntry(
        id: widget.existingEntry?.id ?? 'smk-${now.millisecondsSinceEpoch}',
        date: today,
        cigarettesConsumed: cigarettes,
        cravingIntensity: _selectedCraving,
        trigger: _selectedTrigger,
        personalNote:
            _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: widget.existingEntry?.createdAt ?? now,
      );

      await ref.read(smokingCessationProvider.notifier).addEntry(entry);

      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  IconData _getCravingIcon(CravingIntensity intensity) {
    switch (intensity) {
      case CravingIntensity.low:
        return Icons.sentiment_satisfied_rounded;
      case CravingIntensity.moderate:
        return Icons.sentiment_neutral_rounded;
      case CravingIntensity.high:
        return Icons.sentiment_very_dissatisfied_rounded;
    }
  }

  Color _getCravingColor(CravingIntensity intensity) {
    switch (intensity) {
      case CravingIntensity.low:
        return AppColors.success;
      case CravingIntensity.moderate:
        return AppColors.warning;
      case CravingIntensity.high:
        return AppColors.danger;
    }
  }

  IconData _getTriggerIcon(SmokingTrigger trigger) {
    switch (trigger) {
      case SmokingTrigger.stress:
        return Icons.psychology_rounded;
      case SmokingTrigger.habit:
        return Icons.repeat_rounded;
      case SmokingTrigger.social:
        return Icons.people_rounded;
      case SmokingTrigger.emotion:
        return Icons.favorite_rounded;
      case SmokingTrigger.other:
        return Icons.help_outline_rounded;
    }
  }
}
