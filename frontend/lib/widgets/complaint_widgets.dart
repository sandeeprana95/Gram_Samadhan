import 'package:flutter/material.dart';

import '../models/complaint.dart';
import '../navigation/app_navigation.dart';
import '../screens/complaint_details_screen.dart';
import '../screens/officer_action_screen.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class ComplaintTile extends StatelessWidget {
  const ComplaintTile({
    super.key,
    required this.complaint,
    this.officerMode = false,
  });

  final Complaint complaint;
  final bool officerMode;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.gap),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: statusBackgroundColor(complaint.status),
          foregroundColor: statusTextColor(complaint.status),
          child: const Icon(Icons.report_rounded),
        ),
        title: Text(complaint.category),
        subtitle: Text('${complaint.id} - ${complaint.village}'),
        trailing: StatusChip(status: complaint.status),
        onTap: () => push(
          context,
          officerMode
              ? OfficerActionScreen(complaint: complaint)
              : ComplaintDetailsScreen(complaint: complaint),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final ComplaintStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusBackgroundColor(status),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(
          color: statusTextColor(status),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class SearchAndFilterBar extends StatelessWidget {
  const SearchAndFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search complaint ID',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.gap),
        IconButton.filledTonal(
          onPressed: () {},
          style: IconButton.styleFrom(
            backgroundColor: AppColors.orangeTint,
            foregroundColor: AppColors.primary,
          ),
          icon: const Icon(Icons.filter_list_rounded),
          tooltip: 'Filter',
        ),
      ],
    );
  }
}

class PhotoPreviewGrid extends StatelessWidget {
  const PhotoPreviewGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: EvidenceBox(
            label: 'Before Photo',
            icon: Icons.photo_camera_rounded,
          ),
        ),
        SizedBox(width: AppSpacing.gap),
        Expanded(
          child: EvidenceBox(
            label: 'After Photo',
            icon: Icons.add_photo_alternate_rounded,
          ),
        ),
      ],
    );
  }
}

class EvidenceBox extends StatelessWidget {
  const EvidenceBox({super.key, required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      decoration: BoxDecoration(
        color: AppColors.greenTint,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 34, color: AppColors.secondary),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const Text('Geo-tagged'),
        ],
      ),
    );
  }
}

class TimelineItem extends StatelessWidget {
  const TimelineItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
  });

  final String title;
  final String subtitle;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        color: done ? AppColors.secondary : const Color(0xFFBDBDBD),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class ComplaintSummaryCard extends StatelessWidget {
  const ComplaintSummaryCard({super.key, required this.complaint});

  final Complaint complaint;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              complaint.id,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            DetailRow(label: 'Issue', value: complaint.category),
            DetailRow(label: 'Village', value: complaint.village),
            DetailRow(label: 'Location', value: complaint.location),
            Text(complaint.description),
          ],
        ),
      ),
    );
  }
}

Color statusTextColor(ComplaintStatus status) {
  switch (status) {
    case ComplaintStatus.pending:
      return AppColors.pendingText;
    case ComplaintStatus.inProgress:
      return AppColors.inProgressText;
    case ComplaintStatus.resolved:
      return AppColors.resolvedText;
    case ComplaintStatus.rejected:
      return AppColors.rejectedText;
  }
}

Color statusBackgroundColor(ComplaintStatus status) {
  switch (status) {
    case ComplaintStatus.pending:
      return AppColors.pendingBg;
    case ComplaintStatus.inProgress:
      return AppColors.inProgressBg;
    case ComplaintStatus.resolved:
      return AppColors.resolvedBg;
    case ComplaintStatus.rejected:
      return AppColors.rejectedBg;
  }
}

// Kept for map pin coloring and any legacy usage.
Color statusColor(ComplaintStatus status) => statusTextColor(status);

String statusLabel(ComplaintStatus status) {
  switch (status) {
    case ComplaintStatus.pending:
      return 'Pending';
    case ComplaintStatus.inProgress:
      return 'In Progress';
    case ComplaintStatus.resolved:
      return 'Resolved';
    case ComplaintStatus.rejected:
      return 'Rejected';
  }
}
