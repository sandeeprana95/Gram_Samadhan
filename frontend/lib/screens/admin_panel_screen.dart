import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/complaint.dart';
import '../navigation/app_navigation.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    pushReplacement(context, const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    final pending = complaints
        .where((c) => c.status == ComplaintStatus.pending)
        .length;
    final inProgress = complaints
        .where((c) => c.status == ComplaintStatus.inProgress)
        .length;
    final resolved = complaints
        .where((c) => c.status == ComplaintStatus.resolved)
        .length;

    return AppScaffold(
      title: 'Panchayat Admin',
      subtitle: 'Bhondsi Block · Grievance Monitoring',
      showBackButton: false,
      actions: [
        IconButton(
          tooltip: 'Logout',
          onPressed: () => _logout(context),
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Pending',
                  value: pending.toString().padLeft(2, '0'),
                  icon: Icons.pending_actions_rounded,
                  color: AppColors.pendingText,
                  backgroundColor: AppColors.orangeTint,
                ),
              ),
              const SizedBox(width: AppSpacing.gap),
              Expanded(
                child: StatCard(
                  label: 'In Progress',
                  value: inProgress.toString().padLeft(2, '0'),
                  icon: Icons.autorenew_rounded,
                  color: AppColors.inProgressText,
                  backgroundColor: AppColors.blueTint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Resolved',
                  value: resolved.toString().padLeft(2, '0'),
                  icon: Icons.check_circle_rounded,
                  color: AppColors.resolvedText,
                  backgroundColor: AppColors.greenTint,
                ),
              ),
              const SizedBox(width: AppSpacing.gap),
              const Expanded(
                child: StatCard(
                  label: 'Officers',
                  value: '12',
                  icon: Icons.groups_rounded,
                  color: AppColors.inProgressText,
                  backgroundColor: AppColors.blueTint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Performance Reports'),
          ReportRow(
            label: 'Road & Infrastructure',
            value: '68%',
            percent: 0.68,
          ),
          ReportRow(
            label: 'Water & Sanitation',
            value: '74%',
            percent: 0.74,
          ),
          ReportRow(
            label: 'Electricity & Street Light',
            value: '81%',
            percent: 0.81,
          ),
          const SizedBox(height: 16),
          const ExportPanel(),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Management'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.person_add_outlined),
                  title: Text('Manage Officers'),
                  trailing: Icon(Icons.chevron_right),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.category_outlined),
                  title: Text('Complaint Categories'),
                  trailing: Icon(Icons.chevron_right),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('System Settings'),
                  trailing: Icon(Icons.chevron_right),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.logout_rounded,
                    color: AppColors.rejectedText,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: AppColors.rejectedText),
                  ),
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
