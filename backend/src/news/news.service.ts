import { Injectable, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post } from './post.entity';
import { UsersService } from '../users/users.service';

@Injectable()
export class NewsService implements OnModuleInit {
  constructor(
    @InjectRepository(Post)
    private readonly postRepository: Repository<Post>,
    private readonly usersService: UsersService,
  ) {}

  async onModuleInit() {
    const count = await this.postRepository.count();
    if (count === 0) {
      const users = await this.usersService.getLeaderboard(1);
      if (users.length > 0) {
        await this.create(
          users[0].id,
          'Bienvenue dans la matrice JŌNETSU ! La saison anime s\'annonce légendaire. ⚡🎌',
          ['https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800'],
          ['anime', 'jonetsu', 'cyberpunk'],
        );
      }
    }
  }

  async create(authorId: string, content: string, mediaUrls: string[] = [], tags: string[] = []): Promise<Post> {
    const post = this.postRepository.create({
      authorId,
      content,
      mediaUrls,
      tags,
    });
    return await this.postRepository.save(post);
  }

  async findAll(limit = 20, offset = 0): Promise<Post[]> {
    return await this.postRepository.find({
      relations: ['author'],
      order: { createdAt: 'DESC' },
      take: limit,
      skip: offset,
    });
  }

  async findByAuthor(authorId: string): Promise<Post[]> {
    return await this.postRepository.find({
      where: { authorId },
      relations: ['author'],
      order: { createdAt: 'DESC' },
    });
  }

  async likePost(postId: string): Promise<void> {
    await this.postRepository.increment({ id: postId }, 'likesCount', 1);
  }
}
