# JŌNETSU

JŌNETSU est une plateforme sociale OTAKU futuriste conçue pour fusionner messagerie instantanée, réseau social anime/manga, hub streaming légal, duels communautaires et intelligence artificielle immersive.

## Vision

Une application mobile ultra premium, immersive et scalable, pensée pour les fans d’anime et de manga. JŌNETSU propose des interactions communautaires robustes, un feed OTAKU, une IA conversationnelle nommée `AKIRA AI`, et une expérience visuelle cyberpunk haut de gamme.

## Stack technologique

- Frontend mobile : Flutter (Dart)
- Gestion d’état : Riverpod
- Navigation : GoRouter
- Backend : NestJS + TypeScript
- Base de données : PostgreSQL
- Temps réel : Socket.IO
- Authentification : Firebase Auth + JWT
- Stockage média : Firebase Storage ou AWS S3
- Notifications : Firebase Cloud Messaging
- IA : OpenAI API
- Conteneurisation : Docker
- CI/CD : GitHub Actions

## Architecture principale

### Frontend

- `frontend/lib/core`
- `frontend/lib/shared`
- `frontend/lib/features`
- `frontend/lib/services`
- `frontend/lib/models`
- `frontend/lib/data`
- `frontend/lib/domain`
- `frontend/lib/presentation`
- `frontend/lib/repositories`
- `frontend/lib/utils`
- `frontend/lib/config`

### Backend

- `backend/src/auth`
- `backend/src/users`
- `backend/src/chat`
- `backend/src/messages`
- `backend/src/groups`
- `backend/src/status`
- `backend/src/news`
- `backend/src/streaming`
- `backend/src/duels`
- `backend/src/ai`
- `backend/src/notifications`
- `backend/src/admin`
- `backend/src/analytics`
- `backend/src/common`

### Database

- `database/migrations`
- `database/seeders`

## Prochaines étapes

1. Compléter le schéma PostgreSQL et les migrations.
2. Implémenter le backend NestJS avec modules, services et WebSocket.
3. Construire le système d’authentification Firebase + JWT.
4. Développer le design system Flutter et les écrans d’onboarding/auth.
5. Ajouter les fonctions de messagerie temps réel, profils, feed OTAKU, statuts et duels.
6. Intégrer `AKIRA AI`, notifications push, et hub streaming.

## Notes

Ce projet est conçu pour une montée en charge massive, une expérience mobile premium, et un développement modulaire maintenable.
