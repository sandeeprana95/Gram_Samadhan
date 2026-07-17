import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class AuthApiException implements Exception {
  AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OtpSendResult {
  const OtpSendResult({required this.message, required this.smsSent});

  final String message;
  final bool smsSent;
}

class OtpVerifyResult {
  const OtpVerifyResult({required this.token, required this.mobile});

  final String token;
  final String mobile;
}

/// Talks to `/api/auth` on the Gram Samadhan backend for the citizen
/// mobile-number + OTP login flow.
class AuthApi {
  AuthApi._();

  static Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}/api/auth$path');

  static Future<OtpSendResult> sendOtp(String mobile) async {
    final body = await _post('/send-otp', {'mobile': mobile});
    return OtpSendResult(
      message: body['message'] as String? ?? 'OTP sent',
      smsSent: body['smsSent'] as bool? ?? false,
    );
  }

  static Future<OtpSendResult> resendOtp(String mobile) async {
    final body = await _post('/resend-otp', {'mobile': mobile});
    return OtpSendResult(
      message: body['message'] as String? ?? 'OTP resent',
      smsSent: body['smsSent'] as bool? ?? false,
    );
  }

  static Future<OtpVerifyResult> verifyOtp(String mobile, String otp) async {
    final body = await _post('/verify-otp', {'mobile': mobile, 'otp': otp});
    final user = body['user'] as Map<String, dynamic>?;
    return OtpVerifyResult(
      token: body['token'] as String? ?? '',
      mobile: user?['mobile'] as String? ?? mobile,
    );
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload,
  ) async {
    late final http.Response response;
    try {
      response = await http
          .post(
            _uri(path),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw AuthApiException('Server से कनेक्ट नहीं हो पाया। कृपया पुनः प्रयास करें।');
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = const {};
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(
        body['message'] as String? ?? 'कुछ गलत हो गया। पुनः प्रयास करें।',
      );
    }

    return body;
  }
}
