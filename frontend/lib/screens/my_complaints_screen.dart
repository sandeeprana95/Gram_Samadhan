import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/sample_data.dart';
import '../models/complaint.dart';
import '../navigation/app_navigation.dart';
import '../theme/app_theme.dart';
import '../widgets/complaint_widgets.dart';
import 'complaint_details_screen.dart';
import 'new_complaint_screen.dart';

class MyComplaintsScreen extends StatelessWidget {
  const MyComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF57C00), Color(0xFF2E7D32)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: 'my_complaints_fab',
            onPressed: () => push(context, const NewComplaintScreen()),
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
      body: Column(
        children: [
          const _MyComplaintsHeader(),
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
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.screen + 4,
                    AppSpacing.screen,
                    AppSpacing.screen,
                  ),
                  itemCount: complaints.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.gap),
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    return _MyComplaintCard(
                      complaint: complaint,
                      onTap: () => push(
                        context,
                        ComplaintDetailsScreen(complaint: complaint),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyComplaintsHeader extends StatelessWidget {
  const _MyComplaintsHeader();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Complaints',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: GoogleFonts.poppins(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Search complaint ID or title',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.22),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.gap),
              Material(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(AppRadius.button),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MyComplaintCard extends StatelessWidget {
  const _MyComplaintCard({
    required this.complaint,
    required this.onTap,
  });

  final Complaint complaint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
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
                        color: const Color(0xFF212121),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(status: complaint.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${complaint.id} · ${_relativeDate(complaint.date)}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF757575),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeDate(String date) {
    return switch (date) {
      '06 Jul 2026' => '2 days ago',
      '04 Jul 2026' => '4 days ago',
      '29 Jun 2026' => '9 days ago',
      '08 Jul 2026' => 'Today',
      _ => date,
    };
  }
}
