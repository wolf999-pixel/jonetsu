import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/duel_model.dart';
import '../../services/api_service.dart';
import '../auth/auth_providers.dart';

final activeDuelsProvider = StateNotifierProvider<ActiveDuelsNotifier, AsyncValue<List<DuelModel>>>((ref) {
  return ActiveDuelsNotifier(ref);
});

class ActiveDuelsNotifier extends StateNotifier<AsyncValue<List<DuelModel>>> {
  final Ref ref;

  ActiveDuelsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadDuels();
  }

  Future<void> loadDuels() async {
    try {
      final response = await ApiService.dio.get('/duels/active');
      final duels = (response.data as List).map((json) => DuelModel.fromJson(json)).toList();
      state = AsyncValue.data(duels);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> vote(String duelId, String choice) async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    try {
      await ApiService.dio.post('/duels/$duelId/vote', data: {
        'userId': user.id,
        'choice': choice,
      });
      loadDuels(); // Recharger pour voir les scores mis à jour
    } catch (e) {
      print('Erreur lors du vote: $e');
    }
  }
}
