import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/core/accessibility/accessibility_config.dart';
import 'package:respiracare/core/accessibility/color_blind_safe.dart';
import 'package:respiracare/core/accessibility/focus_manager.dart';
import 'package:respiracare/core/accessibility/responsive_layout.dart';
import 'package:respiracare/core/accessibility/semantics_extensions.dart';
import 'package:respiracare/core/accessibility/text_scale_provider.dart';
import 'package:respiracare/core/accessibility/touch_target_enforcer.dart';
import 'package:respiracare/core/components/buttons/respi_icon_button.dart';

import 'accessibility_test_helpers.dart';

void main() {
  group('Accessibility & Responsive Foundation Tests', () {
    testWidgets('Touch target size and tap area enforcer', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TouchTargetEnforcer(
                child: Container(width: 20, height: 20, color: Colors.blue),
              ),
            ),
          ),
        ),
      );

      // Verify that the enforced size matches 48dp minimum
      AccessibilityTestHelpers.expectMinimumSize(
        tester,
        find.byType(TouchTargetEnforcer),
        AccessibilityConfig.minTouchTarget,
      );
    });

    testWidgets('RespiIconButton accessibility properties', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RespiIconButton(
                icon: Icons.add,
                semanticLabel: 'Add patient',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(RespiIconButton);
      AccessibilityTestHelpers.expectSemanticLabel(tester, buttonFinder, 'Add patient');
      AccessibilityTestHelpers.expectSemanticButton(tester, buttonFinder);
      AccessibilityTestHelpers.expectMinimumSize(tester, buttonFinder, AccessibilityConfig.minTapArea);

      await tester.tap(buttonFinder);
      expect(pressed, isTrue);
    });

    testWidgets('ColorBlindSafe AccessibleStatusIndicator configuration', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AccessibleStatusIndicator(status: RespiStatus.normal),
                AccessibleStatusIndicator(status: RespiStatus.critical),
              ],
            ),
          ),
        ),
      );

      // Verify normal status shows normal text and success icon
      expect(find.text(ColorBlindSafe.labelSuccess), findsOneWidget);
      expect(find.byIcon(ColorBlindSafe.iconSuccess), findsOneWidget);

      // Verify critical status shows critical text and error icon
      expect(find.text(ColorBlindSafe.labelError), findsOneWidget);
      expect(find.byIcon(ColorBlindSafe.iconError), findsOneWidget);
    });

    testWidgets('SemanticsX Extensions work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Heading text').semanticHeading(level: 1),
          ),
        ),
      );

      AccessibilityTestHelpers.expectSemanticHeader(tester, find.text('Heading text'));
    });

    testWidgets('ResponsiveLayout builder matches mobile breakpoint', (WidgetTester tester) async {
      // Set a mobile screen size width
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayout(
            mobile: (context) => const Text('Mobile view'),
            tablet: (context) => const Text('Tablet view'),
            desktop: (context) => const Text('Desktop view'),
          ),
        ),
      );

      expect(find.text('Mobile view'), findsOneWidget);
      expect(find.text('Tablet view'), findsNothing);

      // Reset test view size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('ConstrainedTextScale clamps system text scale', (WidgetTester tester) async {
      // Simulate extreme text scale above 2.0 maximum
      const double largeScale = 3.0;

      MediaQueryData? capturedQuery;

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(largeScale),
              ),
              child: ConstrainedTextScale(
                child: Builder(
                  builder: (context) {
                    capturedQuery = MediaQuery.of(context);
                    return child ?? const SizedBox.shrink();
                  },
                ),
              ),
            );
          },
          home: const SizedBox.shrink(),
        ),
      );

      // ConstrainedTextScale should clamp 3.0 down to maxTextScaleFactor (2.0)
      final scale = capturedQuery?.textScaler.scale(1.0);
      expect(scale, lessThanOrEqualTo(AccessibilityConfig.maxTextScaleFactor));
      expect(scale, greaterThanOrEqualTo(AccessibilityConfig.minTextScaleFactor));
    });

    testWidgets('Keyboard focus traversal helper structure', (WidgetTester tester) async {
      final FocusNode node1 = FocusNode();
      final FocusNode node2 = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RespiFocusManager.formTraversal(
              children: [
                Focus(focusNode: node1, child: const SizedBox(height: 10)),
                Focus(focusNode: node2, child: const SizedBox(height: 10)),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FocusTraversalGroup), findsAtLeastNWidgets(1));

      node1.dispose();
      node2.dispose();
    });
  });
}
