import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_router.dart';
import 'core/app_theme.dart';
import 'features/auth/auth_providers.dart';

class JonetsuApp extends ConsumerWidget {
  const JonetsuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    final router = createAppRouter(
      isLoggedIn: () => authState.asData?.value != null,
    );

    return MaterialApp.router(
      title: 'JŌNETSU',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
