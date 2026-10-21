import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  ApiService._();

  static const String _envApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get _baseHost {
    if (_envApiBaseUrl.isNotEmpty) {
      return _envApiBaseUrl;
    }
    return 'https://jonetsu-omega.vercel.app';
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
