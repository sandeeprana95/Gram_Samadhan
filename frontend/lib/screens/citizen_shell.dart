import 'package:flutter/material.dart';

import 'citizen_dashboard_screen.dart';
import 'complaint_map_screen.dart';
import 'my_complaints_screen.dart';
import 'profile_screen.dart';

class CitizenShell extends StatefulWidget {
  const CitizenShell({super.key});

  @override
  State<CitizenShell> createState() => _CitizenShellState();
}

class _CitizenShellState extends State<CitizenShell> {
  int _index = 0;

  final _screens = const [
    CitizenDashboardScreen(),
    MyComplaintsScreen(),
    ComplaintMapScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 24),
            selectedIcon: Icon(Icons.home_rounded, size: 24),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined, size: 24),
            selectedIcon: Icon(Icons.assignment_rounded, size: 24),
            label: 'Complaints',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined, size: 24),
            selectedIcon: Icon(Icons.map_rounded, size: 24),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, size: 24),
            selectedIcon: Icon(Icons.person_rounded, size: 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
