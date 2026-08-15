import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/core/components/charts/respi_line_chart.dart';
import 'package:respiracare/features/nurse/monitoring/models/respiratory_trend.dart';
import 'package:respiracare/features/nurse/monitoring/providers/nurse_monitoring_provider.dart';
import 'package:respiracare/features/nurse/monitoring/repositories/mock_nurse_monitoring_repository.dart';
import 'package:respiracare/features/nurse/monitoring/screens/respiratory_evolution_screen.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    required String patientId,
    required MockNurseMonitoringRepository repository,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nurseMonitoringRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: RespiratoryEvolutionScreen(patientId: 'p1'),
        ),
      ),
    );
    // Let the initState microtask + repository Future.delayed complete.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('renders the charts with data for a patient', (tester) async {
    await pumpScreen(
      tester,
      patientId: 'p1',
      repository: MockNurseMonitoringRepository(),
    );

    expect(find.text('Évolution respiratoire'), findsOneWidget);
    expect(find.byType(RespiLineChart), findsWidgets);
    expect(find.text('SpO₂'), findsWidgets);
    expect(find.text('Score CAT'), findsOneWidget);
    expect(find.text('Dyspnée mMRC'), findsOneWidget);
    expect(find.text('Sécrétions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a chart point reveals the multi-metric detail panel',
      (tester) async {
    await pumpScreen(
      tester,
      patientId: 'p1',
      repository: MockNurseMonitoringRepository(),
    );

    expect(find.textContaining('Détail'), findsNothing);

    await tester.tap(find.byType(RespiLineChart).first,
        warnIfMissed: false);
    await tester.pump();

    expect(find.textContaining('Détail'), findsOneWidget);
    expect(find.textContaining('SpO₂'), findsWidgets);
  });

  testWidgets('shows an insufficient-data state when fewer than 2 points',
      (tester) async {
    await pumpScreen(
      tester,
      patientId: 'p2',
      repository: _FewPointsRepository(),
    );

    expect(
      find.text(
          'Insufficient data points to render trend graph for selected range.'),
      findsOneWidget,
    );
  });

  testWidgets('shows an error state and retries when the repository fails',
      (tester) async {
    await pumpScreen(
      tester,
      patientId: 'p1',
      repository: _FailingRepository(),
    );

    expect(find.text('Chargement impossible'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

/// Returns a single point so the charts report insufficient data.
class _FewPointsRepository extends MockNurseMonitoringRepository {
  @override
  Future<List<RespiratoryTrendPoint>> getRespiratoryTrend(
    String patientId, {
    TrendTimeframe timeframe = TrendTimeframe.days14,
  }) async {
    return [
      RespiratoryTrendPoint(date: DateTime(2025, 1, 1), spo2: 92),
    ];
  }
}

/// Always throws so the notifier surfaces the error state.
class _FailingRepository extends MockNurseMonitoringRepository {
  @override
  Future<List<RespiratoryTrendPoint>> getRespiratoryTrend(
    String patientId, {
    TrendTimeframe timeframe = TrendTimeframe.days14,
  }) async {
    throw Exception('backend unavailable');
  }
}
