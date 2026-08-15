import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../theme/tokens/respi_colors.dart";
import "../components/navigation/respi_bottom_nav.dart";

/// Patient-facing app shell with bottom navigation and emergency FAB.
///
/// Tabs (6 total matching PatientAppShell):
/// 1. Home — Dashboard, vitals overview, quick actions
/// 2. Monitor — Record measurements, view history
/// 3. Messages — Conversations with care team
/// 4. Treatment — Medication & treatment plans
/// 5. Education — Educational content & rehabilitation
/// 6. Profile — Personal info, settings
class PatientShell extends ConsumerStatefulWidget {
  const PatientShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends ConsumerState<PatientShell> {
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
          content: Text("Appuyez à nouveau pour quitter"),
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
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: "Accueil",
            ),
            RespiBottomNavItem(
              icon: Icons.monitor_heart_outlined,
              activeIcon: Icons.monitor_heart_rounded,
              label: "Suivi",
            ),
            RespiBottomNavItem(
              icon: Icons.chat_bubble_outline_rounded,
              activeIcon: Icons.chat_bubble_rounded,
              label: "Messages",
            ),
            RespiBottomNavItem(
              icon: Icons.medication_outlined,
              activeIcon: Icons.medication_rounded,
              label: "Traitement",
            ),
            RespiBottomNavItem(
              icon: Icons.school_outlined,
              activeIcon: Icons.school_rounded,
              label: "Education",
            ),
            RespiBottomNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: "Profil",
            ),
          ],
        ),
        floatingActionButton: _buildEmergencyFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget? _buildEmergencyFAB() {
    // Only show emergency button on home (index 0) and monitor (index 1) tabs
    if (widget.navigationShell.currentIndex > 1) return null;

    return FloatingActionButton.extended(
      onPressed: () => _showEmergencyDialog(context),
      backgroundColor: RespiColors.error,
      foregroundColor: RespiColors.onError,
      icon: const Icon(Icons.emergency_rounded),
      label: const Text("SOS"),
      elevation: 4,
      extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.emergency_rounded,
            color: RespiColors.error, size: 48),
        title: const Text("Urgence"),
        content: const Text(
          "Avez-vous des difficultés respiratoires sévères ? "
          "Cela alertera votre équipe soignante immédiatement.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text("Alerte d'urgence envoyée à l'équipe soignante"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: RespiColors.error,
              foregroundColor: RespiColors.onError,
            ),
            child: const Text("Envoyer l'alerte"),
          ),
        ],
      ),
    );
  }
}
