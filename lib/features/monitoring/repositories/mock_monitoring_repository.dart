import '../models/clinical_measurement.dart';
import '../models/evaluation_result.dart';
import '../models/measurement_type.dart';
import '../models/monitoring_question.dart';
import '../models/monitoring_submission.dart';
import 'monitoring_repository.dart';
import 'rule_engine.dart';

/// Mock implementation of [MonitoringRepository] for development and testing.
///
/// ## Historical data
///
/// [getHistoricalMeasurements] returns **deterministic** mock data seeded at
/// construction time.  Values are fixed patterns (never random) generated
/// relative to a reference date so that 7/30/90-day ranges always contain
/// readings.
///
/// ### Heart-rate note
///
/// The canonical [MonitoringSubmission] domain model does not yet carry a
/// heart-rate field (it only stores `spo2Value`).  The mock below **does**
/// include heart-rate measurements as demo data because the project
/// specification explicitly permits deterministic mock data when the backend
/// is unavailable.  This is **not** fabricated from questionnaire answers.
/// A future Supabase integration should extend `MonitoringSubmission` with a
/// heart-rate value and persist it alongside SpO₂.
class MockMonitoringRepository implements MonitoringRepository {
  final RuleEngine _ruleEngine;
  final List<ClinicalMeasurement> _measurements;

  MockMonitoringRepository({
    RuleEngine? ruleEngine,
    List<ClinicalMeasurement>? historicalMeasurements,
  })  : _ruleEngine = ruleEngine ?? MockRuleEngine(),
        _measurements = historicalMeasurements ?? _generateDefaultHistory();

  /// Generates 14 days of deterministic SpO₂ and heart-rate measurements
  /// relative to "today" so that 7/30/90-day ranges always contain readings.
  /// Values are fixed patterns, never random.
  static List<ClinicalMeasurement> _generateDefaultHistory() {
    final now = DateTime.now();
    final dayNow = DateTime(now.year, now.month, now.day);
    final result = <ClinicalMeasurement>[];

    // Deterministic patterns — fixed values based on day offset.
    const spo2Pattern = [
      96,
      97,
      98,
      96,
      97,
      98,
      96,
      95,
      97,
      98,
      96,
      97,
      96,
      98
    ];
    const heartRatePattern = [
      72,
      70,
      74,
      71,
      73,
      75,
      68,
      72,
      70,
      76,
      71,
      73,
      74,
      70
    ];

    for (int i = 0; i < 14; i++) {
      final day = dayNow.subtract(Duration(days: i));
      final hour = 9 + (i % 3); // 9, 10, 11, 9, 10, 11...
      final measuredAt = DateTime(day.year, day.month, day.day, hour, 30);

      result.add(ClinicalMeasurement(
        id: 'mock-spo2-$i',
        type: MeasurementType.spo2,
        value: spo2Pattern[i].toDouble(),
        unit: '%',
        measuredAt: measuredAt,
      ));

      result.add(ClinicalMeasurement(
        id: 'mock-hr-$i',
        type: MeasurementType.heartRate,
        value: heartRatePattern[i].toDouble(),
        unit: 'bpm',
        measuredAt: measuredAt,
      ));
    }

    // A "today" measurement at a more recent hour for latest-value display
    final latestMeasuredAt =
        DateTime(dayNow.year, dayNow.month, dayNow.day, 14, 15);
    result.add(ClinicalMeasurement(
      id: 'mock-spo2-latest',
      type: MeasurementType.spo2,
      value: 97.0,
      unit: '%',
      measuredAt: latestMeasuredAt,
    ));
    result.add(ClinicalMeasurement(
      id: 'mock-hr-latest',
      type: MeasurementType.heartRate,
      value: 72.0,
      unit: 'bpm',
      measuredAt: latestMeasuredAt,
    ));

    return result;
  }

  /// Filters, type-screens, validates, and sorts a measurement list.
  static List<ClinicalMeasurement> _filterAndSort(
    List<ClinicalMeasurement> source,
    DateTime start,
    DateTime end,
    Set<MeasurementType> types,
  ) {
    return source
        .where((m) =>
            m.isValid &&
            !m.measuredAt.isBefore(start) &&
            !m.measuredAt.isAfter(end) &&
            types.contains(m.type))
        .toList()
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
  }

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
            description:
                'Je suis essoufflé uniquement lors d\'efforts importants (ex. courir).',
          ),
          QuestionOption(
            id: 'mmrc_1',
            label: 'Niveau 1',
            description:
                'Je suis essoufflé lorsque je marche rapidement à plat ou en montant une côte.',
          ),
          QuestionOption(
            id: 'mmrc_2',
            label: 'Niveau 2',
            description:
                'Je dois ralentir sur du plat ou m\'arrêter pour respirer après 100 mètres.',
          ),
          QuestionOption(
            id: 'mmrc_3',
            label: 'Niveau 3',
            description:
                'Je dois m\'arrêter pour reprendre mon souffle après quelques minutes de marche.',
          ),
          QuestionOption(
            id: 'mmrc_4',
            label: 'Niveau 4',
            description:
                'Je suis trop essoufflé pour quitter la maison ou lors de l\'habillage.',
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
            description:
                'Toux persistante ou invalidante au cours de la journée.',
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
            description:
                'Secrétions devenues purulentes (jaunâtres / verdâtres).',
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
  Future<EvaluationResult> submitMonitoring(
      MonitoringSubmission submission) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Persist the submitted SpO₂ reading so it appears in subsequent history queries.
    _measurements.add(ClinicalMeasurement(
      id: 'measurement-${submission.id}',
      type: MeasurementType.spo2,
      value: submission.spo2Value.toDouble(),
      unit: '%',
      measuredAt: submission.timestamp,
    ));

    return _ruleEngine.evaluateSubmission(submission);
  }

  @override
  Future<List<ClinicalMeasurement>> getHistoricalMeasurements({
    required DateTime start,
    required DateTime end,
    required Set<MeasurementType> types,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Guard against inverted ranges.
    final rangeStart = start.isBefore(end) ? start : end;
    final rangeEnd = start.isBefore(end) ? end : start;
    return _filterAndSort(_measurements, rangeStart, rangeEnd, types);
  }
}
