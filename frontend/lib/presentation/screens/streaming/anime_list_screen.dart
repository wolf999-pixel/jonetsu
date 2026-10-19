import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_colors.dart';
import '../../../features/streaming/streaming_providers.dart';
import '../../../models/anime_model.dart';

class AnimeListScreen extends ConsumerWidget {
  const AnimeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeListAsync = ref.watch(animeListProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F0C29), AppColors.background],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => ref.read(animeListProvider.notifier).loadAnimes(query: value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un anime...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                fillColor: Colors.white.withOpacity(0.05),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: animeListAsync.when(
              data: (animes) => GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: animes.length,
                itemBuilder: (context, index) => _AnimeCard(anime: animes[index]),
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text('Erreur: $err', style: const TextStyle(color: Colors.white24))),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimeCard extends StatelessWidget {
  final AnimeModel anime;
  const _AnimeCard({required this.anime});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/streaming/${anime.id}'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
          image: anime.imageUrl != null
              ? DecorationImage(image: NetworkImage(anime.imageUrl!), fit: BoxFit.cover)
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                anime.title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 12),
                  const SizedBox(width: 4),
                  Text('${anime.rating}', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                    child: Text('${anime.releaseYear}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
