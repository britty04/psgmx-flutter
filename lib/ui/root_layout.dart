import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'home/home_screen.dart';
import 'tasks/tasks_screen.dart';
import 'attendance/attendance_screen.dart';
import 'reports/reports_screen.dart';
import 'profile/profile_screen.dart';

class RootLayout extends StatefulWidget {
  const RootLayout({super.key});

  @override
  State<RootLayout> createState() => _RootLayoutState();
}

class _RootLayoutState extends State<RootLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Dynamic Screen List based on Role
    final screens = [
      const HomeScreen(),
      const TasksScreen(),
      const AttendanceScreen(),
      if (userProvider.isCoordinator || userProvider.isPlacementRep || userProvider.hasActualAdminAccess) 
        const ReportsScreen(),
      const ProfileScreen(),
    ];

    // Dynamic Navigation Items
    final navItems = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined), 
        selectedIcon: Icon(Icons.home), 
        label: 'Home'
      ),
      const NavigationDestination(
        icon: Icon(Icons.task_alt_outlined), 
        selectedIcon: Icon(Icons.task_alt), 
        label: 'Tasks'
      ),
      const NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined), 
        selectedIcon: Icon(Icons.calendar_month), 
        label: 'Attendance'
      ),
      if (userProvider.isCoordinator || userProvider.isPlacementRep || userProvider.hasActualAdminAccess)
        const NavigationDestination(
          icon: Icon(Icons.analytics_outlined), 
          selectedIcon: Icon(Icons.analytics), 
          label: 'Reports'
        ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline), 
        selectedIcon: Icon(Icons.person), 
        label: 'Profile'
      ),
    ];

    // Safety check for index
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    // Root Scaffolding (BottomNav Only)
    // Child screens provide their own Scaffold + AppBar
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: navItems,
      ),
    );
  }
}
