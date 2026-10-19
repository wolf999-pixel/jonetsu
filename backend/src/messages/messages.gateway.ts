import {
  WebSocketGateway,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { MessagesService } from './messages.service';
import { UsersService } from '../users/users.service';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class MessagesGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server!: Server;

  constructor(
    private readonly messagesService: MessagesService,
    private readonly usersService: UsersService,
  ) {}

  handleConnection(client: Socket) {
    console.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('join_room')
  handleJoinRoom(
    @MessageBody() data: { roomId: string },
    @ConnectedSocket() client: Socket,
  ) {
    client.join(data.roomId);
    console.log(`Client ${client.id} joined room ${data.roomId}`);
  }

  @SubscribeMessage('leave_room')
  handleLeaveRoom(
    @MessageBody() data: { roomId: string },
    @ConnectedSocket() client: Socket,
  ) {
    client.leave(data.roomId);
    console.log(`Client ${client.id} left room ${data.roomId}`);
  }

  @SubscribeMessage('send_message')
  async handleSendMessage(
    @MessageBody() data: { roomId: string; content: string; senderId: string },
    @ConnectedSocket() client: Socket,
  ) {
    let username = 'Otaku';
    let avatarUrl: string | undefined;

    try {
      const user = await this.usersService.findById(data.senderId);
      if (user) {
        username = user.displayName || user.username;
        avatarUrl = user.avatarUrl;
      }
    } catch (e) {
      // Ignorer si utilisateur non trouvé
    }

    let savedMessageId = Date.now().toString();
    try {
      const saved = await this.messagesService.create({
        chatId: data.roomId,
        senderId: data.senderId,
        content: data.content,
      });
      savedMessageId = saved.id;
    } catch (e) {
      console.warn('Erreur sauvegarde message DB (diffusion temps réel maintenue):', e);
    }

    this.server.to(data.roomId).emit('message_received', {
      id: savedMessageId,
      roomId: data.roomId,
      chatId: data.roomId,
      userId: data.senderId,
      senderId: data.senderId,
      username,
      userAvatarUrl: avatarUrl,
      content: data.content,
      timestamp: new Date().toISOString(),
    });
  }

  sendMessageToChat(chatId: string, message: any) {
    this.server.to(chatId).emit('message_received', message);
  }
}
