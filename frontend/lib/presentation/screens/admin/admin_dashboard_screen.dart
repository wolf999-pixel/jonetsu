import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_colors.dart';
import '../../../features/admin/admin_providers.dart';
import '../../../models/user_model.dart';
import '../../../shared/glass_container.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('QG COMMANDEMENT JŌNETSU', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('STATISTIQUES SYSTÈME', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            statsAsync.when(
              data: (stats) => Row(
                children: [
                  Expanded(child: _StatCard(label: 'Utilisateurs', value: '${stats['totalUsers']}', icon: Icons.people)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Posts', value: '${stats['totalPosts']}', icon: Icons.article)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Duels Actifs', value: '${stats['activeDuels']}', icon: Icons.bolt)),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur stats: $e', style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 32),
            const Text('GESTION DES UTILISATEURS', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            usersAsync.when(
              data: (users) => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _UserAdminTile(user: user);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur users: $e', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      opacity: 0.1,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _UserAdminTile extends ConsumerWidget {
  final UserModel user;

  const _UserAdminTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        opacity: 0.05,
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null ? Text(user.username[0].toUpperCase()) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.displayName ?? user.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('LVL ${user.otakuLevel} • ${user.xp} XP', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ],
              ),
            ),
            _LevelControl(
              currentLevel: user.otakuLevel,
              onChanged: (newLevel) {
                ref.read(adminUsersProvider.notifier).updateUserLevel(user.id, newLevel);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelControl extends StatelessWidget {
  final int currentLevel;
  final Function(int) onChanged;

  const _LevelControl({required this.currentLevel, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.white54, size: 20),
          onPressed: currentLevel > 1 ? () => onChanged(currentLevel - 1) : null,
        ),
        Text('$currentLevel', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
          onPressed: () => onChanged(currentLevel + 1),
        ),
      ],
    );
  }
}
