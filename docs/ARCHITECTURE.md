# Architecture JŌNETSU

## Objectif

Définir l’architecture modulaire et évolutive de JŌNETSU pour garantir performance, maintenabilité et collaboration entre les équipes frontend et backend.

## Modules backend

- `auth` : gestion des tokens JWT, intégration Firebase Auth, vérification des emails, logins sociaux.
- `users` : profils, avatars, badges, statistiques OTAKU, préférences, thèmes.
- `chat` : WebSocket, messages instantanés, état online/offline, messages éphémères.
- `messages` : historique, recherches, réactions, épinglés, modération.
- `groups` : communautés, canaux, groupes publics/privés.
- `status` : stories, statuts publics, vues, réactions.
- `news` : calendrier anime, fiches de sorties, notifications nouveautés.
- `streaming` : hub légal, redirections officielles, fiches de contenus.
- `duels` : tournois, votes en temps réel, classements, leaderboards.
- `ai` : AKIRA AI, modération, recommandations, génération de conversations.
- `notifications` : FCM, push, notifications in-app, alerts IA.
- `admin` : panneau d’administration, modération, gestion utilisateurs.
- `analytics` : métriques d’usage, performance, engagement.
- `common` : configuration, constantes, sécurité, pipes et guards.

## Modules frontend

- `core` : startup app, thèmes, constantes globales, responsive design.
- `shared` : widgets réutilisables, styles, assets.
- `features` : fonctionnalité par domaine (auth, chat, feed, profile, duels, ai, notifications).
- `services` : intégrations API, sockets, Firebase, stockage média.
- `models` : entités métier, DTOs frontend.
- `data` : sources locales et distantes, repository patterns.
- `domain` : cas d’usage, logique métier, validations.
- `presentation` : écrans, widgets UI, transitions, animations.
- `repositories` : interfaces d’accès aux données.
- `utils` : helper, extensions, gestion du cache.
- `config` : routing, environment, themes.

## Base de données

- PostgreSQL relationnel optimisé.
- Tables `users`, `profiles`, `chats`, `messages`, `groups`, `statuses`, `posts`, `duels`, `notifications`, `analytics`, `media`, `ai_logs`, `sessions`.
- Indexation sur `user_id`, `chat_id`, `group_id`, `created_at`, `status`.
- Migrations et seeders pour initialiser données principales.

## Temps réel

- `Socket.IO` pour messages instantanés, notifications live, votes des duels.
- Couche socket séparée dans backend pour décorréler de l’API REST.
- Événements principaux : `message:send`, `message:read`, `user:online`, `duel:vote`, `notification:push`, `status:view`, `reaction:add`.

## Authentification

- Firebase Authentication pour signup/login social et vérification d’identités.
- Backend JWT sécurisé pour l’accès aux routes REST et WebSocket.
- Support : email/password, Google, Facebook, Apple, téléphone.
- Session management avec expiration et rafraîchissement.

## Stockage média

- Architecture abstraite pour Firebase Storage ou AWS S3.
- Media service dans backend pour uploads d’avatars, images de statuts, vidéos et documents.
- Protection des uploads avec validation de type, taille, et politique CORS.

## Notifications

- Firebase Cloud Messaging pour push mobile.
- WebSocket pour notifications in-app en temps réel.
- Notifications IA et rappels d’épisodes.

## CI/CD et DevOps

- Docker pour environnements `dev` et `prod`.
- GitHub Actions pour tests, lint, build et déploiement.
- Stratégie de release : branches `main`, `develop`, `feature/*`, `hotfix/*`.

## Notes de design

- UI : dark mode cyberpunk premium.
- Animations : transitions fluides, micro-interactions, shimmer loaders.
- Identité visuelle : noir profond, gris anthracite, rouge néon, or premium.
- Typographie : moderne, lisible, futuriste.
