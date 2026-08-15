import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/features/monitoring/widgets/chart_card_skeleton.dart';
import 'package:respiracare/features/monitoring/widgets/clinical_chart_card.dart';
import 'package:respiracare/features/monitoring/providers/monitoring_provider.dart';
import 'package:respiracare/features/monitoring/screens/monitoring_history_screen.dart';

import 'monitoring_test_helpers.dart';

void main() {
  late FakeMonitoringRepository fake;

  setUp(() {
    fake = FakeMonitoringRepository();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    // Use a tall viewport so all chart cards are laid out by the lazy
    // ListView (cards below the fold would not be built otherwise).
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          monitoringRepositoryProvider.overrideWithValue(fake),
        ],
        child: const MaterialApp(
          home: MonitoringHistoryScreen(),
        ),
      ),
    );
    // Let the first frame (and the load microtask) run; the reload itself
    // finishes during [settle] below.
    await tester.pump();
  }

  group('layout & controls', () {
    testWidgets('shows an informational banner and range selector',
        (tester) async {
      final now = DateTime.now();
      fake.measurements = [
        spo2Reading(
            id: 'a', value: 96, at: now.subtract(const Duration(days: 1))),
      ];

      await pumpScreen(tester);

      expect(find.text('Historique'), findsOneWidget);
      expect(find.textContaining('ne remplacent pas un avis'), findsOneWidget);
      expect(find.text('7 days'), findsOneWidget);
      expect(find.text('30 days'), findsOneWidget);
      expect(find.text('90 days'), findsOneWidget);
      // Both type chips are always present (only SpO₂ is selected initially).
      expect(find.widgetWithText(FilterChip, 'SpO₂'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Heart rate'), findsOneWidget);
    });

    testWidgets('shows a chart card with readings and trend', (tester) async {
      final now = DateTime.now();
      fake.measurements = [
        spo2Reading(
            id: 'a', value: 96, at: now.subtract(const Duration(days: 2))),
        spo2Reading(
            id: 'b', value: 98, at: now.subtract(const Duration(days: 1))),
      ];

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      // Exactly one card for the default SpO₂ series.
      expect(find.byType(ClinicalChartCard), findsOneWidget);
      // Latest reading value rendered in the header as RichText.
      // Find a RichText containing "98" by checking the text content.
      final richTexts = find.byType(RichText).evaluate();
      final hasValue98 = richTexts.any((element) {
        final richText = element.widget as RichText;
        final textSpan = richText.text as TextSpan?;
        return textSpan?.toPlainText().contains('98') ?? false;
      });
      expect(hasValue98, isTrue);
      // The 96->98 rise crosses the SpO₂ threshold -> classified upward.
      expect(find.text('En hausse'), findsOneWidget);
      // Footer reads the reading count.
      expect(find.textContaining('2 mesures'), findsOneWidget);
    });

    testWidgets('shows empty state when there is no data', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(ClinicalChartCard), findsNothing);
      expect(find.text('Aucune mesure sur cette période'), findsOneWidget);
    });

    testWidgets('shows an error state with retry when loading fails',
        (tester) async {
      fake.throwOnHistory = true;

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Impossible de charger vos mesures'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
      expect(find.byType(ClinicalChartCard), findsNothing);
    });
  });

  group('user interactions', () {
    testWidgets('toggling the heart-rate filter shows a second card',
        (tester) async {
      final now = DateTime.now();
      fake.measurements = [
        spo2Reading(
            id: 'a', value: 96, at: now.subtract(const Duration(days: 1))),
        heartRateReading(
            id: 'b', value: 72, at: now.subtract(const Duration(days: 1))),
      ];

      await pumpScreen(tester);
      await tester.pumpAndSettle();
      expect(find.byType(ClinicalChartCard), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'Heart rate'));
      await tester.pumpAndSettle();

      // Both series now selected -> two cards.
      expect(find.byType(ClinicalChartCard), findsNWidgets(2));
      // The heart-rate card header is rendered inside its card.
      final heartCards = find
          .descendant(
            of: find.byType(ClinicalChartCard),
            matching: find.text('Heart rate'),
          )
          .evaluate();
      expect(heartCards.length, 1);
      // The heart-rate latest value is rendered as a RichText (unit not yet
      // in that line), e.g. "72 bpm" — mirror the SpO₂ value assertion.
      final richTexts = find.byType(RichText).evaluate();
      final hasValue72 = richTexts.any((element) {
        final textSpan = (element.widget as RichText).text as TextSpan?;
        return textSpan?.toPlainText().contains('72') ?? false;
      });
      expect(hasValue72, isTrue);
    });

    testWidgets('retry after an error reloads data', (tester) async {
      fake.throwOnHistory = true;

      await pumpScreen(tester);
      await tester.pumpAndSettle();
      expect(find.text('Impossible de charger vos mesures'), findsOneWidget);

      fake.throwOnHistory = false;
      final now = DateTime.now();
      fake.measurements = [
        spo2Reading(
            id: 'a', value: 96, at: now.subtract(const Duration(days: 1))),
      ];

      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();

      expect(find.text('Impossible de charger vos mesures'), findsNothing);
      expect(find.byType(ClinicalChartCard), findsOneWidget);
      // Single reading -> stable trend, no "En hausse" badge.
      expect(find.text('En hausse'), findsNothing);
    });

    testWidgets('refresh pulls fresh data', (tester) async {
      final now = DateTime.now();
      fake.measurements = [
        spo2Reading(
            id: 'a', value: 96, at: now.subtract(const Duration(days: 1))),
      ];

      await pumpScreen(tester);
      await tester.pumpAndSettle();
      expect(find.text('1 mesure'), findsOneWidget);

      fake.measurements = [
        spo2Reading(
            id: 'a', value: 96, at: now.subtract(const Duration(days: 1))),
        spo2Reading(
            id: 'b', value: 99, at: now.subtract(const Duration(hours: 1))),
      ];

      final historyCountBefore = fake.historyCallCount;
      // Drag the scrollable down to trigger the RefreshIndicator's onRefresh.
      await tester.drag(find.byType(ListView), const Offset(0, 400));
      await tester.pumpAndSettle();

      // A new load was triggered by pull-to-refresh...
      expect(fake.historyCallCount, greaterThan(historyCountBefore));
      // ...and the UI reflects the fresh reading count.
      expect(find.text('2 mesures'), findsOneWidget);
    });
  });

  group('skeleton -> chart transition', () {
    testWidgets('renders skeletons while loading then cards once ready',
        (tester) async {
      final completer = Completer<void>();
      fake.historyGate = completer.future;
      final now = DateTime.now();
      fake.measurements = [
        spo2Reading(
            id: 'a', value: 96, at: now.subtract(const Duration(days: 1))),
      ];

      await pumpScreen(tester);

      // While the repository await is held in flight: skeletons only.
      expect(find.byType(ClinicalChartCard), findsNothing);
      expect(find.byType(ChartCardSkeleton), findsWidgets);
      // The footer should not exist yet (no measurements shown).
      expect(find.text('1 mesure'), findsNothing);

      // Allow the load to complete.
      completer.complete();
      await tester.pumpAndSettle();

      expect(find.byType(ChartCardSkeleton), findsNothing);
      expect(find.byType(ClinicalChartCard), findsOneWidget);
      expect(find.text('1 mesure'), findsOneWidget);
    });
  });
}
