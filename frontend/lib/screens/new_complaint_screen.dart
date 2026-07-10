import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/complaint.dart';
import '../navigation/app_navigation.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'complaint_success_screen.dart';

class NewComplaintScreen extends StatefulWidget {
  const NewComplaintScreen({super.key});

  @override
  State<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends State<NewComplaintScreen> {
  static const _categories = [
    'Damaged Road',
    'Street Light',
    'Drainage',
    'Water Supply',
    'Cleanliness',
    'Illegal Encroachment',
  ];

  static const _villages = ['Bhondsi', 'Sohna', 'Badshahpur', 'Gurugram'];
  static const _panchayats = [
    'Bhondsi Gram Panchayat',
    'Sohna Gram Panchayat',
    'Badshahpur Gram Panchayat',
  ];

  String _category = _categories.first;
  String _village = _villages.first;
  String _panchayat = _panchayats.first;
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final complaint = Complaint(
      id: 'PG-2026-0149',
      category: _category,
      village: _village,
      description: _descriptionController.text.trim().isEmpty
          ? 'Complaint registered from mobile app.'
          : _descriptionController.text.trim(),
      date: '08 Jul 2026',
      status: ComplaintStatus.pending,
      officer: 'Not assigned',
      location: '28.3521, 77.0642',
    );

    pushReplacement(
      context,
      ComplaintSuccessScreen(complaint: complaint),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'New Complaint',
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDropdown(
                    label: 'Category',
                    value: _category,
                    icon: Icons.category_rounded,
                    items: _categories,
                    onChanged: (value) {
                      if (value != null) setState(() => _category = value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.gap),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Village',
                          value: _village,
                          icon: Icons.home_work_rounded,
                          items: _villages,
                          compact: true,
                          onChanged: (value) {
                            if (value != null) setState(() => _village = value);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.gap),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Panchayat',
                          value: _panchayat,
                          icon: Icons.account_balance_rounded,
                          items: _panchayats,
                          compact: true,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _panchayat = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.gap),
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF616161),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    minLines: 4,
                    maxLines: 6,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: 'Describe the issue in detail...',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.screen),
                  Text(
                    'Attachments',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF616161),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gap),
                  const Row(
                    children: [
                      Expanded(
                        child: _AttachmentTile(
                          icon: Icons.photo_camera_rounded,
                          label: 'Photo',
                        ),
                      ),
                      SizedBox(width: AppSpacing.gap),
                      Expanded(
                        child: _AttachmentTile(
                          icon: Icons.my_location_rounded,
                          label: 'GPS',
                        ),
                      ),
                      SizedBox(width: AppSpacing.gap),
                      Expanded(
                        child: _AttachmentTile(
                          icon: Icons.mic_rounded,
                          label: 'Voice note',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.gap),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greyBg,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: Color(0xFF757575),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '28.3521, 77.0642 — Bhondsi, Gurugram',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF616161),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.gapSm,
              AppSpacing.screen,
              AppSpacing.screen,
            ),
            child: GradientButton(
              onPressed: _submit,
              label: 'Submit complaint',
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool compact = false,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      isDense: compact,
      initialValue: value,
      style: GoogleFonts.poppins(
        fontSize: compact ? 13 : 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF212121),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: compact ? 12 : 14),
        prefixIcon: compact
            ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(icon, color: const Color(0xFF9E9E9E), size: 20),
              )
            : Icon(icon, color: const Color(0xFF9E9E9E)),
        prefixIconConstraints: compact
            ? const BoxConstraints(minWidth: 36, maxWidth: 36)
            : null,
        contentPadding: compact
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
      selectedItemBuilder: (context) {
        return items.map((item) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }).toList();
      },
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: const Color(0xFFBDBDBD),
        radius: AppRadius.button,
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          height: 88,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
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
