import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../features/auth/auth_providers.dart';
import 'chat/chat_list_screen.dart';
import 'news/feed_screen.dart';
import 'ai/akira_chat_screen.dart';
import 'duels/duels_screen.dart';
import 'streaming/anime_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ChatListScreen(),
    const FeedScreen(),
    const AkiraChatScreen(),
    const DuelsScreen(),
    const AnimeListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0C29),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Image.asset('assets/images/LOGO.jpg',
                height: 32,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.stars, color: AppColors.primary)),
            const SizedBox(width: 12),
            const Text('JŌNETSU',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 18)),
          ],
        ),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
              ),
              child: Text('LVL ${user?.otakuLevel ?? 1}',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white70),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: Colors.white.withOpacity(0.05), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF070A10),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.white38,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Chats'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_motion),
                activeIcon: Icon(Icons.auto_awesome_motion),
                label: 'Feed'),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.bolt, size: 18, color: Colors.white),
              ),
              label: 'AKIRA',
            ),
            const BottomNavigationBarItem(
                icon: Icon(Icons.shield_outlined),
                activeIcon: Icon(Icons.shield),
                label: 'Duels'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.play_circle_outline),
                activeIcon: Icon(Icons.play_circle),
                label: 'Stream'),
          ],
        ),
      ),
    );
  }
}
