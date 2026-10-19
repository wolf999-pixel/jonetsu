import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_colors.dart';
import '../../../features/streaming/streaming_providers.dart';
import '../../../features/analytics/analytics_providers.dart';

class AnimeDetailScreen extends ConsumerStatefulWidget {
  final String animeId;

  const AnimeDetailScreen({super.key, required this.animeId});

  @override
  ConsumerState<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends ConsumerState<AnimeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsProvider).trackEvent('page_view', value: 'anime_detail', metadata: {'animeId': widget.animeId});
    });
  }

  @override
  Widget build(BuildContext context) {
    final animeAsync = ref.watch(animeDetailProvider(widget.animeId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: animeAsync.when(
        data: (anime) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(anime.title, style: const TextStyle(shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (anime.imageUrl != null)
                      Image.network(anime.imageUrl!, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AppColors.background],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _infoTag(anime.genre ?? 'Anime'),
                        const SizedBox(width: 10),
                        _infoTag('${anime.releaseYear}'),
                        const Spacer(),
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text('${anime.rating}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('SYNOPSIS', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    Text(
                      anime.description ?? 'Pas de description disponible.',
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 15),
                    ),
                    const SizedBox(height: 30),
                    const Text('ÉPISODES', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final episode = anime.episodes[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(8)),
                      child: Center(child: Text('${episode.number}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                    ),
                    title: Text(episode.title, style: const TextStyle(color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.play_circle_outline, color: AppColors.primary),
                    onTap: () {
                      // Tracker l'événement de lecture
                      ref.read(analyticsProvider).trackEvent(
                        'video_play',
                        value: anime.title,
                        metadata: {'animeId': anime.id, 'episode': episode.number}
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lancement de l\'épisode ${episode.number}...')),
                      );
                    },
                  );
                },
                childCount: anime.episodes.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _infoTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
