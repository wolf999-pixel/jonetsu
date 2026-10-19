import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/socket_service.dart';

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;
  final FirebaseAuthService _firebaseAuthService;
  final SocketService _socketService = SocketService();
  String? _token;

  AuthNotifier(this._authService, this._firebaseAuthService)
      : super(const AsyncData(null));

  String? get token => _token;

  // Inscription
  Future<void> signUpWithEmailPassword(
      String email, String username, String password) async {
    state = const AsyncLoading();
    try {
      // 1. Essai direct via l'API NestJS principale
      final response = await _authService.register(email, username, password);
      await _handleAuthSuccess(response);
    } catch (backendError) {
      print('NestJS registration failed, attempting Firebase fallback: $backendError');
      try {
        // 2. Fallback Firebase si NestJS échoue
        final response = await _firebaseAuthService.signUpWithEmailPassword(
            email, password, username);
        await _handleAuthSuccess(response);
      } catch (firebaseError) {
        state = AsyncError(backendError, StackTrace.current);
        rethrow;
      }
    }
  }

  // Connexion
  Future<void> signInWithEmailPassword(String email, String password) async {
    state = const AsyncLoading();
    try {
      // 1. Essai direct via l'API NestJS principale
      final response = await _authService.login(email, password);
      await _handleAuthSuccess(response);
    } catch (backendError) {
      print('NestJS login failed, attempting Firebase fallback: $backendError');
      try {
        // 2. Fallback Firebase
        final response = await _firebaseAuthService.signInWithEmailPassword(
            email, password);
        await _handleAuthSuccess(response);
      } catch (firebaseError) {
        state = AsyncError(backendError, StackTrace.current);
        rethrow;
      }
    }
  }

  // Restauration de session
  Future<void> restoreSession() async {
    try {
      final response =
          await _firebaseAuthService.signInWithCurrentFirebaseUser();
      await _handleAuthSuccess(response);
    } catch (_) {
      state = const AsyncData(null);
    }
  }

  // Google Sign-In
  Future<void> loginWithGoogle() async {
    state = const AsyncLoading();
    try {
      final response = await _firebaseAuthService.signInWithGoogle();
      await _handleAuthSuccess(response);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> _handleAuthSuccess(Map<String, dynamic> data) async {
    _token = data['accessToken']?.toString();
    if (_token != null && _token!.isNotEmpty) {
      ApiService.setAuthToken(_token!);
      try {
        await _socketService.connect(_token!);
      } catch (e) {
        print('Socket connection optional error: $e');
      }
    }
    final user = _authService.parseUser(data);
    state = AsyncData(user);
    if (user.id.isNotEmpty) {
      try {
        await NotificationService().updateTokenOnBackend(user.id);
      } catch (e) {
        print('Notification token update optional error: $e');
      }
    }
  }

  void logout() {
    _token = null;
    try {
      _firebaseAuthService.signOut();
    } catch (_) {}
    try {
      _socketService.disconnect();
    } catch (_) {}
    ApiService.clearAuthToken();
    state = const AsyncData(null);
  }
}
