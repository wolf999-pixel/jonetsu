import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

final userProfileProvider = StateNotifierProvider.family<UserProfileNotifier, AsyncValue<UserModel>, String>((ref, userId) {
  return UserProfileNotifier(userId);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel>> {
  final String userId;

  UserProfileNotifier(this.userId) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiService.dio.get('/users/$userId');
      state = AsyncValue.data(UserModel.fromJson(response.data));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.dio.patch('/users/$userId', data: data);
      state = AsyncValue.data(UserModel.fromJson(response.data));
    } catch (e) {
      print('Erreur update profil: $e');
    }
  }
}
