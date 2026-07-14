import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/sample_data.dart';
import '../models/complaint.dart';
import '../navigation/app_navigation.dart';
import '../theme/app_theme.dart';
import '../widgets/complaint_widgets.dart';
import 'complaint_details_screen.dart';
import 'new_complaint_screen.dart';

enum _ComplaintFilter { all, active, inProgress, done, overdue }

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  _ComplaintFilter _filter = _ComplaintFilter.all;

  static const _tabs = <(_ComplaintFilter, String)>[
    (_ComplaintFilter.all, 'All'),
    (_ComplaintFilter.active, 'Active'),
    (_ComplaintFilter.inProgress, 'In Progress'),
    (_ComplaintFilter.done, 'Done'),
    (_ComplaintFilter.overdue, 'Overdue'),
  ];

  List<Complaint> get _filtered {
    return complaints.where(_matchesFilter).toList();
  }

  bool _matchesFilter(Complaint c) {
    return switch (_filter) {
      _ComplaintFilter.all => true,
      _ComplaintFilter.active => c.status == ComplaintStatus.pending,
      _ComplaintFilter.inProgress => c.status == ComplaintStatus.inProgress,
      _ComplaintFilter.done => c.status == ComplaintStatus.resolved,
      _ComplaintFilter.overdue => _isOverdue(c),
    };
  }

  /// Open complaints older than 7 days are treated as overdue.
  bool _isOverdue(Complaint c) {
    if (c.status == ComplaintStatus.resolved ||
        c.status == ComplaintStatus.rejected) {
      return false;
    }
    final filed = _parseDate(c.date);
    if (filed == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(filed).inDays > 7;
  }

  DateTime? _parseDate(String date) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    final parts = date.trim().split(RegExp(r'\s+'));
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = months[parts[1]];
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

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
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.screen),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screen,
                        ),
                        itemCount: _tabs.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final (value, label) = _tabs[index];
                          return _FilterPill(
                            label: label,
                            selected: _filter == value,
                            onTap: () => setState(() => _filter = value),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No complaints in this filter',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.screen,
                                AppSpacing.gap,
                                AppSpacing.screen,
                                AppSpacing.screen,
                              ),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppSpacing.gap),
                              itemBuilder: (context, index) {
                                final complaint = filtered[index];
                                return _MyComplaintCard(
                                  complaint: complaint,
                                  onTap: () => push(
                                    context,
                                    ComplaintDetailsScreen(
                                      complaint: complaint,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
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

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected ? AppGradients.header : null,
            color: selected ? null : AppColors.greyBg,
            borderRadius: BorderRadius.circular(20),
            border: selected
                ? null
                : Border.all(color: AppColors.border, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF616161),
            ),
          ),
        ),
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
                  ComplaintStatusRow(complaint: complaint),
                ],
              ),
              const SizedBox(height: 8),
              ComplaintAssetMetaRow(complaint: complaint),
              const SizedBox(height: 6),
              Text(
                complaint.id,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
