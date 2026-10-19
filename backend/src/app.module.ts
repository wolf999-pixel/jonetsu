import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';
import { ThrottlerModule } from '@nestjs/throttler';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { ChatModule } from './chat/chat.module';
import { MessagesModule } from './messages/messages.module';
import { GroupsModule } from './groups/groups.module';
import { StatusModule } from './status/status.module';
import { NewsModule } from './news/news.module';
import { StreamingModule } from './streaming/streaming.module';
import { DuelsModule } from './duels/duels.module';
import { AiModule } from './ai/ai.module';
import { NotificationsModule } from './notifications/notifications.module';
import { AdminModule } from './admin/admin.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { CommonModule } from './common/common.module';
import { DatabaseModule } from './common/database.module';
import { HealthModule } from './health/health.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env', '.env.local'],
    }),
    ThrottlerModule.forRoot([
      {
        name: 'short',
        ttl: 1000,
        limit: 5,
      },
      {
        name: 'long',
        ttl: 60000,
        limit: 100,
      },
    ]),
    ScheduleModule.forRoot(),
    DatabaseModule,
    CommonModule,
    AuthModule,
    UsersModule,
    ChatModule,
    MessagesModule,
    GroupsModule,
    StatusModule,
    NewsModule,
    StreamingModule,
    DuelsModule,
    AiModule,
    NotificationsModule,
    AdminModule,
    AnalyticsModule,
    HealthModule,
  ],
})
export class AppModule {}
