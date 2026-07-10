import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/sample_data.dart';
import '../models/complaint.dart';
import '../navigation/app_navigation.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/complaint_widgets.dart';
import 'notification_screen.dart';
import 'officer_action_screen.dart';

class OfficerDashboardScreen extends StatelessWidget {
  const OfficerDashboardScreen({super.key});

  static const _distances = ['1.2 km away', '3.6 km away', '2.1 km away'];

  @override
  Widget build(BuildContext context) {
    final pending = complaints
        .where((c) => c.status == ComplaintStatus.pending)
        .length;
    final assigned = complaints
        .where((c) => c.status != ComplaintStatus.resolved)
        .length;
    final completed = complaints
        .where((c) => c.status == ComplaintStatus.resolved)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _OfficerHeader(
            name: 'Rajesh Kumar',
            designation: 'Junior Engineer · Bhondsi Block',
            onNotificationTap: () => push(context, const NotificationScreen()),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.screen + 4,
                    AppSpacing.screen,
                    AppSpacing.screen,
                  ),
                  children: [
                Row(
                  children: [
                    Expanded(
                      child: _OfficerStat(
                        label: 'Pending',
                        value: pending.toString().padLeft(2, '0'),
                        icon: Icons.hourglass_empty_rounded,
                        color: AppColors.pendingText,
                        background: AppColors.orangeTint,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.gap),
                    Expanded(
                      child: _OfficerStat(
                        label: 'Assigned',
                        value: assigned.toString().padLeft(2, '0'),
                        icon: Icons.assignment_rounded,
                        color: AppColors.inProgressText,
                        background: AppColors.blueTint,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.gap),
                    Expanded(
                      child: _OfficerStat(
                        label: 'Completed',
                        value: completed.toString().padLeft(2, '0'),
                        icon: Icons.task_alt_rounded,
                        color: AppColors.resolvedText,
                        background: AppColors.greenTint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.screen),
                Text(
                  "Today's Complaints",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: AppSpacing.gap),
                ...complaints.asMap().entries.map((entry) {
                  final complaint = entry.value;
                  return _OfficerTaskCard(
                    complaint: complaint,
                    distance: _distances[entry.key % _distances.length],
                    onAction: () => push(
                      context,
                      OfficerActionScreen(complaint: complaint),
                    ),
                  );
                }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficerHeader extends StatelessWidget {
  const _OfficerHeader({
    required this.name,
    required this.designation,
    required this.onNotificationTap,
  });

  final String name;
  final String designation;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        topPadding + 12,
        AppSpacing.screen,
        28,
      ),
      decoration: const BoxDecoration(gradient: AppGradients.header),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withValues(alpha: 0.22),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'O',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  designation,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFFF3E0),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNotificationTap,
            icon: const Icon(Icons.notifications_rounded, color: Colors.white),
            tooltip: 'Notifications',
          ),
        ],
      ),
    );
  }
}

class _OfficerStat extends StatelessWidget {
  const _OfficerStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF616161),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficerTaskCard extends StatelessWidget {
  const _OfficerTaskCard({
    required this.complaint,
    required this.distance,
    required this.onAction,
  });

  final Complaint complaint;
  final String distance;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final isPending = complaint.status == ComplaintStatus.pending;
    final actionLabel = isPending ? 'Accept' : 'Navigate';
    final actionIcon = isPending ? Icons.check_rounded : Icons.navigation_rounded;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.gap),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    complaint.category,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatusChip(status: complaint.status),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.near_me_rounded,
                  size: 15,
                  color: Color(0xFF9E9E9E),
                ),
                const SizedBox(width: 4),
                Text(
                  '${complaint.village} · $distance',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF757575),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                onPressed: onAction,
                label: actionLabel,
                icon: actionIcon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
