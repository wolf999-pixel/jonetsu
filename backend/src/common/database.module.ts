import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { User } from '../users/user.entity';
import { Chat } from '../chat/chat.entity';
import { Message } from '../messages/message.entity';
import { Post } from '../news/post.entity';
import { Duel } from '../duels/duel.entity';
import { Character } from '../duels/character.entity';
import { DuelVote } from '../duels/vote.entity';
import { Anime } from '../streaming/anime.entity';
import { AnalyticsEvent } from '../analytics/event.entity';

@Module({
  imports: [
    ConfigModule,
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => {
        const isProduction = configService.get<string>('NODE_ENV') === 'production';
        const dbUrl = configService.get<string>('DATABASE_URL');

        if (dbUrl) {
          return {
            type: 'postgres',
            url: dbUrl,
            entities: [User, Chat, Message, Post, Duel, Character, DuelVote, Anime, AnalyticsEvent],
            synchronize: !isProduction,
            logging: !isProduction,
            ssl: isProduction ? { rejectUnauthorized: false } : false,
          };
        }

        return {
          type: 'postgres',
          host: configService.get<string>('DATABASE_HOST', 'localhost'),
          port: configService.get<number>('DATABASE_PORT', 5432),
          username: configService.get<string>('DATABASE_USER', 'postgres'),
          password: configService.get<string>('DATABASE_PASSWORD', 'postgres'),
          database: configService.get<string>('DATABASE_NAME', 'jonetsu_db'),
          entities: [User, Chat, Message, Post, Duel, Character, DuelVote, Anime, AnalyticsEvent],
          synchronize: !isProduction,
          logging: !isProduction,
          ssl: isProduction ? { rejectUnauthorized: false } : false,
        };
      },
      inject: [ConfigService],
    }),
  ],
  exports: [TypeOrmModule],
})
export class DatabaseModule {}
