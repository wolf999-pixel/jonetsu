import { Controller, Post, Body } from '@nestjs/common';
import { AiService } from './ai.service';
import { UsersService } from '../users/users.service';

@Controller('ai')
export class AiController {
  constructor(
    private readonly aiService: AiService,
    private readonly usersService: UsersService,
  ) {}

  @Post('chat')
  async chat(@Body('prompt') prompt: string, @Body('userId') userId?: string) {
    const response = await this.aiService.generateResponse(prompt);

    // Gagner de l'XP pour avoir discuté avec AKIRA (ex: 8 XP)
    if (userId) {
      try {
        await this.usersService.addXp(userId, 8);
      } catch (e) {
        console.error('Erreur XP AI:', e);
      }
    }

    return { response };
  }
}
