import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/complaint.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/complaint_widgets.dart';

class OfficerTasksScreen extends StatelessWidget {
  const OfficerTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = complaints
        .where((c) => c.status != ComplaintStatus.resolved)
        .toList();

    return AppScaffold(
      title: 'My Tasks',
      showBackButton: false,
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screen),
        itemCount: tasks.length,
        itemBuilder: (context, index) => ComplaintTile(
          complaint: tasks[index],
          officerMode: true,
        ),
      ),
    );
  }
}
