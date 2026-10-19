import { Injectable, BadRequestException, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan, LessThan } from 'typeorm';
import { Duel } from './duel.entity';
import { Character } from './character.entity';
import { DuelVote } from './vote.entity';
import { Cron, CronExpression } from '@nestjs/schedule';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class DuelsService implements OnModuleInit {
  constructor(
    @InjectRepository(Duel)
    private readonly duelRepository: Repository<Duel>,
    @InjectRepository(Character)
    private readonly characterRepository: Repository<Character>,
    @InjectRepository(DuelVote)
    private readonly voteRepository: Repository<DuelVote>,
    private readonly notificationsService: NotificationsService,
  ) {}

  async onModuleInit() {
    await this.seedInitialDuels();
  }

  async getActiveDuels(): Promise<Duel[]> {
    return await this.duelRepository.find({
      where: {
        isActive: true,
        endsAt: MoreThan(new Date())
      },
      relations: ['characterA', 'characterB'],
    });
  }

  async vote(duelId: string, userId: string, choice: 'A' | 'B'): Promise<void> {
    const duel = await this.duelRepository.findOne({ where: { id: duelId, isActive: true } });
    if (!duel || duel.endsAt < new Date()) {
      throw new BadRequestException('Duel non trouvé ou terminé');
    }

    const existingVote = await this.voteRepository.findOne({ where: { duelId, userId } });
    if (existingVote) {
      throw new BadRequestException('Vous avez déjà voté pour ce duel');
    }

    const vote = this.voteRepository.create({ duelId, userId, choice });
    await this.voteRepository.save(vote);

    if (choice === 'A') {
      await this.duelRepository.increment({ id: duelId }, 'votesA', 1);
    } else {
      await this.duelRepository.increment({ id: duelId }, 'votesB', 1);
    }
  }

  @Cron(CronExpression.EVERY_MINUTE)
  async handleEndedDuels() {
    const endedDuels = await this.duelRepository.find({
      where: {
        isActive: true,
        endsAt: LessThan(new Date()),
      },
      relations: ['characterA', 'characterB'],
    });

    for (const duel of endedDuels) {
      duel.isActive = false;
      await this.duelRepository.save(duel);

      const winner = duel.votesA > duel.votesB ? duel.characterA : (duel.votesB > duel.votesA ? duel.characterB : null);
      const message = winner
        ? `Le duel est fini ! ${winner.name} l'emporte avec ${Math.max(duel.votesA, duel.votesB)} votes !`
        : `Le duel est fini ! Égalité parfaite entre ${duel.characterA.name} et ${duel.characterB.name} !`;

      // Notifier tous les votants
      const votes = await this.voteRepository.find({ where: { duelId: duel.id } });
      const userIds = [...new Set(votes.map(v => v.userId))];

      for (const userId of userIds) {
        await this.notificationsService.sendNotification(
          userId,
          'Résultat du Duel !',
          message,
          { duelId: duel.id, type: 'duel_result' }
        );
      }
    }
  }

  async seedInitialDuels() {
    let char1 = await this.characterRepository.findOne({ where: { name: 'Son Goku' } });
    if (!char1) {
      char1 = await this.characterRepository.save({
        name: 'Son Goku',
        anime: 'Dragon Ball Z',
        imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=400',
      });
    }
    let char2 = await this.characterRepository.findOne({ where: { name: 'Vegeta' } });
    if (!char2) {
      char2 = await this.characterRepository.save({
        name: 'Vegeta',
        anime: 'Dragon Ball Z',
        imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400',
      });
    }

    const activeDuel = await this.duelRepository.findOne({ where: { isActive: true } });
    if (!activeDuel) {
      const endsAt = new Date();
      endsAt.setDate(endsAt.getDate() + 7);

      await this.duelRepository.save({
        characterAId: char1.id,
        characterBId: char2.id,
        endsAt,
        isActive: true,
        votesA: 42,
        votesB: 38,
      });
    }
  }
}
