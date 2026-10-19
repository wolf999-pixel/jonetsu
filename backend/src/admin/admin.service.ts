import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../users/user.entity';
import { Post } from '../news/post.entity';
import { Duel } from '../duels/duel.entity';

@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Post)
    private readonly postRepository: Repository<Post>,
    @InjectRepository(Duel)
    private readonly duelRepository: Repository<Duel>,
  ) {}

  async getAllUsers(limit = 50, offset = 0) {
    return await this.userRepository.find({
      order: { createdAt: 'DESC' },
      take: limit,
      skip: offset,
    });
  }

  async setUserLevel(userId: string, level: number) {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (user) {
      user.otakuLevel = level;
      // On ajuste l'XP pour qu'elle corresponde au minimum du niveau
      user.xp = (level - 1) * (level - 1) * 50;
      return await this.userRepository.save(user);
    }
  }

  async getPlatformStats() {
    const totalUsers = await this.userRepository.count();
    const totalPosts = await this.postRepository.count();
    const activeDuels = await this.duelRepository.count({ where: { isActive: true } });

    return {
      totalUsers,
      totalPosts,
      activeDuels,
    };
  }
}
