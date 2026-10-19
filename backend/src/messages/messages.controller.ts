import { Controller, Get, Post, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { MessagesService } from './messages.service';
import { CreateMessageDto } from './dto/create-message.dto';
import { MessagesGateway } from './messages.gateway';
import { NotificationsService } from '../notifications/notifications.service';
import { ChatService } from '../chat/chat.service';
import { UsersService } from '../users/users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { Throttle } from '@nestjs/throttler';

@Controller('messages')
export class MessagesController {
  constructor(
    private readonly messagesService: MessagesService,
    private readonly messagesGateway: MessagesGateway,
    private readonly notificationsService: NotificationsService,
    private readonly chatService: ChatService,
    private readonly usersService: UsersService,
  ) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @Throttle({ default: { limit: 20, ttl: 60000 } })
  async create(@Request() req, @Body() createMessageDto: CreateMessageDto) {
    const userId = req.user?.userId ?? createMessageDto.senderId;
    if (!userId) {
      throw new Error('User not authenticated');
    }

    const message = await this.messagesService.create({ ...createMessageDto, senderId: userId });

    this.messagesGateway.sendMessageToChat(createMessageDto.chatId, message);

    try {
      await this.usersService.addXp(userId, 5);
    } catch (e) {
      console.error('Erreur XP message:', e);
    }

    try {
      const chat = await this.chatService.findOne(createMessageDto.chatId);
      if (chat && chat.members) {
        for (const member of chat.members) {
          if (member.id !== userId) {
            await this.notificationsService.sendNotification(
              member.id,
              chat.isGroup ? `Nouveau message dans ${chat.name}` : 'Nouveau message privé',
              message.content || 'Pièce jointe reçue',
              { chatId: chat.id, type: 'chat_message' },
            );
          }
        }
      }
    } catch (error) {
      console.error('Erreur notifications message:', error);
    }

    return message;
  }

  @Get('chat/:chatId')
  @UseGuards(JwtAuthGuard)
  async findByChat(
    @Param('chatId') chatId: string,
    @Query('limit') limit?: number,
    @Query('offset') offset?: number,
  ) {
    return await this.messagesService.findByChatId(chatId, limit, offset);
  }
}
