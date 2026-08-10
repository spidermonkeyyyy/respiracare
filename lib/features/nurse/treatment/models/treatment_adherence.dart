import 'package:equatable/equatable.dart';

class TreatmentAdherence extends Equatable {
  final String patientId;
  final int confirmedCount;
  final int missedCount;
  final double weeklyCompliance;
  final List<TreatmentDay> history;

  const TreatmentAdherence({
    required this.patientId,
    required this.confirmedCount,
    required this.missedCount,
    required this.weeklyCompliance,
    required this.history,
  });

  @override
  List<Object?> get props => [patientId, confirmedCount, missedCount, weeklyCompliance, history];
}

class TreatmentDay extends Equatable {
  final DateTime? date;
  final bool confirmed;

  const TreatmentDay({
    this.date,
    required this.confirmed,
  });

  @override
  List<Object?> get props => [date, confirmed];
}
