import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/complaint.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/complaint_widgets.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  const ComplaintDetailsScreen({super.key, required this.complaint});

  final Complaint complaint;

  @override
  Widget build(BuildContext context) {
    final officerParts = _officerParts(complaint.officer);
    final timeline = _timelineStages(complaint);

    return AppScaffold(
      title: complaint.id,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        complaint.category,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF212121),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ComplaintStatusRow(complaint: complaint),
                  ],
                ),
                const SizedBox(height: 10),
                ComplaintAssetMetaRow(complaint: complaint),
                const SizedBox(height: AppSpacing.screen),
                const Row(
                  children: [
                    Expanded(
                      child: _PhotoPlaceholder(
                        label: 'Before Photo',
                        icon: Icons.photo_camera_rounded,
                      ),
                    ),
                    SizedBox(width: AppSpacing.gap),
                    Expanded(
                      child: _PhotoPlaceholder(
                        label: 'After Photo',
                        icon: Icons.add_photo_alternate_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.screen),
                Text(
                  'Description',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  complaint.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.5,
                    color: const Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: AppSpacing.screen),
                Text(
                  'Timeline',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        for (var i = 0; i < timeline.length; i++)
                          _TimelineStage(
                            title: timeline[i].title,
                            timestamp: timeline[i].timestamp,
                            done: timeline[i].done,
                            isLast: i == timeline.length - 1,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _OfficerFooter(
            name: officerParts.$1,
            designation: officerParts.$2,
          ),
        ],
      ),
    );
  }

  (String, String) _officerParts(String officer) {
    if (officer == 'Not assigned') {
      return ('Not assigned', 'Awaiting assignment');
    }
    final parts = officer.split(',');
    if (parts.length >= 2) {
      return (parts[0].trim(), parts.sublist(1).join(',').trim());
    }
    return (officer, 'Field Officer');
  }

  List<_TimelineData> _timelineStages(Complaint complaint) {
    final assigned = complaint.status != ComplaintStatus.pending;
    final siteVisitDone = complaint.status == ComplaintStatus.resolved;

    return [
      _TimelineData(
        title: 'Registered',
        timestamp: '${complaint.date} · 10:24 AM',
        done: true,
      ),
      _TimelineData(
        title: 'Assigned',
        timestamp: assigned
            ? '${complaint.date} · 02:15 PM'
            : 'Pending assignment',
        done: assigned,
      ),
      _TimelineData(
        title: 'Site visit pending',
        timestamp: siteVisitDone
            ? 'Completed'
            : assigned
                ? 'Scheduled soon'
                : 'Waiting',
        done: siteVisitDone,
      ),
    ];
  }
}

class _TimelineData {
  const _TimelineData({
    required this.title,
    required this.timestamp,
    required this.done,
  });

  final String title;
  final String timestamp;
  final bool done;
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.greyBg,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: const Color(0xFF9E9E9E)),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStage extends StatelessWidget {
  const _TimelineStage({
    required this.title,
    required this.timestamp,
    required this.done,
    required this.isLast,
  });

  final String title;
  final String timestamp;
  final bool done;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dotColor = done ? AppColors.secondary : const Color(0xFFBDBDBD);
    final lineColor = done ? AppColors.greenTint : AppColors.greyBg;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: done ? AppColors.greenTint : AppColors.greyBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: dotColor, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: done
                          ? const Color(0xFF212121)
                          : const Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficerFooter extends StatelessWidget {
  const _OfficerFooter({
    required this.name,
    required this.designation,
  });

  final String name;
  final String designation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screen,
        vertical: 14,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.orangeTint,
            child: Text(
              name.isNotEmpty && name != 'Not assigned'
                  ? name[0].toUpperCase()
                  : '?',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
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
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  designation,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
