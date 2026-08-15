import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens/respi_colors.dart';
import '../components/navigation/respi_bottom_nav.dart';
import '../components/feedback/respi_badge.dart';

/// Nurse-facing app shell with bottom navigation and alert badge.
///
/// Tabs:
/// 1. Dashboard — Caseload overview, urgent items
/// 2. Patients — Assigned patient list
/// 3. Tasks — Monitoring tasks, to-do items
/// 4. Alerts — Triage notifications
/// 5. Profile — Nurse info, settings
class NurseShell extends ConsumerStatefulWidget {
  const NurseShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<NurseShell> createState() => _NurseShellState();
}

class _NurseShellState extends ConsumerState<NurseShell> {
  DateTime? _lastBackPress;

  void _handleBackPress(BuildContext context) {
    final now = DateTime.now();

    if (_lastBackPress != null &&
        now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
    } else {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appuyez à nouveau pour quitter'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? RespiColors.backgroundDark : RespiColors.background;

    // TODO: Connect to real alert count provider
    const alertCount = 3;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: widget.navigationShell,
        bottomNavigationBar: RespiBottomNav(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: (index) => widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          ),
          items: const [
            RespiBottomNavItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard_rounded,
              label: 'Tableau de bord',
            ),
            RespiBottomNavItem(
              icon: Icons.people_outline_rounded,
              activeIcon: Icons.people_rounded,
              label: 'Patients',
            ),
            RespiBottomNavItem(
              icon: Icons.checklist_outlined,
              activeIcon: Icons.checklist_rounded,
              label: 'Tâches',
            ),
            RespiBottomNavItem(
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications_rounded,
              label: 'Alertes',
              badge: alertCount > 0
                  ? RespiBadge(
                      label: '$alertCount',
                      isDot: false,
                      variant: alertCount > 5
                          ? RespiBadgeVariant.error
                          : RespiBadgeVariant.warning,
                    )
                  : null,
            ),
            RespiBottomNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
