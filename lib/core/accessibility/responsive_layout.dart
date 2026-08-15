import 'package:flutter/material.dart';
import '../theme/tokens/respi_breakpoints.dart';

/// A responsive layout builder that provides device-type callbacks.
///
/// Usage:
/// ```dart
/// ResponsiveLayout(
///   mobile: (context) => PatientListCompact(),
///   tablet: (context) => PatientListWithDetail(),
///   desktop: (context) => PatientDashboardThreePane(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= RespiBreakpoints.xl && desktop != null) {
          return desktop!(context);
        }
        if (constraints.maxWidth >= RespiBreakpoints.lg && tablet != null) {
          return tablet!(context);
        }
        return mobile(context);
      },
    );
  }
}

/// A responsive value selector.
///
/// ```dart
/// final padding = ResponsiveValue(context)
///   .when(small: 8, medium: 16, large: 24, extraLarge: 32);
/// ```
class ResponsiveValue<T> {
  ResponsiveValue(this.context);

  final BuildContext context;

  T when({
    required T small,
    T? medium,
    T? large,
    T? extraLarge,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width >= RespiBreakpoints.xl && extraLarge != null) return extraLarge;
    if (width >= RespiBreakpoints.lg && large != null) return large;
    if (width >= RespiBreakpoints.md && medium != null) return medium;
    return small;
  }
}

/// A responsive padding widget.
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.small = const EdgeInsets.all(16),
    this.medium,
    this.large,
    this.extraLarge,
  });

  final Widget child;
  final EdgeInsets small;
  final EdgeInsets? medium;
  final EdgeInsets? large;
  final EdgeInsets? extraLarge;

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveValue<EdgeInsets>(context).when(
      small: small,
      medium: medium,
      large: large,
      extraLarge: extraLarge,
    );

    return Padding(padding: padding, child: child);
  }
}

/// A responsive grid that adapts column count to screen width.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.smallCrossAxisCount = 1,
    this.mediumCrossAxisCount = 2,
    this.largeCrossAxisCount = 3,
    this.extraLargeCrossAxisCount = 4,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.padding = const EdgeInsets.all(16),
  });

  final List<Widget> children;
  final int smallCrossAxisCount;
  final int? mediumCrossAxisCount;
  final int? largeCrossAxisCount;
  final int? extraLargeCrossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveValue<int>(context).when(
      small: smallCrossAxisCount,
      medium: mediumCrossAxisCount,
      large: largeCrossAxisCount,
      extraLarge: extraLargeCrossAxisCount,
    );

    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
