import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../data/asset_types_data.dart';
import '../models/asset_type.dart';
import '../models/survey.dart';
import '../navigation/app_navigation.dart';
import '../services/complaint_api.dart';
import '../services/survey_api.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'complaint_success_screen.dart';

class NewComplaintScreen extends StatefulWidget {
  const NewComplaintScreen({super.key});

  @override
  State<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends State<NewComplaintScreen> {
  List<String> _villages = ['Unknown', 'Bhondsi', 'Sohna', 'Badshahpur', 'Gurugram'];
  List<String> _panchayats = [
    'Unknown',
    'Bhondsi Gram Panchayat',
    'Sohna Gram Panchayat',
    'Badshahpur Gram Panchayat',
  ];

  String? _category;
  late String _village = _villages.first;
  late String _panchayat = _panchayats.first;
  final _descriptionController = TextEditingController();
  final _assetLocationController = TextEditingController();

  List<AssetType> _assetTypes = const [];
  String? _assetTypeId;
  List<Survey> _assetInstances = const [];
  String? _assetInstanceId;
  bool _loadingTypes = true;
  bool _loadingInstances = false;
  bool _submitting = false;

  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _photoBytes;

  bool _detectingLocation = false;
  double? _latitude;
  double? _longitude;
  String _locationLabel = 'No GPS captured yet — tap "GPS" above';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAssetTypes();
      _detectLocation();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _assetLocationController.dispose();
    super.dispose();
  }

  Future<void> _loadAssetTypes() async {
    try {
      final types = await SurveyApi.getAssetTypes();
      if (!mounted) return;
      setState(() {
        _assetTypes = types;
        _loadingTypes = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _assetTypes = assetTypes;
        _loadingTypes = false;
      });
    }
  }

  Future<void> _onAssetTypeChanged(String? id) async {
    setState(() {
      _assetTypeId = id;
      _assetInstanceId = null;
      _assetInstances = const [];
      _assetLocationController.clear();
      _loadingInstances = id != null;
      if (id != null) {
        final derived = _categoryFromAssetType(id);
        if (derived != null) _category = derived;
      }
    });
    if (id == null) return;

    try {
      final instances = await SurveyApi.getAssetTypeInstances(id);
      if (!mounted) return;
      setState(() {
        _assetInstances = instances;
        _loadingInstances = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _assetInstances = const [];
        _loadingInstances = false;
      });
    }
  }

  String? _categoryFromAssetType(String assetTypeId) {
    final name = assetTypeById(assetTypeId)?.name.toLowerCase() ?? '';
    if (name.contains('road') || name.contains('street network')) {
      return 'Damaged Road';
    }
    if (name.contains('light') || name.contains('solar')) {
      return 'Street Light';
    }
    if (name.contains('drain') || name.contains('sarovar')) {
      return 'Drainage';
    }
    if (name.contains('tube') || name.contains('water')) {
      return 'Water Supply';
    }
    return null;
  }

  String _instanceLabel(Survey survey) {
    final typeName = assetTypeById(survey.assetTypeId)?.name ?? 'Asset';
    return '$typeName - ${survey.panchayat} GP';
  }

