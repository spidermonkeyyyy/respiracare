import 'package:equatable/equatable.dart';
import 'monitoring_answer.dart';

enum MeasurementSource {
  manual,
  bluetooth,
}

class MonitoringSubmission extends Equatable {
  final String id;
  final String patientId;
  final DateTime timestamp;
  final Map<String, MonitoringAnswer> answers;
  final int spo2Value;
  final MeasurementSource measurementSource;

  const MonitoringSubmission({
    required this.id,
    required this.patientId,
    required this.timestamp,
    required this.answers,
    required this.spo2Value,
    this.measurementSource = MeasurementSource.manual,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        timestamp,
        answers,
        spo2Value,
        measurementSource,
      ];
}
