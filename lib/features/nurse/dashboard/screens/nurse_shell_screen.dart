import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/colors.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../alerts/screens/alerts_screen.dart';
import '../../../communication/screens/nurse_messages_screen.dart';
import '../../patients/screens/nurse_patient_list_screen.dart';
import 'nurse_dashboard_screen.dart';
import '../../patients/screens/nurse_profile_screen.dart';

class NurseShellScreen extends ConsumerStatefulWidget {
  const NurseShellScreen({super.key});

  @override
  ConsumerState<NurseShellScreen> createState() => _NurseShellScreenState();
}

class _NurseShellScreenState extends ConsumerState<NurseShellScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;

    final screens = <Widget>[
      const NurseDashboardScreen(),
      const NursePatientListScreen(),
      const AlertsScreen(),
      const NurseMessagesScreen(),
      NurseProfileScreen(user: user),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Accueil'),
          NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Patients'),
          NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications_rounded),
              label: 'Alertes'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Messages'),
          NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profil'),
        ],
      ),
    );
  }
}
