import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/auth_providers.dart';
import '../models/user_model.dart';
import '../presentation/screens/admin/admin_dashboard_screen.dart';
import '../presentation/screens/ai/akira_chat_screen.dart';
import '../presentation/screens/auth/leaderboard_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/profile_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/chat/chat_detail_screen.dart';
import '../presentation/screens/chat/chat_list_screen.dart';
import '../presentation/screens/duels/duels_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/news/feed_screen.dart';
import '../presentation/screens/onboarding_screen.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/streaming/anime_detail_screen.dart';
import '../presentation/screens/streaming/anime_list_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<UserModel?>>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          from: state.uri.queryParameters['from'],
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(
          from: state.uri.queryParameters['from'],
        ),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return ChatDetailScreen(chatId: chatId);
        },
      ),
      GoRoute(
        path: '/ai',
        builder: (context, state) => const AkiraChatScreen(),
      ),
      GoRoute(
        path: '/feed',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/duels',
        builder: (context, state) => const DuelsScreen(),
      ),
      GoRoute(
        path: '/streaming',
        builder: (context, state) => const AnimeListScreen(),
      ),
      GoRoute(
        path: '/streaming/:animeId',
        builder: (context, state) {
          final animeId = state.pathParameters['animeId']!;
          return AnimeDetailScreen(animeId: animeId);
        },
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final loggedIn = authState.asData?.value != null;
      final path = state.uri.path;
      final isAuthRoute = path == '/login' ||
          path == '/register' ||
          path == '/onboarding' ||
          path == '/';

      if (!loggedIn && !isAuthRoute) {
        final redirectPath = Uri.encodeComponent(state.uri.toString());
        return '/login?from=$redirectPath';
      }
      if (loggedIn && isAuthRoute) {
        return '/home';
      }
      return null;
    },
  );
});
