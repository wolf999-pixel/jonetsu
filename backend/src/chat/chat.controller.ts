import { Controller, Get, Post, Body, Param, UseGuards, ForbiddenException } from '@nestjs/common';
import { ChatService } from './chat.service';
import { Chat } from './chat.entity';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('chats')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  async create(@CurrentUser('userId') userId: string, @Body() chatData: Partial<Chat>) {
    if (!userId) {
      throw new ForbiddenException('Authentication required');
    }
    return await this.chatService.create(chatData);
  }

  @Get()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  async findAll() {
    return await this.chatService.findAll();
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  async findOne(@Param('id') id: string) {
    return await this.chatService.findOne(id);
  }

  @Get('user/:userId')
  @UseGuards(JwtAuthGuard)
  async findUserChats(@CurrentUser('userId') currentUserId: string, @Param('userId') userId: string) {
    if (currentUserId !== userId) {
      throw new ForbiddenException('You can only access your own chats');
    }
    return await this.chatService.findUserChats(userId);
  }
}
