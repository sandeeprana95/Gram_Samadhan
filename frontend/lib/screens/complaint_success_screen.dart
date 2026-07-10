import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/complaint.dart';
import '../navigation/app_navigation.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/complaint_widgets.dart';
import 'complaint_details_screen.dart';

class ComplaintSuccessScreen extends StatelessWidget {
  const ComplaintSuccessScreen({super.key, required this.complaint});

  final Complaint complaint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.header,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 52,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'शिकायत सफलतापूर्वक दर्ज हुई',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF212121),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Complaint ID: ${complaint.id}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF616161),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.greyBg,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    Text(
                      'Status',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF616161),
                      ),
                    ),
                    const Spacer(),
                    StatusChip(status: complaint.status),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  onPressed: () => push(
                    context,
                    ComplaintDetailsScreen(complaint: complaint),
                  ),
                  label: 'View complaint',
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.gap),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF616161),
                    minimumSize: const Size.fromHeight(52),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Back to dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
