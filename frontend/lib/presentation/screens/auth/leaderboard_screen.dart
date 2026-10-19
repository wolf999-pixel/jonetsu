import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../models/user_model.dart';
import '../../../shared/glass_container.dart';

final leaderboardProvider = FutureProvider<List<UserModel>>((ref) async {
  final response = await ApiService.dio.get('/users/leaderboard');
  return (response.data as List).map((json) => UserModel.fromJson(json)).toList();
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CLASSEMENT OTAKU', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: leaderboardAsync.when(
        data: (users) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final isTop3 = index < 3;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                opacity: isTop3 ? 0.15 : 0.05,
                color: isTop3 ? AppColors.primary : Colors.white,
                child: ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isTop3 ? AppColors.primary : Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      CircleAvatar(
                        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                        child: user.avatarUrl == null ? Text(user.username[0].toUpperCase()) : null,
                      ),
                    ],
                  ),
                  title: Text(
                    user.displayName ?? user.username,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'LVL ${user.otakuLevel}',
                    style: TextStyle(color: AppColors.primary.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${user.xp}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Text(
                        'XP',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}
