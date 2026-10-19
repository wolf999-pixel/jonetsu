import { Controller, Get, Post, Body, Param, UseGuards, ForbiddenException } from '@nestjs/common';
import { DuelsService } from './duels.service';
import { UsersService } from '../users/users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('duels')
export class DuelsController {
  constructor(
    private readonly duelsService: DuelsService,
    private readonly usersService: UsersService,
  ) {}

  @Get('active')
  @UseGuards(JwtAuthGuard)
  async getActive() {
    return await this.duelsService.getActiveDuels();
  }

  @Post(':id/vote')
  @UseGuards(JwtAuthGuard)
  async vote(
    @CurrentUser('userId') currentUserId: string,
    @Param('id') duelId: string,
    @Body('userId') userId: string,
    @Body('choice') choice: 'A' | 'B',
  ) {
    if (currentUserId !== userId) {
      throw new ForbiddenException('You can only vote with your own user ID');
    }

    await this.duelsService.vote(duelId, userId, choice);

    try {
      await this.usersService.addXp(userId, 10);
    } catch (e) {
      console.error('Erreur XP vote:', e);
    }

    return { success: true };
  }

  @Post('seed')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  async seed() {
    await this.duelsService.seedInitialDuels();
    return { success: true };
  }
}
