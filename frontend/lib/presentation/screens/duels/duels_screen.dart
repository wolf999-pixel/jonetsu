import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_colors.dart';
import '../../../features/duels/duels_providers.dart';
import '../../../models/duel_model.dart';

class DuelsScreen extends ConsumerWidget {
  const DuelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duelsAsync = ref.watch(activeDuelsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('DUELS LÉGENDAIRES'),
        centerTitle: true,
      ),
      body: duelsAsync.when(
        data: (duels) => duels.isEmpty
            ? const Center(
                child: Text('Aucun duel actif pour le moment.',
                    style: TextStyle(color: AppColors.textSecondary)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: duels.length,
                itemBuilder: (context, index) => _DuelCard(duel: duels[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}

class _DuelCard extends ConsumerWidget {
  final DuelModel duel;

  const _DuelCard({required this.duel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _CharacterVote(
                      character: duel.characterA,
                      duelId: duel.id,
                      choice: 'A',
                      percent: duel.percentA)),
              const Text('VS',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 24)),
              Expanded(
                  child: _CharacterVote(
                      character: duel.characterB,
                      duelId: duel.id,
                      choice: 'B',
                      percent: duel.percentB)),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(duel.percentA * 100).toInt()}%',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold)),
                Text('${(duel.percentB * 100).toInt()}%',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LinearProgressIndicator(
              value: duel.percentA,
              backgroundColor: Colors.blue.withOpacity(0.3),
              color: AppColors.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Fin dans ${_formatTimeRemaining(duel.endsAt)}',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _formatTimeRemaining(DateTime endsAt) {
    final diff = endsAt.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays} jours';
    return '${diff.inHours} heures';
  }
}

class _CharacterVote extends ConsumerWidget {
  final CharacterModel character;
  final String duelId;
  final String choice;
  final double percent;

  const _CharacterVote(
      {required this.character,
      required this.duelId,
      required this.choice,
      required this.percent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => ref.read(activeDuelsProvider.notifier).vote(duelId, choice),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: character.imageUrl != null
                ? NetworkImage(character.imageUrl!)
                : null,
            child: character.imageUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(height: 12),
          Text(character.name,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          Text(character.anime,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}
