-- JŌNETSU PostgreSQL schema

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(50) UNIQUE NOT NULL,
  display_name VARCHAR(100),
  avatar_url TEXT,
  banner_url TEXT,
  bio TEXT,
  otaku_level INT DEFAULT 1,
  xp INT DEFAULT 0,
  badges JSONB DEFAULT '[]',
  favorite_anime VARCHAR(255),
  favorite_character VARCHAR(255),
  password_hash TEXT,
  auth_provider VARCHAR(50) DEFAULT 'email',
  fcm_token TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  theme VARCHAR(50) DEFAULT 'dark',
  language VARCHAR(10) DEFAULT 'fr',
  privacy_settings JSONB DEFAULT '{}'::JSONB,
  notification_settings JSONB DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE chats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  is_group BOOLEAN DEFAULT false,
  name VARCHAR(150),
  metadata JSONB DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE chat_members (
  chat_id UUID REFERENCES chats(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  PRIMARY KEY (chat_id, user_id)
);

CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT,
  attachments JSONB DEFAULT '[]',
  message_type VARCHAR(30) DEFAULT 'text',
  status VARCHAR(30) DEFAULT 'sent',
  is_ephemeral BOOLEAN DEFAULT false,
  replied_to UUID REFERENCES messages(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  media_urls JSONB DEFAULT '[]',
  likes_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  tags JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE characters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  anime VARCHAR(100) NOT NULL,
  image_url TEXT,
  description TEXT
);

CREATE TABLE duels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  character_a_id UUID NOT NULL REFERENCES characters(id),
  character_b_id UUID NOT NULL REFERENCES characters(id),
  votes_a INT DEFAULT 0,
  votes_b INT DEFAULT 0,
  ends_at TIMESTAMPTZ NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE duel_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  duel_id UUID NOT NULL REFERENCES duels(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  choice CHAR(1) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(duel_id, user_id)
);

CREATE TABLE animes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  image_url TEXT,
  genre VARCHAR(100),
  rating FLOAT DEFAULT 0,
  release_year INT DEFAULT 0,
  status VARCHAR(50) DEFAULT 'ongoing',
  episodes JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type VARCHAR(100) NOT NULL,
  event_value VARCHAR(255),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_posts_author_id ON posts(author_id);
CREATE INDEX idx_posts_created_at ON posts(created_at);
CREATE INDEX idx_duels_ends_at ON duels(ends_at);
CREATE INDEX idx_animes_title ON animes(title);
CREATE INDEX idx_analytics_event_type ON analytics_events(event_type);
