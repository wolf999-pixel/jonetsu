import { Controller, Get, Patch, Body, Param, Query, UseGuards } from '@nestjs/common';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UpdateUserLevelDto } from '../users/dto/update-user.dto';

@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('users')
  @Roles('admin')
  async getUsers(@Query('limit') limit?: number, @Query('offset') offset?: number) {
    return await this.adminService.getAllUsers(limit, offset);
  }

  @Patch('users/:id/level')
  @Roles('admin')
  async updateLevel(@Param('id') userId: string, @Body() dto: UpdateUserLevelDto) {
    return await this.adminService.setUserLevel(userId, dto.level);
  }

  @Get('stats')
  @Roles('admin')
  async getStats() {
    return await this.adminService.getPlatformStats();
  }
}
