import { DataSource, DataSourceOptions } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { User } from '../users/user.entity';
import { Chat } from '../chat/chat.entity';
import { Message } from '../messages/message.entity';
import { Post } from '../news/post.entity';
import { Duel } from '../duels/duel.entity';
import { Character } from '../duels/character.entity';
import { DuelVote } from '../duels/vote.entity';
import { Anime } from '../streaming/anime.entity';
import { AnalyticsEvent } from '../analytics/event.entity';

const config = new ConfigService();

export const typeormConfig: DataSourceOptions = {
  type: 'postgres',
  host: config.get<string>('DATABASE_HOST', 'localhost'),
  port: config.get<number>('DATABASE_PORT', 5432),
  username: config.get<string>('DATABASE_USER', 'postgres'),
  password: config.get<string>('DATABASE_PASSWORD', 'postgres'),
  database: config.get<string>('DATABASE_NAME', 'jonetsu_db'),
  entities: [User, Chat, Message, Post, Duel, Character, DuelVote, Anime, AnalyticsEvent],
  migrations: ['src/migrations/*.ts'],
  synchronize: false,
  logging: false,
};

export default new DataSource(typeormConfig);