  Future<void> _detectLocation() async {
    if (_detectingLocation) return;
    setState(() => _detectingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage('कृपया अपने डिवाइस की लोकेशन सर्विस चालू करें');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showMessage('स्थान दर्ज करने के लिए लोकेशन अनुमति आवश्यक है');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      String? detectedVillage;
      String? detectedArea;
      try {
        final placemarks = await Geocoding().placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          detectedVillage = (place.subLocality?.trim().isNotEmpty ?? false)
              ? place.subLocality!.trim()
              : place.locality?.trim();
          detectedArea = (place.locality?.trim().isNotEmpty ?? false)
              ? place.locality!.trim()
              : place.subAdministrativeArea?.trim();
        }
      } catch (_) {
        // Reverse geocoding unavailable; fall back to raw coordinates only.
      }

      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;

        if (detectedVillage != null && detectedVillage.isNotEmpty) {
          final existingVillage = _villages.firstWhere(
            (v) => v.toLowerCase() == detectedVillage!.toLowerCase(),
            orElse: () => detectedVillage!,
          );
          if (!_villages.contains(existingVillage)) {
            _villages = [..._villages, existingVillage];
          }
          _village = existingVillage;

          final derivedPanchayat = '$existingVillage Gram Panchayat';
          final existingPanchayat = _panchayats.firstWhere(
            (p) => p.toLowerCase().contains(existingVillage.toLowerCase()),
            orElse: () => derivedPanchayat,
          );
          if (!_panchayats.contains(existingPanchayat)) {
            _panchayats = [..._panchayats, existingPanchayat];
          }
          _panchayat = existingPanchayat;
        }

        final lat = position.latitude.toStringAsFixed(4);
        final lng = position.longitude.toStringAsFixed(4);
        final place = [
          detectedVillage,
          detectedArea,
        ].where((p) => p != null && p.isNotEmpty).join(', ');
        _locationLabel = place.isNotEmpty ? '$lat, $lng — $place' : '$lat, $lng';
      });
    } catch (_) {
      _showMessage('लोकेशन प्राप्त नहीं हो सकी। कृपया पुनः प्रयास करें।');
    } finally {
      if (mounted) setState(() => _detectingLocation = false);
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo == null) return;
      final bytes = await photo.readAsBytes();
      if (!mounted) return;
      setState(() => _photoBytes = bytes);
    } catch (_) {
      _showMessage('फोटो लेने में समस्या हुई। कृपया कैमरा अनुमति जांचें।');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.poppins())),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;

    if (_assetTypeId == null) {
      _showMessage('Please select an asset type');
      return;
    }

    final hasInstances = _assetInstances.isNotEmpty;
    if (hasInstances && _assetInstanceId == null) {
      _showMessage('Please select a specific asset');
      return;
    }

    if (!hasInstances && _assetLocationController.text.trim().isEmpty) {
      _showMessage('Please enter the asset location');
      return;
    }

    final latitude = _latitude ?? 28.3521;
    final longitude = _longitude ?? 77.0642;
    final description = _descriptionController.text.trim().isEmpty
        ? 'Complaint registered from mobile app.'
        : _descriptionController.text.trim();

    setState(() => _submitting = true);
    try {
      final complaint = await ComplaintApi.submit(
        assetTypeId: _assetTypeId,
        assetInstanceId: _assetInstanceId,
        category: _category,
        village: _village,
        panchayat: _panchayat,
        description: description,
        latitude: latitude,
        longitude: longitude,
        photoBytes: _photoBytes,
      );

      if (!mounted) return;
      pushReplacement(context, ComplaintSuccessScreen(complaint: complaint));
    } on ComplaintApiException catch (e) {
      _showMessage(e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasInstances = _assetInstances.isNotEmpty;

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
                  if (_loadingTypes)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _assetTypeId,
                      hint: Text(
                        '-- Choose an asset type --',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.mutedText,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF212121),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Select Asset Type *',
                        labelStyle: GoogleFonts.poppins(fontSize: 14),
                        prefixIcon: const Icon(
                          Icons.apartment_rounded,
                          color: Color(0xFF9E9E9E),
                        ),
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
                      items: [
                        for (final type in _assetTypes)
                          DropdownMenuItem(
                            value: type.id,
                            child: Text(
                              type.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: _onAssetTypeChanged,
                    ),
                  if (_assetTypeId != null) ...[
                    const SizedBox(height: AppSpacing.gap),
                    if (_loadingInstances)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else if (hasInstances)
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _assetInstanceId,
                        hint: Text(
                          '-- Choose a specific asset --',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.mutedText,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF212121),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Select Specific Asset *',
                          labelStyle: GoogleFonts.poppins(fontSize: 14),
                          prefixIcon: const Icon(
                            Icons.place_rounded,
                            color: Color(0xFF9E9E9E),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.button),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.button),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.button),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.2,
                            ),
                          ),
                        ),
                        items: [
                          for (final instance in _assetInstances)
                            DropdownMenuItem(
                              value: instance.id,
                              child: Text(
                                _instanceLabel(instance),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (id) =>
                            setState(() => _assetInstanceId = id),
                      )
                    else ...[
                      Text(
                        'No surveyed assets found for this type in your area. Enter a location instead.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.mutedText,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _assetLocationController,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Asset location *',
                          hintText: 'e.g. Near school gate, Ward 2',
                          labelStyle: GoogleFonts.poppins(fontSize: 14),
                          prefixIcon: const Icon(
                            Icons.edit_location_alt_rounded,
                            color: Color(0xFF9E9E9E),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.button),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.button),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.button),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
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
                  if (_detectingLocation)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'आपका स्थान पता किया जा रहा है...',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.mutedText,
                        ),
                      ),
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
                  Row(
                    children: [
                      Expanded(
                        child: _AttachmentTile(
                          icon: Icons.photo_camera_rounded,
                          label: 'Photo',
                          onTap: _pickPhoto,
                          thumbnailBytes: _photoBytes,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.gap),
                      Expanded(
                        child: _AttachmentTile(
                          icon: Icons.my_location_rounded,
                          label: 'GPS',
                          onTap: _detectLocation,
                          busy: _detectingLocation,
                          done: _latitude != null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.gap),
                      const Expanded(
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
                            _locationLabel,
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
              onPressed: _submitting ? null : _submit,
              label: _submitting ? 'Submitting...' : 'Submit complaint',
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
      value: value,
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
  const _AttachmentTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.busy = false,
    this.done = false,
    this.thumbnailBytes,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool busy;
  final bool done;
  final Uint8List? thumbnailBytes;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: const Color(0xFFBDBDBD),
        radius: AppRadius.button,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          height: 88,
          alignment: Alignment.center,
          child: thumbnailBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.button - 2),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(thumbnailBytes!, fit: BoxFit.cover),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      done ? Icons.check_circle_rounded : icon,
                      color: AppColors.primary,
                      size: 28,
                    ),
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
