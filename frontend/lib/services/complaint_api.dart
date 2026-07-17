import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;

import '../config/api_config.dart';
import '../models/complaint.dart';
import 'auth_service.dart';

class ComplaintApiException implements Exception {
  ComplaintApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Talks to `/api/complaints` on the Gram Samadhan backend.
class ComplaintApi {
  ComplaintApi._();

  static Uri _uri(String path) =>
      Uri.parse('${ApiConfig.baseUrl}/api/complaints$path');

  static Future<Complaint> submit({
    String? assetTypeId,
    String? assetInstanceId,
    String? category,
    required String village,
    required String panchayat,
    required String description,
    double? latitude,
    double? longitude,
    Uint8List? photoBytes,
  }) async {
    final session = await AuthService.getSession();
    if (session == null || !session.isValid) {
      throw ComplaintApiException('कृपया पहले लॉगिन करें');
    }

    late final http.Response response;
    try {
      final request = http.MultipartRequest('POST', _uri(''))
        ..headers['Authorization'] = 'Bearer ${session.token}'
        ..fields.addAll({
          if (assetTypeId != null) 'assetTypeId': assetTypeId,
          if (assetInstanceId != null) 'assetInstanceId': assetInstanceId,
          if (category != null) 'category': category,
          'village': village,
          'panchayat': panchayat,
          'description': description,
          if (latitude != null) 'latitude': latitude.toString(),
          if (longitude != null) 'longitude': longitude.toString(),
        });

      if (photoBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'photo',
            photoBytes,
            filename: 'complaint_photo.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamed = await request.send().timeout(const Duration(seconds: 20));
      response = await http.Response.fromStream(streamed);
    } catch (_) {
      throw ComplaintApiException('Server से कनेक्ट नहीं हो पाया। कृपया पुनः प्रयास करें।');
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = const {};
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ComplaintApiException(
        body['message'] as String? ?? 'शिकायत दर्ज नहीं हो पाई। पुनः प्रयास करें।',
      );
    }

    final complaint = body['complaint'] as Map<String, dynamic>? ?? const {};
    return _fromJson(complaint);
  }

  /// Fetches all complaints raised by the signed-in user, newest first.
  static Future<List<Complaint>> getMine() async {
    final session = await AuthService.getSession();
    if (session == null || !session.isValid) {
      throw ComplaintApiException('कृपया पहले लॉगिन करें');
    }

    late final http.Response response;
    try {
      response = await http
          .get(_uri(''), headers: {'Authorization': 'Bearer ${session.token}'})
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw ComplaintApiException('Server से कनेक्ट नहीं हो पाया। कृपया पुनः प्रयास करें।');
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = const {};
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ComplaintApiException(
        body['message'] as String? ?? 'शिकायतें लोड नहीं हो पाईं। पुनः प्रयास करें।',
      );
    }

    final complaints = body['complaints'] as List<dynamic>? ?? const [];
    return complaints
        .map((item) => _fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the latest state of a previously submitted complaint.
  static Future<Complaint> getById(String id) async {
    final session = await AuthService.getSession();
    if (session == null || !session.isValid) {
      throw ComplaintApiException('कृपया पहले लॉगिन करें');
    }

    late final http.Response response;
    try {
      response = await http
          .get(_uri('/$id'), headers: {'Authorization': 'Bearer ${session.token}'})
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw ComplaintApiException('Server से कनेक्ट नहीं हो पाया। कृपया पुनः प्रयास करें।');
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = const {};
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ComplaintApiException(
        body['message'] as String? ?? 'शिकायत लोड नहीं हो पाई। पुनः प्रयास करें।',
      );
    }

    final complaint = body['complaint'] as Map<String, dynamic>? ?? const {};
    return _fromJson(complaint);
  }

  static Complaint _fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
    final photoUrl = json['photoUrl'] as String?;
    final latitude = json['latitude'];
    final longitude = json['longitude'];

    return Complaint(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      village: json['village'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date: _formatDate(createdAt),
      status: _parseStatus(json['status'] as String? ?? 'PENDING'),
      officer: json['officer'] as String? ?? 'Not assigned',
      location: latitude != null && longitude != null
          ? '$latitude, $longitude'
          : '',
      assetTypeId: json['assetTypeId'] as String?,
      assetInstanceId: json['assetInstanceId'] as String?,
      photoUrl: photoUrl != null ? '${ApiConfig.baseUrl}$photoUrl' : null,
      createdAt: createdAt,
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}';
  }

  static ComplaintStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'IN_PROGRESS':
        return ComplaintStatus.inProgress;
      case 'RESOLVED':
        return ComplaintStatus.resolved;
      case 'REJECTED':
        return ComplaintStatus.rejected;
      default:
        return ComplaintStatus.pending;
    }
  }
}
