import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class OfficerReportsScreen extends StatelessWidget {
  const OfficerReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Reports',
      showBackButton: false,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Row(
            children: const [
              Expanded(
                child: StatCard(
                  label: 'Resolved',
                  value: '18',
                  icon: Icons.task_alt_rounded,
                  color: AppColors.resolvedText,
                  backgroundColor: AppColors.greenTint,
                ),
              ),
              SizedBox(width: AppSpacing.gap),
              Expanded(
                child: StatCard(
                  label: 'Avg. Days',
                  value: '2.4',
                  icon: Icons.timer_rounded,
                  color: AppColors.inProgressText,
                  backgroundColor: AppColors.blueTint,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.screen),
          const SectionTitle(title: 'Category-wise Resolution'),
          const ReportRow(
            label: 'Road & Infrastructure',
            value: '68%',
            percent: 0.68,
          ),
          const ReportRow(
            label: 'Water & Sanitation',
            value: '74%',
            percent: 0.74,
          ),
          const ReportRow(
            label: 'Electricity & Street Light',
            value: '81%',
            percent: 0.81,
          ),
          const SizedBox(height: AppSpacing.screen),
          const ExportPanel(),
        ],
      ),
    );
  }
}
