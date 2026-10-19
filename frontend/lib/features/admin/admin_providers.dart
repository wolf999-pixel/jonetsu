import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

final adminUsersProvider = StateNotifierProvider<AdminUsersNotifier, AsyncValue<List<UserModel>>>((ref) {
  return AdminUsersNotifier();
});

class AdminUsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  AdminUsersNotifier() : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiService.dio.get('/admin/users');
      final users = (response.data as List).map((json) => UserModel.fromJson(json)).toList();
      state = AsyncValue.data(users);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateUserLevel(String userId, int newLevel) async {
    try {
      await ApiService.dio.patch('/admin/users/$userId/level', data: {'level': newLevel});
      // Refresh local list
      loadUsers();
    } catch (e) {
      print('Erreur update level: $e');
    }
  }
}

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final response = await ApiService.dio.get('/admin/stats');
  return response.data;
});
