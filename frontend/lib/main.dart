import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'features/auth/auth_providers.dart';
import 'services/notification_service.dart';

void main() async {
  // 1. Initialisation des bindings Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Création du container Riverpod pour accéder aux providers avant runApp
  final container = ProviderContainer();

  try {
    // 3. Initialisation RÉELLE de Firebase
    await Firebase.initializeApp();
    
    // 4. Initialisation des notifications
    await NotificationService().init();
    
    // 5. Tentative de restauration de la session utilisateur
    await container.read(authNotifierProvider.notifier).restoreSession();
    
    print('✔ Système JŌNETSU prêt : Firebase & Session synchronisés');
  } catch (e) {
    print('⚠ Mode dégradé : Firebase non configuré ou google-services.json manquant ($e)');
  }

  // 6. Lancement de l'application avec le scope Riverpod
  runApp(
    ProviderScope(
      parent: container,
      child: const JonetsuApp(),
    ),
  );
}
