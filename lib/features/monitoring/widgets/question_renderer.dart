import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../models/monitoring_question.dart';
import '../models/monitoring_submission.dart';
import 'question_option.dart';
import 'spo2_input.dart';

/// Dynamically renders the correct input widget based on QuestionType.
/// This decouples question content from presentation logic.
class MonitoringQuestionRenderer extends StatelessWidget {
  final MonitoringQuestion question;
  final dynamic currentAnswer; // String (optionId) or int (SpO2)
  final MeasurementSource measurementSource;
  final ValueChanged<dynamic> onAnswerChanged;

  const MonitoringQuestionRenderer({
    super.key,
    required this.question,
    required this.currentAnswer,
    required this.onAnswerChanged,
    this.measurementSource = MeasurementSource.manual,
  });

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoice();
      case QuestionType.numericInput:
        return _buildNumericInput();
    }
  }

  Widget _buildSingleChoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.description != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 2,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              question.description!,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        ...question.options.map(
          (option) => QuestionOptionCard(
            option: option,
            isSelected: currentAnswer == option.id,
            onTap: () => onAnswerChanged(option.id),
          ),
        ),
      ],
    );
  }

  Widget _buildNumericInput() {
    return SpO2Input(
      initialValue: currentAnswer as int?,
      measurementSource: measurementSource,
      onChanged: (val) => onAnswerChanged(val),
    );
  }
}
