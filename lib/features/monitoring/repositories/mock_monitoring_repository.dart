import '../models/evaluation_result.dart';
import '../models/monitoring_question.dart';
import '../models/monitoring_submission.dart';
import 'monitoring_repository.dart';
import 'rule_engine.dart';

class MockMonitoringRepository implements MonitoringRepository {
  final RuleEngine _ruleEngine;

  MockMonitoringRepository({RuleEngine? ruleEngine})
      : _ruleEngine = ruleEngine ?? MockRuleEngine();

  @override
  Future<List<MonitoringQuestion>> getQuestions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      MonitoringQuestion(
        id: 'dyspnea',
        type: QuestionType.singleChoice,
        title: 'Comment évaluez-vous votre essoufflement aujourd\'hui ?',
        description: 'Échelle d\'évaluation clinique mMRC',
        order: 1,
        options: [
          QuestionOption(
            id: 'mmrc_0',
            label: 'Niveau 0',
            description: 'Je suis essoufflé uniquement lors d\'efforts importants (ex. courir).',
          ),
          QuestionOption(
            id: 'mmrc_1',
            label: 'Niveau 1',
            description: 'Je suis essoufflé lorsque je marche rapidement à plat ou en montant une côte.',
          ),
          QuestionOption(
            id: 'mmrc_2',
            label: 'Niveau 2',
            description: 'Je dois ralentir sur du plat ou m\'arrêter pour respirer après 100 mètres.',
          ),
          QuestionOption(
            id: 'mmrc_3',
            label: 'Niveau 3',
            description: 'Je dois m\'arrêter pour reprendre mon souffle après quelques minutes de marche.',
          ),
          QuestionOption(
            id: 'mmrc_4',
            label: 'Niveau 4',
            description: 'Je suis trop essoufflé pour quitter la maison ou lors de l\'habillage.',
          ),
        ],
      ),
      MonitoringQuestion(
        id: 'cough',
        type: QuestionType.singleChoice,
        title: 'Avez-vous davantage toussé aujourd\'hui ?',
        description: 'Comparaison par rapport à votre niveau habituel',
        order: 2,
        options: [
          QuestionOption(
            id: 'cough_normal',
            label: 'Pas plus que d\'habitude',
            description: 'La quinte de toux reste identique.',
          ),
          QuestionOption(
            id: 'cough_mild',
            label: 'Un peu plus que d\'habitude',
            description: 'Augmentation légère de la fréquence des toux.',
          ),
          QuestionOption(
            id: 'cough_severe',
            label: 'Beaucoup plus que d\'habitude',
            description: 'Toux persistante ou invalidante au cours de la journée.',
          ),
        ],
      ),
      MonitoringQuestion(
        id: 'sputum',
        type: QuestionType.singleChoice,
        title: 'Avez-vous remarqué un changement dans vos expectorations ?',
        description: 'Quantité et aspect des crachats',
        order: 3,
        options: [
          QuestionOption(
            id: 'sputum_normal',
            label: 'Pas de changement',
            description: 'Aspect et volume habituels.',
          ),
          QuestionOption(
            id: 'sputum_amount',
            label: 'Quantité augmentée',
            description: 'Volume des sécrétions plus important.',
          ),
          QuestionOption(
            id: 'sputum_color',
            label: 'Aspect ou couleur modifiée',
            description: 'Secrétions devenues purulentes (jaunâtres / verdâtres).',
          ),
        ],
      ),
      MonitoringQuestion(
        id: 'spo2',
        type: QuestionType.numericInput,
        title: 'Votre saturation en oxygène (SpO₂)',
        description: 'Indiquez la valeur mesurée avec votre oxymètre de pouls.',
        order: 4,
        unit: '%',
        minValue: 70,
        maxValue: 100,
      ),
    ];
  }

  @override
  Future<EvaluationResult> submitMonitoring(MonitoringSubmission submission) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _ruleEngine.evaluateSubmission(submission);
  }
}
