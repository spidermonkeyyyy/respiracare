import 'package:flutter/material.dart';
import '../../../core/widgets/cards/health_status_card.dart';
import '../models/patient_dashboard_data.dart';

class PatientHealthStatusCard extends StatelessWidget {
  final PatientDashboardData data;
  final VoidCallback? onTap;

  const PatientHealthStatusCard({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final variant = _mapVariant(data.status);

    return HealthStatusCard(
      title: 'Votre suivi respiratoire',
      value: 'SpO₂ ${data.spo2Value}%',
      statusText: data.statusText,
      subtitle: 'Dernière mesure : ${data.spo2Timestamp}',
      variant: variant,
      onTap: onTap,
    );
  }

  HealthStatusVariant _mapVariant(MonitoringStatus status) {
    switch (status) {
      case MonitoringStatus.normal:
        return HealthStatusVariant.normal;
      case MonitoringStatus.attentionNeeded:
        return HealthStatusVariant.attention;
      case MonitoringStatus.incomplete:
        return HealthStatusVariant.information;
    }
  }
}
