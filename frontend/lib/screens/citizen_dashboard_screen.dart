import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/complaint.dart';
import '../navigation/app_navigation.dart';
import '../services/complaint_api.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/complaint_widgets.dart';
import 'complaint_map_screen.dart';
import 'complaint_details_screen.dart';
import 'my_complaints_screen.dart';
import 'new_complaint_screen.dart';
import 'notification_screen.dart';
import 'asset_survey_screen.dart';

class CitizenDashboardScreen extends StatefulWidget {
  const CitizenDashboardScreen({super.key});

  @override
  State<CitizenDashboardScreen> createState() =>
      _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState extends State<CitizenDashboardScreen> {
  List<Complaint> _recentComplaints = [];
  bool _loadingRecent = true;

  @override
  void initState() {
    super.initState();
    _loadRecentComplaints();
  }

  Future<void> _loadRecentComplaints() async {
    setState(() => _loadingRecent = true);
    try {
      final complaints = await ComplaintApi.getMine();
      if (!mounted) return;
      setState(() => _recentComplaints = complaints.take(2).toList());
    } catch (_) {
      // Keep showing whatever we already had.
    } finally {
      if (mounted) setState(() => _loadingRecent = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentComplaints = _recentComplaints;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _DashboardHeader(
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.screen + 4,
                    AppSpacing.screen,
                    AppSpacing.gap,
                  ),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Pending',
                          value: '08',
                          icon: Icons.hourglass_empty_rounded,
                          color: AppColors.pendingText,
                          backgroundColor: AppColors.orangeTint,
                        ),
                      ),
                      SizedBox(width: AppSpacing.gap),
                      Expanded(
                        child: StatCard(
                          label: 'Resolved',
                          value: '42',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.resolvedText,
                          backgroundColor: AppColors.greenTint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.screen),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSpacing.gap,
                    mainAxisSpacing: AppSpacing.gap,
                    childAspectRatio: 1.15,
                    children: [
                      _QuickActionCard(
                        icon: Icons.add_circle_rounded,
                        label: 'New Complaint',
                        color: AppColors.primary,
                        background: AppColors.orangeTint,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const NewComplaintScreen(),
                            ),
                          );
                          _loadRecentComplaints();
                        },
                      ),
                      _QuickActionCard(
                        icon: Icons.assignment_rounded,
                        label: 'My Complaints',
                        color: AppColors.inProgressText,
                        background: AppColors.blueTint,
                        onTap: () => push(context, const MyComplaintsScreen()),
                      ),
                      _QuickActionCard(
                        icon: Icons.poll_rounded,
                        label: 'Survey',
                        color: AppColors.secondary,
                        background: AppColors.greenTint,
                        onTap: () => push(context, const AssetSurveyScreen()),
                      ),
                      _QuickActionCard(
                        icon: Icons.map_rounded,
                        label: 'GIS Map',
                        color: AppColors.pendingText,
                        background: AppColors.orangeTint,
                        onTap: () => push(context, const ComplaintMapScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.screen),
                  Text(
                    'Recent complaints',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gap),
                  if (_loadingRecent)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (recentComplaints.isEmpty)
                    Text(
                      'No complaints filed yet',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ...recentComplaints.map(
                    (item) => _RecentComplaintRow(
                      complaint: item,
                      onTap: () => push(
                        context,
                        ComplaintDetailsScreen(complaint: item),
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.onNotificationTap,
  });

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
          Expanded(
            child: Text(
              'नमस्ते 👋',
              style: GoogleFonts.notoSansDevanagari(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
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

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: background,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: const Color(0xFF212121),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentComplaintRow extends StatelessWidget {
  const _RecentComplaintRow({
    required this.complaint,
    required this.onTap,
  });

  final Complaint complaint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.gap),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      complaint.category,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      complaint.date,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(status: complaint.status),
            ],
          ),
        ),
      ),
    );
  }
}
