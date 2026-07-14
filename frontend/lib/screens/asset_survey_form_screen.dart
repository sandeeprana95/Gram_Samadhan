import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/survey.dart';
import '../services/survey_api.dart';
import '../theme/app_theme.dart';

const List<String> kHaryanaDistricts = [
  'Ambala',
  'Bhiwani',
  'Charkhi Dadri',
  'Faridabad',
  'Fatehabad',
  'Gurugram',
  'Hisar',
  'Jhajjar',
  'Jind',
  'Kaithal',
  'Karnal',
  'Kurukshetra',
  'Mahendragarh',
  'Nuh',
  'Palwal',
  'Panchkula',
  'Panipat',
  'Rewari',
  'Rohtak',
  'Sirsa',
  'Sonipat',
  'Yamunanagar',
];

const List<String> kConditionRatings = [
  '1 - Poor',
  '2 - Fair',
  '3 - Good',
  '4 - Very Good',
  '5 - Excellent',
];

const List<String> kFunctionalStatuses = [
  'Active',
  'Inactive',
  'Under Repair',
  'Non-Functional',
];

const List<String> kPrInstitutionLevels = [
  'Gram Panchayat',
  'Panchayat Samiti',
  'Zila Parishad',
  'Not Applicable',
];

class AssetSurveyFormScreen extends StatefulWidget {
  const AssetSurveyFormScreen({
    super.key,
    required this.assetTypeId,
    required this.assetTypeName,
    this.existingSurvey,
  });

  final String assetTypeId;
  final String assetTypeName;
  final Survey? existingSurvey;

  @override
  State<AssetSurveyFormScreen> createState() => _AssetSurveyFormScreenState();
}

