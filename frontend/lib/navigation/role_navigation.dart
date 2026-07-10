import 'package:flutter/material.dart';

import '../models/user_role.dart';
import '../screens/admin_panel_screen.dart';
import '../screens/citizen_shell.dart';
import '../screens/officer_shell.dart';

Widget dashboardForRole(UserRole role) {
  return switch (role) {
    UserRole.citizen => const CitizenShell(),
    UserRole.officer => const OfficerShell(),
    UserRole.admin => const AdminPanelScreen(),
  };
}
