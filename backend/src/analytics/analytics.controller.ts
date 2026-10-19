import { Controller, Get, Post, Body } from '@nestjs/common';
import { AnalyticsService } from './analytics.service';
import { UsersService } from '../users/users.service';

@Controller('analytics')
export class AnalyticsController {
  constructor(
    private readonly analyticsService: AnalyticsService,
    private readonly usersService: UsersService,
  ) {}

  @Post('track')
  async track(
    @Body('type') eventType: string,
    @Body('value') eventValue?: string,
    @Body('userId') userId?: string,
    @Body('metadata') metadata?: any,
  ) {
    await this.analyticsService.trackEvent(eventType, userId, eventValue, metadata);

    // Récompense XP pour certaines actions trackées
    if (userId) {
      if (eventType === 'video_play') {
        await this.usersService.addXp(userId, 15); // 15 XP pour regarder un anime
      } else if (eventType === 'search') {
        await this.usersService.addXp(userId, 2); // 2 XP pour une recherche
      }
    }

    return { success: true };
  }

  @Get('stats')
  async getStats() {
    return await this.analyticsService.getGlobalStats();
  }
}
