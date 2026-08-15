import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/widgets/app_header.dart';
import 'patient_bottom_nav.dart';

/// Shared patient application shell (Step 4.11C / 4.11D / 4.11E).
///
/// Mirrors [NurseShellScreen]: one consistent header + bottom navigation for
/// every top-level patient screen, so navigation never depends on which screen
/// you happen to be on. Sub-flows (monitoring questions, rehab session, a
/// conversation thread, ...) stay as separate full-screen routes pushed on top.
class PatientAppShell extends StatelessWidget {
  const PatientAppShell({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.appBar,
  });

  final Widget child;
  final int currentIndex;
  final PreferredSizeWidget? appBar;

  static const List<String> _routes = <String>[
    '/patient/home',
    '/patient/monitoring',
    '/patient/treatment',
    '/patient/education',
    '/patient/profile',
    '/patient/messages',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: appBar ?? const AppHeader(),
      body: child,
      bottomNavigationBar: PatientBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index != currentIndex) context.go(_routes[index]);
        },
      ),
    );
  }
}
