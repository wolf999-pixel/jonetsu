import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/anime_model.dart';
import '../../services/api_service.dart';

final animeListProvider = StateNotifierProvider<AnimeListNotifier, AsyncValue<List<AnimeModel>>>((ref) {
  return AnimeListNotifier();
});

class AnimeListNotifier extends StateNotifier<AsyncValue<List<AnimeModel>>> {
  AnimeListNotifier() : super(const AsyncValue.loading()) {
    loadAnimes();
  }

  Future<void> loadAnimes({String? query, String? genre}) async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiService.dio.get('/streaming', queryParameters: {
        if (query != null) 'q': query,
        if (genre != null) 'genre': genre,
      });
      final animes = (response.data as List).map((json) => AnimeModel.fromJson(json)).toList();
      state = AsyncValue.data(animes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final animeDetailProvider = FutureProvider.family<AnimeModel, String>((ref, id) async {
  final response = await ApiService.dio.get('/streaming/$id');
  return AnimeModel.fromJson(response.data);
});
