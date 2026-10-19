import { Controller, Get, Post, Body, Query, Param, Put } from '@nestjs/common';
import { NewsService } from './news.service';
import { UsersService } from '../users/users.service';

@Controller('news')
export class NewsController {
  constructor(
    private readonly newsService: NewsService,
    private readonly usersService: UsersService,
  ) {}

  @Post()
  async create(
    @Body('authorId') authorId: string,
    @Body('content') content: string,
    @Body('mediaUrls') mediaUrls?: string[],
    @Body('tags') tags?: string[],
  ) {
    const post = await this.newsService.create(authorId, content, mediaUrls, tags);

    // Gagner de l'XP pour avoir publié un post (ex: 20 XP)
    try {
      await this.usersService.addXp(authorId, 20);
    } catch (e) {
      console.error('Erreur XP post:', e);
    }

    return post;
  }

  @Get()
  async findAll(
    @Query('limit') limit?: number,
    @Query('offset') offset?: number,
  ) {
    return await this.newsService.findAll(limit, offset);
  }

  @Get('author/:authorId')
  async findByAuthor(@Param('authorId') authorId: string) {
    return await this.newsService.findByAuthor(authorId);
  }

  @Put('like/:id')
  async likePost(@Param('id') id: string) {
    await this.newsService.likePost(id);
    return { success: true };
  }
}
