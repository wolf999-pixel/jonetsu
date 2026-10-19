import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final Dio _dio = ApiService.dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return _normalizeResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String username,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'email': email, 'username': username, 'password': password},
      );
      return _normalizeResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Map<String, dynamic> _normalizeResponse(Response response) {
    final data = response.data;
    if (data == null || data is! Map) {
      throw Exception('Format de réponse invalide du serveur');
    }
    return Map<String, dynamic>.from(data);
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) return Exception('Délai de connexion dépassé');
    if (e.response?.statusCode == 401) return Exception('Identifiants incorrects');
    if (e.response?.statusCode == 409) return Exception('Email ou nom d\'utilisateur déjà utilisé');
    return Exception(e.message ?? 'Erreur réseau inconnue');
  }

  UserModel parseUser(Map<String, dynamic> json) {
    // On extrait l'objet 'user' de manière sécurisée
    final userData = json['user'];
    if (userData != null && userData is Map) {
      return UserModel.fromJson(Map<String, dynamic>.from(userData));
    }
    // Si 'user' est absent mais que l'objet racine ressemble à un utilisateur
    return UserModel.fromJson(json);
  }
}
