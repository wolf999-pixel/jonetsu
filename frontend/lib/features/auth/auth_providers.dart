import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_auth_service.dart';
import 'auth_notifier.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firebaseAuthServiceProvider =
    Provider<FirebaseAuthService>((ref) => FirebaseAuthService());

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    final firebaseAuthService = ref.watch(firebaseAuthServiceProvider);
    return AuthNotifier(authService, firebaseAuthService);
  },
);
