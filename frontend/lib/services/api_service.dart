import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  ApiService._();

  static const String _envApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get _baseHost {
    if (_envApiBaseUrl.isNotEmpty) {
      return _envApiBaseUrl;
    }
    if (kIsWeb) return 'http://localhost:3000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
      default:
        return 'http://127.0.0.1:3000';
    }
  }

  static final String baseUrl =
      _baseHost.endsWith('/api') ? _baseHost : '$_baseHost/api';

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }
}