class _AssetSurveyFormScreenState extends State<AssetSurveyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gpController = TextEditingController();
  final _notesController = TextEditingController();

  late final String _surveyId;
  late final DateTime _createdAt;

  String _district = 'Hisar';
  double? _lat;
  double? _lng;
  double? _accuracy;
  bool _gpsEnabled = false;
  int _conditionRating = 3;
  String _functionalStatus = 'Active';
  String? _prLevel = 'Gram Panchayat';
  final List<GeoTaggedPhoto> _photos = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSurvey;
    if (existing != null) {
      _surveyId = existing.id;
      _createdAt = existing.createdAt;
      _district = existing.district.isNotEmpty ? existing.district : 'Hisar';
      _gpController.text = existing.gramPanchayat;
      _notesController.text = existing.notes;
      _lat = existing.gpsLat;
      _lng = existing.gpsLng;
      _accuracy = existing.gpsAccuracy;
      _gpsEnabled = existing.gpsLat != null && existing.gpsLng != null;
      _conditionRating = existing.conditionRating.clamp(1, 5);
      _functionalStatus = existing.functionalStatus;
      _prLevel = existing.prInstitutionLevel;
      _photos.addAll(existing.photos);
    } else {
      _surveyId = _generateSurveyId();
      _createdAt = DateTime.now();
    }
  }

  @override
  void dispose() {
    _gpController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _generateSurveyId() {
    final now = DateTime.now();
    final stamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
        '${now.millisecond.toString().padLeft(3, '0')}';
    return 'SVY-$stamp';
  }

  String get _dateLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final d = _createdAt;
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  void _enableGps() {
    setState(() {
      _gpsEnabled = true;
      _lat = 29.1492;
      _lng = 75.7217;
      _accuracy = 6.4;
    });
  }

  void _addPhoto() {
    setState(() {
      _photos.add(
        GeoTaggedPhoto(
          url: 'local://photo_${_photos.length + 1}.jpg',
          latitude: _lat,
          longitude: _lng,
        ),
      );
    });
  }

  Survey _buildSurvey({required SurveyStatus status, required bool synced}) {
    return Survey(
      id: _surveyId,
      assetTypeId: widget.assetTypeId,
      district: _district,
      gramPanchayat: _gpController.text.trim(),
      gpsLat: _lat,
      gpsLng: _lng,
      gpsAccuracy: _accuracy,
      conditionRating: _conditionRating,
      functionalStatus: _functionalStatus,
      prInstitutionLevel: _prLevel,
      notes: _notesController.text.trim(),
      photos: List.unmodifiable(_photos),
      status: status,
      synced: synced,
      createdBy: 'citizen',
      createdAt: _createdAt,
    );
  }

  Future<void> _saveDraft() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await SurveyApi.saveDraft(
        _buildSurvey(status: SurveyStatus.draft, synced: false),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Draft saved', style: GoogleFonts.poppins()),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    if (!_gpsEnabled || _lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enable GPS to capture coordinates',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await SurveyApi.submitSurvey(
        _buildSurvey(status: SurveyStatus.submitted, synced: true),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingSurvey != null
                ? 'Survey updated'
                : 'Survey submitted',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'Survey Form',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    _HeaderCard(
                      assetName: widget.assetTypeName,
                      surveyId: _surveyId,
                      dateLabel: _dateLabel,
                      isUpdate: widget.existingSurvey != null,
                    ),
                    const SizedBox(height: 14),
                    _LabeledDropdown<String>(
                      label: 'District *',
                      value: _district,
                      items: kHaryanaDistricts,
                      onChanged: (v) =>
                          setState(() => _district = v ?? _district),
                    ),
                    const SizedBox(height: 12),
                    _LabeledTextField(
                      label: 'Gram Panchayat *',
                      controller: _gpController,
                      hint: 'Enter GP name',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _GpsCoordinateField(
                      label: 'GPS Latitude *',
                      value: _lat,
                      available: _gpsEnabled,
                    ),
                    const SizedBox(height: 12),
                    _GpsCoordinateField(
                      label: 'GPS Longitude *',
                      value: _lng,
                      available: _gpsEnabled,
                    ),
                    const SizedBox(height: 12),
                    _GpsAccuracyRow(
                      enabled: _gpsEnabled,
                      accuracy: _accuracy,
                      onEnable: _enableGps,
                    ),
                    const SizedBox(height: 12),
                    _LabeledDropdown<String>(
                      label: 'Condition Rating *',
                      value: kConditionRatings[_conditionRating - 1],
                      items: kConditionRatings,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(
                          () => _conditionRating =
                              kConditionRatings.indexOf(v) + 1,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _LabeledDropdown<String>(
                      label: 'Functional Status *',
                      value: _functionalStatus,
                      items: kFunctionalStatuses,
                      onChanged: (v) => setState(
                        () => _functionalStatus = v ?? _functionalStatus,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _LabeledDropdown<String>(
                      label: 'PR Institution Level',
                      value: _prLevel,
                      items: kPrInstitutionLevels,
                      onChanged: (v) => setState(() => _prLevel = v),
                    ),
                    const SizedBox(height: 12),
                    _NotesField(controller: _notesController),
                    const SizedBox(height: 14),
                    _PhotosSection(
                      photos: _photos,
                      onAdd: _addPhoto,
                      onRemove: (i) => setState(() => _photos.removeAt(i)),
                    ),
                  ],
                ),
              ),
            ),
            _BottomActions(
              busy: _saving,
              onSaveDraft: _saveDraft,
              onCancel: () => Navigator.of(context).maybePop(),
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.assetName,
    required this.surveyId,
    required this.dateLabel,
    this.isUpdate = false,
  });

  final String assetName;
  final String surveyId;
  final String dateLabel;
  final bool isUpdate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.greenTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.assignment_turned_in_rounded,
                color: AppColors.secondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assetName,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isUpdate ? 'Update Asset Survey' : 'New Asset Survey'} · Survey ID: $surveyId · $dateLabel',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: AppColors.mutedText,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.controller,
    required this.hint,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: AppColors.mutedText,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _GpsCoordinateField extends StatelessWidget {
  const _GpsCoordinateField({
    required this.label,
    required this.value,
    required this.available,
  });

  final String label;
  final double? value;
  final bool available;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: available ? AppColors.background : AppColors.greyBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: available
              ? Text(
                  value!.toStringAsFixed(6),
                  style: GoogleFonts.poppins(fontSize: 13),
                )
              : Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: AppColors.pendingText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '⚠ Unable to fetch',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.pendingText,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _GpsAccuracyRow extends StatelessWidget {
  const _GpsAccuracyRow({
    required this.enabled,
    required this.accuracy,
    required this.onEnable,
  });

  final bool enabled;
  final double? accuracy;
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GPS Accuracy',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        if (!enabled)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEnable,
              icon: const Icon(Icons.my_location_rounded, size: 18),
              label: Text(
                'Enable GPS',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size.fromHeight(46),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.greenTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '± ${accuracy?.toStringAsFixed(1) ?? '--'} m',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        const SizedBox(height: 6),
        Text(
          enabled
              ? '📍 Live GPS · Accurate'
              : '📍 Live GPS · Waiting for fix',
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes / Observations',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Additional observations...',
            hintStyle: GoogleFonts.poppins(
              color: AppColors.mutedText,
              fontSize: 13,
            ),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}

class _PhotosSection extends StatelessWidget {
  const _PhotosSection({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  final List<GeoTaggedPhoto> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              painter: const _DashedBorderPainter(color: AppColors.secondary),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                child: Column(
                  children: [
                    const Icon(
                      Icons.photo_camera_rounded,
                      color: AppColors.secondary,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click to upload photos',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (photos.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < photos.length; i++)
                Chip(
                  avatar: const Icon(Icons.image_rounded, size: 16),
                  label: Text(
                    'Photo ${i + 1}',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => onRemove(i),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.busy,
    required this.onSaveDraft,
    required this.onCancel,
    required this.onSubmit,
  });

  final bool busy;
  final VoidCallback onSaveDraft;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : onSaveDraft,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondaryText,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size.fromHeight(46),
                ),
                child: Text(
                  '💾 Save Draft',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondaryText,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size.fromHeight(46),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: busy ? null : onSubmit,
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppGradients.cta,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      height: 46,
                      alignment: Alignment.center,
                      child: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              '☁ Submit',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
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
