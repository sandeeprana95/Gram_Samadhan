import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../data/sample_data.dart';
import '../models/complaint.dart';
import '../navigation/app_navigation.dart';
import '../theme/app_theme.dart';
import 'complaint_details_screen.dart';

class ComplaintMapScreen extends StatefulWidget {
  const ComplaintMapScreen({super.key});

  @override
  State<ComplaintMapScreen> createState() => _ComplaintMapScreenState();
}

class _ComplaintMapScreenState extends State<ComplaintMapScreen> {
  final _mapController = MapController();

  static const _initialCenter = LatLng(28.3521, 77.0642);
  static const _initialZoom = 12.0;

  List<Complaint> get _geoComplaints =>
      complaints.where((c) => c.latitude != null && c.longitude != null).toList();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _recenter() {
    _mapController.move(_initialCenter, _initialZoom);
  }

  Color _markerColor(ComplaintStatus status) {
    return switch (status) {
      ComplaintStatus.pending => const Color(0xFFD32F2F),
      ComplaintStatus.inProgress => const Color(0xFFF9A825),
      ComplaintStatus.resolved => const Color(0xFF2E7D32),
      ComplaintStatus.rejected => const Color(0xFF616161),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              minZoom: 4,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.my_first_app',
              ),
              MarkerLayer(
                markers: [
                  for (final complaint in _geoComplaints)
                    Marker(
                      point: LatLng(complaint.latitude!, complaint.longitude!),
                      width: 44,
                      height: 52,
                      alignment: Alignment.topCenter,
                      child: _TeardropMarker(
                        color: _markerColor(complaint.status),
                        onTap: () => push(
                          context,
                          ComplaintDetailsScreen(complaint: complaint),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          _buildSearchBar(context),
          const Positioned(
            left: AppSpacing.screen,
            bottom: AppSpacing.screen,
            child: _MapLegend(),
          ),
          Positioned(
            right: AppSpacing.screen,
            bottom: AppSpacing.screen,
            child: FloatingActionButton(
              heroTag: 'my_location',
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.primary,
              onPressed: _recenter,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topPadding + 12,
      left: AppSpacing.screen,
      right: AppSpacing.screen,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(30),
        shadowColor: Colors.black26,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(20),
                child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF616161)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Search location or complaint',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ),
              ),
              const Icon(Icons.search_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeardropMarker extends StatelessWidget {
  const _TeardropMarker({required this.color, required this.onTap});

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        Icons.location_on,
        color: color,
        size: 44,
        shadows: const [
          Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Legend',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),
          _legendRow(const Color(0xFFD32F2F), 'Pending'),
          const SizedBox(height: 6),
          _legendRow(const Color(0xFFF9A825), 'In Progress'),
          const SizedBox(height: 6),
          _legendRow(const Color(0xFF2E7D32), 'Resolved'),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF424242),
          ),
        ),
      ],
    );
  }
}
