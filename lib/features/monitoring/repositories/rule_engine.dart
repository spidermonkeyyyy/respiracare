import '../models/evaluation_result.dart';
import '../models/monitoring_submission.dart';

abstract class RuleEngine {
  Future<EvaluationResult> evaluateSubmission(MonitoringSubmission submission);
}

class MockRuleEngine implements RuleEngine {
  @override
  Future<EvaluationResult> evaluateSubmission(MonitoringSubmission submission) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final bool isLowSpo2 = submission.spo2Value < 92;
    final dyspneaAnswer = submission.answers['dyspnea']?.value as String?;
    final bool isHighDyspnea = dyspneaAnswer == 'mmrc_3' || dyspneaAnswer == 'mmrc_4';

    if (isLowSpo2 || isHighDyspnea) {
      return const EvaluationResult(
        status: EvaluationStatus.reviewRequired,
        triggeredRuleIds: ['RULE_LOW_SPO2_OR_DYSPNEA'],
        patientMessage:
            'Votre suivi a bien été transmis. Certaines informations nécessitent une vérification par votre équipe soignante. Votre infirmier référent a été notifié.',
      );
    }

    return const EvaluationResult(
      status: EvaluationStatus.normal,
      triggeredRuleIds: [],
      patientMessage:
          'Vos informations ont été transmises à votre équipe soignante. Merci d\'avoir complété votre suivi quotidien.',
    );
  }
}
