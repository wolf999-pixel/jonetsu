import { Controller, Get, Patch, Body, Param, Put, Query, UseGuards, ForbiddenException } from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('leaderboard')
  @UseGuards(JwtAuthGuard)
  async getLeaderboard(@Query('limit') limit?: number) {
    return await this.usersService.getLeaderboard(limit);
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  async getProfile(@Param('id') id: string) {
    const user = await this.usersService.findById(id);
    return {
      id: user.id,
      username: user.username,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      bannerUrl: user.bannerUrl,
      bio: user.bio,
      favoriteAnime: user.favoriteAnime,
      favoriteCharacter: user.favoriteCharacter,
      otakuLevel: user.otakuLevel,
      xp: user.xp,
      badges: user.badges,
    };
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  async update(@CurrentUser('userId') userId: string, @Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    if (userId !== id) {
      throw new ForbiddenException('You can only update your own profile');
    }
    return await this.usersService.update(id, updateUserDto);
  }

  @Put(':id/fcm-token')
  @UseGuards(JwtAuthGuard)
  async updateFcmToken(@CurrentUser('userId') userId: string, @Param('id') id: string, @Body('token') token: string) {
    if (userId !== id) {
      throw new ForbiddenException('You can only update your own FCM token');
    }
    return await this.usersService.update(id, { fcmToken: token } as any);
  }

  @Get('admin/list')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  async adminList() {
    return { ok: true };
  }
}
