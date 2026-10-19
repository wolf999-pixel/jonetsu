-- Seeder: initial admin user and profile
-- Uses pgcrypto digest to compute sha256 password hash (password: "changeme")

CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO users (id, email, username, display_name, avatar_url, bio, otaku_level, badges, favorite_anime, password_hash, auth_provider, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'admin@jonetsu.local',
  'admin',
  'Admin JōNETSU',
  NULL,
  'Compte administrateur initial',
  99,
  '[]',
  'None',
  encode(digest('changeme','sha256'), 'hex'),
  'email',
  NOW(),
  NOW()
);

-- Create a basic profile for the admin
INSERT INTO profiles (id, user_id, theme, language, privacy_settings, notification_settings, created_at, updated_at)
SELECT gen_random_uuid(), id, 'dark', 'fr', '{}'::jsonb, '{}'::jsonb, NOW(), NOW() FROM users WHERE username = 'admin' LIMIT 1;
