import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/core/components/charts/respi_line_chart.dart';

void main() {
  Future<void> pumpChart(WidgetTester tester, Widget chart) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: SizedBox(width: 360, child: chart)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  final samplePoints = [
    ChartPoint(value: 98, time: DateTime(2025, 1, 1, 9)),
    ChartPoint(value: 96, time: DateTime(2025, 1, 2, 9)),
    ChartPoint(value: 97, time: DateTime(2025, 1, 3, 9)),
    ChartPoint(value: 99, time: DateTime(2025, 1, 4, 9)),
  ];

  testWidgets('renders a chart without exceptions', (tester) async {
    await pumpChart(
      tester,
      RespiLineChart(points: samplePoints, unit: '%'),
    );

    expect(find.byType(RespiLineChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders an empty placeholder for no points', (tester) async {
    await pumpChart(
      tester,
      const RespiLineChart(points: [], unit: '%'),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes a semantic label summarizing the series',
      (tester) async {
    await pumpChart(
      tester,
      RespiLineChart(
        points: samplePoints,
        unit: '%',
      ),
    );

    // The chart carries an image semantic label.
    final semantics = tester.getSemantics(find.byType(RespiLineChart));
    final label = semantics.label;
    expect(label, isNotNull);
    expect(label, contains('4 mesures'));
  });

  testWidgets('honours the provided semantics label override', (tester) async {
    await pumpChart(
      tester,
      RespiLineChart(
        points: samplePoints,
        unit: '%',
        semanticsLabel: 'Courbe de saturation',
      ),
    );

    final semantics = tester.getSemantics(find.byType(RespiLineChart));
    expect(semantics.label, contains('Courbe de saturation'));
  });

  testWidgets('works for a single data point', (tester) async {
    await pumpChart(
      tester,
      RespiLineChart(
        points: [ChartPoint(value: 97, time: DateTime(2025, 1, 1, 9))],
        unit: '%',
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('safe when animation is disabled', (tester) async {
    await pumpChart(
      tester,
      RespiLineChart(
        points: samplePoints,
        unit: '%',
        enableAnimation: false,
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
