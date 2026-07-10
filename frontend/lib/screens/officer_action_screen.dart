import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/complaint.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class OfficerActionScreen extends StatefulWidget {
  const OfficerActionScreen({super.key, required this.complaint});

  final Complaint complaint;

  @override
  State<OfficerActionScreen> createState() => _OfficerActionScreenState();
}

class _OfficerActionScreenState extends State<OfficerActionScreen> {
  final _remarksController = TextEditingController();

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _close(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.complaint.id} $action')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(title: '${complaint.id} · Action'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          _CitizenInfoCard(
            name: 'Ramesh Kumar',
            phone: '+91 98765 43210',
            address: '${complaint.village}, Gurugram, Haryana',
          ),
          const SizedBox(height: AppSpacing.screen),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              onPressed: () => _close('navigation started'),
              label: 'Navigate',
              icon: Icons.navigation_rounded,
            ),
          ),
          const SizedBox(height: AppSpacing.screen),
          _SectionLabel('Site Photos'),
          const SizedBox(height: AppSpacing.gap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(child: _BeforePhotoTile()),
              SizedBox(width: AppSpacing.gap),
              Expanded(child: _AfterPhotoTile()),
            ],
          ),
          const SizedBox(height: AppSpacing.screen),
          _SectionLabel('Remarks'),
          const SizedBox(height: AppSpacing.gap),
          TextField(
            controller: _remarksController,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Add resolution remarks or reason for rejection...',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _close('marked as rejected'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rejectedText,
                    side: const BorderSide(color: AppColors.rejectedText),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Reject'),
                ),
              ),
              const SizedBox(width: AppSpacing.gap),
              Expanded(
                child: GradientButton(
                  onPressed: () => _close('marked as resolved'),
                  label: 'Resolve',
                  icon: Icons.check_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF212121),
      ),
    );
  }
}

class _CitizenInfoCard extends StatelessWidget {
  const _CitizenInfoCard({
    required this.name,
    required this.phone,
    required this.address,
  });

  final String name;
  final String phone;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.orangeTint,
              foregroundColor: AppColors.primary,
              child: Icon(Icons.person_rounded, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _InfoLine(icon: Icons.phone_rounded, text: phone),
                  const SizedBox(height: 2),
                  _InfoLine(icon: Icons.location_on_rounded, text: address),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF616161),
            ),
          ),
        ),
      ],
    );
  }
}

class _BeforePhotoTile extends StatelessWidget {
  const _BeforePhotoTile();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Before',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.greyBg,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_rounded,
            size: 34,
            color: Color(0xFFBDBDBD),
          ),
        ),
      ],
    );
  }
}

class _AfterPhotoTile extends StatelessWidget {
  const _AfterPhotoTile();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'After',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 6),
        CustomPaint(
          painter: _DashedBorderPainter(
            color: const Color(0xFFBDBDBD),
            radius: AppRadius.button,
          ),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(AppRadius.button),
            child: Container(
              height: 110,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo_rounded,
                    size: 30,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add photo',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF616161),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
