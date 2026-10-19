import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_colors.dart';
import '../../../features/auth/auth_providers.dart';
import '../../../features/auth/profile_providers.dart';
import '../../../shared/glass_container.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _animeController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _bioController = TextEditingController();
    _animeController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _animeController.dispose();
    super.dispose();
  }

  void _setupControllers(dynamic user) {
    _displayNameController.text = user.displayName ?? '';
    _bioController.text = user.bio ?? '';
    _animeController.text = user.favoriteAnime ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authNotifierProvider).value;
    if (authUser == null) return const Scaffold(body: Center(child: Text('Non connecté')));

    final profileAsync = ref.watch(userProfileProvider(authUser.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        data: (user) => SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(user),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    _buildIdentitySection(user),
                    const SizedBox(height: 24),
                    _buildXpBar(user),
                    const SizedBox(height: 30),
                    _buildStatRow(user),
                    const SizedBox(height: 30),
                    _buildInfoSection('BIO', user.bio, _bioController, Icons.info_outline),
                    const SizedBox(height: 20),
                    _buildInfoSection('ANIME PRÉFÉRÉ', user.favoriteAnime, _animeController, Icons.movie_filter),
                    const SizedBox(height: 30),
                    _buildBadgesSection(user),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildHeader(dynamic user) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            image: user.bannerUrl != null
                ? DecorationImage(image: NetworkImage(user.bannerUrl!), fit: BoxFit.cover)
                : null,
          ),
          child: user.bannerUrl == null
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.auto_awesome, size: 50, color: AppColors.primary.withOpacity(0.3)),
                ),
              )
            : null,
        ),
        Positioned(
          top: 40,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          top: 40,
          right: 10,
          child: GlassContainer(
            borderRadius: BorderRadius.circular(30),
            padding: EdgeInsets.zero,
            child: IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
              onPressed: () {
                if (_isEditing) {
                  ref.read(userProfileProvider(user.id).notifier).updateProfile({
                    'displayName': _displayNameController.text,
                    'bio': _bioController.text,
                    'favoriteAnime': _animeController.text,
                  });
                } else {
                  _setupControllers(user);
                }
                setState(() => _isEditing = !_isEditing);
              },
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
            child: Hero(
              tag: 'profile_avatar',
              child: CircleAvatar(
                radius: 55,
                backgroundColor: AppColors.primary,
                backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                child: user.avatarUrl == null
                  ? Text(user.username[0].toUpperCase(), style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold))
                  : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentitySection(dynamic user) {
    return Center(
      child: Column(
        children: [
          Text(
            user.displayName ?? user.username,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.username}',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildXpBar(dynamic user) {
    final currentLevel = user.otakuLevel;
    final xpStart = (currentLevel - 1) * (currentLevel - 1) * 50;
    final xpEnd = currentLevel * currentLevel * 50;
    final progress = (user.xp - xpStart) / (xpEnd - xpStart);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('NIVEAU $currentLevel', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
            Text('${user.xp} / $xpEnd XP', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.1),
            color: AppColors.primary,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(dynamic user) {
    return Row(
      children: [
        Expanded(child: _StatBox(label: 'Posts', value: '12', icon: Icons.grid_view)),
        const SizedBox(width: 12),
        Expanded(child: _StatBox(label: 'Abonnés', value: '450', icon: Icons.people_outline)),
        const SizedBox(width: 12),
        Expanded(child: _StatBox(label: 'Abonnements', value: '128', icon: Icons.person_add_alt)),
      ],
    );
  }

  Widget _buildInfoSection(String title, String? value, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1)),
          ],
        ),
        const SizedBox(height: 12),
        _isEditing
            ? TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                maxLines: title == 'BIO' ? 3 : 1,
                decoration: InputDecoration(
                  fillColor: Colors.white.withOpacity(0.05),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(16),
                ),
              )
            : GlassContainer(
                padding: const EdgeInsets.all(16),
                opacity: 0.05,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    value ?? 'Non renseigné',
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildBadgesSection(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BADGES RÉCENTS', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1)),
        const SizedBox(height: 16),
        user.badges.isEmpty
          ? Text('Aucun badge débloqué.', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14))
          : Wrap(
              spacing: 12,
              runSpacing: 12,
              children: user.badges.map<Widget>((b) => _BadgeIcon(name: b)).toList(),
            ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 16),
      opacity: 0.05,
      child: Column(
        children: [
          Icon(icon, size: 18, color: Colors.white.withOpacity(0.4)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
        ],
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final String name;
  const _BadgeIcon({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Tooltip(
        message: name,
        child: const Icon(Icons.stars, color: AppColors.primary, size: 24),
      ),
    );
  }
}
