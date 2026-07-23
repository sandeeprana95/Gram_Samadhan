import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/asset_type.dart';
import 'auth_service.dart';

class AssetTypeApiException implements Exception {
  AssetTypeApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Talks to `/api/asset-types` on the Gram Samadhan backend — the asset
/// type catalog lives in the database so new types can be added without an
/// app release.
class AssetTypeApi {
  AssetTypeApi._();

  static Uri get _uri => Uri.parse('${ApiConfig.baseUrl}/api/asset-types');

  static Future<List<AssetType>> getAssetTypes() async {
    final session = await AuthService.getSession();
    if (session == null || !session.isValid) {
      throw AssetTypeApiException('कृपया पहले लॉगिन करें');
    }

    late final http.Response response;
    try {
      response = await http
          .get(_uri, headers: {'Authorization': 'Bearer ${session.token}'})
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw AssetTypeApiException('Server से कनेक्ट नहीं हो पाया। कृपया पुनः प्रयास करें।');
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = const {};
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AssetTypeApiException(
        body['message'] as String? ?? 'एसेट प्रकार लोड नहीं हो पाए। पुनः प्रयास करें।',
      );
    }

    final items = body['assetTypes'] as List<dynamic>? ?? const [];
    return items
        .map(
          (item) => AssetType.fromJson({
            'id': (item as Map<String, dynamic>)['id'],
            'name': item['name'],
            'icon_key': item['iconKey'],
          }),
        )
        .toList();
  }
}
