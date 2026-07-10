import 'package:flutter/material.dart';

import 'officer_dashboard_screen.dart';
import 'officer_reports_screen.dart';
import 'officer_tasks_screen.dart';
import 'profile_screen.dart';

class OfficerShell extends StatefulWidget {
  const OfficerShell({super.key});

  @override
  State<OfficerShell> createState() => _OfficerShellState();
}

class _OfficerShellState extends State<OfficerShell> {
  int _index = 0;

  final _screens = const [
    OfficerDashboardScreen(),
    OfficerTasksScreen(),
    OfficerReportsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _screens[_index]),
        NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.task_outlined),
              selectedIcon: Icon(Icons.task_rounded),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ],
    );
  }
}
