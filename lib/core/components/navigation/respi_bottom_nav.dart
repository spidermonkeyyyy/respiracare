import 'package:flutter/material.dart';

/// Role-aware bottom navigation with large touch targets.
///
/// Patient tabs: Home, Monitoring, Messages, Profile
/// Nurse tabs: Dashboard, Patients, Tasks, Alerts, Profile
class RespiBottomNav extends StatelessWidget {
  const RespiBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<RespiBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: cs.surface,
      elevation: 0,
      indicatorColor: cs.primaryContainer,
      destinations: items
          .map((item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.activeIcon ?? item.icon),
                label: item.label,
                tooltip: item.label,
              ))
          .toList(),
    );
  }
}

class RespiBottomNavItem {
  const RespiBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
}
