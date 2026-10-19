import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';
import { UpdateUserDto } from './dto/update-user.dto';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly notificationsService: NotificationsService,
  ) {}

  async findById(id: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException('Utilisateur introuvable');
    }
    return user;
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { email } });
  }

  async findByUsername(username: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { username } });
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const user = await this.findById(id);
    Object.assign(user, updateUserDto);
    return await this.userRepository.save(user);
  }

  async addXp(userId: string, amount: number): Promise<User> {
    const user = await this.findById(userId);
    const oldLevel = user.otakuLevel;

    user.xp += amount;

    // Formule simplifiée : level = floor(sqrt(xp / 50)) + 1
    const newLevel = Math.floor(Math.sqrt(user.xp / 50)) + 1;

    if (newLevel > oldLevel) {
      user.otakuLevel = newLevel;

      // Essayer d'envoyer une notification (ne pas bloquer si ça échoue)
      try {
        await this.notificationsService.sendNotification(
          userId,
          'LEVEL UP ! 🆙',
          `Félicitations ! Tu es maintenant un Otaku de Niveau ${newLevel} !`,
          { type: 'level_up', level: newLevel.toString() }
        );
      } catch (e) {
        console.error('Erreur notification Level Up:', e);
      }
    }

    return await this.userRepository.save(user);
  }

  async getLeaderboard(limit = 10): Promise<User[]> {
    return await this.userRepository.find({
      order: { xp: 'DESC' },
      take: limit,
      select: ['id', 'username', 'displayName', 'avatarUrl', 'otakuLevel', 'xp'],
    });
  }
}
