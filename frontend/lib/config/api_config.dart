import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Base URL for the Gram Samadhan backend.
///
/// Android emulators can't reach the host machine via `localhost`, so
/// `10.0.2.2` is used instead. Point this at your deployed backend URL
/// for physical devices / production builds.
class ApiConfig {
  ApiConfig._();

  static const String _devPort = '8080';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:$_devPort';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$_devPort';
    }
    return 'http://localhost:$_devPort';
  }
}
