import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../auth/auth_providers.dart';

final analyticsProvider = Provider((ref) => AnalyticsNotifier(ref));

class AnalyticsNotifier {
  final Ref _ref;

  AnalyticsNotifier(this._ref);

  Future<void> trackEvent(String type, {String? value, Map<String, dynamic>? metadata}) async {
    final user = _ref.read(authNotifierProvider).value;
    try {
      await ApiService.dio.post('/analytics/track', data: {
        'type': type,
        'value': value,
        'userId': user?.id,
        'metadata': metadata ?? {},
      });
    } catch (e) {
      print('Erreur tracking analytics: $e');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await ApiService.dio.get('/analytics/stats');
      return response.data;
    } catch (e) {
      print('Erreur fetching stats: $e');
      return {};
    }
  }
}
