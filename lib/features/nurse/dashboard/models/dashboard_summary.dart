import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final int totalPatients;
  final int highPriorityCount;
  final int reviewRequiredCount;
  final int newSubmissionsCount;

  const DashboardSummary({
    required this.totalPatients,
    required this.highPriorityCount,
    required this.reviewRequiredCount,
    required this.newSubmissionsCount,
  });

  @override
  List<Object?> get props => [
        totalPatients,
        highPriorityCount,
        reviewRequiredCount,
        newSubmissionsCount,
      ];
}
